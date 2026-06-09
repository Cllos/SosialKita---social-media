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
  max: 10000,
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
