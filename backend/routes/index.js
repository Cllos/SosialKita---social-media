const router = require('express').Router();

// Mount semua routes
router.use('/auth', require('./authRoutes'));
router.use('/users', require('./userRoutes'));
router.use('/posts', require('./postRoutes'));
router.use('/comments', require('./commentRoutes'));
router.use('/likes', require('./likeRoutes'));
router.use('/follows', require('./followRoutes'));
router.use('/saved', require('./savedRoutes'));
router.use('/explore', require('./exploreRoutes'));
router.use('/messages', require('./messageRoutes'));
router.use('/stories', require('./storyRoutes'));
router.use('/moderator', require('./moderatorRoutes'));

module.exports = router;
