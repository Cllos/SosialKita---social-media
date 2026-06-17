import 'package:flutter/material.dart';
import '../models/notification_model.dart';

/// NotificationProvider — mengelola state notifikasi pengguna
class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      type: NotificationType.like,
      fromUserId: '2', // siti_rahma
      postId: '1', // Sunset Losari
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n2',
      type: NotificationType.comment,
      fromUserId: '5', // reza_h
      postId: '1',
      commentText: 'Resep coto makassar-nya mantap betul gan!',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n3',
      type: NotificationType.follow,
      fromUserId: '3', // maulana_b
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n4',
      type: NotificationType.like,
      fromUserId: '4', // fitri_dewi
      postId: '2', // Coto Makassar
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Menandai semua notifikasi sebagai telah dibaca
  void markAllAsRead() {
    bool updated = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        updated = true;
      }
    }
    if (updated) {
      notifyListeners();
    }
  }

  /// Tambah notifikasi baru
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
