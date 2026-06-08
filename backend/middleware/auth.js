const jwt = require('jsonwebtoken');
const { error } = require('../utils/response');
const { User } = require('../models');

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return error(res, 'Token tidak ditemukan, silakan login', 401);
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findByPk(decoded.id, {
      attributes: { exclude: ['password'] }
    });

    if (!user || !user.is_active) {
      return error(res, 'Akun tidak ditemukan atau tidak aktif', 401);
    }

    req.user = user;  // attach user ke request
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return error(res, 'Token expired, silakan login ulang', 401);
    }
    return error(res, 'Token tidak valid', 401);
  }
};
