const router = require('express').Router();
const { body } = require('express-validator');
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

// POST /register
router.post('/register', [
  body('username')
    .notEmpty().withMessage('Username wajib diisi')
    .isLength({ min: 3, max: 50 }).withMessage('Username harus 3-50 karakter')
    .matches(/^[a-zA-Z0-9_]+$/).withMessage('Username hanya boleh huruf, angka, dan underscore'),
  body('display_name')
    .notEmpty().withMessage('Nama tampilan wajib diisi')
    .isLength({ min: 2, max: 100 }).withMessage('Nama tampilan harus 2-100 karakter'),
  body('email')
    .isEmail().withMessage('Email tidak valid')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 6 }).withMessage('Password minimal 6 karakter')
], authController.register);

// POST /login
router.post('/login', [
  body('email').isEmail().withMessage('Email tidak valid'),
  body('password').notEmpty().withMessage('Password wajib diisi')
], authController.login);

// GET /me
router.get('/me', auth, authController.me);

// POST /logout
router.post('/logout', auth, authController.logout);

module.exports = router;
