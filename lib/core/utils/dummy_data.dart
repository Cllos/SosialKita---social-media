import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../models/dm_message_model.dart';

// ══════════════════════════════════════
//  DATA DUMMY — USERS
// ══════════════════════════════════════

final List<UserModel> dummyUsers = [
  UserModel(
    id: 'u1',
    username: 'andi_yusuf',
    displayName: 'Andi Yusuf',
    email: 'andi@email.com',
    password: '123456',
    bio: 'Pecinta sunset dan kuliner Makassar 🌅',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    avatarInitials: 'AY',
    avatarColor: const Color(0xFFFF6B9D),
    role: 'user',
    followers: ['u2', 'u3', 'u4'],
    following: ['u2', 'u5'],
    savedPosts: ['p2', 'p4'],
    joinedAt: DateTime(2024, 1, 10),
  ),
  UserModel(
    id: 'u2',
    username: 'siti_rahma',
    displayName: 'Siti Rahma',
    email: 'siti@email.com',
    password: '123456',
    bio: 'Food blogger | Kuliner Sulsel 🍲',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    avatarInitials: 'SR',
    avatarColor: const Color(0xFF4F9EFF),
    role: 'user',
    followers: ['u1', 'u3'],
    following: ['u1', 'u3', 'u4'],
    savedPosts: ['p1'],
    joinedAt: DateTime(2024, 2, 5),
  ),
  UserModel(
    id: 'u3',
    username: 'maulana_b',
    displayName: 'Maulana Budi',
    email: 'maulana@email.com',
    password: '123456',
    bio: 'Fotografer jalanan Makassar 📸',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    avatarInitials: 'MB',
    avatarColor: const Color(0xFF43E97B),
    role: 'user',
    followers: ['u1'],
    following: ['u1', 'u2'],
    savedPosts: [],
    joinedAt: DateTime(2024, 3, 20),
  ),
  UserModel(
    id: 'u4',
    username: 'fitri_dewi',
    displayName: 'Fitri Dewi',
    email: 'fitri@email.com',
    password: '123456',
    bio: 'Traveler | Wisata Sulawesi 🏝️',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
    avatarInitials: 'FD',
    avatarColor: const Color(0xFFF093FB),
    role: 'user',
    followers: ['u1', 'u2'],
    following: ['u3'],
    savedPosts: ['p3'],
    joinedAt: DateTime(2024, 4, 1),
  ),
  UserModel(
    id: 'u5',
    username: 'reza_h',
    displayName: 'Reza Hasni',
    email: 'reza@email.com',
    password: '123456',
    bio: 'Developer & coffee enthusiast ☕',
    avatarUrl: 'https://i.pravatar.cc/150?img=7',
    avatarInitials: 'RH',
    avatarColor: const Color(0xFF43E97B),
    role: 'user',
    followers: [],
    following: ['u1'],
    savedPosts: [],
    joinedAt: DateTime(2024, 5, 15),
  ),
  UserModel(
    id: 'u6',
    username: 'dian_p',
    displayName: 'Dian Putri',
    email: 'dian@email.com',
    password: '123456',
    bio: 'Mahasiswi UNHAS | Suka nulis ✍️',
    avatarUrl: 'https://i.pravatar.cc/150?img=10',
    avatarInitials: 'DP',
    avatarColor: const Color(0xFFFF8E53),
    role: 'user',
    followers: ['u1', 'u3'],
    following: ['u2', 'u4'],
    savedPosts: [],
    joinedAt: DateTime(2024, 6, 1),
  ),
  UserModel(
    id: 'u7',
    username: 'budi_s',
    displayName: 'Budi Santoso',
    email: 'budi@email.com',
    password: '123456',
    bio: 'Musik & seni rupa 🎨🎵',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    avatarInitials: 'BS',
    avatarColor: const Color(0xFF38F9D7),
    role: 'user',
    followers: ['u2'],
    following: ['u1', 'u5'],
    savedPosts: ['p1'],
    joinedAt: DateTime(2024, 7, 10),
  ),
  UserModel(
    id: 'mod1',
    username: 'admin_sosialkita',
    displayName: 'Admin SosialKita',
    email: 'admin@sosialkita.app',
    password: 'admin123',
    bio: 'Moderator resmi SosialKita 🛡️',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    avatarInitials: 'AS',
    avatarColor: const Color(0xFFF43F5E),
    role: 'moderator',
    followers: [],
    following: [],
    savedPosts: [],
    joinedAt: DateTime(2024, 1, 1),
  ),
];

