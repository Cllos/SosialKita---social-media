const { Op } = require('sequelize');
const { Story, User } = require('../models');
const { success, error } = require('../utils/response');
const { timeAgo } = require('../utils/timeAgo');

// POST / — Buat story baru
exports.createStory = async (req, res) => {
  try {
    if (!req.file) {
      return error(res, 'Gambar wajib diupload', 400);
    }

    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

    // Story expires setelah 24 jam
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    const story = await Story.create({
      user_id: req.user.id,
      image_url: imageUrl,
      expires_at: expiresAt
    });

    return success(res, story, 'Story berhasil dibuat', 201);
  } catch (err) {
    console.error('Create story error:', err);
    return error(res, 'Gagal membuat story');
  }
};

// GET / — Daftar story yang masih aktif (belum expired)
exports.getStories = async (req, res) => {
  try {
    const userId = req.user.id;

    // Ambil story yang masih aktif dari user yang diikuti + diri sendiri
    const { Follow } = require('../models');
    const following = await Follow.findAll({
      where: { follower_id: userId },
      attributes: ['following_id']
    });
    const followingIds = following.map(f => f.following_id);
    followingIds.push(userId);

    const stories = await Story.findAll({
      where: {
        user_id: { [Op.in]: followingIds },
        expires_at: { [Op.gt]: new Date() }
      },
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'username', 'display_name', 'avatar_url']
      }],
      order: [['created_at', 'DESC']]
    });

    // Group by user
    const storyMap = new Map();
    for (const story of stories) {
      const uid = story.user_id;
      if (!storyMap.has(uid)) {
        storyMap.set(uid, {
          user: story.user,
          stories: []
        });
      }
      storyMap.get(uid).stories.push({
        id: story.id,
        image_url: story.image_url,
        expires_at: story.expires_at,
        created_at: story.created_at,
        time_ago: timeAgo(story.created_at)
      });
    }

    const data = Array.from(storyMap.values());
    return success(res, data, 'Stories berhasil diambil');
  } catch (err) {
    console.error('Get stories error:', err);
    return error(res, 'Gagal mengambil stories');
  }
};

// GET /my — Story milik user sendiri
exports.getMyStories = async (req, res) => {
  try {
    const userId = req.user.id;

    const stories = await Story.findAll({
      where: {
        user_id: userId,
        expires_at: { [Op.gt]: new Date() }
      },
      order: [['created_at', 'DESC']]
    });

    return success(res, stories, 'My stories berhasil diambil');
  } catch (err) {
    console.error('Get my stories error:', err);
    return error(res, 'Gagal mengambil my stories');
  }
};

// DELETE /:id — Hapus story milik sendiri
exports.deleteStory = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const story = await Story.findByPk(id);
    if (!story) {
      return error(res, 'Story tidak ditemukan', 404);
    }

    if (story.user_id !== userId && req.user.role !== 'moderator') {
      return error(res, 'Anda tidak berhak menghapus story ini', 403);
    }

    await story.destroy();
    return success(res, null, 'Story berhasil dihapus');
  } catch (err) {
    console.error('Delete story error:', err);
    return error(res, 'Gagal menghapus story');
  }
};
