const { Op } = require('sequelize');
const { Message, User } = require('../models');
const { success, error } = require('../utils/response');
const { timeAgo } = require('../utils/timeAgo');
const { sendPushNotification } = require('../utils/fcmSender');

// GET /conversations — Daftar semua percakapan
exports.getConversations = async (req, res) => {
  try {
    const userId = req.user.id;

    // Ambil semua pesan yang melibatkan user
    const messages = await Message.findAll({
      where: {
        [Op.or]: [
          { sender_id: userId },
          { receiver_id: userId }
        ]
      },
      include: [
        { model: User, as: 'sender', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: User, as: 'receiver', attributes: ['id', 'username', 'display_name', 'avatar_url'] }
      ],
      order: [['created_at', 'DESC']]
    });

    // Group by partner — ambil pesan terakhir per percakapan
    const conversationMap = new Map();
    for (const msg of messages) {
      const partnerId = msg.sender_id === userId ? msg.receiver_id : msg.sender_id;
      if (!conversationMap.has(partnerId)) {
        const partner = msg.sender_id === userId ? msg.receiver : msg.sender;
        const unreadCount = await Message.count({
          where: {
            sender_id: partnerId,
            receiver_id: userId,
            is_read: false
          }
        });

        conversationMap.set(partnerId, {
          partner,
          last_message: {
            text: msg.text,
            sender_id: msg.sender_id,
            created_at: msg.created_at,
            time_ago: timeAgo(msg.created_at)
          },
          unread_count: unreadCount
        });
      }
    }

    const conversations = Array.from(conversationMap.values());
    return success(res, conversations, 'Percakapan berhasil diambil');
  } catch (err) {
    console.error('Get conversations error:', err);
    return error(res, 'Gagal mengambil percakapan');
  }
};

// GET /:userId — Pesan dengan user tertentu
exports.getMessages = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { userId } = req.params;

    const messages = await Message.findAll({
      where: {
        [Op.or]: [
          { sender_id: currentUserId, receiver_id: userId },
          { sender_id: userId, receiver_id: currentUserId }
        ]
      },
      include: [
        { model: User, as: 'sender', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: User, as: 'receiver', attributes: ['id', 'username', 'display_name', 'avatar_url'] }
      ],
      order: [['created_at', 'ASC']]
    });

    const data = messages.map(m => ({
      ...m.toJSON(),
      time_ago: timeAgo(m.created_at)
    }));

    return success(res, data, 'Pesan berhasil diambil');
  } catch (err) {
    console.error('Get messages error:', err);
    return error(res, 'Gagal mengambil pesan');
  }
};

// POST /:userId — Kirim pesan ke user tertentu
exports.sendMessage = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { userId } = req.params;
    const { text } = req.body;

    if (!text || text.trim().length === 0) {
      return error(res, 'Teks pesan tidak boleh kosong', 400);
    }

    // Cek user tujuan ada
    const targetUser = await User.findByPk(userId);
    if (!targetUser) {
      return error(res, 'User tidak ditemukan', 404);
    }

    const message = await Message.create({
      sender_id: currentUserId,
      receiver_id: parseInt(userId),
      text
    });

    const fullMessage = await Message.findByPk(message.id, {
      include: [
        { model: User, as: 'sender', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: User, as: 'receiver', attributes: ['id', 'username', 'display_name', 'avatar_url'] }
      ]
    });

    // Kirim push notifikasi ke penerima pesan secara background
    sendPushNotification(
      parseInt(userId),
      `Pesan baru dari @${fullMessage.sender.username}`,
      text,
      {
        id: String(message.id),
        type: 'message',
        fromUserId: String(currentUserId),
        commentText: text,
        createdAt: message.created_at.toISOString(),
      }
    ).catch(err => console.error('Error sending message push notification:', err));

    return success(res, {
      ...fullMessage.toJSON(),
      time_ago: timeAgo(fullMessage.created_at)
    }, 'Pesan berhasil dikirim', 201);
  } catch (err) {
    console.error('Send message error:', err);
    return error(res, 'Gagal mengirim pesan');
  }
};

// PUT /:userId/read — Tandai semua pesan sebagai dibaca
exports.markAsRead = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { userId } = req.params;

    await Message.update(
      { is_read: true },
      {
        where: {
          sender_id: userId,
          receiver_id: currentUserId,
          is_read: false
        }
      }
    );

    return success(res, null, 'Pesan ditandai sebagai dibaca');
  } catch (err) {
    console.error('Mark as read error:', err);
    return error(res, 'Gagal menandai pesan');
  }
};

// GET /unread/count — Total pesan belum dibaca
exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.id;

    const count = await Message.count({
      where: {
        receiver_id: userId,
        is_read: false
      }
    });

    return success(res, { unread_count: count }, 'Jumlah pesan belum dibaca');
  } catch (err) {
    console.error('Get unread count error:', err);
    return error(res, 'Gagal mengambil jumlah pesan belum dibaca');
  }
};
