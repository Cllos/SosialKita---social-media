const { Post, PostTag } = require('../../models');

module.exports = async () => {
  const posts = await Post.bulkCreate([
    {
      user_id: 1,
      image_url: 'https://picsum.photos/seed/post1/600/600',
      caption: 'Sunset indah di Pantai Losari 🌅 #SunsetMakassar #PantaiLosari #Beautiful',
      location: 'Pantai Losari, Makassar'
    },
    {
      user_id: 2,
      image_url: 'https://picsum.photos/seed/post2/600/600',
      caption: 'Coto Makassar terenak yang pernah saya coba! 🍲 #KulinerMakassar #CotoMakassar #Foodie',
      location: 'Gowa, Sulawesi Selatan'
    },
    {
      user_id: 3,
      image_url: 'https://picsum.photos/seed/post3/600/600',
      caption: 'Street photography hari ini 📸 #Photography #StreetPhoto #Makassar',
      location: 'Jalan Somba Opu, Makassar'
    },
    {
      user_id: 4,
      image_url: 'https://picsum.photos/seed/post4/600/600',
      caption: 'Menikmati keindahan Toraja 🏔️ #Toraja #Sulawesi #Travel #Adventure',
      location: 'Tana Toraja'
    },
    {
      user_id: 5,
      image_url: 'https://picsum.photos/seed/post5/600/600',
      caption: 'Coding session with coffee ☕ #Developer #Coding #CoffeeTime',
      location: 'Kafe Baca, Makassar'
    },
    {
      user_id: 1,
      image_url: 'https://picsum.photos/seed/post6/600/600',
      caption: 'Morning vibes di Fort Rotterdam 🏰 #FortRotterdam #Makassar #History',
      location: 'Fort Rotterdam, Makassar'
    },
    {
      user_id: 2,
      image_url: 'https://picsum.photos/seed/post7/600/600',
      caption: 'Pisang epe favorit! 🍌🔥 #PisangEpe #Makassar #JajananMakassar',
      location: 'Pantai Losari, Makassar'
    },
    {
      user_id: 3,
      image_url: 'https://picsum.photos/seed/post8/600/600',
      caption: 'Golden hour 🌇 #GoldenHour #Photography #CityVibes',
      location: 'Makassar'
    },
    {
      user_id: 4,
      image_url: 'https://picsum.photos/seed/post9/600/600',
      caption: 'Pantai Bira yang menakjubkan 🏖️ #PantaiBira #Bulukumba #BeachLife',
      location: 'Pantai Bira, Bulukumba'
    },
    {
      user_id: 5,
      image_url: 'https://picsum.photos/seed/post10/600/600',
      caption: 'Hackathon weekend! 💻 #Hackathon #Developer #Tech',
      location: 'Universitas Hasanuddin'
    }
  ], { ignoreDuplicates: true });

  // Parse dan simpan hashtag dari setiap post
  for (const post of posts) {
    if (post.caption) {
      const tags = post.caption.match(/#\w+/g) || [];
      for (const tag of tags) {
        await PostTag.create({ post_id: post.id, tag: tag.replace('#', '') });
      }
    }
  }

  console.log('✅ Posts & tags seeded');
};
