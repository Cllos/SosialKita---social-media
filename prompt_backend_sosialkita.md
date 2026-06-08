# PROMPT LENGKAP — SosialKita Backend (Node.js + Express + MySQL)

---

## KONTEKS & TUJUAN

Kamu adalah backend developer senior. Buatkan REST API untuk aplikasi **SosialKita** — Social Media Platform — menggunakan **Node.js + Express.js** dengan database **MySQL**.

API ini akan dikonsumsi oleh aplikasi Flutter multiplatform (mobile, desktop, web). Semua response dalam format JSON. Autentikasi menggunakan **JWT (JSON Web Token)**.

Referensi fitur mengacu pada `prompt_sosialkita_flutter.md` yang sudah ada — backend harus mensupport semua fitur di sana.

---

## STACK TEKNOLOGI

| Komponen | Teknologi |
|---|---|
| Runtime | Node.js v18+ |
| Framework | Express.js v4 |
| Database | MySQL 8.0 |
| ORM | Sequelize v6 |
| Auth | JWT + bcryptjs |
| Upload file | Multer + Cloudinary (atau local storage) |
| Validasi | express-validator |
| Env | dotenv |
| CORS | cors |
| Rate limiting | express-rate-limit |
| Logging | morgan |

---

## STRUKTUR FOLDER

```
sosialkita-backend/
├── .env                        # Variabel environment
├── .env.example                # Template env
├── .gitignore
├── package.json
├── server.js                   # Entry point — jalankan app
├── app.js                      # Setup express, middleware, routes
│
├── config/
│   ├── database.js             # Koneksi Sequelize ke MySQL
│   ├── cloudinary.js           # Konfigurasi upload gambar (opsional)
│   └── jwt.js                  # Secret + helper sign/verify token
│
├── models/                     # Sequelize models (satu file per tabel)
│   ├── index.js                # Init Sequelize + load semua model + asosiasi
│   ├── User.js
│   ├── Post.js
│   ├── Comment.js
│   ├── Like.js
│   ├── Follow.js
│   ├── SavedPost.js
│   ├── Story.js
│   └── Message.js             # Untuk fitur Chat/DM
│
├── controllers/                # Logic bisnis per fitur
│   ├── authController.js       # register, login, logout, me
│   ├── userController.js       # getProfile, updateProfile, searchUser
│   ├── postController.js       # createPost, getFeed, getPost, deletePost
│   ├── commentController.js    # addComment, getComments, deleteComment
│   ├── likeController.js       # toggleLike, getLikes
│   ├── followController.js     # toggleFollow, getFollowers, getFollowing
│   ├── savedController.js      # toggleSave, getSaved
│   ├── exploreController.js    # getExplore, getTrending
│   └── messageController.js   # getConversations, getMessages, sendMessage
│
├── routes/                     # Express router per fitur
│   ├── index.js                # Mount semua routes ke /api/v1
│   ├── authRoutes.js
│   ├── userRoutes.js
│   ├── postRoutes.js
│   ├── commentRoutes.js
│   ├── likeRoutes.js
│   ├── followRoutes.js
│   ├── savedRoutes.js
│   ├── exploreRoutes.js
│   └── messageRoutes.js
│
├── middleware/
│   ├── auth.js                 # Verifikasi JWT — proteksi route
│   ├── isModerator.js          # Cek role moderator
│   ├── uploadMiddleware.js     # Multer config untuk upload file
│   ├── validateRequest.js      # Helper express-validator
│   └── errorHandler.js        # Global error handler
│
├── utils/
│   ├── response.js             # Helper format response JSON standar
│   ├── pagination.js           # Helper pagination (limit, offset)
│   └── timeAgo.js              # Format waktu relatif (opsional)
│
└── database/
    ├── migrations/             # File migrasi tabel (opsional, pakai Sequelize CLI)
    └── seeders/                # Data awal / dummy untuk testing
        ├── 01-users.js
        ├── 02-posts.js
        ├── 03-comments.js
        ├── 04-follows.js
        └── 05-messages.js
```

