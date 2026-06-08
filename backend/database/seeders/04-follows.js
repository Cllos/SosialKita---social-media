const { Follow } = require('../../models');

module.exports = async () => {
  await Follow.bulkCreate([
    // Andi follows semua orang
    { follower_id: 1, following_id: 2 },
    { follower_id: 1, following_id: 3 },
    { follower_id: 1, following_id: 4 },
    { follower_id: 1, following_id: 5 },
    // Siti follows beberapa
    { follower_id: 2, following_id: 1 },
    { follower_id: 2, following_id: 3 },
    { follower_id: 2, following_id: 4 },
    // Maulana follows beberapa
    { follower_id: 3, following_id: 1 },
    { follower_id: 3, following_id: 2 },
    { follower_id: 3, following_id: 5 },
    // Fitri follows beberapa
    { follower_id: 4, following_id: 1 },
    { follower_id: 4, following_id: 2 },
    { follower_id: 4, following_id: 3 },
    // Reza follows beberapa
    { follower_id: 5, following_id: 1 },
    { follower_id: 5, following_id: 3 },
    { follower_id: 5, following_id: 4 },
  ], { ignoreDuplicates: true });

  console.log('✅ Follows seeded');
};
