const { error } = require('../utils/response');

module.exports = (err, req, res, next) => {
  console.error('Global error:', err.stack);

  // Sequelize validation error
  if (err.name === 'SequelizeValidationError') {
    const messages = err.errors.map(e => e.message);
    return error(res, 'Validasi database gagal', 422, messages);
  }

  // Sequelize unique constraint
  if (err.name === 'SequelizeUniqueConstraintError') {
    return error(res, 'Data sudah ada / duplikat', 409);
  }

  // Default
  return error(res, err.message || 'Internal server error', err.status || 500);
};