---

## DATABASE SCHEMA (MySQL)

### Tabel `users`
```sql
CREATE TABLE users (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  username      VARCHAR(50) UNIQUE NOT NULL,
  display_name  VARCHAR(100) NOT NULL,
  email         VARCHAR(150) UNIQUE NOT NULL,
  password      VARCHAR(255) NOT NULL,          -- bcrypt hash
  bio           TEXT,
  avatar_url    VARCHAR(500),                   -- URL foto profil
  role          ENUM('user', 'moderator') DEFAULT 'user',
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Tabel `posts`
```sql
CREATE TABLE posts (
  id          INT PRIMARY KEY AUTO_INCREMENT,
  user_id     INT NOT NULL,
  image_url   VARCHAR(500) NOT NULL,
  caption     TEXT,
  location    VARCHAR(200),
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Tabel `post_tags` (hashtag per post)
```sql
CREATE TABLE post_tags (
  id      INT PRIMARY KEY AUTO_INCREMENT,
  post_id INT NOT NULL,
  tag     VARCHAR(100) NOT NULL,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
```

### Tabel `likes`
```sql
CREATE TABLE likes (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  user_id    INT NOT NULL,
  post_id    INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_like (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
```

### Tabel `comments`
```sql
CREATE TABLE comments (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  user_id    INT NOT NULL,
  post_id    INT NOT NULL,
  text       TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
```

### Tabel `follows`
```sql
CREATE TABLE follows (
  id           INT PRIMARY KEY AUTO_INCREMENT,
  follower_id  INT NOT NULL,              -- yang follow
  following_id INT NOT NULL,             -- yang difollow
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_follow (follower_id, following_id),
  FOREIGN KEY (follower_id)  REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Tabel `saved_posts`
```sql
CREATE TABLE saved_posts (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  user_id    INT NOT NULL,
  post_id    INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_save (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
```

### Tabel `stories`
```sql
CREATE TABLE stories (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  user_id    INT NOT NULL,
  image_url  VARCHAR(500) NOT NULL,
  expires_at TIMESTAMP NOT NULL,          -- otomatis hapus setelah 24 jam
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Tabel `messages` (Chat / DM)
```sql
CREATE TABLE messages (
  id           INT PRIMARY KEY AUTO_INCREMENT,
  sender_id    INT NOT NULL,
  receiver_id  INT NOT NULL,
  text         TEXT NOT NULL,
  is_read      BOOLEAN DEFAULT FALSE,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id)   REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## FILE `.env`

```env
# Server
PORT=3000
NODE_ENV=development

# Database MySQL
DB_HOST=localhost
DB_PORT=3306
DB_NAME=sosialkita_db
DB_USER=root
DB_PASS=

# JWT
JWT_SECRET=sosialkita_super_secret_key_ganti_ini
JWT_EXPIRES_IN=7d

# Cloudinary (opsional, untuk upload gambar)
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=

# Upload lokal (jika tidak pakai Cloudinary)
UPLOAD_DIR=uploads/
MAX_FILE_SIZE=5242880    # 5MB dalam bytes
```

---

## `package.json`

```json
{
  "name": "sosialkita-backend",
  "version": "1.0.0",
  "description": "REST API untuk SosialKita Social Media Platform",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "db:sync": "node -e \"require('./config/database').sync({ force: false })\"",
    "db:seed": "node database/seeders/runAll.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "sequelize": "^6.35.1",
    "mysql2": "^3.6.5",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "multer": "^1.4.5-lts.1",
    "cloudinary": "^1.41.3",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "express-validator": "^7.0.1",
    "express-rate-limit": "^7.1.5",
    "morgan": "^1.10.0",
    "uuid": "^9.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
```

---

## `server.js`

```javascript
require('dotenv').config();
const app = require('./app');
const { sequelize } = require('./config/database');

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    await sequelize.authenticate();
    console.log('✅ Database MySQL terhubung');

    // Sync semua model ke database (alter:true agar tidak hapus data)
    await sequelize.sync({ alter: true });
    console.log('✅ Database sync selesai');

    app.listen(PORT, () => {
      console.log(`🚀 SosialKita API berjalan di http://localhost:${PORT}`);
      console.log(`📋 API Base URL: http://localhost:${PORT}/api/v1`);
    });
  } catch (error) {
    console.error('❌ Gagal start server:', error);
    process.exit(1);
  }
}

startServer();
```

---

## `app.js`

```javascript
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const path = require('path');

const routes = require('./routes/index');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// ── Middleware dasar ──
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// ── Static files (upload lokal) ──
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ── Rate limiting ──
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 menit
  max: 100,
  message: { success: false, message: 'Terlalu banyak request, coba lagi nanti' }
});
app.use('/api', limiter);

// ── Routes ──
app.use('/api/v1', routes);

// ── Health check ──
app.get('/', (req, res) => {
  res.json({ success: true, message: 'SosialKita API is running 🚀', version: '1.0.0' });
});

// ── 404 handler ──
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Endpoint tidak ditemukan' });
});

