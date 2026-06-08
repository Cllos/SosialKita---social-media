const { Op, fn, col, literal } = require('sequelize');
const { Post, User, PostTag, Like, Comment, SavedPost } = require('../models');
const { success, error, paginated } = require('../utils/response');
const { getPagination, getPagingData } = require('../utils/pagination');
const { timeAgo } = require('../utils/timeAgo');

// GET /posts — Grid semua post untuk explore
exports.getExplorePosts = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const { limit: lim, offset } = getPagination(page, limit);
    const userId = req.user.id;

    const { count, rows } = await Post.findAndCountAll({
      include: [
        { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] }
      ],
      order: [['created_at', 'DESC']],
      limit: lim,
      offset,
      distinct: true
    });

    const postsWithMeta = await Promise.all(rows.map(async (post) => {
      const [likeCount, commentCount] = await Promise.all([
        Like.count({ where: { post_id: post.id } }),
        Comment.count({ where: { post_id: post.id } })
      ]);

      return {
        ...post.toJSON(),
        like_count: likeCount,
        comment_count: commentCount
      };
    }));

    const pagination = getPagingData(count, page, lim);
    return paginated(res, postsWithMeta, pagination, 'Explore posts berhasil diambil');
  } catch (err) {
    console.error('Get explore posts error:', err);
    return error(res, 'Gagal mengambil explore posts');
  }
};

// GET /trending — Hashtag trending
exports.getTrending = async (req, res) => {
  try {
    const trending = await PostTag.findAll({
      attributes: [
        'tag',
        [fn('COUNT', col('tag')), 'count']
      ],
      group: ['tag'],
      order: [[literal('count'), 'DESC']],
      limit: 20
    });

    return success(res, trending, 'Trending hashtags berhasil diambil');
  } catch (err) {
    console.error('Get trending error:', err);
    return error(res, 'Gagal mengambil trending');
  }
};

// GET /search?q=keyword — Search post by caption/tag + users
exports.searchAll = async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.trim().length === 0) {
      return error(res, 'Kata kunci pencarian diperlukan', 400);
    }

    // Search users
    const users = await User.findAll({
      where: {
        [Op.or]: [
          { username: { [Op.like]: `%${q}%` } },
          { display_name: { [Op.like]: `%${q}%` } }
        ],
        is_active: true
      },
      attributes: ['id', 'username', 'display_name', 'avatar_url', 'bio'],
      limit: 10
    });

    // Search posts by caption
    const posts = await Post.findAll({
      where: {
        caption: { [Op.like]: `%${q}%` }
      },
      include: [
        { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: PostTag, as: 'tags', attributes: ['tag'] }
      ],
      order: [['created_at', 'DESC']],
      limit: 20
    });

    // Search posts by tag
    const taggedPostIds = await PostTag.findAll({
      where: { tag: { [Op.like]: `%${q}%` } },
      attributes: ['post_id'],
      group: ['post_id']
    });

    let taggedPosts = [];
    if (taggedPostIds.length > 0) {
      const ids = taggedPostIds.map(t => t.post_id);
      taggedPosts = await Post.findAll({
        where: {
          id: { [Op.in]: ids },
          id: { [Op.notIn]: posts.map(p => p.id) } // exclude duplicates
        },
        include: [
          { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
          { model: PostTag, as: 'tags', attributes: ['tag'] }
        ],
        order: [['created_at', 'DESC']],
        limit: 10
      });
    }

    const allPosts = [...posts, ...taggedPosts].map(p => ({
      ...p.toJSON(),
      tags: p.tags ? p.tags.map(t => t.tag) : [],
      time_ago: timeAgo(p.created_at)
    }));

    return success(res, { users, posts: allPosts }, 'Hasil pencarian');
  } catch (err) {
    console.error('Search error:', err);
    return error(res, 'Gagal melakukan pencarian');
  }
};
