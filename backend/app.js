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

// ── Image Proxy (to bypass CORS on Web for seed images) ──
const https = require('https');
const http = require('http');

app.get('/api/v1/proxy', (req, res) => {
  const imageUrl = req.query.url;
  if (!imageUrl) {
    return res.status(400).json({ success: false, message: 'Missing url parameter' });
  }
  const parsedUrl = new URL(imageUrl);
  const client = parsedUrl.protocol === 'https:' ? https : http;
  
  client.get(imageUrl, (response) => {
    if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
      // Handle redirects (e.g. picsum.photos redirecting to fastly.jsdelivr.net)
      client.get(response.headers.location, (redirectRes) => {
        if (redirectRes.headers['content-type']) {
          res.setHeader('Content-Type', redirectRes.headers['content-type']);
        }
        res.setHeader('Cache-Control', 'public, max-age=86400');
        redirectRes.pipe(res);
      }).on('error', (err) => {
        res.status(500).json({ success: false, message: 'Failed to fetch redirect image', error: err.message });
      });
      return;
    }
    
    if (response.headers['content-type']) {
      res.setHeader('Content-Type', response.headers['content-type']);
    }
    res.setHeader('Cache-Control', 'public, max-age=86400');
    response.pipe(res);
  }).on('error', (err) => {
    res.status(500).json({ success: false, message: 'Failed to fetch image', error: err.message });
  });
});

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
