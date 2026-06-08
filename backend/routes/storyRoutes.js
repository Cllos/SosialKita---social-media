const router = require('express').Router();
const storyController = require('../controllers/storyController');
const auth = require('../middleware/auth');
const upload = require('../middleware/uploadMiddleware');

// POST / — Buat story baru (dengan upload gambar)
router.post('/', auth, upload.single('image'), storyController.createStory);

// GET / — Daftar story yang masih aktif
router.get('/', auth, storyController.getStories);

// GET /my — Story milik user sendiri
router.get('/my', auth, storyController.getMyStories);

// DELETE /:id — Hapus story milik sendiri
router.delete('/:id', auth, storyController.deleteStory);

module.exports = router;
