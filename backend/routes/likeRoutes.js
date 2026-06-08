const router = require('express').Router();
const likeController = require('../controllers/likeController');
const auth = require('../middleware/auth');

// POST /posts/:postId — Toggle like/unlike
router.post('/posts/:postId', auth, likeController.toggleLike);

module.exports = router;
