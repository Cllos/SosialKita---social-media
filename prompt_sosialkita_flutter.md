# PROMPT LENGKAP — SosialKita Flutter App (Fitur Sementara + Data Dummy)

---

## KONTEKS & TUJUAN

Kamu adalah developer Flutter senior. Buatkan aplikasi **SosialKita** — sebuah Social Media Platform — menggunakan Flutter yang dapat berjalan di **mobile, desktop, dan web** (minimal 2 platform).

Aplikasi ini masih dalam tahap awal (fitur sementara), sehingga **seluruh data menggunakan data dummy in-memory** (tidak ada backend nyata, tidak ada database eksternal). Semua state dikelola secara lokal menggunakan Flutter state management.

Referensi desain visual mengacu pada file `sosialkita_ui.html` yang telah disediakan. Gunakan sebagai panduan warna, layout, dan komponen UI.

---

## IDENTITAS APLIKASI

| Properti | Value |
|---|---|
| Nama Aplikasi | SosialKita |
| Tema | Social Media Platform |
| Target Platform | Mobile (Android/iOS), Desktop (Windows/macOS), Web |
| Bahasa | Indonesia |
| State Management | Provider atau GetX |
| Data | Dummy in-memory (tidak ada backend) |

---

## DESIGN SYSTEM (wajib diikuti)

Ambil dari referensi `sosialkita_ui.html`:

```dart
// Palet warna utama SosialKita
const Color skRose     = Color(0xFFF43F5E);
const Color skViolet   = Color(0xFF8B5CF6);
const Color skOrange   = Color(0xFFFB923C);
const Color skDark     = Color(0xFF0F0A1A);
const Color skDark2    = Color(0xFF1A1028);
const Color skCard     = Color(0xFF22163A);
const Color skMuted    = Color(0xFF6B5F82);
const Color skWhite    = Color(0xFFFAF8FF);
const Color skBorder   = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

// Gradient utama
const LinearGradient skGradient = LinearGradient(
  colors: [skRose, skViolet],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient skGradientBtn = LinearGradient(
  colors: [skRose, skViolet],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
```

**Ketentuan UI:**
- Background utama: `#0F0A1A`
- Card background: `#22163A`
- Border: `rgba(255,255,255,0.08)`
- Teks utama: `#FAF8FF`
- Teks muted: `#6B5F82`
- Tombol utama: gradient rose → violet
- Border radius card: 14px, tombol: 12–14px, avatar: circular
- Font: gunakan `Google Fonts` → `Syne` (heading/logo) + `DM Sans` (body)

---

## STRUKTUR FOLDER

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp + routing + theme
│   └── routes.dart                 # Named routes
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # Semua konstanta warna
│   │   ├── app_text_styles.dart    # TextStyle standar
│   │   └── app_theme.dart          # ThemeData dark
│   └── utils/
│       ├── dummy_data.dart         # Semua data dummy
│       └── responsive_layout.dart  # Helper mobile/tablet/desktop
├── models/
│   ├── user_model.dart
│   ├── post_model.dart
│   └── comment_model.dart
├── providers/
│   ├── auth_provider.dart          # currentUser, login, logout, register
│   ├── post_provider.dart          # feed, like, save, upload
│   ├── user_provider.dart          # follow, unfollow, search users
│   ├── comment_provider.dart       # komentar per post
│   └── chat_provider.dart          # DM conversations, send, read
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart        # Wrapper responsive
│   │   ├── mobile_home.dart        # Bottom nav layout
│   │   └── desktop_home.dart       # Sidebar layout
│   ├── feed/
│   │   └── feed_screen.dart        # Daftar postingan
│   ├── post/
│   │   ├── create_post_screen.dart # Upload gambar + caption
│   │   └── post_detail_screen.dart # Detail post + komentar
│   ├── search/
│   │   └── search_screen.dart      # Explore grid + search user/post
│   ├── chat/
│   │   ├── chat_list_screen.dart   # Daftar percakapan DM
│   │   └── chat_detail_screen.dart # Percakapan 1-on-1
│   ├── profile/
│   │   ├── profile_screen.dart     # Profil sendiri
│   │   └── other_profile_screen.dart # Profil user lain
│   ├── saved/
│   │   └── saved_screen.dart       # Postingan tersimpan
│   └── moderator/
│       └── moderator_dashboard.dart # Khusus role Moderator
└── widgets/
    ├── common/
    │   ├── sk_button.dart          # Tombol gradient utama
    │   ├── sk_text_field.dart      # Input field dark style
    │   ├── sk_avatar.dart          # Avatar dengan gradient ring
    │   ├── sk_gradient_text.dart   # Teks gradient rose→violet
    │   └── loading_indicator.dart
    ├── post/
    │   ├── post_card.dart          # Card postingan di feed
    │   └── post_image.dart         # Gambar postingan
    ├── story/
    │   └── story_row.dart          # Baris story di home
    └── layout/
        ├── desktop_sidebar.dart
        └── desktop_right_panel.dart
