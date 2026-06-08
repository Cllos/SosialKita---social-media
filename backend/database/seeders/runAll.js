require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { sequelize } = require('../../config/database');

async function runSeeders() {
  try {
    await sequelize.authenticate();
    console.log('✅ Database terhubung');

    await sequelize.sync({ alter: true });
    console.log('✅ Database sync selesai');

    await require('./01-users')();
    await require('./02-posts')();
    await require('./03-comments')();
    await require('./04-follows')();
    await require('./05-messages')();

    console.log('✅ Semua seeder selesai!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Seeder error:', err);
    process.exit(1);
  }
}

runSeeders();