// ══════════════════════════════════════
//  DATA DUMMY — POSTS (12 postingan)
// ══════════════════════════════════════

final List<PostModel> dummyPosts = [
  PostModel(
    id: 'p1',
    userId: 'u1',
    imageUrl: 'https://picsum.photos/seed/sunset-losari/600/400',
    caption:
        'Sunset di Pantai Losari selalu bikin kagum. Golden hour yang sempurna! ✨ #SunsetLosari #Makassar #GoldenHour',
    likes: ['u2', 'u3', 'u4', 'u5'],
    tags: ['SunsetLosari', 'Makassar', 'GoldenHour'],
    location: 'Pantai Losari, Makassar',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  PostModel(
    id: 'p2',
    userId: 'u2',
    imageUrl: 'https://picsum.photos/seed/coto-makassar/600/400',
    caption:
        'Coto Makassar terenak yang pernah aku coba! Wajib kesini kalau mampir ke Gowa 🍲 #KulinerMakassar #CotoMakassar',
    likes: ['u1', 'u3'],
    tags: ['KulinerMakassar', 'CotoMakassar'],
    location: 'Warung Coto Nusantara, Gowa',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  PostModel(
    id: 'p3',
    userId: 'u3',
    imageUrl: 'https://picsum.photos/seed/street-makassar/600/400',
    caption:
        'Sudut kota Makassar yang penuh cerita 📸 #FotografiJalanan #Makassar',
    likes: ['u1', 'u4'],
    tags: ['FotografiJalanan', 'Makassar'],
    location: 'Jl. Somba Opu, Makassar',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  PostModel(
    id: 'p4',
    userId: 'u4',
    imageUrl: 'https://picsum.photos/seed/island-samalona/600/400',
    caption:
        'Pulau Samalona, surga tersembunyi di Makassar 🏝️ Air jernih banget! #WisataMakassar #PulauSamalona #TravelSulsel',
    likes: ['u1', 'u2', 'u3', 'u5'],
    tags: ['WisataMakassar', 'PulauSamalona', 'TravelSulsel'],
    location: 'Pulau Samalona, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  PostModel(
    id: 'p5',
    userId: 'u5',
    imageUrl: 'https://picsum.photos/seed/coffee-toraja/600/400',
    caption:
        'Weekend vibes ☕ Kopi toraja favorit di cafe langganan. #KopiToraja #CafeVibes #Makassar',
    likes: ['u2'],
    tags: ['KopiToraja', 'CafeVibes', 'Makassar'],
    location: 'Kopi Kulo, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  PostModel(
    id: 'p6',
    userId: 'u1',
    imageUrl: 'https://picsum.photos/seed/fort-rotterdam/600/400',
    caption:
        'Fort Rotterdam, saksi sejarah kota Makassar 🏛️ Arsitekturnya luar biasa! #FortRotterdam #SejarahMakassar',
    likes: ['u2', 'u3', 'u6'],
    tags: ['FortRotterdam', 'SejarahMakassar'],
    location: 'Fort Rotterdam, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  PostModel(
    id: 'p7',
    userId: 'u6',
    imageUrl: 'https://picsum.photos/seed/campus-unhas/600/400',
    caption:
        'Hari pertama semester baru di UNHAS! Semangat teman-teman 📚✨ #UNHAS #KampusLife #Makassar',
    likes: ['u1', 'u3', 'u4'],
    tags: ['UNHAS', 'KampusLife', 'Makassar'],
    location: 'Universitas Hasanuddin',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
  ),
  PostModel(
    id: 'p8',
    userId: 'u7',
    imageUrl: 'https://picsum.photos/seed/mural-art/600/400',
    caption:
        'Mural baru di lorong wisata Makassar 🎨 Seni jalanan yang keren! #MuralMakassar #StreetArt',
    likes: ['u2', 'u6'],
    tags: ['MuralMakassar', 'StreetArt'],
    location: 'Lorong Wisata, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  PostModel(
    id: 'p9',
    userId: 'u2',
    imageUrl: 'https://picsum.photos/seed/pisang-epe/600/400',
    caption:
        'Pisang Epe di pinggir pantai Losari 🍌🔥 Jajanan khas Makassar yang nggak pernah bosen! #PisangEpe #JajananMakassar',
    likes: ['u1', 'u4', 'u5', 'u7'],
    tags: ['PisangEpe', 'JajananMakassar'],
    location: 'Pantai Losari, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 8)),
  ),
  PostModel(
    id: 'p10',
    userId: 'u3',
    imageUrl: 'https://picsum.photos/seed/masjid-makassar/600/400',
    caption:
        'Masjid Raya Makassar di malam hari, megah dan indah 🕌✨ #MasjidRaya #Makassar #NightPhotography',
    likes: ['u1', 'u2', 'u5', 'u6', 'u7'],
    tags: ['MasjidRaya', 'Makassar', 'NightPhotography'],
    location: 'Masjid Raya Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  PostModel(
    id: 'p11',
    userId: 'u4',
    imageUrl: 'https://picsum.photos/seed/tana-toraja/600/400',
    caption:
        'Weekend trip ke Tana Toraja! Budaya yang sangat kaya dan pemandangan luar biasa 🏔️ #TanaToraja #WisataSulsel',
    likes: ['u1', 'u2', 'u3'],
    tags: ['TanaToraja', 'WisataSulsel'],
    location: 'Tana Toraja, Sulawesi Selatan',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  PostModel(
    id: 'p12',
    userId: 'u5',
    imageUrl: 'https://picsum.photos/seed/coding-night/600/400',
    caption:
        'Coding marathon sampai subuh 💻🌙 Side project baru yang excited banget! #Coding #DevLife #NightOwl',
    likes: ['u7'],
    tags: ['Coding', 'DevLife', 'NightOwl'],
    location: 'Home Office, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
];

// ══════════════════════════════════════
//  DATA DUMMY — COMMENTS (20 komentar)
// ══════════════════════════════════════

final List<CommentModel> dummyComments = [
  // Post 1 — Sunset Losari
  CommentModel(
    id: 'c1',
    postId: 'p1',
    userId: 'u2',
    text: 'Keren banget! Kapan-kapan mau kesana juga 😍',
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  ),
  CommentModel(
    id: 'c2',
    postId: 'p1',
    userId: 'u3',
    text: 'Fotonya bagus! Pakai kamera apa?',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  CommentModel(
    id: 'c3',
    postId: 'p1',
    userId: 'u4',
    text: '🔥🔥 Losari memang selalu hits!',
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
  // Post 2 — Coto Makassar
  CommentModel(
    id: 'c4',
    postId: 'p2',
    userId: 'u1',
    text: 'Coto Makassar emang juara! 🍜',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  CommentModel(
    id: 'c5',
    postId: 'p2',
    userId: 'u4',
    text: 'Share alamatnya dong kak!',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  CommentModel(
    id: 'c6',
    postId: 'p2',
    userId: 'u5',
    text: 'Wah jadi lapar 🤤',
    createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
  ),
  // Post 3 — Fotografi Jalanan
  CommentModel(
    id: 'c7',
    postId: 'p3',
    userId: 'u1',
    text: 'Angle-nya keren bro! Ajakin kapan-kapan 📸',
    createdAt: DateTime.now().subtract(const Duration(hours: 7)),
  ),
  CommentModel(
    id: 'c8',
    postId: 'p3',
    userId: 'u6',
    text: 'Somba Opu memang pusat sejarah ya',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  // Post 4 — Pulau Samalona
  CommentModel(
    id: 'c9',
    postId: 'p4',
    userId: 'u1',
    text: 'Mau kesana juga! Biaya berapa kak?',
    createdAt: DateTime.now().subtract(const Duration(hours: 20)),
  ),
  CommentModel(
    id: 'c10',
    postId: 'p4',
    userId: 'u2',
    text: 'Snorkeling-nya seru banget pasti! 🐠',
    createdAt: DateTime.now().subtract(const Duration(hours: 18)),
  ),
  CommentModel(
    id: 'c11',
    postId: 'p4',
    userId: 'u3',
    text: 'Airnya bening banget, kapan lagi bisa kesana',
    createdAt: DateTime.now().subtract(const Duration(hours: 16)),
  ),
  // Post 5 — Coffee
  CommentModel(
    id: 'c12',
    postId: 'p5',
    userId: 'u1',
    text: 'Kopi Toraja yang terbaik ☕👌',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
  ),
  // Post 6 — Fort Rotterdam
  CommentModel(
    id: 'c13',
    postId: 'p6',
    userId: 'u3',
    text: 'Tempat favorit buat hunting foto!',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 20)),
  ),
  CommentModel(
    id: 'c14',
    postId: 'p6',
    userId: 'u6',
    text: 'Sejarah Indonesia yang harus dijaga 🇮🇩',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 18)),
  ),
  // Post 7 — UNHAS
  CommentModel(
    id: 'c15',
    postId: 'p7',
    userId: 'u1',
    text: 'Semangat kuliahnya! 💪',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
  ),
  // Post 9 — Pisang Epe
  CommentModel(
    id: 'c16',
    postId: 'p9',
    userId: 'u1',
    text: 'Pisang epe + susu keju = combo terbaik! 🤤',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
  ),
  CommentModel(
    id: 'c17',
    postId: 'p9',
    userId: 'u5',
    text: 'Mantap sih ini, jadi kangen Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
  ),
  // Post 10 — Masjid Raya
  CommentModel(
    id: 'c18',
    postId: 'p10',
    userId: 'u4',
    text: 'Subhanallah, cantik banget 🕌',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 20)),
  ),
  CommentModel(
    id: 'c19',
    postId: 'p10',
    userId: 'u7',
    text: 'Skill fotonya makin keren aja',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 18)),
  ),
  // Post 11 — Tana Toraja
  CommentModel(
    id: 'c20',
    postId: 'p11',
    userId: 'u6',
    text: 'Bucket list aku ini! Cerita lengkapnya dong kak',
    createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 20)),
  ),
];

