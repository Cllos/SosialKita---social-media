const bcrypt = require('bcryptjs');
const { User } = require('../../models');

module.exports = async () => {
  const hash = await bcrypt.hash('123456', 12);
  const adminHash = await bcrypt.hash('admin123', 12);

  await User.bulkCreate([
    { username: 'andi_yusuf',   display_name: 'Andi Yusuf',       email: 'andi@email.com',       password: hash,      role: 'user',      bio: 'Pecinta sunset 🌅',       avatar_url: 'https://i.pravatar.cc/150?img=1' },
    { username: 'siti_rahma',   display_name: 'Siti Rahma',       email: 'siti@email.com',       password: hash,      role: 'user',      bio: 'Food blogger 🍲',         avatar_url: 'https://i.pravatar.cc/150?img=5' },
    { username: 'maulana_b',    display_name: 'Maulana Budi',     email: 'maulana@email.com',    password: hash,      role: 'user',      bio: 'Fotografer jalanan 📸',   avatar_url: 'https://i.pravatar.cc/150?img=3' },
    { username: 'fitri_dewi',   display_name: 'Fitri Dewi',       email: 'fitri@email.com',      password: hash,      role: 'user',      bio: 'Traveler Sulawesi 🏝️',   avatar_url: 'https://i.pravatar.cc/150?img=9' },
    { username: 'reza_h',       display_name: 'Reza Hasni',       email: 'reza@email.com',       password: hash,      role: 'user',      bio: 'Developer & coffee ☕',   avatar_url: 'https://i.pravatar.cc/150?img=7' },
    { username: 'admin_sk',     display_name: 'Admin SosialKita',  email: 'admin@sosialkita.app', password: adminHash, role: 'moderator', bio: 'Moderator resmi 🛡️',     avatar_url: 'https://i.pravatar.cc/150?img=12' },
  ], { ignoreDuplicates: true });

  console.log('✅ Users seeded');
};