// ── Global error handler ──
app.use(errorHandler);

module.exports = app;
```

---

## `config/database.js`

```javascript
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASS,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    dialect: 'mysql',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: {
      max: 10,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

module.exports = { sequelize };
```

---

## `utils/response.js` (Format response standar)

```javascript
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
```

---

## `middleware/auth.js`

```javascript
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
```

---

## `middleware/isModerator.js`

```javascript
const { error } = require('../utils/response');

module.exports = (req, res, next) => {
  if (req.user.role !== 'moderator') {
    return error(res, 'Akses ditolak — hanya untuk moderator', 403);
  }
  next();
};
```

---

## SEMUA ENDPOINT API

### Base URL: `http://localhost:3000/api/v1`
### Header Auth: `Authorization: Bearer <token>`

---

### 🔐 AUTH — `/api/v1/auth`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| POST | `/register` | ❌ | Daftar akun baru |
| POST | `/login` | ❌ | Login, return JWT |
| GET | `/me` | ✅ | Data user yang sedang login |
| POST | `/logout` | ✅ | Logout (invalidate token di client) |

**POST /register — Request body:**
```json
{
  "username": "andi_yusuf",
  "display_name": "Andi Yusuf",
  "email": "andi@email.com",
  "password": "rahasia123",
  "password_confirmation": "rahasia123"
}
```

**POST /register — Response 201:**
```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "token": "eyJhbGci...",
    "user": {
      "id": 1,
      "username": "andi_yusuf",
      "display_name": "Andi Yusuf",
      "email": "andi@email.com",
      "role": "user",
      "avatar_url": null,
      "created_at": "2024-01-10T00:00:00.000Z"
    }
  }
}
```

**POST /login — Request body:**
```json
{ "email": "andi@email.com", "password": "rahasia123" }
```

---

### 👤 USER — `/api/v1/users`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/:username` | ✅ | Profil user by username |
| PUT | `/profile` | ✅ | Update profil sendiri |
| GET | `/search?q=keyword` | ✅ | Cari user by username/nama |
| GET | `/:id/followers` | ✅ | Daftar follower user |
| GET | `/:id/following` | ✅ | Daftar following user |

**GET /:username — Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "andi_yusuf",
    "display_name": "Andi Yusuf",
    "bio": "Pecinta sunset 🌅",
    "avatar_url": "https://...",
    "role": "user",
    "post_count": 12,
    "follower_count": 340,
    "following_count": 128,
    "is_following": true      // apakah currentUser follow user ini
  }
}
```

**PUT /profile — Request body (multipart/form-data):**
```
display_name: "Andi Yusuf Updated"
bio: "Bio baru saya"
avatar: [file gambar]         // opsional
```

---

### 📸 POST — `/api/v1/posts`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| POST | `/` | ✅ | Buat postingan baru |
| GET | `/feed` | ✅ | Feed dari user yang diikuti |
| GET | `/explore` | ✅ | Semua post (untuk halaman explore) |
| GET | `/:id` | ✅ | Detail satu post |
| DELETE | `/:id` | ✅ | Hapus post milik sendiri |
| GET | `/user/:userId` | ✅ | Semua post milik user tertentu |

**POST / — Request body (multipart/form-data):**
```
image: [file gambar — wajib]
caption: "Caption postingan #tag1 #tag2"
location: "Pantai Losari, Makassar"
```

**GET /feed — Query params:**
```
?page=1&limit=10
```

**GET /feed — Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user": {
        "id": 2,
        "username": "siti_rahma",
        "display_name": "Siti Rahma",
        "avatar_url": "https://..."
      },
      "image_url": "https://...",
      "caption": "Coto Makassar terenak! 🍲",
      "location": "Gowa",
      "tags": ["KulinerMakassar", "CotoMakassar"],
      "like_count": 843,
      "comment_count": 62,
      "is_liked": false,       // apakah currentUser sudah like
      "is_saved": true,        // apakah currentUser sudah save
      "created_at": "2024-06-01T05:00:00.000Z",
      "time_ago": "5 jam lalu"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 48,
    "totalPages": 5
  }
}
```

