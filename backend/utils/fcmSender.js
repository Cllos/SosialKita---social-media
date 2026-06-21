const admin = require('../config/firebase');
const { User } = require('../models');

/**
 * Mengirimkan push notifikasi via FCM ke user tertentu.
 * Jika token dideteksi expired/tidak valid, token akan otomatis dihapus dari database.
 * 
 * @param {number|string} targetUserId ID user penerima notifikasi
 * @param {string} title Judul notifikasi
 * @param {string} body Isi pesan notifikasi
 * @param {Object} dataPayload Data payload opsional (harus berupa key-value string)
 */
async function sendPushNotification(targetUserId, title, body, dataPayload = {}) {
  try {
    // 1. Dapatkan user dari database
    const user = await User.findByPk(targetUserId);
    if (!user) {
      console.warn(`[FCM] User dengan ID ${targetUserId} tidak ditemukan.`);
      return false;
    }

    const token = user.fcm_token;
    if (!token) {
      console.log(`[FCM] User ${user.username} tidak memiliki fcm_token. Notifikasi tidak dikirim.`);
      return false;
    }

    // 2. Pastikan semua dataPayload bertipe string
    const stringifiedData = {};
    for (const key in dataPayload) {
      if (dataPayload.hasOwnProperty(key)) {
        stringifiedData[key] = String(dataPayload[key]);
      }
    }

    // Tambahan metadata default
    stringifiedData.title = String(title);
    stringifiedData.body = String(body);
    stringifiedData.click_action = stringifiedData.click_action || 'FLUTTER_NOTIFICATION_CLICK';

    // 3. Susun payload pesan FCM
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: stringifiedData,
      token: token,
      android: {
        notification: {
          sound: 'default',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
    };

    // 4. Kirim notifikasi menggunakan Firebase Admin SDK
    if (admin.apps.length === 0) {
      console.warn('[FCM] Firebase Admin SDK belum diinisialisasi. Lewati pengiriman.');
      return false;
    }

    const response = await admin.messaging().send(message);
    console.log(`[FCM] Notifikasi berhasil dikirim ke ${user.username}:`, response);
    return true;
  } catch (error) {
    console.error(`[FCM] Gagal mengirim notifikasi ke user ID ${targetUserId}:`, error);

    // Jika token sudah tidak valid / tidak terdaftar, bersihkan dari database
    if (
      error.code === 'messaging/registration-token-not-registered' ||
      error.code === 'messaging/invalid-registration-token' ||
      error.message?.includes('registration token')
    ) {
      try {
        const user = await User.findByPk(targetUserId);
        if (user) {
          user.fcm_token = null;
          await user.save();
          console.log(`[FCM] Token tidak valid untuk user ${user.username} telah dihapus dari DB.`);
        }
      } catch (dbError) {
        console.error('[FCM] Gagal membersihkan token tidak valid dari database:', dbError);
      }
    }
    return false;
  }
}

module.exports = { sendPushNotification };
