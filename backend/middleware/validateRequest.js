const { validationResult } = require('express-validator');
const { error } = require('../utils/response');

const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return error(res, 'Validasi gagal', 422, errors.array());
  }
  next();
};

module.exports = validateRequest;
