import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/time_ago.dart';
import '../../models/notification_model.dart';
import '../../models/user_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../widgets/post/post_card.dart';

/// NotificationScreen — Menampilkan daftar notifikasi aktivitas pengguna
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Secara otomatis tandai semua notifikasi dibaca ketika membuka halaman ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: AppColors.skDark,
      appBar: AppBar(
        backgroundColor: AppColors.skDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.skWhite),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.skGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'Notifikasi',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withOpacity(0.05),
            height: 1,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 64,
                    color: AppColors.skMuted.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.skMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aktivitas seperti suka, komentar, atau pengikut baru akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.skMuted.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final fromUser = _getNotificationUser(notification.fromUserId);

                return InkWell(
                  onTap: () {
                    if (notification.postId != null) {
                      _showPostDetailDialog(context, notification.postId!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.transparent : AppColors.skRose.withOpacity(0.03),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.04),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        SKAvatar(
                          imageUrl: fromUser.avatarUrl,
                          initials: fromUser.avatarInitials,
                          backgroundColor: fromUser.avatarColor,
                          size: 40,
                        ),
                        const SizedBox(width: 12),

                        // Isi teks notifikasi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 12.5,
                                    color: Color(0xFFC4B5D4),
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '@${fromUser.username} ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.skWhite,
                                      ),
                                    ),
                                    TextSpan(text: _getNotificationText(notification)),
                                  ],
                                ),
                              ),
                              if ((notification.type == NotificationType.comment || notification.type == NotificationType.message) && notification.commentText != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.skCard.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '"${notification.commentText}"',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 11,
                                      color: AppColors.skWhite.withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                timeAgo(notification.createdAt),
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10,
                                  color: AppColors.skMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Indikator belum dibaca
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.skRose,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Teks aksi berdasarkan tipe notifikasi
  String _getNotificationText(NotificationModel n) {
    switch (n.type) {
      case NotificationType.like:
        return 'menyukai postingan Anda.';
      case NotificationType.comment:
        return 'mengomentari postingan Anda.';
      case NotificationType.follow:
        return 'mulai mengikuti Anda.';
      case NotificationType.message:
        return 'mengirim pesan kepada Anda.';
    }
  }

  final Set<String> _pendingFetches = {};

  void _triggerUserFetch(String userId) {
    if (_pendingFetches.contains(userId)) return;
    _pendingFetches.add(userId);

    Future.microtask(() async {
      try {
        if (mounted) {
          await context.read<UserProvider>().fetchUserById(userId);
        }
      } catch (e) {
        debugPrint('Error fetching user $userId: $e');
      }
    });
  }

  // Helper untuk mengambil detail user
  UserModel _getNotificationUser(String userId) {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser?.id == userId) {
      return auth.currentUser!;
    }

    try {
      return dummyUsers.firstWhere((u) => u.id == userId);
    } catch (_) {
      // Trigger background fetch if not found
      _triggerUserFetch(userId);

      // Return a fallback model so the notification still displays gracefully
      return UserModel(
        id: userId,
        username: 'user_$userId',
        displayName: 'Pengguna SosialKita',
        email: '',
        password: '',
        bio: '',
        avatarUrl: '',
        avatarInitials: 'U',
        avatarColor: Colors.grey,
        role: 'user',
        joinedAt: DateTime.now(),
      );
    }
  }

  // Menampilkan popup postingan jika diklik
  void _showPostDetailDialog(BuildContext context, String postId) {
    final postProvider = context.read<PostProvider>();
    final post = postProvider.getPostById(postId);

    if (post == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '1';
        return Dialog(
          backgroundColor: AppColors.skDark2,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.skWhite),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Postingan',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 15,
                    color: AppColors.skWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: PostCard(
                    post: post,
                    currentUserId: currentUserId,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
