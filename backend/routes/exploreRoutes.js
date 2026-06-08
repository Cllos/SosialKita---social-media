const router = require('express').Router();
const exploreController = require('../controllers/exploreController');
const auth = require('../middleware/auth');

// GET /posts — Grid semua post untuk explore
router.get('/posts', auth, exploreController.getExplorePosts);

// GET /trending — Hashtag trending
router.get('/trending', auth, exploreController.getTrending);

// GET /search?q=keyword — Search post by caption/tag + users
router.get('/search', auth, exploreController.searchAll);

module.exports = router;