---

### ❤️ LIKE — `/api/v1/likes`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| POST | `/posts/:postId` | ✅ | Toggle like/unlike |

**POST /posts/:postId — Response:**
```json
{
  "success": true,
  "message": "Post disukai",   // atau "Like dibatalkan"
  "data": {
    "is_liked": true,
    "like_count": 844
  }
}
```

---

### 💬 COMMENT — `/api/v1/comments`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/posts/:postId` | ✅ | Daftar komentar sebuah post |
| POST | `/posts/:postId` | ✅ | Tambah komentar |
| DELETE | `/:commentId` | ✅ | Hapus komentar sendiri |

**POST /posts/:postId — Request body:**
```json
{ "text": "Keren banget fotonya! 😍" }
```

**GET /posts/:postId — Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user": {
        "id": 2,
        "username": "siti_rahma",
        "avatar_url": "https://..."
      },
      "text": "Keren banget! 😍",
      "time_ago": "30 menit lalu",
      "created_at": "2024-06-01T06:30:00.000Z"
    }
  ]
}
```

---

### 👥 FOLLOW — `/api/v1/follows`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| POST | `/:userId` | ✅ | Toggle follow/unfollow user |
| GET | `/:userId/followers` | ✅ | Daftar follower |
| GET | `/:userId/following` | ✅ | Daftar following |

**POST /:userId — Response:**
```json
{
  "success": true,
  "message": "Berhasil mengikuti",   // atau "Berhenti mengikuti"
  "data": {
    "is_following": true,
    "follower_count": 341
  }
}
```

---

### 🔖 SAVED POST — `/api/v1/saved`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| POST | `/posts/:postId` | ✅ | Toggle simpan/hapus simpan |
| GET | `/` | ✅ | Daftar postingan yang disimpan |

---

### 🔍 EXPLORE — `/api/v1/explore`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/posts` | ✅ | Grid semua post untuk explore |
| GET | `/trending` | ✅ | Hashtag trending |
| GET | `/search?q=keyword` | ✅ | Search post by caption/tag |

**GET /search — Response:**
```json
{
  "success": true,
  "data": {
    "users": [ ... ],
    "posts": [ ... ]
  }
}
```

---