// ══════════════════════════════════════
//  DATA DUMMY — DM CONVERSATIONS
// ══════════════════════════════════════

final List<DmConversation> dummyConversations = [
  DmConversation(
    id: 'u1_u2',
    participantIds: ['u1', 'u2'],
    messages: [
      DmMessageModel(
        id: 'dm1',
        fromUserId: 'u2',
        toUserId: 'u1',
        text: 'Hei! Sunset di Losari kemarin keren banget 😍',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      DmMessageModel(
        id: 'dm2',
        fromUserId: 'u1',
        toUserId: 'u2',
        text: 'Makasih! Datang aja sendiri, tiap sore bagus',
        isRead: true,
        createdAt:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 50)),
      ),
      DmMessageModel(
        id: 'dm3',
        fromUserId: 'u2',
        toUserId: 'u1',
        text: 'Oke siap! Btw resep coto-nya mau dishare ga? 🍲',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ],
  ),
  DmConversation(
    id: 'u1_u3',
    participantIds: ['u1', 'u3'],
    messages: [
      DmMessageModel(
        id: 'dm4',
        fromUserId: 'u3',
        toUserId: 'u1',
        text: 'Bro, mau minta tips foto sunset dong 📸',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DmMessageModel(
        id: 'dm5',
        fromUserId: 'u1',
        toUserId: 'u3',
        text: 'Pakai golden hour jam 5-6 sore, settingan manual ISO 100',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 23)),
      ),
    ],
  ),
  DmConversation(
    id: 'u1_u4',
    participantIds: ['u1', 'u4'],
    messages: [
      DmMessageModel(
        id: 'dm6',
        fromUserId: 'u4',
        toUserId: 'u1',
        text: 'Kapan ke Pulau Samalona lagi? Ikut dong!',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  ),
  DmConversation(
    id: 'u1_u5',
    participantIds: ['u1', 'u5'],
    messages: [
      DmMessageModel(
        id: 'dm7',
        fromUserId: 'u1',
        toUserId: 'u5',
        text: 'Reza, café kopi toraja-nya di mana tuh?',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DmMessageModel(
        id: 'dm8',
        fromUserId: 'u5',
        toUserId: 'u1',
        text: 'Kopi Kulo, Jl. AP Pettarani. Recommended banget ☕',
        isRead: true,
        createdAt:
            DateTime.now().subtract(const Duration(days: 1, hours: 22)),
      ),
    ],
  ),
];
