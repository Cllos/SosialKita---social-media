// Semua controller pakai helper ini agar response konsisten

const success = (res, data = null, message = 'Berhasil', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data
  });
};

const error = (res, message = 'Terjadi kesalahan', statusCode = 500, errors = null) => {
  return res.status(statusCode).json({
    success: false,
    message,
    ...(errors && { errors })
  });
};

const paginated = (res, data, pagination, message = 'Berhasil') => {
  return res.status(200).json({
    success: true,
    message,
    data,
    pagination  // { page, limit, total, totalPages }
  });
};

module.exports = { success, error, paginated };
