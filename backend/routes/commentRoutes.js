const router = require('express').Router();
const commentController = require('../controllers/commentController');
const auth = require('../middleware/auth');

// GET /posts/:postId — Daftar komentar sebuah post
router.get('/posts/:postId', auth, commentController.getComments);

// POST /posts/:postId — Tambah komentar
router.post('/posts/:postId', auth, commentController.addComment);

// DELETE /:commentId — Hapus komentar sendiri
router.delete('/:commentId', auth, commentController.deleteComment);

module.exports = router;
