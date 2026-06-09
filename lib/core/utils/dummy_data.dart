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
    id: '1',
    username: 'andi_yusuf',
    displayName: 'Andi Yusuf',
    email: 'andi@email.com',
    password: '123456',
    bio: 'Pecinta sunset dan kuliner Makassar 🌅',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    avatarInitials: 'AY',
    avatarColor: const Color(0xFFFF6B9D),
    role: 'user',
    followers: ['2', '3', '4'],
    following: ['2', '5'],
    savedPosts: ['p2', 'p4'],
    joinedAt: DateTime(2024, 1, 10),
  ),
  UserModel(
    id: '2',
    username: 'siti_rahma',
    displayName: 'Siti Rahma',
    email: 'siti@email.com',
    password: '123456',
    bio: 'Food blogger | Kuliner Sulsel 🍲',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    avatarInitials: 'SR',
    avatarColor: const Color(0xFF4F9EFF),
    role: 'user',
    followers: ['1', '3'],
    following: ['1', '3', '4'],
    savedPosts: ['p1'],
    joinedAt: DateTime(2024, 2, 5),
  ),
  UserModel(
    id: '3',
    username: 'maulana_b',
    displayName: 'Maulana Budi',
    email: 'maulana@email.com',
    password: '123456',
    bio: 'Fotografer jalanan Makassar 📸',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    avatarInitials: 'MB',
    avatarColor: const Color(0xFF43E97B),
    role: 'user',
    followers: ['1'],
    following: ['1', '2'],
    savedPosts: [],
    joinedAt: DateTime(2024, 3, 20),
  ),
  UserModel(
    id: '4',
    username: 'fitri_dewi',
    displayName: 'Fitri Dewi',
    email: 'fitri@email.com',
    password: '123456',
    bio: 'Traveler | Wisata Sulawesi 🏝️',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
    avatarInitials: 'FD',
    avatarColor: const Color(0xFFF093FB),
    role: 'user',
    followers: ['1', '2'],
    following: ['3'],
    savedPosts: ['p3'],
    joinedAt: DateTime(2024, 4, 1),
  ),
  UserModel(
    id: '5',
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
    following: ['1'],
    savedPosts: [],
    joinedAt: DateTime(2024, 5, 15),
  ),
  UserModel(
    id: '7',
    username: 'dian_p',
    displayName: 'Dian Putri',
    email: 'dian@email.com',
    password: '123456',
    bio: 'Mahasiswi UNHAS | Suka nulis ✍️',
    avatarUrl: 'https://i.pravatar.cc/150?img=10',
    avatarInitials: 'DP',
    avatarColor: const Color(0xFFFF8E53),
    role: 'user',
    followers: ['1', '3'],
    following: ['2', '4'],
    savedPosts: [],
    joinedAt: DateTime(2024, 6, 1),
  ),
  UserModel(
    id: '8',
    username: 'budi_s',
    displayName: 'Budi Santoso',
    email: 'budi@email.com',
    password: '123456',
    bio: 'Musik & seni rupa 🎨🎵',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    avatarInitials: 'BS',
    avatarColor: const Color(0xFF38F9D7),
    role: 'user',
    followers: ['2'],
    following: ['1', '5'],
    savedPosts: ['p1'],
    joinedAt: DateTime(2024, 7, 10),
  ),
  UserModel(
    id: '6',
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
    userId: '1',
    imageUrl: 'https://picsum.photos/seed/sunset-losari/600/400',
    caption:
        'Sunset di Pantai Losari selalu bikin kagum. Golden hour yang sempurna! ✨ #SunsetLosari #Makassar #GoldenHour',
    likes: ['2', '3', '4', '5'],
    tags: ['SunsetLosari', 'Makassar', 'GoldenHour'],
    location: 'Pantai Losari, Makassar',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  PostModel(
    id: 'p2',
    userId: '2',
    imageUrl: 'https://picsum.photos/seed/coto-makassar/600/400',
    caption:
        'Coto Makassar terenak yang pernah aku coba! Wajib kesini kalau mampir ke Gowa 🍲 #KulinerMakassar #CotoMakassar',
    likes: ['1', '3'],
    tags: ['KulinerMakassar', 'CotoMakassar'],
    location: 'Warung Coto Nusantara, Gowa',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  PostModel(
    id: 'p3',
    userId: '3',
    imageUrl: 'https://picsum.photos/seed/street-makassar/600/400',
    caption:
        'Sudut kota Makassar yang penuh cerita 📸 #FotografiJalanan #Makassar',
    likes: ['1', '4'],
    tags: ['FotografiJalanan', 'Makassar'],
    location: 'Jl. Somba Opu, Makassar',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  PostModel(
    id: 'p4',
    userId: '4',
    imageUrl: 'https://picsum.photos/seed/island-samalona/600/400',
    caption:
        'Pulau Samalona, surga tersembunyi di Makassar 🏝️ Air jernih banget! #WisataMakassar #PulauSamalona #TravelSulsel',
    likes: ['1', '2', '3', '5'],
    tags: ['WisataMakassar', 'PulauSamalona', 'TravelSulsel'],
    location: 'Pulau Samalona, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  PostModel(
    id: 'p5',
    userId: '5',
    imageUrl: 'https://picsum.photos/seed/coffee-toraja/600/400',
    caption:
        'Weekend vibes ☕ Kopi toraja favorit di cafe langganan. #KopiToraja #CafeVibes #Makassar',
    likes: ['2'],
    tags: ['KopiToraja', 'CafeVibes', 'Makassar'],
    location: 'Kopi Kulo, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  PostModel(
    id: 'p6',
    userId: '1',
    imageUrl: 'https://picsum.photos/seed/fort-rotterdam/600/400',
    caption:
        'Fort Rotterdam, saksi sejarah kota Makassar 🏛️ Arsitekturnya luar biasa! #FortRotterdam #SejarahMakassar',
    likes: ['2', '3', '7'],
    tags: ['FortRotterdam', 'SejarahMakassar'],
    location: 'Fort Rotterdam, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  PostModel(
    id: 'p7',
    userId: '7',
    imageUrl: 'https://picsum.photos/seed/campus-unhas/600/400',
    caption:
        'Hari pertama semester baru di UNHAS! Semangat teman-teman 📚✨ #UNHAS #KampusLife #Makassar',
    likes: ['1', '3', '4'],
    tags: ['UNHAS', 'KampusLife', 'Makassar'],
    location: 'Universitas Hasanuddin',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
  ),
  PostModel(
    id: 'p8',
    userId: '8',
    imageUrl: 'https://picsum.photos/seed/mural-art/600/400',
    caption:
        'Mural baru di lorong wisata Makassar 🎨 Seni jalanan yang keren! #MuralMakassar #StreetArt',
    likes: ['2', '7'],
    tags: ['MuralMakassar', 'StreetArt'],
    location: 'Lorong Wisata, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  PostModel(
    id: 'p9',
    userId: '2',
    imageUrl: 'https://picsum.photos/seed/pisang-epe/600/400',
    caption:
        'Pisang Epe di pinggir pantai Losari 🍌🔥 Jajanan khas Makassar yang nggak pernah bosen! #PisangEpe #JajananMakassar',
    likes: ['1', '4', '5', '8'],
    tags: ['PisangEpe', 'JajananMakassar'],
    location: 'Pantai Losari, Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 8)),
  ),
  PostModel(
    id: 'p10',
    userId: '3',
    imageUrl: 'https://picsum.photos/seed/masjid-makassar/600/400',
    caption:
        'Masjid Raya Makassar di malam hari, megah dan indah 🕌✨ #MasjidRaya #Makassar #NightPhotography',
    likes: ['1', '2', '5', '7', '8'],
    tags: ['MasjidRaya', 'Makassar', 'NightPhotography'],
    location: 'Masjid Raya Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  PostModel(
    id: 'p11',
    userId: '4',
    imageUrl: 'https://picsum.photos/seed/tana-toraja/600/400',
    caption:
        'Weekend trip ke Tana Toraja! Budaya yang sangat kaya dan pemandangan luar biasa 🏔️ #TanaToraja #WisataSulsel',
    likes: ['1', '2', '3'],
    tags: ['TanaToraja', 'WisataSulsel'],
    location: 'Tana Toraja, Sulawesi Selatan',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  PostModel(
    id: 'p12',
    userId: '5',
    imageUrl: 'https://picsum.photos/seed/coding-night/600/400',
    caption:
        'Coding marathon sampai subuh 💻🌙 Side project baru yang excited banget! #Coding #DevLife #NightOwl',
    likes: ['8'],
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
    userId: '2',
    text: 'Keren banget! Kapan-kapan mau kesana juga 😍',
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  ),
  CommentModel(
    id: 'c2',
    postId: 'p1',
    userId: '3',
    text: 'Fotonya bagus! Pakai kamera apa?',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  CommentModel(
    id: 'c3',
    postId: 'p1',
    userId: '4',
    text: 'Bagus sekali! Losari memang selalu hits!',
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
  // Post 2 — Coto Makassar
  CommentModel(
    id: 'c4',
    postId: 'p2',
    userId: '1',
    text: 'Coto Makassar emang juara! 🍜',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  CommentModel(
    id: 'c5',
    postId: 'p2',
    userId: '4',
    text: 'Share alamatnya dong kak!',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  CommentModel(
    id: 'c6',
    postId: 'p2',
    userId: '5',
    text: 'Wah jadi lapar 🤤',
    createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
  ),
  // Post 3 — Fotografi Jalanan
  CommentModel(
    id: 'c7',
    postId: 'p3',
    userId: '1',
    text: 'Angle-nya keren bro! Ajakin kapan-kapan 📸',
    createdAt: DateTime.now().subtract(const Duration(hours: 7)),
  ),
  CommentModel(
    id: 'c8',
    postId: 'p3',
    userId: '7',
    text: 'Somba Opu memang pusat sejarah ya',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  // Post 4 — Pulau Samalona
  CommentModel(
    id: 'c9',
    postId: 'p4',
    userId: '1',
    text: 'Mau kesana juga! Biaya berapa kak?',
    createdAt: DateTime.now().subtract(const Duration(hours: 20)),
  ),
  CommentModel(
    id: 'c10',
    postId: 'p4',
    userId: '2',
    text: 'Snorkeling-nya seru banget pasti! 🐠',
    createdAt: DateTime.now().subtract(const Duration(hours: 18)),
  ),
  CommentModel(
    id: 'c11',
    postId: 'p4',
    userId: '3',
    text: 'Airnya bening banget, kapan lagi bisa kesana',
    createdAt: DateTime.now().subtract(const Duration(hours: 16)),
  ),
  // Post 5 — Coffee
  CommentModel(
    id: 'c12',
    postId: 'p5',
    userId: '1',
    text: 'Kopi Toraja yang terbaik ☕👌',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
  ),
  // Post 6 — Fort Rotterdam
  CommentModel(
    id: 'c13',
    postId: 'p6',
    userId: '3',
    text: 'Tempat favorit buat hunting foto!',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 20)),
  ),
  CommentModel(
    id: 'c14',
    postId: 'p6',
    userId: '7',
    text: 'Sejarah Indonesia yang harus dijaga 🇮🇩',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 18)),
  ),
  // Post 7 — UNHAS
  CommentModel(
    id: 'c15',
    postId: 'p7',
    userId: '1',
    text: 'Semangat kuliahnya! 💪',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
  ),
  // Post 9 — Pisang Epe
  CommentModel(
    id: 'c16',
    postId: 'p9',
    userId: '1',
    text: 'Pisang epe + susu keju = combo terbaik! 🤤',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
  ),
  CommentModel(
    id: 'c17',
    postId: 'p9',
    userId: '5',
    text: 'Mantap sih ini, jadi kangen Makassar',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
  ),
  // Post 10 — Masjid Raya
  CommentModel(
    id: 'c18',
    postId: 'p10',
    userId: '4',
    text: 'Subhanallah, cantik banget 🕌',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 20)),
  ),
  CommentModel(
    id: 'c19',
    postId: 'p10',
    userId: '8',
    text: 'Skill fotonya makin keren aja',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 18)),
  ),
  // Post 11 — Tana Toraja
  CommentModel(
    id: 'c20',
    postId: 'p11',
    userId: '7',
    text: 'Bucket list aku ini! Cerita lengkapnya dong kak',
    createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 20)),
  ),
];

