import '../../models/user_model.dart';

enum NotificationType {
  like,
  comment,
  follow,
}

/// Model untuk Notifikasi SosialKita
class NotificationModel {
  final String id;
  final NotificationType type;
  final String fromUserId;
  final String? postId;
  final String? commentText;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.fromUserId,
    this.postId,
    this.commentText,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? fromUserId,
    String? postId,
    String? commentText,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      fromUserId: fromUserId ?? this.fromUserId,
      postId: postId ?? this.postId,
      commentText: commentText ?? this.commentText,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
