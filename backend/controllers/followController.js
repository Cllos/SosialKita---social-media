const { Follow, User } = require('../models');
const { success, error } = require('../utils/response');
const { sendPushNotification } = require('../utils/fcmSender');

// POST /:userId — Toggle follow/unfollow user
exports.toggleFollow = async (req, res) => {
  try {
    const { userId } = req.params;
    const followerId = req.user.id;

    // Tidak bisa follow diri sendiri
    if (parseInt(userId) === followerId) {
      return error(res, 'Tidak bisa mengikuti diri sendiri', 400);
    }

    // Cek user yang akan difollow ada
    const targetUser = await User.findByPk(userId);
    if (!targetUser) {
      return error(res, 'User tidak ditemukan', 404);
    }

    // Cek apakah sudah follow
    const existingFollow = await Follow.findOne({
      where: { follower_id: followerId, following_id: userId }
    });

    let isFollowing;
    if (existingFollow) {
      // Unfollow
      await existingFollow.destroy();
      isFollowing = false;
    } else {
      // Follow
      await Follow.create({ follower_id: followerId, following_id: userId });
      isFollowing = true;

      // Kirim push notifikasi ke user tujuan secara background
      sendPushNotification(
        parseInt(userId),
        'Pengikut Baru',
        `@${req.user.username} mulai mengikuti Anda.`,
        {
          id: `follow_${followerId}_${userId}`,
          type: 'follow',
          fromUserId: String(followerId),
          createdAt: new Date().toISOString(),
        }
      ).catch(err => console.error('Error sending follow push notification:', err));
    }

    const followerCount = await Follow.count({ where: { following_id: userId } });

    return success(res, {
      is_following: isFollowing,
      follower_count: followerCount
    }, isFollowing ? 'Berhasil mengikuti' : 'Berhenti mengikuti');
  } catch (err) {
    console.error('Toggle follow error:', err);
    return error(res, 'Gagal toggle follow');
  }
};

// GET /:userId/followers — Daftar follower
exports.getFollowers = async (req, res) => {
  try {
    const { userId } = req.params;

    const followers = await Follow.findAll({
      where: { following_id: userId },
      include: [{
        model: User,
        as: 'follower',
        attributes: ['id', 'username', 'display_name', 'avatar_url']
      }],
      order: [['created_at', 'DESC']]
    });

    const data = followers.map(f => f.follower);
    return success(res, data, 'Daftar follower berhasil diambil');
  } catch (err) {
    console.error('Get followers error:', err);
    return error(res, 'Gagal mengambil daftar follower');
  }
};

// GET /:userId/following — Daftar following
exports.getFollowing = async (req, res) => {
  try {
    const { userId } = req.params;

    const following = await Follow.findAll({
      where: { follower_id: userId },
      include: [{
        model: User,
        as: 'followingUser',
        attributes: ['id', 'username', 'display_name', 'avatar_url']
      }],
      order: [['created_at', 'DESC']]
    });

    const data = following.map(f => f.followingUser);
    return success(res, data, 'Daftar following berhasil diambil');
  } catch (err) {
    console.error('Get following error:', err);
    return error(res, 'Gagal mengambil daftar following');
  }
};