### 💬 CHAT / DM — `/api/v1/messages`

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/conversations` | ✅ | Daftar semua percakapan |
| GET | `/:userId` | ✅ | Pesan dengan user tertentu |
| POST | `/:userId` | ✅ | Kirim pesan ke user tertentu |
| PUT | `/:userId/read` | ✅ | Tandai semua pesan sebagai dibaca |
| GET | `/unread/count` | ✅ | Total pesan belum dibaca |

**GET /conversations — Response:**
```json
{
  "success": true,
  "data": [
    {
      "partner": {
        "id": 2,
        "username": "siti_rahma",
        "display_name": "Siti Rahma",
        "avatar_url": "https://..."
      },
      "last_message": {
        "text": "Oke siap! Btw resep coto-nya mau dishare ga?",
        "sender_id": 2,
        "created_at": "2024-06-08T21:42:00.000Z",
        "time_ago": "20 menit lalu"
      },
      "unread_count": 1
    }
  ]
}
```

**POST /:userId — Request body:**
```json
{ "text": "Hei, apa kabar?" }
```

---

### 🛡️ MODERATOR — `/api/v1/moderator`

Semua route di bawah ini memerlukan: `auth` + `isModerator` middleware

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/posts` | ✅🛡️ | Semua post (untuk moderasi) |
| DELETE | `/posts/:id` | ✅🛡️ | Hapus post manapun |
| DELETE | `/comments/:id` | ✅🛡️ | Hapus komentar manapun |
| GET | `/users` | ✅🛡️ | Semua user |
| PUT | `/users/:id/deactivate` | ✅🛡️ | Nonaktifkan akun user |
| GET | `/stats` | ✅🛡️ | Statistik: total user, post, komentar |

---

## IMPLEMENTASI CONTROLLER (Contoh Lengkap)

### `controllers/authController.js`

```javascript
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');
const { User } = require('../models');
const { success, error } = require('../utils/response');

exports.register = async (req, res) => {
  try {
    // Cek validasi
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return error(res, 'Validasi gagal', 422, errors.array());
    }

    const { username, display_name, email, password } = req.body;

    // Cek email/username sudah ada
    const existingUser = await User.findOne({
      where: { email }
    });
    if (existingUser) {
      return error(res, 'Email sudah terdaftar', 409);
    }

    const existingUsername = await User.findOne({ where: { username } });
    if (existingUsername) {
      return error(res, 'Username sudah digunakan', 409);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Buat user baru
    const user = await User.create({
      username,
      display_name,
      email,
      password: hashedPassword,
      role: 'user'
    });

    // Generate JWT
    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    const userData = {
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      email: user.email,
      role: user.role,
      avatar_url: user.avatar_url,
      created_at: user.created_at
    };

    return success(res, { token, user: userData }, 'Registrasi berhasil', 201);
  } catch (err) {
    console.error('Register error:', err);
    return error(res, 'Gagal registrasi, coba lagi');
  }
};

exports.login = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return error(res, 'Validasi gagal', 422, errors.array());
    }

    const { email, password } = req.body;

    // Cari user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return error(res, 'Email atau password salah', 401);
    }

    if (!user.is_active) {
      return error(res, 'Akun Anda telah dinonaktifkan', 403);
    }

    // Cek password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return error(res, 'Email atau password salah', 401);
    }

    // Generate JWT
    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    const userData = {
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      email: user.email,
      bio: user.bio,
      avatar_url: user.avatar_url,
      role: user.role
    };

    return success(res, { token, user: userData }, 'Login berhasil');
  } catch (err) {
    console.error('Login error:', err);
    return error(res, 'Gagal login, coba lagi');
  }
};

exports.me = async (req, res) => {
  try {
    return success(res, req.user, 'Data user berhasil diambil');
  } catch (err) {
    return error(res, 'Gagal mengambil data user');
  }
};
```

---

### `controllers/postController.js`

