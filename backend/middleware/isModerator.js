const { error } = require('../utils/response');

module.exports = (req, res, next) => {
  if (req.user.role !== 'moderator') {
    return error(res, 'Akses ditolak — hanya untuk moderator', 403);
  }
  next();
};
