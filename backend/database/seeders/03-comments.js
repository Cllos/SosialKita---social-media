const { Comment } = require('../../models');

module.exports = async () => {
  await Comment.bulkCreate([
    { user_id: 2, post_id: 1, text: 'Sunset-nya indah banget! 😍' },
    { user_id: 3, post_id: 1, text: 'Kapan-kapan kita ke sana bareng ya!' },
    { user_id: 1, post_id: 2, text: 'Wah bikin ngiler! Di mana tuh tempatnya?' },
    { user_id: 4, post_id: 2, text: 'Coto favoritku juga itu! 🔥' },
    { user_id: 5, post_id: 2, text: 'Mau dong resepnya! 🤤' },
    { user_id: 1, post_id: 3, text: 'Angle-nya keren banget bro! 📸' },
    { user_id: 4, post_id: 3, text: 'Ini pakai kamera apa?' },
    { user_id: 2, post_id: 4, text: 'Toraja memang luar biasa! ❤️' },
    { user_id: 5, post_id: 4, text: 'Bucket list saya nih!' },
    { user_id: 1, post_id: 5, text: 'Coffee + code = productif! ☕💻' },
    { user_id: 3, post_id: 5, text: 'Kafe Baca memang enak buat ngoding' },
    { user_id: 2, post_id: 6, text: 'Fort Rotterdam iconic banget!' },
    { user_id: 5, post_id: 7, text: 'Pisang epe-nya bikin kangen Makassar 😢' },
    { user_id: 1, post_id: 8, text: 'Wow golden hour terbaik!' },
    { user_id: 3, post_id: 9, text: 'Pantai Bira emang juara sih 🏆' },
  ], { ignoreDuplicates: true });

  console.log('✅ Comments seeded');
};
