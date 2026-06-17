const { Op } = require('sequelize');
const { User, Post, Comment } = require('../models');
const { success, error } = require('../utils/response');

// GET /posts — Semua post (untuk moderasi)
exports.getAllPosts = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    const { count, rows } = await Post.findAndCountAll({
      include: [{
        model: User,
        as: 'author',
        attributes: ['id', 'username', 'display_name', 'avatar_url']
      }],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset,
      distinct: true
    });

    return success(res, {
      posts: rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        totalPages: Math.ceil(count / limit)
      }
    }, 'Semua post berhasil diambil');
  } catch (err) {
    console.error('Moderator get posts error:', err);
    return error(res, 'Gagal mengambil post');
  }
};

// DELETE /posts/:id — Hapus post manapun
exports.deletePost = async (req, res) => {
  try {
    const { id } = req.params;

    const post = await Post.findByPk(id);
    if (!post) {
      return error(res, 'Post tidak ditemukan', 404);
    }

    await post.destroy();
    return success(res, null, 'Post berhasil dihapus oleh moderator');
  } catch (err) {
    console.error('Moderator delete post error:', err);
    return error(res, 'Gagal menghapus post');
  }
};

// DELETE /comments/:id — Hapus komentar manapun
exports.deleteComment = async (req, res) => {
  try {
    const { id } = req.params;

    const comment = await Comment.findByPk(id);
    if (!comment) {
      return error(res, 'Komentar tidak ditemukan', 404);
    }

    await comment.destroy();
    return success(res, null, 'Komentar berhasil dihapus oleh moderator');
  } catch (err) {
    console.error('Moderator delete comment error:', err);
    return error(res, 'Gagal menghapus komentar');
  }
};

// GET /users — Semua user
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']]
    });

    return success(res, users, 'Semua user berhasil diambil');
  } catch (err) {
    console.error('Moderator get users error:', err);
    return error(res, 'Gagal mengambil user');
  }
};

// PUT /users/:id/deactivate — Nonaktifkan akun user
exports.deactivateUser = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findByPk(id);
    if (!user) {
      return error(res, 'User tidak ditemukan', 404);
    }

    if (user.role === 'moderator') {
      return error(res, 'Tidak bisa menonaktifkan sesama moderator', 403);
    }

    user.is_active = !user.is_active; // toggle
    await user.save();

    return success(res, {
      id: user.id,
      username: user.username,
      is_active: user.is_active
    }, user.is_active ? 'User diaktifkan kembali' : 'User dinonaktifkan');
  } catch (err) {
    console.error('Moderator deactivate user error:', err);
    return error(res, 'Gagal menonaktifkan user');
  }
};

// GET /stats — Statistik: total user, post, komentar
exports.getStats = async (req, res) => {
  try {
    const [totalUsers, totalPosts, totalComments, activeUsers] = await Promise.all([
      User.count(),
      Post.count(),
      Comment.count(),
      User.count({ where: { is_active: true } })
    ]);

    return success(res, {
      total_users: totalUsers,
      active_users: activeUsers,
      total_posts: totalPosts,
      total_comments: totalComments
    }, 'Statistik berhasil diambil');
  } catch (err) {
    console.error('Moderator stats error:', err);
    return error(res, 'Gagal mengambil statistik');
  }
};

// GET /comments — Semua komentar (untuk moderasi)
exports.getAllComments = async (req, res) => {
  try {
    const comments = await Comment.findAll({
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'display_name', 'avatar_url']
        },
        {
          model: Post,
          attributes: ['id', 'caption', 'image_url']
        }
      ],
      order: [['created_at', 'DESC']]
    });

    return success(res, comments, 'Semua komentar berhasil diambil');
  } catch (err) {
    console.error('Moderator get comments error:', err);
    return error(res, 'Gagal mengambil komentar');
  }
};

// DELETE /users/:id — Hapus user (bukan moderator)
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findByPk(id);
    if (!user) {
      return error(res, 'User tidak ditemukan', 404);
    }

    if (user.role === 'moderator') {
      return error(res, 'Tidak bisa menghapus sesama moderator', 403);
    }

    await user.destroy();
    return success(res, null, 'User berhasil dihapus oleh moderator');
  } catch (err) {
    console.error('Moderator delete user error:', err);
    return error(res, 'Gagal menghapus user');
  }
};