```

---

## MODELS

### `user_model.dart`
```dart
class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String password;       // plain text (dummy only)
  final String bio;
  final String avatarUrl;      // asset atau network dummy
  final String avatarInitials; // fallback "AY"
  final Color avatarColor;     // warna avatar
  final String role;           // 'user' | 'moderator'
  final List<String> followers; // list of user IDs
  final List<String> following; // list of user IDs
  final List<String> savedPosts;// list of post IDs
  final DateTime joinedAt;
}
```

### `post_model.dart`
```dart
class PostModel {
  final String id;
  final String userId;
  final String imageUrl;       // network dummy image URL
  final String caption;
  final List<String> likes;    // list of user IDs
  final List<String> tags;     // hashtags
  final String location;
  final DateTime createdAt;
}
```

### `comment_model.dart`
```dart
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;
}
```

### `dm_message_model.dart` *(baru)*
```dart
class DmMessageModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String text;
  final bool isRead;
  final DateTime createdAt;
}

class DmConversation {
  final String id;               // gabungan userId dua pihak, misal "u1_u2"
  final List<String> participantIds;
  final List<DmMessageModel> messages;
  DateTime get lastMessageTime => messages.isNotEmpty
      ? messages.last.createdAt
      : DateTime(2024);
  DmMessageModel? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;
  int unreadCount(String myId) =>
      messages.where((m) => m.toUserId == myId && !m.isRead).length;
}
```

---

## DATA DUMMY

Buat file `lib/core/utils/dummy_data.dart` dengan isi berikut:

### Users (minimal 8 user)
```dart
// Gunakan network images dari https://i.pravatar.cc/150?img=N
// untuk foto profil dummy

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
    avatarColor: Color(0xFFFF6B9D),
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
    avatarColor: Color(0xFF4F9EFF),
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
    avatarColor: Color(0xFF43E97B),
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
    avatarColor: Color(0xFFF093FB),
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
    avatarColor: Color(0xFF43E97B),
    role: 'user',
    followers: [],
    following: ['u1'],
    savedPosts: [],
    joinedAt: DateTime(2024, 5, 15),
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
    avatarColor: Color(0xFFF43F5E),
    role: 'moderator',
    followers: [],
    following: [],
    savedPosts: [],
    joinedAt: DateTime(2024, 1, 1),
  ),
  // Tambah 2 user lagi sesuai kebutuhan
];
```

### Posts (minimal 10 post)
```dart
// Gunakan network images dari:
// https://picsum.photos/seed/{keyword}/600/400
// untuk gambar postingan dummy

