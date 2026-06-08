const router = require('express').Router();
const postController = require('../controllers/postController');
const auth = require('../middleware/auth');
const upload = require('../middleware/uploadMiddleware');

// POST / — Buat postingan baru (dengan upload gambar)
router.post('/', auth, upload.single('image'), postController.createPost);

// GET /feed — Feed dari user yang diikuti
router.get('/feed', auth, postController.getFeed);

// GET /explore — Semua post (untuk halaman explore)
router.get('/explore', auth, postController.getExplore);

// GET /user/:userId — Semua post milik user tertentu
router.get('/user/:userId', auth, postController.getUserPosts);

// GET /:id — Detail satu post (harus setelah routes spesifik)
router.get('/:id', auth, postController.getPost);

// DELETE /:id — Hapus post milik sendiri
router.delete('/:id', auth, postController.deletePost);

module.exports = router;
