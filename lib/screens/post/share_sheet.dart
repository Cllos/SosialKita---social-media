import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/common/sk_avatar.dart';

/// ShareSheet — Lembar bagikan postingan bergaya modern
class ShareSheet extends StatelessWidget {
  final PostModel post;

  const ShareSheet({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return const SizedBox.shrink();

    // Dapatkan penulis postingan
    UserModel? postAuthor;
    try {
      postAuthor = dummyUsers.firstWhere((u) => u.id == post.userId);
    } catch (_) {}

    // Dapatkan daftar pengguna lain untuk dikirim pesan
    final otherUsers = dummyUsers.where((u) => u.id != currentUser.id).toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.skDark2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bagikan ke',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.skWhite,
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Teman untuk dikirim lewat DM
          const Text(
            'Kirim sebagai pesan obrolan (DM)',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.skMuted,
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 96,
            child: otherUsers.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada teman ditemukan',
                      style: TextStyle(color: AppColors.skMuted, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: otherUsers.length,
                    itemBuilder: (context, index) {
                      final friend = otherUsers[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: GestureDetector(
                          onTap: () {
                            _sendPostAsDm(context, currentUser.id, friend, postAuthor?.username ?? '');
                          },
                          child: Column(
                            children: [
                              SKAvatar(
                                initials: friend.avatarInitials,
                                backgroundColor: friend.avatarColor,
                                size: 48,
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  friend.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 10,
                                    color: AppColors.skWhite,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.skRose.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Kirim',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 8,
                                    color: AppColors.skRose,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const Divider(color: Colors.white10, height: 24),

          // Menu Berbagi Eksternal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                context,
                icon: Icons.link,
                label: 'Salin Tautan',
                onTap: () {
                  final link = 'https://sosialkita.app/post/${post.id}';
                  Clipboard.setData(ClipboardData(text: link));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Tautan disalin ke papan klip'),
                      backgroundColor: AppColors.skCard,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.send_rounded,
                label: 'WhatsApp',
                onTap: () => _showExternalToast(context, 'WhatsApp'),
              ),
              _buildShareOption(
                context,
                icon: Icons.telegram,
                label: 'Telegram',
                onTap: () => _showExternalToast(context, 'Telegram'),
              ),
              _buildShareOption(
                context,
                icon: Icons.camera_alt_outlined,
                label: 'Stories',
                onTap: () => _showExternalToast(context, 'Stories'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendPostAsDm(BuildContext context, String currentUserId, UserModel friend, String authorUsername) {
    final chatProvider = context.read<ChatProvider>();
    final conv = chatProvider.getOrCreateConversation(currentUserId, friend.id);

    final msgText = 'Hei! Lihat postingan dari @$authorUsername ini: "${post.caption}"';

    chatProvider.sendMessage(conv.id, currentUserId, friend.id, msgText);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Postingan terkirim ke @${friend.username} melalui DM'),
        backgroundColor: AppColors.skCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showExternalToast(BuildContext context, String appName) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil dibagikan ke $appName'),
        backgroundColor: AppColors.skCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: Icon(icon, color: AppColors.skWhite, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10,
              color: AppColors.skMuted,
            ),
          ),
        ],
      ),
    );
  }
}