final List<PostModel> dummyPosts = [
  PostModel(
    id: 'p1',
    userId: 'u1',
    imageUrl: 'https://picsum.photos/seed/sunset/600/400',
    caption: 'Sunset di Pantai Losari selalu bikin kagum. Golden hour yang sempurna! ✨',
    likes: ['u2', 'u3', 'u4', 'u5'],
    tags: ['SunsetLosari', 'Makassar', 'GoldenHour'],
    location: 'Pantai Losari, Makassar',
    createdAt: DateTime.now().subtract(Duration(hours: 2)),
  ),
  PostModel(
    id: 'p2',
    userId: 'u2',
    imageUrl: 'https://picsum.photos/seed/food/600/400',
    caption: 'Coto Makassar terenak yang pernah aku coba! Wajib kesini 🍲',
    likes: ['u1', 'u3'],
    tags: ['KulinerMakassar', 'CotoMakassar'],
    location: 'Warung Coto Nusantara, Gowa',
    createdAt: DateTime.now().subtract(Duration(hours: 5)),
  ),
  PostModel(
    id: 'p3',
    userId: 'u3',
    imageUrl: 'https://picsum.photos/seed/street/600/400',
    caption: 'Sudut kota Makassar yang penuh cerita 📸',
    likes: ['u1', 'u4'],
    tags: ['FotografiJalanan', 'Makassar'],
    location: 'Jl. Somba Opu, Makassar',
    createdAt: DateTime.now().subtract(Duration(hours: 8)),
  ),
  PostModel(
    id: 'p4',
    userId: 'u4',
    imageUrl: 'https://picsum.photos/seed/island/600/400',
    caption: 'Pulau Samalona, surga tersembunyi di Makassar 🏝️ Air jernih banget!',
    likes: ['u1', 'u2', 'u3', 'u5'],
    tags: ['WisataMakassar', 'PulauSamalona', 'TravelSulsel'],
    location: 'Pulau Samalona, Makassar',
    createdAt: DateTime.now().subtract(Duration(days: 1)),
  ),
  PostModel(
    id: 'p5',
    userId: 'u5',
    imageUrl: 'https://picsum.photos/seed/coffee/600/400',
    caption: 'Weekend vibes ☕ Kopi toraja favorit di cafe langganan.',
    likes: ['u2'],
    tags: ['KopiToraja', 'CafeVibes', 'Makassar'],
    location: 'Kopi Kulo, Makassar',
    createdAt: DateTime.now().subtract(Duration(days: 1, hours: 3)),
  ),
  // Tambah 5 post lagi dari user berbeda
];
```

### Comments (minimal 15 komentar)
```dart
final List<CommentModel> dummyComments = [
  CommentModel(
    id: 'c1', postId: 'p1', userId: 'u2',
    text: 'Keren banget! Kapan-kapan mau kesana juga 😍',
    createdAt: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
  ),
  CommentModel(
    id: 'c2', postId: 'p1', userId: 'u3',
    text: 'Fotonya bagus! Pakai kamera apa?',
    createdAt: DateTime.now().subtract(Duration(hours: 1)),
  ),
  CommentModel(
    id: 'c3', postId: 'p1', userId: 'u4',
    text: '🔥🔥 Losari memang selalu hits!',
    createdAt: DateTime.now().subtract(Duration(minutes: 45)),
  ),
  CommentModel(
    id: 'c4', postId: 'p2', userId: 'u1',
    text: 'Coto Makassar emang juara! 🍜',
    createdAt: DateTime.now().subtract(Duration(hours: 4)),
  ),
  CommentModel(
    id: 'c5', postId: 'p2', userId: 'u4',
    text: 'Share alamatnya dong kak!',
    createdAt: DateTime.now().subtract(Duration(hours: 3)),
  ),
  // Tambah komentar lainnya...
];
```

### DM Conversations (minimal 4 percakapan)
```dart
final List<DmConversation> dummyConversations = [
  DmConversation(
    id: 'u1_u2',
    participantIds: ['u1', 'u2'],
    messages: [
      DmMessageModel(id: 'dm1', fromUserId: 'u2', toUserId: 'u1',
          text: 'Hei! Sunset di Losari kemarin keren banget 😍',
          isRead: true, createdAt: DateTime.now().subtract(Duration(hours: 3))),
      DmMessageModel(id: 'dm2', fromUserId: 'u1', toUserId: 'u2',
          text: 'Makasih! Datang aja sendiri, tiap sore bagus',
          isRead: true, createdAt: DateTime.now().subtract(Duration(hours: 2, minutes: 50))),
      DmMessageModel(id: 'dm3', fromUserId: 'u2', toUserId: 'u1',
          text: 'Oke siap! Btw resep coto-nya mau dishare ga? 🍲',
          isRead: false, createdAt: DateTime.now().subtract(Duration(minutes: 20))),
    ],
  ),
  DmConversation(
    id: 'u1_u3',
    participantIds: ['u1', 'u3'],
    messages: [
      DmMessageModel(id: 'dm4', fromUserId: 'u3', toUserId: 'u1',
          text: 'Bro, mau minta tips foto sunset dong 📸',
          isRead: true, createdAt: DateTime.now().subtract(Duration(days: 1))),
      DmMessageModel(id: 'dm5', fromUserId: 'u1', toUserId: 'u3',
          text: 'Pakai golden hour jam 5-6 sore, settingan manual ISO 100',
          isRead: true, createdAt: DateTime.now().subtract(Duration(hours: 23))),
    ],
  ),
  DmConversation(
    id: 'u1_u4',
    participantIds: ['u1', 'u4'],
    messages: [
      DmMessageModel(id: 'dm6', fromUserId: 'u4', toUserId: 'u1',
          text: 'Kapan ke Pulau Samalona lagi? Ikut dong!',
          isRead: false, createdAt: DateTime.now().subtract(Duration(minutes: 5))),
    ],
  ),
  DmConversation(
    id: 'u1_u5',
    participantIds: ['u1', 'u5'],
    messages: [
      DmMessageModel(id: 'dm7', fromUserId: 'u1', toUserId: 'u5',
          text: 'Reza, café kopi toraja-nya di mana tuh?',
          isRead: true, createdAt: DateTime.now().subtract(Duration(days: 2))),
      DmMessageModel(id: 'dm8', fromUserId: 'u5', toUserId: 'u1',
          text: 'Kopi Kulo, Jl. AP Pettarani. Recommended banget ☕',
          isRead: true, createdAt: DateTime.now().subtract(Duration(days: 1, hours: 22))),
    ],
  ),
];
```

---

## FITUR YANG HARUS DIIMPLEMENTASI

### 1. REGISTER & LOGIN

**Login Screen:**
- Input email/username dan password (dengan validasi tidak boleh kosong)
- Tombol "Masuk" dengan gradient rose→violet
- Link "Lupa password?" (tampilkan SnackBar: "Fitur belum tersedia")
- Login dengan Google (tampilkan SnackBar: "Login Google segera hadir")
- Link ke halaman Register
- Logika: cocokkan email+password dengan `dummyUsers`, simpan ke `AuthProvider`
- Jika role = 'moderator' → redirect ke `ModeratorDashboard`
- Jika role = 'user' → redirect ke `HomeScreen`

**Register Screen:**
- Input: nama lengkap, username, email, password, konfirmasi password
- Validasi: semua field wajib diisi, email format valid, password min 6 karakter, konfirmasi cocok
- Setelah register → tambahkan user baru ke list dummy → auto login → redirect ke Home
- Tampilkan error inline jika validasi gagal

**AuthProvider:**
```dart
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isModerator => _currentUser?.role == 'moderator';

  Future<bool> login(String email, String password) async { ... }
  Future<bool> register(String displayName, String username, String email, String password) async { ... }
  void logout() { ... }
  void updateProfile(UserModel updated) { ... }
}
```

---

### 2. HOME FEED

**Layout Responsif:**
```dart
// responsive_layout.dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) return mobile;
      if (constraints.maxWidth < 1024) return tablet;
      return desktop;
    });
  }
}
```

**Mobile Layout:** `BottomNavigationBar` dengan 5 tab:
- Home (feed), Search/Explore, Buat Post (+), Chat/DM, Profil

**Desktop Layout:** Sidebar kiri (navigasi) + konten tengah (feed) + panel kanan (saran follow, trending tag)

**Feed:**
- Tampilkan stories row di atas (avatar pengguna yang diikuti)
- Tampilkan postingan dari user yang diikuti + postingan sendiri, urut terbaru
- Jika belum follow siapapun, tampilkan semua post sebagai rekomendasi
- Gunakan `ListView.builder` dengan `PostCard` widget

---

### 3. POST CARD WIDGET

Setiap `PostCard` menampilkan:
```
[Avatar + Username + Lokasi]           [... menu]
[Gambar Postingan]
[Caption dengan hashtag berwarna violet]
[❤️ Like  💬 Komentar  ✈️ Share]    [🔖 Simpan]
```

- Tap gambar 2x → toggle like dengan animasi heart pop
- Tap ❤️ → toggle like
- Tap 💬 → navigasi ke `PostDetailScreen`
- Tap 🔖 → toggle simpan
- Tap avatar/username → navigasi ke `ProfileScreen` atau `OtherProfileScreen`
- Tampilkan jumlah like dan komentar
- Format waktu: "2 jam lalu", "1 hari lalu" (bukan timestamp)

---

### 4. CREATE POST (Upload Gambar + Caption)

**CreatePostScreen:**
- Pilih gambar dari galeri menggunakan package `image_picker`
  - Jika platform tidak support (web limitation) → tampilkan field URL gambar sebagai fallback
- Input caption (multiline, max 500 karakter, tampilkan counter)
- Input lokasi (opsional)
- Input hashtag (opsional, parse otomatis dari caption jika ada #)
- Preview gambar sebelum post
- Tombol "Bagikan" → tambahkan `PostModel` baru ke list dummy
- Validasi: gambar wajib ada, caption tidak boleh kosong

---

### 5. LIKE

- Di `PostProvider`: method `toggleLike(String postId, String userId)`
- Toggle: jika userId sudah ada di `post.likes` → hapus (unlike), jika belum → tambah (like)
- Update UI secara reaktif
- Tampilkan animasi: scale + opacity pada icon heart saat di-tap

---

### 6. KOMENTAR

**PostDetailScreen:**
- Tampilkan gambar post + caption di atas
- `ListView` komentar dengan avatar, username, teks, dan waktu
- Input komentar di bawah (dengan keyboard-aware scroll)
- Tombol kirim → tambahkan `CommentModel` baru ke list dummy
- Validasi: komentar tidak boleh kosong

---

### 7. FOLLOW / UNFOLLOW

**Di ProfileScreen (profil user lain):**
- Tombol "Follow" / "Unfollow" → toggle di `UserProvider`
- Update jumlah followers dan following secara reaktif
- Method: `toggleFollow(String currentUserId, String targetUserId)`
- Di feed, tampilkan badge "Mengikuti" di bawah username jika difollow

---

### 8. PROFIL PENGGUNA

**ProfileScreen (profil sendiri):**
- Header: foto profil, nama, username, bio, jumlah post/followers/following
- Tab: Postingan | Tersimpan
- Grid postingan 3 kolom (thumbnail)
- Tombol "Edit Profil" → bottom sheet / dialog untuk ubah nama, bio
- Role badge: tampilkan chip "Moderator 🛡️" jika role = moderator

**OtherProfileScreen (profil user lain):**
- Sama seperti di atas, tapi tanpa tab Tersimpan
- Tombol Follow/Unfollow
- Jika sudah follow → tombol "Unfollow" dengan style secondary

---

### 9. SEARCH / EXPLORE (tampilan grid ala TikTok/Instagram Explore)

**SearchScreen — dua mode tampilan:**

**Mode Default (belum mengetik) = Explore Grid:**
- SearchBar di paling atas dengan hint "Cari pengguna, postingan, tagar..."
- Di bawah search bar: **grid 3 kolom** berisi thumbnail semua postingan dari `dummyPosts`
- Setiap thumbnail berukuran sama (aspek rasio 1:1, atau bervariasi seperti Pinterest — 1 item besar di kolom kiri, 2 item kecil di kolom kanan, bergantian)
- Di pojok kanan bawah thumbnail: tampilkan ikon ▶️ jika ada video (untuk versi dummy cukup tampilkan ikon play di atas gambar)
- Tap thumbnail → navigasi ke `PostDetailScreen`
- Grid menggunakan `GridView.builder` dengan `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2)`
- Tidak ada label/teks di bawah thumbnail, murni visual seperti referensi gambar 2

**Mode Aktif (sedang mengetik) = Hasil Pencarian:**
- Tampilan berubah dari grid → list hasil pencarian
- Tampilkan 2 tab: **Pengguna** | **Postingan**
- Tab Pengguna: list avatar + username + displayName + tombol Follow/Unfollow
- Tab Postingan: list mini card (thumbnail kecil + caption + username)
- Filter real-time: cari berdasarkan username / displayName / caption / hashtag (case-insensitive)
- Tap hasil user → navigasi ke `OtherProfileScreen`
- Tap hasil post → navigasi ke `PostDetailScreen`
- Jika tidak ada hasil → ilustrasi kosong + teks "Tidak ada hasil untuk '...'"
- Tap X di search bar → kembali ke mode Explore Grid

**Transisi antar mode:**
```dart
// Gunakan AnimatedSwitcher untuk transisi halus antara grid dan list
AnimatedSwitcher(
  duration: Duration(milliseconds: 250),
  child: _isSearching ? _buildSearchResults() : _buildExploreGrid(),
)
```

---

### 10. CHAT / DIRECT MESSAGE (DM)

**ChatListScreen (daftar percakapan):**
- AppBar: judul "Pesan" + ikon pensil (buat DM baru)
- List percakapan diurut dari yang paling baru
- Setiap item percakapan menampilkan:
  - Avatar lawan bicara (dengan gradient ring jika ada pesan belum dibaca)
  - Nama + username lawan bicara
  - Preview pesan terakhir (truncate jika panjang)
  - Waktu pesan terakhir (format: "5 mnt", "2 jam", "Kemarin")
  - Badge bulat merah dengan angka jika ada pesan belum dibaca (`unreadCount > 0`)
- Tap item → navigasi ke `ChatDetailScreen`
- Ikon pensil di AppBar → tampilkan bottom sheet daftar user yang bisa di-DM (dari following list)
- Jika belum ada percakapan → tampilkan ilustrasi kosong + "Belum ada pesan"

**ChatDetailScreen (percakapan 1-on-1):**
- AppBar: avatar + nama lawan bicara (tap → OtherProfileScreen)
- `ListView` bubble chat dari atas ke bawah, scroll ke pesan terbaru otomatis
- Bubble pesan sendiri (kanan, warna rose/violet), bubble lawan bicara (kiri, warna card)
- Format waktu di bawah setiap bubble: "14:32"
- Input field di bawah: text field + tombol kirim (gradient)
- Kirim pesan → tambahkan `DmMessageModel` baru ke `DmConversation` di `ChatProvider`
- Semua pesan dari lawan bicara otomatis ditandai `isRead: true` saat buka screen ini
- Keyboard-aware: gunakan `resizeToAvoidBottomInset: true`

**ChatProvider:**
```dart
class ChatProvider extends ChangeNotifier {
  List<DmConversation> _conversations = List.from(dummyConversations);

