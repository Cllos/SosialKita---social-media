const router = require('express').Router();
const messageController = require('../controllers/messageController');
const auth = require('../middleware/auth');

// GET /unread/count — Total pesan belum dibaca (sebelum /:userId)
router.get('/unread/count', auth, messageController.getUnreadCount);

// GET /conversations — Daftar semua percakapan
router.get('/conversations', auth, messageController.getConversations);

// GET /:userId — Pesan dengan user tertentu
router.get('/:userId', auth, messageController.getMessages);

// POST /:userId — Kirim pesan ke user tertentu
router.post('/:userId', auth, messageController.sendMessage);

// PUT /:userId/read — Tandai semua pesan sebagai dibaca
router.put('/:userId/read', auth, messageController.markAsRead);

module.exports = router;
