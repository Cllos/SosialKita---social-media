const { SavedPost, Post, User, Like, Comment, PostTag } = require('../models');
const { success, error } = require('../utils/response');
const { timeAgo } = require('../utils/timeAgo');

// POST /posts/:postId — Toggle simpan/hapus simpan
exports.toggleSave = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.id;

    // Cek post ada
    const post = await Post.findByPk(postId);
    if (!post) {
      return error(res, 'Post tidak ditemukan', 404);
    }

    // Cek apakah sudah disimpan
    const existingSave = await SavedPost.findOne({
      where: { user_id: userId, post_id: postId }
    });

    let isSaved;
    if (existingSave) {
      // Hapus simpan
      await existingSave.destroy();
      isSaved = false;
    } else {
      // Simpan
      await SavedPost.create({ user_id: userId, post_id: postId });
      isSaved = true;
    }

    return success(res, {
      is_saved: isSaved
    }, isSaved ? 'Post disimpan' : 'Simpanan dihapus');
  } catch (err) {
    console.error('Toggle save error:', err);
    return error(res, 'Gagal toggle simpan');
  }
};

// GET / — Daftar postingan yang disimpan
exports.getSaved = async (req, res) => {
  try {
    const userId = req.user.id;

    const savedPosts = await SavedPost.findAll({
      where: { user_id: userId },
      include: [{
        model: Post,
        as: 'post',
        include: [
          { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
          { model: PostTag, as: 'tags', attributes: ['tag'] }
        ]
      }],
      order: [['created_at', 'DESC']]
    });

    const postsWithMeta = await Promise.all(savedPosts.map(async (sp) => {
      const post = sp.post;
      const [likeCount, commentCount, isLiked] = await Promise.all([
        Like.count({ where: { post_id: post.id } }),
        Comment.count({ where: { post_id: post.id } }),
        Like.findOne({ where: { user_id: userId, post_id: post.id } })
      ]);

      return {
        ...post.toJSON(),
        tags: post.tags.map(t => t.tag),
        like_count: likeCount,
        comment_count: commentCount,
        is_liked: !!isLiked,
        is_saved: true,
        time_ago: timeAgo(post.created_at)
      };
    }));

    return success(res, postsWithMeta, 'Saved posts berhasil diambil');
  } catch (err) {
    console.error('Get saved error:', err);
    return error(res, 'Gagal mengambil saved posts');
  }
};