  List<DmConversation> getConversationsForUser(String userId) {
    return _conversations
        .where((c) => c.participantIds.contains(userId))
        .toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  DmConversation? getConversation(String userId1, String userId2) { ... }

  void sendMessage(String fromId, String toId, String text) {
    // Cari atau buat conversation baru, tambahkan pesan
    notifyListeners();
  }

  void markAsRead(String conversationId, String myId) {
    // Set isRead = true untuk semua pesan dengan toUserId == myId
    notifyListeners();
  }

  int totalUnread(String myId) {
    return _conversations
        .fold(0, (sum, c) => sum + c.unreadCount(myId));
  }
}
```

**Badge unread di bottom nav:**
- Jika `totalUnread > 0` → tampilkan badge merah kecil di atas ikon Chat di bottom nav
- Gunakan `Stack` + `Positioned` untuk badge di atas icon

---

### 11. SIMPAN POSTINGAN

- Method `toggleSave(String postId, String userId)` di `PostProvider`
- Update `currentUser.savedPosts` di `AuthProvider`
- Di `SavedScreen`: tampilkan grid postingan yang disimpan
- Jika kosong → tampilkan ilustrasi + teks "Belum ada postingan tersimpan"

---

### 12. LOGOUT

- Tombol logout di ProfileScreen (pojok kanan atas atau di pengaturan)
- Tampilkan dialog konfirmasi: "Yakin ingin keluar?" + tombol Batal / Keluar
- Setelah konfirmasi: `AuthProvider.logout()` → clear state → redirect ke LoginScreen
- Gunakan `Navigator.pushAndRemoveUntil` agar tidak bisa back ke halaman dalam

---

### 13. ROLE: MODERATOR

**ModeratorDashboard** — layout web/desktop penuh dengan sidebar navigasi kiri. Hanya bisa diakses jika `currentUser.role == 'moderator'`. Referensi desain: lihat dashboard interaktif yang sudah dibuat.

**Layout struktur:**
```
[TopBar: Logo + badge MOD + tombol Keluar]
[Sidebar kiri 200px] | [Konten utama flex:1]
```

**Sidebar navigasi (NavigationRail atau Column):**
- Avatar + nama moderator + label "Moderator resmi"
- Menu: Dashboard, Pengguna, Postingan, Komentar, Chat/DM, Laporan, Pengaturan
- Item aktif: warna rose + border-left highlight

**5 halaman dalam ModeratorDashboard (gunakan IndexedStack atau PageView):**

**Halaman 1 — Dashboard:**
- 4 stat card horizontal: Total Pengguna, Total Postingan, Total Komentar, Total Percakapan DM
- Setiap card punya ikon berwarna, angka besar, label, dan tren singkat
- Tabel log aktivitas terbaru: kolom Waktu, Pengguna, Aksi (chip berwarna), Detail

**Halaman 2 — Kelola Pengguna (CRUD Lengkap):**
- Search bar filter real-time by username/nama/email
- Tabel kolom: Avatar+Nama, Email, Role (chip), Status (chip), Aksi
- Tombol "Tambah Pengguna" → Dialog/Modal form:
  - Field: Nama lengkap, Username, Email, Role (dropdown), Status (dropdown)
  - Validasi semua field wajib diisi
  - Simpan → tambah ke dummyUsers
- Tombol Edit per baris → isi form dengan data existing → update
- Tombol Hapus per baris → konfirmasi dialog → hapus dari dummyUsers
- Moderator tidak bisa dihapus (hide tombol hapus untuk role moderator)

**Halaman 3 — Kelola Postingan:**
- Search bar filter by caption/username
- Tabel kolom: Thumbnail emoji + caption, Username, Likes, Komentar, Aksi
- Tombol Hapus per baris → hapus dari dummyPosts

**Halaman 4 — Kelola Komentar:**
- Search bar filter by isi komentar/username
- Tabel kolom: Teks komentar + waktu, Username, Di postingan, Aksi
- Tombol Hapus per baris → hapus dari dummyComments

**Halaman 5 — Monitor Chat/DM:**
- List semua percakapan: avatar, "user_a → user_b", preview pesan terakhir, waktu, badge unread
- Tap item → tampilkan detail isi percakapan di bawah list
- Bubble chat: pesan kiri/kanan dibedakan warna
- Tombol "Hapus percakapan" untuk konten yang melanggar aturan

**Widget pendukung:**
```dart
// Stat card
class ModStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String delta;
  // ...
}

