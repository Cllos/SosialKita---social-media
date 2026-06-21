const { Like, Post } = require('../models');
const { success, error } = require('../utils/response');
const { sendPushNotification } = require('../utils/fcmSender');

// POST /posts/:postId — Toggle like/unlike
exports.toggleLike = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.id;

    // Cek post ada
    const post = await Post.findByPk(postId);
    if (!post) {
      return error(res, 'Post tidak ditemukan', 404);
    }

    // Cek apakah sudah like
    const existingLike = await Like.findOne({
      where: { user_id: userId, post_id: postId }
    });

    let isLiked;
    if (existingLike) {
      // Unlike
      await existingLike.destroy();
      isLiked = false;
    } else {
      // Like
      await Like.create({ user_id: userId, post_id: postId });
      isLiked = true;

      // Kirim push notifikasi ke pembuat postingan (jika bukan diri sendiri)
      if (post.user_id !== userId) {
        sendPushNotification(
          post.user_id,
          'Suka Baru',
          `@${req.user.username} menyukai postingan Anda.`,
          {
            id: `like_${userId}_${postId}`,
            type: 'like',
            fromUserId: String(userId),
            postId: String(postId),
            createdAt: new Date().toISOString(),
          }
        ).catch(err => console.error('Error sending like push notification:', err));
      }
    }

    const likeCount = await Like.count({ where: { post_id: postId } });

    return success(res, {
      is_liked: isLiked,
      like_count: likeCount
    }, isLiked ? 'Post disukai' : 'Like dibatalkan');
  } catch (err) {
    console.error('Toggle like error:', err);
    return error(res, 'Gagal toggle like');
  }
};
