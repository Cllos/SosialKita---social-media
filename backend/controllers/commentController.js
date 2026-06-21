const { Comment, User, Post } = require('../models');
const { success, error } = require('../utils/response');
const { timeAgo } = require('../utils/timeAgo');
const { sendPushNotification } = require('../utils/fcmSender');

// GET /posts/:postId — Daftar komentar sebuah post
exports.getComments = async (req, res) => {
  try {
    const { postId } = req.params;

    const comments = await Comment.findAll({
      where: { post_id: postId },
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'username', 'display_name', 'avatar_url']
      }],
      order: [['created_at', 'ASC']]
    });

    const data = comments.map(c => ({
      ...c.toJSON(),
      time_ago: timeAgo(c.created_at)
    }));

    return success(res, data, 'Komentar berhasil diambil');
  } catch (err) {
    console.error('Get comments error:', err);
    return error(res, 'Gagal mengambil komentar');
  }
};

// POST /posts/:postId — Tambah komentar
exports.addComment = async (req, res) => {
  try {
    const { postId } = req.params;
    const { text } = req.body;

    if (!text || text.trim().length === 0) {
      return error(res, 'Teks komentar tidak boleh kosong', 400);
    }

    const post = await Post.findByPk(postId);
    if (!post) {
      return error(res, 'Post tidak ditemukan', 404);
    }

    const comment = await Comment.create({
      user_id: req.user.id,
      post_id: postId,
      text
    });

    const fullComment = await Comment.findByPk(comment.id, {
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'username', 'display_name', 'avatar_url']
      }]
    });

    // Kirim push notifikasi ke pembuat postingan (jika bukan diri sendiri)
    if (post.user_id !== req.user.id) {
      sendPushNotification(
        post.user_id,
        'Komentar Baru',
        `@${req.user.username} mengomentari postingan Anda: "${text}"`,
        {
          id: String(comment.id),
          type: 'comment',
          fromUserId: String(req.user.id),
          postId: String(postId),
          commentText: text,
          createdAt: comment.created_at.toISOString(),
        }
      ).catch(err => console.error('Error sending comment push notification:', err));
    }

    return success(res, {
      ...fullComment.toJSON(),
      time_ago: timeAgo(fullComment.created_at)
    }, 'Komentar berhasil ditambahkan', 201);
  } catch (err) {
    console.error('Add comment error:', err);
    return error(res, 'Gagal menambahkan komentar');
  }
};

// DELETE /:commentId — Hapus komentar sendiri
exports.deleteComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    const userId = req.user.id;

    const comment = await Comment.findByPk(commentId);
    if (!comment) {
      return error(res, 'Komentar tidak ditemukan', 404);
    }

    // Cek apakah pemilik komentar atau moderator
    if (comment.user_id !== userId && req.user.role !== 'moderator') {
      return error(res, 'Anda tidak berhak menghapus komentar ini', 403);
    }

    await comment.destroy();
    return success(res, null, 'Komentar berhasil dihapus');
  } catch (err) {
    console.error('Delete comment error:', err);
    return error(res, 'Gagal menghapus komentar');
  }
};