// Form dialog tambah/edit user
class UserFormDialog extends StatefulWidget { ... }

// Baris tabel dengan aksi
class ModTableRow extends StatelessWidget { ... }
```

**State management moderator:**
```dart
class ModeratorProvider extends ChangeNotifier {
  // Mirror dari provider utama tapi dengan akses penuh
  List<UserModel> get allUsers => List.from(dummyUsers);
  List<PostModel> get allPosts => List.from(dummyPosts);
  List<CommentModel> get allComments => List.from(dummyComments);
  List<DmConversation> get allConversations => List.from(dummyConversations);

  void deleteAnyPost(String postId) { ... notifyListeners(); }
  void deleteAnyComment(String commentId) { ... notifyListeners(); }
  void deleteAnyConversation(String conversationId) { ... notifyListeners(); }
  void addUser(UserModel user) { ... notifyListeners(); }
  void updateUser(UserModel user) { ... notifyListeners(); }
  void deleteUser(String userId) { ... notifyListeners(); }
  void toggleUserStatus(String userId) { ... notifyListeners(); }

  // Statistik realtime
  int get totalUsers => allUsers.length;
  int get totalPosts => allPosts.length;
  int get totalComments => allComments.length;
  int get totalConversations => allConversations.length;
}
```

---

## NAVIGASI & ROUTING

```dart
// routes.dart
class AppRoutes {
  static const splash       = '/';
  static const onboarding   = '/onboarding';
  static const login        = '/login';
  static const register     = '/register';
  static const home         = '/home';
  static const createPost   = '/create-post';
  static const postDetail   = '/post-detail';
  static const profile      = '/profile';
  static const otherProfile = '/other-profile';
  static const search       = '/search';
  static const saved        = '/saved';
  static const chatList     = '/chat';
  static const chatDetail   = '/chat-detail';
  static const moderator    = '/moderator';
}
```

**Alur navigasi:**
```
Splash (2 detik) 
  → [Pertama kali] Onboarding 
  → Login / Register 
  → [role: user]      HomeScreen
  → [role: moderator] ModeratorDashboard