// ══════════════════════════════════════
//  DATA DUMMY — DM CONVERSATIONS
// ══════════════════════════════════════

final List<DmConversation> dummyConversations = [
  DmConversation(
    id: '1_2',
    participantIds: ['1', '2'],
    messages: [
      DmMessageModel(
        id: 'dm1',
        fromUserId: '2',
        toUserId: '1',
        text: 'Hei! Sunset di Losari kemarin keren banget 😍',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      DmMessageModel(
        id: 'dm2',
        fromUserId: '1',
        toUserId: '2',
        text: 'Makasih! Datang aja sendiri, tiap sore bagus',
        isRead: true,
        createdAt:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 50)),
      ),
      DmMessageModel(
        id: 'dm3',
        fromUserId: '2',
        toUserId: '1',
        text: 'Oke siap! Btw resep coto-nya mau dishare ga? 🍲',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ],
  ),
  DmConversation(
    id: '1_3',
    participantIds: ['1', '3'],
    messages: [
      DmMessageModel(
        id: 'dm4',
        fromUserId: '3',
        toUserId: '1',
        text: 'Bro, mau minta tips foto sunset dong 📸',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DmMessageModel(
        id: 'dm5',
        fromUserId: '1',
        toUserId: '3',
        text: 'Pakai golden hour jam 5-6 sore, settingan manual ISO 100',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 23)),
      ),
    ],
  ),
  DmConversation(
    id: '1_4',
    participantIds: ['1', '4'],
    messages: [
      DmMessageModel(
        id: 'dm6',
        fromUserId: '4',
        toUserId: '1',
        text: 'Kapan ke Pulau Samalona lagi? Ikut dong!',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  ),
  DmConversation(
    id: '1_5',
    participantIds: ['1', '5'],
    messages: [
      DmMessageModel(
        id: 'dm7',
        fromUserId: '1',
        toUserId: '5',
        text: 'Reza, café kopi toraja-nya di mana tuh?',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DmMessageModel(
        id: 'dm8',
        fromUserId: '5',
        toUserId: '1',
        text: 'Kopi Kulo, Jl. AP Pettarani. Recommended banget ☕',
        isRead: true,
        createdAt:
            DateTime.now().subtract(const Duration(days: 1, hours: 22)),
      ),
    ],
  ),
];

/// Fungsi helper untuk sinkronisasi profile user backend ke cache dummyUsers lokal
void upsertUserFromBackend(Map<String, dynamic> json, {String Function(String?)? resolveUrl}) {
  final id = json['id'].toString();
  final username = json['username'] as String? ?? '';
  final displayName = json['display_name'] as String? ?? json['username'] as String? ?? '';
  
  String resolvedAvatar = '';
  if (resolveUrl != null) {
    resolvedAvatar = resolveUrl(json['avatar_url'] as String?);
  } else {
    final avatar = json['avatar_url'] as String? ?? '';
    if (avatar.startsWith('http') || avatar.isEmpty) {
      resolvedAvatar = avatar;
    } else {
      resolvedAvatar = 'http://192.168.1.5:5000/$avatar';
    }
  }

  var initials = '';
  if (displayName.isNotEmpty) {
    final parts = displayName.trim().split(' ');
    initials = parts.map((e) => e.trim().isEmpty ? '' : e.trim()[0]).join();
    if (initials.length > 2) {
      initials = initials.substring(0, 2);
    }
    initials = initials.toUpperCase();
  }
  if (initials.isEmpty) initials = 'U';

  final existingIndex = dummyUsers.indexWhere((u) => u.id == id);
  
  final colors = [
    const Color(0xFFFF6B9D),
    const Color(0xFF4F9EFF),
    const Color(0xFF43E97B),
    const Color(0xFFFFB85C),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];
  final color = colors[id.hashCode % colors.length];

  // Parse followers/following jika ada
  final followingIds = <String>[];
  if (json['following'] is List) {
    for (final f in json['following']) {
      if (f is Map && f['following_id'] != null) {
        followingIds.add(f['following_id'].toString());
      } else if (f is Map && f['id'] != null) {
        followingIds.add(f['id'].toString());
      } else {
        followingIds.add(f.toString());
      }
    }
  }
  final followerIds = <String>[];
  if (json['followers'] is List) {
    for (final f in json['followers']) {
      if (f is Map && f['follower_id'] != null) {
        followerIds.add(f['follower_id'].toString());
      } else if (f is Map && f['id'] != null) {
        followerIds.add(f['id'].toString());
      } else {
        followerIds.add(f.toString());
      }
    }
  }

  final user = UserModel(
    id: id,
    username: username,
    displayName: displayName,
    email: json['email'] as String? ?? '$username@email.com',
    password: '',
    avatarUrl: resolvedAvatar,
    avatarInitials: initials,
    avatarColor: color,
    bio: json['bio'] as String? ?? '',
    role: json['role'] as String? ?? 'user',
    following: followingIds,
    followers: followerIds,
  );

  if (existingIndex != -1) {
    final existing = dummyUsers[existingIndex];
    dummyUsers[existingIndex] = existing.copyWith(
      username: username,
      displayName: displayName,
      avatarUrl: resolvedAvatar,
      avatarInitials: initials,
      bio: user.bio.isNotEmpty ? user.bio : existing.bio,
      role: user.role,
      following: followingIds.isNotEmpty ? followingIds : existing.following,
      followers: followerIds.isNotEmpty ? followerIds : existing.followers,
    );
  } else {
    dummyUsers.add(user);
  }
}
