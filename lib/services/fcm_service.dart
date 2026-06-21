import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

// Background message handler — must be a top-level function annotated with @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("[FCM] Menangani pesan di background: ${message.messageId}");
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static NotificationProvider? _notificationProvider;
  bool _initialized = false;

  /// Mendaftarkan instance NotificationProvider agar notifikasi masuk langsung di-update ke UI
  static void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  /// Inisialisasi Firebase Messaging
  Future<void> initialize() async {
    if (_initialized) return;

    // Bypassing jika berjalan di platform Web
    if (kIsWeb) {
      debugPrint('[FCM] Firebase Messaging berjalan di Web. Lewati inisialisasi lokal notifikasi.');
      _initialized = true;
      return;
    }

    try {
      // 1. Minta izin notifikasi
      await requestPermission();

      // 2. Konfigurasi Flutter Local Notifications untuk Foreground Banner
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
      );

      // Membuat Notification Channel Android (Penting untuk Android 8.0+)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'sosialkita_high_channel', // id
        'Notifikasi SosialKita', // title
        description: 'Channel untuk notifikasi aktivitas aplikasi SosialKita.', // description
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Konfigurasi FCM Listeners
      // A. Foreground Message Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Pesan diterima di foreground: ${message.messageId}');
        _processRemoteMessage(message, showLocal: true);
      });

      // B. Background Message Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // C. App Opened from Background State via Notification Tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM] Aplikasi dibuka dari background lewat tap notifikasi.');
        _processRemoteMessage(message, showLocal: false);
        _handleNotificationTap(jsonEncode(message.data));
      });

      // D. App Opened from Terminated State (Initial Message)
      final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM] Aplikasi dibuka dari terminated state lewat tap notifikasi.');
        _processRemoteMessage(initialMessage, showLocal: false);
        _handleNotificationTap(jsonEncode(initialMessage.data));
      }

      _initialized = true;
      debugPrint('[FCM] FcmService berhasil diinisialisasi.');
    } catch (e) {
      debugPrint('[FCM] Error menginisialisasi FcmService: $e');
    }
  }

  /// Meminta izin notifikasi (Android 13+ & iOS)
  Future<void> requestPermission() async {
    if (kIsWeb) return;
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('[FCM] Status izin notifikasi: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('[FCM] Gagal meminta izin notifikasi: $e');
    }
  }

  /// Mengambil token FCM perangkat ini
  Future<String?> getToken() async {
    try {
      final token = await _fcm.getToken();
      debugPrint('[FCM] Device Token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] Gagal mengambil token perangkat: $e');
      return null;
    }
  }

  /// Memproses remote message dan memasukkannya ke NotificationProvider
  void _processRemoteMessage(RemoteMessage message, {required bool showLocal}) {
    try {
      final data = message.data;
      if (data.isEmpty) return;

      final id = data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final typeStr = data['type'] ?? 'like';
      final fromUserId = data['fromUserId'] ?? '1';
      final postId = data['postId'];
      final commentText = data['commentText'];
      final createdAtStr = data['createdAt'] ?? DateTime.now().toIso8601String();

      NotificationType type;
      switch (typeStr) {
        case 'like':
          type = NotificationType.like;
          break;
        case 'comment':
          type = NotificationType.comment;
          break;
        case 'follow':
          type = NotificationType.follow;
          break;
        case 'message':
          type = NotificationType.message;
          break;
        default:
          type = NotificationType.like;
      }

      final notification = NotificationModel(
        id: id,
        type: type,
        fromUserId: fromUserId,
        postId: postId,
        commentText: commentText,
        createdAt: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
        isRead: false,
      );

      // Masukkan ke Provider agar langsung tampil di tab Notifikasi
      if (_notificationProvider != null) {
        _notificationProvider!.addNotification(notification);
      }

      // Tampilkan banner notifikasi lokal jika aplikasi sedang di foreground
      if (showLocal && message.notification != null) {
        final title = message.notification?.title ?? 'Notifikasi Baru';
        final body = message.notification?.body ?? '';
        
        _showForegroundNotification(title, body, jsonEncode(data));
      }
    } catch (e) {
      debugPrint('[FCM] Error memproses RemoteMessage: $e');
    }
  }

  /// Tampilkan notifikasi banner (Heads-up) saat foreground
  Future<void> _showForegroundNotification(String title, String body, String payload) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sosialkita_high_channel',
      'Notifikasi SosialKita',
      channelDescription: 'Channel untuk notifikasi aktivitas aplikasi SosialKita.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().hashCode,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Logika saat notifikasi di laci diklik oleh user
  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      debugPrint('[FCM] Notifikasi di-tap dengan payload: $data');
      // Aksi navigasi dapat ditambahkan di sini jika dibutuhkan
    } catch (e) {
      debugPrint('[FCM] Gagal memproses tap notifikasi: $e');
    }
  }
}
