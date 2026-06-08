const router = require('express').Router();
const userController = require('../controllers/userController');
const auth = require('../middleware/auth');
const upload = require('../middleware/uploadMiddleware');

// GET /search?q=keyword — Cari user (harus sebelum /:username)
router.get('/search', auth, userController.searchUser);

// GET /:username — Profil user by username
router.get('/:username', auth, userController.getProfile);

// PUT /profile — Update profil sendiri
router.put('/profile', auth, upload.single('avatar'), userController.updateProfile);

// GET /:id/followers — Daftar follower user
router.get('/:id/followers', auth, userController.getFollowers);

// GET /:id/following — Daftar following user
router.get('/:id/following', auth, userController.getFollowing);

module.exports = router;