```

Gunakan `SharedPreferences` untuk menyimpan apakah onboarding sudah pernah ditampilkan.

---

## PUBSPEC.YAML — DEPENDENCIES

```yaml
name: sosialkita
description: Social Media Platform — SosialKita

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.2
  
  # Google Fonts
  google_fonts: ^6.2.1
  
  # Image Picker (upload gambar)
  image_picker: ^1.1.2
  
  # Cached Network Image (gambar dummy dari internet)
  cached_network_image: ^3.3.1
  
  # Shared Preferences (simpan status onboarding)
  shared_preferences: ^2.2.3
  
  # Intl (format tanggal/waktu)
  intl: ^0.19.0
  
  # UUID (generate ID untuk data baru)
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

---

## APP THEME

```dart
// app_theme.dart
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0A1A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFF43F5E),
      secondary: Color(0xFF8B5CF6),
      surface: Color(0xFF1A1028),
      background: Color(0xFF0F0A1A),
    ),
    fontFamily: GoogleFonts.dmSans().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F0A1A),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFFFAF8FF),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0F0A1A),
      selectedItemColor: Color(0xFFF43F5E),
      unselectedItemColor: Color(0xFF6B5F82),
    ),
  );
}
```

---

## WIDGET STANDAR

### SKButton (tombol gradient)
```dart
class SKButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isLoading ? null : const LinearGradient(
            colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6)],
          ),
          color: isLoading ? const Color(0xFF6B5F82) : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) Icon(icon, color: Colors.white, size: 18),
                  if (icon != null) const SizedBox(width: 8),
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}
```

