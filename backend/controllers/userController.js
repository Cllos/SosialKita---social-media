const { Op } = require('sequelize');
const { User, Post, Follow } = require('../models');
const { success, error } = require('../utils/response');

// GET /:username — Profil user by username
exports.getProfile = async (req, res) => {
  try {
    const { username } = req.params;
    const currentUserId = req.user.id;

    const user = await User.findOne({
      where: { username },
      attributes: { exclude: ['password'] }
    });

    if (!user) {
      return error(res, 'User tidak ditemukan', 404);
    }

    // Hitung post, follower, following
    const [postCount, followerCount, followingCount, isFollowing] = await Promise.all([
      Post.count({ where: { user_id: user.id } }),
      Follow.count({ where: { following_id: user.id } }),
      Follow.count({ where: { follower_id: user.id } }),
      Follow.findOne({ where: { follower_id: currentUserId, following_id: user.id } })
    ]);

    const profileData = {
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      bio: user.bio,
      avatar_url: user.avatar_url,
      role: user.role,
      post_count: postCount,
      follower_count: followerCount,
      following_count: followingCount,
      is_following: !!isFollowing,
      created_at: user.created_at
    };

    return success(res, profileData, 'Profil berhasil diambil');
  } catch (err) {
    console.error('Get profile error:', err);
    return error(res, 'Gagal mengambil profil');
  }
};

// PUT /profile — Update profil sendiri
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { display_name, bio } = req.body;

    const user = await User.findByPk(userId);
    if (!user) {
      return error(res, 'User tidak ditemukan', 404);
    }

    // Update fields
    if (display_name) user.display_name = display_name;
    if (bio !== undefined) user.bio = bio;

    // Jika ada upload avatar
    if (req.file) {
      const avatarUrl = `uploads/${req.file.filename}`;
      user.avatar_url = avatarUrl;
    }

    await user.save();

    const userData = {
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      email: user.email,
      bio: user.bio,
      avatar_url: user.avatar_url,
      role: user.role
    };

    return success(res, userData, 'Profil berhasil diupdate');
  } catch (err) {
    console.error('Update profile error:', err);
    return error(res, 'Gagal update profil');
  }
};

// GET /search?q=keyword — Cari user by username/nama
exports.searchUser = async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.trim().length === 0) {
      return error(res, 'Kata kunci pencarian diperlukan', 400);
    }

    const users = await User.findAll({
      where: {
        [Op.or]: [
          { username: { [Op.like]: `%${q}%` } },
          { display_name: { [Op.like]: `%${q}%` } }
        ],
        is_active: true
      },
      attributes: ['id', 'username', 'display_name', 'avatar_url', 'bio'],
      limit: 20
    });

    return success(res, users, 'Hasil pencarian user');
  } catch (err) {
    console.error('Search user error:', err);
    return error(res, 'Gagal mencari user');
  }
};

// GET /:id/followers — Daftar follower user
exports.getFollowers = async (req, res) => {
  try {
    const { id } = req.params;

    const followers = await Follow.findAll({
      where: { following_id: id },
      include: [{
        model: User,
        as: 'follower',
        attributes: ['id', 'username', 'display_name', 'avatar_url']
      }]
    });

    const data = followers.map(f => f.follower);
    return success(res, data, 'Daftar follower berhasil diambil');
  } catch (err) {
    console.error('Get followers error:', err);
    return error(res, 'Gagal mengambil daftar follower');
  }
};

// GET /:id/following — Daftar following user
exports.getFollowing = async (req, res) => {
  try {
    const { id } = req.params;

    const following = await Follow.findAll({
      where: { follower_id: id },
      include: [{
        model: User,
        as: 'followingUser',
        attributes: ['id', 'username', 'display_name', 'avatar_url']
      }]
    });

    const data = following.map(f => f.followingUser);
    return success(res, data, 'Daftar following berhasil diambil');
  } catch (err) {
    console.error('Get following error:', err);
    return error(res, 'Gagal mengambil daftar following');
  }
};

// GET /id/:id — Profil user by ID
exports.getProfileById = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findByPk(id, {
      attributes: { exclude: ['password'] }
    });

    if (!user) {
      return error(res, 'User tidak ditemukan', 404);
    }

    return success(res, user, 'User berhasil diambil');
  } catch (err) {
    console.error('Get profile by ID error:', err);
    return error(res, 'Gagal mengambil profil');
  }
};