```javascript
const { Op } = require('sequelize');
const { Post, User, Like, Comment, SavedPost, PostTag } = require('../models');
const { success, error, paginated } = require('../utils/response');
const { getPagination, getPagingData } = require('../utils/pagination');

exports.createPost = async (req, res) => {
  try {
    const { caption, location } = req.body;

    if (!req.file) {
      return error(res, 'Gambar wajib diupload', 400);
    }

    // URL gambar — sesuaikan jika pakai Cloudinary
    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

    const post = await Post.create({
      user_id: req.user.id,
      image_url: imageUrl,
      caption,
      location
    });

    // Parse hashtag dari caption
    if (caption) {
      const tags = caption.match(/#\w+/g) || [];
      for (const tag of tags) {
        await PostTag.create({ post_id: post.id, tag: tag.replace('#', '') });
      }
    }

    return success(res, post, 'Post berhasil dibuat', 201);
  } catch (err) {
    console.error('Create post error:', err);
    return error(res, 'Gagal membuat post');
  }
};

exports.getFeed = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const { limit: lim, offset } = getPagination(page, limit);
    const userId = req.user.id;

    // Ambil ID user yang diikuti
    const { Follow } = require('../models');
    const following = await Follow.findAll({
      where: { follower_id: userId },
      attributes: ['following_id']
    });
    const followingIds = following.map(f => f.following_id);
    followingIds.push(userId); // include post sendiri

    const { count, rows } = await Post.findAndCountAll({
      where: { user_id: { [Op.in]: followingIds } },
      include: [
        { model: User, as: 'author', attributes: ['id', 'username', 'display_name', 'avatar_url'] },
        { model: PostTag, as: 'tags', attributes: ['tag'] }
      ],
      order: [['created_at', 'DESC']],
      limit: lim,
      offset,
      distinct: true
    });

    // Tambahkan is_liked, is_saved, like_count, comment_count
    const postsWithMeta = await Promise.all(rows.map(async (post) => {
      const [likeCount, commentCount, isLiked, isSaved] = await Promise.all([
        Like.count({ where: { post_id: post.id } }),
        Comment.count({ where: { post_id: post.id } }),
        Like.findOne({ where: { user_id: userId, post_id: post.id } }),
        SavedPost.findOne({ where: { user_id: userId, post_id: post.id } })
      ]);

      return {
        ...post.toJSON(),
        tags: post.tags.map(t => t.tag),
        like_count: likeCount,
        comment_count: commentCount,
        is_liked: !!isLiked,
        is_saved: !!isSaved
      };
    }));

    const pagination = getPagingData(count, page, lim);
    return paginated(res, postsWithMeta, pagination, 'Feed berhasil diambil');
  } catch (err) {
    console.error('Get feed error:', err);
    return error(res, 'Gagal mengambil feed');
  }
};
```

---

## `utils/pagination.js`

```javascript
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
```

---

## `middleware/errorHandler.js`

```javascript
const { error } = require('../utils/response');

module.exports = (err, req, res, next) => {
  console.error('Global error:', err.stack);

  // Sequelize validation error
  if (err.name === 'SequelizeValidationError') {
    const messages = err.errors.map(e => e.message);
    return error(res, 'Validasi database gagal', 422, messages);
  }

  // Sequelize unique constraint
  if (err.name === 'SequelizeUniqueConstraintError') {
    return error(res, 'Data sudah ada / duplikat', 409);
  }

  // Default
  return error(res, err.message || 'Internal server error', err.status || 500);
};
```

---

## DATABASE SEEDER (Data Awal Testing)

### `database/seeders/01-users.js`
```javascript
const bcrypt = require('bcryptjs');
const { User } = require('../../models');

module.exports = async () => {
  const hash = await bcrypt.hash('123456', 12);
  const adminHash = await bcrypt.hash('admin123', 12);

  await User.bulkCreate([
    { username: 'andi_yusuf',   display_name: 'Andi Yusuf',     email: 'andi@email.com',  password: hash,      role: 'user',      bio: 'Pecinta sunset 🌅',       avatar_url: 'https://i.pravatar.cc/150?img=1' },
    { username: 'siti_rahma',   display_name: 'Siti Rahma',     email: 'siti@email.com',  password: hash,      role: 'user',      bio: 'Food blogger 🍲',         avatar_url: 'https://i.pravatar.cc/150?img=5' },
    { username: 'maulana_b',    display_name: 'Maulana Budi',   email: 'maulana@email.com',password: hash,     role: 'user',      bio: 'Fotografer jalanan 📸',   avatar_url: 'https://i.pravatar.cc/150?img=3' },
    { username: 'fitri_dewi',   display_name: 'Fitri Dewi',     email: 'fitri@email.com', password: hash,      role: 'user',      bio: 'Traveler Sulawesi 🏝️',   avatar_url: 'https://i.pravatar.cc/150?img=9' },
    { username: 'reza_h',       display_name: 'Reza Hasni',     email: 'reza@email.com',  password: hash,      role: 'user',      bio: 'Developer & coffee ☕',   avatar_url: 'https://i.pravatar.cc/150?img=7' },
    { username: 'admin_sk',     display_name: 'Admin SosialKita', email: 'admin@sosialkita.app', password: adminHash, role: 'moderator', bio: 'Moderator resmi 🛡️', avatar_url: 'https://i.pravatar.cc/150?img=12' },
  ], { ignoreDuplicates: true });

  console.log('✅ Users seeded');
};
```