### SKTextField (input dark style)
```dart
class SKTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: Color(0xFF6B5F82), letterSpacing: 0.8,
        )),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: Color(0xFFFAF8FF), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF6B5F82)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF6B5F82), size: 18)
                : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(suffixIcon, color: const Color(0xFF6B5F82), size: 18),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF43F5E)),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## HALAMAN MINIMUM (wajib ada — total 8 halaman)

| No | Halaman | Route | Keterangan |
|---|---|---|---|
| 1 | Splash Screen | `/` | Logo + animasi 2 detik |
| 2 | Onboarding | `/onboarding` | 1 halaman perkenalan |
| 3 | Login | `/login` | Form login |
| 4 | Register | `/register` | Form register |
| 5 | Home Feed | `/home` | Feed + stories |
| 6 | Search/Explore | `/search` | Grid explore + pencarian |
| 7 | Create Post | `/create-post` | Upload + caption |
| 8 | Post Detail | `/post-detail` | Detail + komentar |
| 9 | Chat List | `/chat` | Daftar percakapan DM |
| 10 | Chat Detail | `/chat-detail` | Percakapan 1-on-1 |
| 11 | Profile | `/profile` | Profil sendiri |
| 12 | Profil Lain | `/other-profile` | Profil user lain |
| 13 | Saved | `/saved` | Postingan tersimpan |
| 14 | Moderator | `/moderator` | Dashboard moderator |

---

## ERROR HANDLING & LOADING STATE

Terapkan di setiap operasi async:

```dart
// Di provider, gunakan enum state
enum LoadState { idle, loading, success, error }

