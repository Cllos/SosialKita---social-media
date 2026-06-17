const router = require('express').Router();
const moderatorController = require('../controllers/moderatorController');
const auth = require('../middleware/auth');
const isModerator = require('../middleware/isModerator');

// Semua route moderator memerlukan auth + isModerator
router.use(auth, isModerator);

// GET /posts — Semua post (untuk moderasi)
router.get('/posts', moderatorController.getAllPosts);

// DELETE /posts/:id — Hapus post manapun
router.delete('/posts/:id', moderatorController.deletePost);

// DELETE /comments/:id — Hapus komentar manapun
router.delete('/comments/:id', moderatorController.deleteComment);

// GET /users — Semua user
router.get('/users', moderatorController.getAllUsers);

// PUT /users/:id/deactivate — Nonaktifkan akun user
router.put('/users/:id/deactivate', moderatorController.deactivateUser);

// GET /stats — Statistik
router.get('/stats', moderatorController.getStats);

// GET /comments — Semua komentar (untuk moderasi)
router.get('/comments', moderatorController.getAllComments);

// DELETE /users/:id — Hapus user (bukan moderator)
router.delete('/users/:id', moderatorController.deleteUser);

module.exports = router;
