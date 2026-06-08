const { Op } = require('sequelize');
const { Post, User, Like, Comment, SavedPost, PostTag } = require('../models');
const { success, error, paginated } = require('../utils/response');
const { getPagination, getPagingData } = require('../utils/pagination');
const { timeAgo } = require('../utils/timeAgo');

// POST / — Buat postingan baru
exports.createPost = async (req, res) => {
  try {
    const { caption, location } = req.body;

    if (!req.file) {
      return error(res, 'Gambar wajib diupload', 400);
    }

    // URL gambar — lokal storage
    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

    const post = await Post.create({
      user_id: req.user.id,
      image_url: imageUrl,
      caption,
      location
    });

    // Parse hashtag dari caption
    if (caption) {
      const tags = caption.match(/#\w+/g) || [];
      for (const tag of tags) {
        await PostTag.create({ post_id: post.id, tag: tag.replace('#', '') });
      }
    }

    // Ambil post dengan relasi
    const fullPost = await Post.findByPk(post.id, {
      include: [
        { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: PostTag, as: 'tags', attributes: ['tag'] }
      ]
    });

    return success(res, fullPost, 'Post berhasil dibuat', 201);
  } catch (err) {
    console.error('Create post error:', err);
    return error(res, 'Gagal membuat post');
  }
};

// GET /feed — Feed dari user yang diikuti
exports.getFeed = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const { limit: lim, offset } = getPagination(page, limit);
    const userId = req.user.id;

    // Ambil ID user yang diikuti
    const { Follow } = require('../models');
    const following = await Follow.findAll({
      where: { follower_id: userId },
      attributes: ['following_id']
    });
    const followingIds = following.map(f => f.following_id);
    followingIds.push(userId); // include post sendiri

    const { count, rows } = await Post.findAndCountAll({
      where: { user_id: { [Op.in]: followingIds } },
      include: [
        { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: PostTag, as: 'tags', attributes: ['tag'] }
      ],
      order: [['created_at', 'DESC']],
      limit: lim,
      offset,
      distinct: true
    });

    // Tambahkan is_liked, is_saved, like_count, comment_count
    const postsWithMeta = await Promise.all(rows.map(async (post) => {
      const [likeCount, commentCount, isLiked, isSaved] = await Promise.all([
        Like.count({ where: { post_id: post.id } }),
        Comment.count({ where: { post_id: post.id } }),
        Like.findOne({ where: { user_id: userId, post_id: post.id } }),
        SavedPost.findOne({ where: { user_id: userId, post_id: post.id } })
      ]);

      return {
        ...post.toJSON(),
        tags: post.tags.map(t => t.tag),
        like_count: likeCount,
        comment_count: commentCount,
        is_liked: !!isLiked,
        is_saved: !!isSaved,
        time_ago: timeAgo(post.created_at)
      };
    }));

    const pagination = getPagingData(count, page, lim);
    return paginated(res, postsWithMeta, pagination, 'Feed berhasil diambil');
  } catch (err) {
    console.error('Get feed error:', err);
    return error(res, 'Gagal mengambil feed');
  }
};

// GET /explore — Semua post (untuk halaman explore)
exports.getExplore = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const { limit: lim, offset } = getPagination(page, limit);
    const userId = req.user.id;

    const { count, rows } = await Post.findAndCountAll({
      include: [
        { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: PostTag, as: 'tags', attributes: ['tag'] }
      ],
      order: [['created_at', 'DESC']],
      limit: lim,
      offset,
      distinct: true
    });

    const postsWithMeta = await Promise.all(rows.map(async (post) => {
      const [likeCount, commentCount, isLiked, isSaved] = await Promise.all([
        Like.count({ where: { post_id: post.id } }),
        Comment.count({ where: { post_id: post.id } }),
        Like.findOne({ where: { user_id: userId, post_id: post.id } }),
        SavedPost.findOne({ where: { user_id: userId, post_id: post.id } })
      ]);

      return {
        ...post.toJSON(),
        tags: post.tags.map(t => t.tag),
        like_count: likeCount,
        comment_count: commentCount,
        is_liked: !!isLiked,
        is_saved: !!isSaved,
        time_ago: timeAgo(post.created_at)
      };
    }));

    const pagination = getPagingData(count, page, lim);
    return paginated(res, postsWithMeta, pagination, 'Explore berhasil diambil');
  } catch (err) {
    console.error('Get explore error:', err);
    return error(res, 'Gagal mengambil explore');
  }
};

// GET /:id — Detail satu post
exports.getPost = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const post = await Post.findByPk(id, {
      include: [
        { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: PostTag, as: 'tags', attributes: ['tag'] }
      ]
    });

    if (!post) {
      return error(res, 'Post tidak ditemukan', 404);
    }

    const [likeCount, commentCount, isLiked, isSaved] = await Promise.all([
      Like.count({ where: { post_id: post.id } }),
      Comment.count({ where: { post_id: post.id } }),
      Like.findOne({ where: { user_id: userId, post_id: post.id } }),
      SavedPost.findOne({ where: { user_id: userId, post_id: post.id } })
    ]);

    const postData = {
      ...post.toJSON(),
      tags: post.tags.map(t => t.tag),
      like_count: likeCount,
      comment_count: commentCount,
      is_liked: !!isLiked,
      is_saved: !!isSaved,
      time_ago: timeAgo(post.created_at)
    };

    return success(res, postData, 'Detail post berhasil diambil');
  } catch (err) {
    console.error('Get post error:', err);
    return error(res, 'Gagal mengambil detail post');
  }
};

// DELETE /:id — Hapus post milik sendiri
exports.deletePost = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const post = await Post.findByPk(id);
    if (!post) {
      return error(res, 'Post tidak ditemukan', 404);
    }

    // Cek apakah pemilik post atau moderator
    if (post.user_id !== userId && req.user.role !== 'moderator') {
      return error(res, 'Anda tidak berhak menghapus post ini', 403);
    }

    await post.destroy();
    return success(res, null, 'Post berhasil dihapus');
  } catch (err) {
    console.error('Delete post error:', err);
    return error(res, 'Gagal menghapus post');
  }
};

// GET /user/:userId — Semua post milik user tertentu
exports.getUserPosts = async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUserId = req.user.id;
    const { page = 1, limit = 12 } = req.query;
    const { limit: lim, offset } = getPagination(page, limit);

    const { count, rows } = await Post.findAndCountAll({
      where: { user_id: userId },
      include: [
        { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: PostTag, as: 'tags', attributes: ['tag'] }
      ],
      order: [['created_at', 'DESC']],
      limit: lim,
      offset,
      distinct: true
    });

    const postsWithMeta = await Promise.all(rows.map(async (post) => {
      const [likeCount, commentCount, isLiked, isSaved] = await Promise.all([
        Like.count({ where: { post_id: post.id } }),
        Comment.count({ where: { post_id: post.id } }),
        Like.findOne({ where: { user_id: currentUserId, post_id: post.id } }),
        SavedPost.findOne({ where: { user_id: currentUserId, post_id: post.id } })
      ]);

      return {
        ...post.toJSON(),
        tags: post.tags.map(t => t.tag),
        like_count: likeCount,
        comment_count: commentCount,
        is_liked: !!isLiked,
        is_saved: !!isSaved,
        time_ago: timeAgo(post.created_at)
      };
    }));

    const pagination = getPagingData(count, page, lim);
    return paginated(res, postsWithMeta, pagination, 'Post user berhasil diambil');
  } catch (err) {
    console.error('Get user posts error:', err);
    return error(res, 'Gagal mengambil post user');
  }
};