// Di screen, tampilkan sesuai state:
// loading → CircularProgressIndicator dengan warna rose
// error   → SnackBar merah dengan pesan error
// empty   → Widget ilustrasi kosong dengan teks deskriptif
// success → tampilkan data
```

**SnackBar standar:**
```dart
// Success
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    backgroundColor: const Color(0xFF22163A),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
);
```

---

## VALIDASI FORM

Gunakan `Form` + `GlobalKey<FormState>` + `validator` di setiap field:

| Field | Aturan Validasi |
|---|---|
| Email | Tidak kosong, format email valid (mengandung @ dan .) |
| Username | Tidak kosong, min 3 karakter, hanya huruf/angka/underscore |
| Password | Tidak kosong, min 6 karakter |
| Konfirmasi password | Harus sama dengan password |
| Caption | Tidak kosong, max 500 karakter |
| Komentar | Tidak kosong, max 200 karakter |

---

## FORMAT WAKTU

```dart
// Gunakan fungsi ini untuk format waktu relatif
String timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1)  return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24)   return '${diff.inHours} jam lalu';
  if (diff.inDays < 7)     return '${diff.inDays} hari lalu';
  if (diff.inDays < 30)    return '${(diff.inDays / 7).floor()} minggu lalu';
  return '${(diff.inDays / 30).floor()} bulan lalu';
}
```

---

## CATATAN IMPLEMENTASI PLATFORM

### Mobile
- Gunakan `image_picker` untuk pilih gambar dari galeri
- Bottom navigation bar 5 tab
- Gunakan `SafeArea` di setiap screen

### Desktop
- Sidebar navigasi kiri (lebar 220px)
- Panel kanan untuk saran/trending (lebar 260px)
- Konten utama di tengah (max width 600px, center)
- Gunakan `PointerInterceptor` jika perlu untuk hover state

### Web
- Fallback input URL gambar jika `image_picker` tidak tersedia
- Layout mengikuti breakpoint: < 600px mobile, 600–1024px tablet, > 1024px desktop
- Pastikan semua gambar menggunakan `cached_network_image`

---

## URUTAN IMPLEMENTASI YANG DISARANKAN

1. Setup project + struktur folder + theme + colors
2. Buat semua models + dummy data
3. Buat AuthProvider + LoginScreen + RegisterScreen
4. Buat SplashScreen + OnboardingScreen + routing
5. Buat PostCard widget + PostProvider
6. Buat HomeScreen (mobile) + FeedScreen
7. Buat CreatePostScreen
8. Buat PostDetailScreen + komentar
9. Buat SearchScreen
10. Buat ProfileScreen + OtherProfileScreen
11. Buat SavedScreen
12. Tambah responsive layout (tablet + desktop)
13. Buat ModeratorDashboard
14. Polish UI + animasi + error handling

---

## OUTPUT YANG DIHARAPKAN

Setelah kode selesai, aplikasi harus bisa:
- [ ] Login dengan akun dummy (contoh: `andi@email.com` / `123456`)
- [ ] Login sebagai moderator (`admin@sosialkita.app` / `admin123`)
- [ ] Register akun baru
- [ ] Melihat feed postingan
- [ ] Like dan unlike postingan
- [ ] Berkomentar pada postingan
- [ ] Follow dan unfollow user
- [ ] Upload postingan baru (dengan gambar + caption)
- [ ] Mencari user dan postingan
- [ ] Menyimpan dan melihat postingan tersimpan
- [ ] Melihat profil sendiri dan profil orang lain
- [ ] Logout
- [ ] Moderator dapat melihat semua post dan menghapusnya
- [ ] Berjalan di minimal 2 platform (mobile + web atau mobile + desktop)

---

*Prompt ini dibuat sebagai panduan pengembangan tahap awal (fitur sementara) untuk proyek SosialKita — Tugas Proyek Flutter Multiplatform.*
