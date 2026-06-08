const { Message } = require('../../models');

module.exports = async () => {
  await Message.bulkCreate([
    // Percakapan antara Andi dan Siti
    { sender_id: 1, receiver_id: 2, text: 'Hei Siti! Resep coto-nya mau dishare ga?', is_read: true },
    { sender_id: 2, receiver_id: 1, text: 'Hai Andi! Boleh dong, nanti aku kirim ya 😊', is_read: true },
    { sender_id: 1, receiver_id: 2, text: 'Oke siap! Ditunggu yaa', is_read: true },
    { sender_id: 2, receiver_id: 1, text: 'Oke siap! Btw resep coto-nya mau dishare ga?', is_read: false },

    // Percakapan antara Andi dan Maulana
    { sender_id: 1, receiver_id: 3, text: 'Bro, foto street photography-mu keren banget!', is_read: true },
    { sender_id: 3, receiver_id: 1, text: 'Makasih bro! Kapan hunting bareng?', is_read: true },
    { sender_id: 1, receiver_id: 3, text: 'Weekend ini gimana?', is_read: false },

    // Percakapan antara Siti dan Fitri
    { sender_id: 2, receiver_id: 4, text: 'Fitri! Foto Toraja-nya bagus banget', is_read: true },
    { sender_id: 4, receiver_id: 2, text: 'Makasih kak! Kamu harus kesana deh 😍', is_read: true },
    { sender_id: 2, receiver_id: 4, text: 'Pengen banget sih, next trip ya!', is_read: false },

    // Percakapan antara Reza dan Andi
    { sender_id: 5, receiver_id: 1, text: 'Andi, sunset photo-mu di Losari keren!', is_read: true },
    { sender_id: 1, receiver_id: 5, text: 'Thanks Reza! Pakai HP aja itu haha', is_read: true },

    // Percakapan antara Maulana dan Fitri
    { sender_id: 3, receiver_id: 4, text: 'Fitri, boleh minta rekomendasi tempat foto di Toraja?', is_read: true },
    { sender_id: 4, receiver_id: 3, text: 'Banyak spot bagus! Ke\'te Kesu wajib itu 📸', is_read: false },
  ], { ignoreDuplicates: true });

  console.log('✅ Messages seeded');
};