### `database/seeders/runAll.js`
```javascript
require('dotenv').config();
const { sequelize } = require('../../config/database');

async function runSeeders() {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ alter: true });

    await require('./01-users')();
    await require('./02-posts')();
    await require('./03-comments')();
    await require('./04-follows')();
    await require('./05-messages')();

    console.log('✅ Semua seeder selesai!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Seeder error:', err);
    process.exit(1);
  }
}

runSeeders();
```

---

## CARA INTEGRASI KE FLUTTER

Ganti base URL di Flutter dari dummy data ke API:

```dart
// lib/core/utils/api_client.dart
class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  // Production: 'https://api.sosialkita.app/api/v1'

  static Map<String, String> headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
```

```dart
// Contoh call login dari Flutter
Future<void> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('${ApiClient.baseUrl}/auth/login'),
    headers: ApiClient.headers(null),
    body: jsonEncode({ 'email': email, 'password': password }),
  );

  final data = jsonDecode(response.body);
  if (data['success']) {
    final token = data['data']['token'];
    // Simpan token ke SharedPreferences
    // Update AuthProvider dengan data user
  }
}
```

---

## URUTAN IMPLEMENTASI YANG DISARANKAN

| Langkah | Yang dikerjakan |
|---|---|
| 1 | Setup project: `npm init`, install semua dependency |
| 2 | Buat `.env` + `config/database.js` + test koneksi MySQL |
| 3 | Buat semua Sequelize models + asosiasi di `models/index.js` |
| 4 | `server.js` + `app.js` + `utils/response.js` + middleware dasar |
| 5 | Auth: register + login + JWT + middleware auth |
| 6 | User: getProfile + updateProfile + search |
| 7 | Post: createPost + getFeed + getExplore + upload gambar |
| 8 | Like: toggleLike |
| 9 | Comment: addComment + getComments + deleteComment |
| 10 | Follow: toggleFollow + getFollowers + getFollowing |
| 11 | Saved: toggleSave + getSaved |
| 12 | Explore: grid + trending + search |
| 13 | Chat/DM: getConversations + getMessages + sendMessage |
| 14 | Moderator routes |
| 15 | Seeder data awal |
| 16 | Test semua endpoint (pakai Postman/Thunder Client) |
| 17 | Integrasi ke Flutter: ganti dummy data → HTTP calls |

---

## OUTPUT YANG DIHARAPKAN

Setelah backend selesai, API harus bisa:

- [ ] Register dan login user, return JWT
- [ ] Proteksi semua route private dengan JWT middleware
- [ ] Upload gambar (lokal atau Cloudinary)
- [ ] Return feed postingan dengan pagination
- [ ] Toggle like/unlike
- [ ] CRUD komentar
- [ ] Toggle follow/unfollow
- [ ] Toggle simpan post
- [ ] Search user dan post
- [ ] Chat DM — kirim dan baca pesan
- [ ] Moderator bisa hapus post/komentar apapun
- [ ] Semua response format JSON konsisten `{ success, message, data }`
- [ ] Error handling terpusat

---

*Prompt ini adalah panduan backend Node.js + Express + MySQL untuk proyek SosialKita.*
*Gunakan bersama `prompt_sosialkita_flutter.md` untuk implementasi full-stack.*
