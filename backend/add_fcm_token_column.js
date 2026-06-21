require('dotenv').config();
const { sequelize } = require('./config/database');
const { DataTypes } = require('sequelize');

async function migrate() {
  try {
    await sequelize.authenticate();
    console.log('✅ Database terhubung untuk migrasi...');

    const queryInterface = sequelize.getQueryInterface();
    const tableInfo = await queryInterface.describeTable('users');

    if (!tableInfo.fcm_token) {
      await queryInterface.addColumn('users', 'fcm_token', {
        type: DataTypes.STRING(255),
        allowNull: true
      });
      console.log('✅ Kolom fcm_token berhasil ditambahkan ke tabel users.');
    } else {
      console.log('ℹ️ Kolom fcm_token sudah ada di tabel users, tidak ada perubahan.');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Gagal menjalankan migrasi:', error);
    process.exit(1);
  }
}

migrate();
