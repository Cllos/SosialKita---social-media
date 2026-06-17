require('dotenv').config();
const app = require('./app');
const { sequelize } = require('./config/database');

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    await sequelize.authenticate();
    console.log('✅ Database MySQL terhubung');

    // Sync model ke database (tanpa alter agar tidak duplikasi index)
    await sequelize.sync();
    console.log('✅ Database sync selesai');

    app.listen(PORT, () => {
      console.log(`🚀 SosialKita API berjalan di http://localhost:${PORT}`);
      console.log(`📋 API Base URL: http://localhost:${PORT}/api/v1`);
    });
  } catch (error) {
    console.error('❌ Gagal start server:', error);
    process.exit(1);
  }
}

startServer();
