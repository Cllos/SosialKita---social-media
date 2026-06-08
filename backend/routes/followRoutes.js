const router = require('express').Router();
const followController = require('../controllers/followController');
const auth = require('../middleware/auth');

// POST /:userId — Toggle follow/unfollow user
router.post('/:userId', auth, followController.toggleFollow);

// GET /:userId/followers — Daftar follower
router.get('/:userId/followers', auth, followController.getFollowers);

// GET /:userId/following — Daftar following
router.get('/:userId/following', auth, followController.getFollowing);

module.exports = router;
