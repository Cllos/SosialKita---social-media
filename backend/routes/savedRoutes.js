const router = require('express').Router();
const savedController = require('../controllers/savedController');
const auth = require('../middleware/auth');

// POST /posts/:postId — Toggle simpan/hapus simpan
router.post('/posts/:postId', auth, savedController.toggleSave);

// GET / — Daftar postingan yang disimpan
router.get('/', auth, savedController.getSaved);

module.exports = router;
