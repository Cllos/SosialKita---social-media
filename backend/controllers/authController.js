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

    // Cek email sudah ada
    const existingUser = await User.findOne({
      where: { email }
    });
    if (existingUser) {
      return error(res, 'Email sudah terdaftar', 409);
    }

    // Cek username sudah ada
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

exports.logout = async (req, res) => {
  try {
    // JWT stateless — invalidate di client side
    return success(res, null, 'Logout berhasil');
  } catch (err) {
    return error(res, 'Gagal logout');
  }
};
