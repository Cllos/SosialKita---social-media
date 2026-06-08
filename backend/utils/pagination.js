const getPagination = (page, size) => {
  const limit = size ? +size : 10;
  const offset = page ? (page - 1) * limit : 0;
  return { limit, offset };
};

const getPagingData = (totalItems, page, limit) => {
  const totalPages = Math.ceil(totalItems / limit);
  return {
    page: +page,
    limit: +limit,
    total: totalItems,
    totalPages
  };
};

module.exports = { getPagination, getPagingData };
