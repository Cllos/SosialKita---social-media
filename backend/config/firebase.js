const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Resolving path relative to backend/config
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH 
  ? path.resolve(__dirname, '..', process.env.FIREBASE_SERVICE_ACCOUNT_PATH) 
  : path.resolve(__dirname, '..', '../sosialkita-18db3-firebase-adminsdk-fbsvc-cde1b9ef0d.json');

if (fs.existsSync(serviceAccountPath)) {
  try {
    const serviceAccount = require(serviceAccountPath);
    if (admin.apps.length === 0) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      console.log('✅ Firebase Admin SDK berhasil diinisialisasi');
    }
  } catch (error) {
    console.error('❌ Gagal membaca file service account Firebase:', error);
  }
} else {
  console.warn('⚠️ File service account Firebase tidak ditemukan di: ' + serviceAccountPath);
}

module.exports = admin;
