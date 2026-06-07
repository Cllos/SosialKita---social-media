import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../screens/profile/mobile_profile.dart';

/// UserListSheet — Bottom sheet / dialog list user pengikut / mengikuti
class UserListSheet extends StatelessWidget {
  final String title;
  final List<String> userIds;

  const UserListSheet({
    super.key,
    required this.title,
    required this.userIds,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    // Ambil detail data user dari list ID
    final users = userIds
        .map((id) => userProvider.getUserById(id))
        .where((u) => u != null)
        .cast<UserModel>()
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.skCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
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
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.skWhite,
            ),
          ),
          const SizedBox(height: 16),

          // Users list
          if (users.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Belum ada pengguna',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: AppColors.skMuted.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isMe = user.id == currentUserId;
                  final isFollowing = userProvider.isFollowing(currentUserId, user.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        // Avatar
                        SKAvatar(
                          imageUrl: user.avatarUrl,
                          initials: user.avatarInitials,
                          backgroundColor: user.avatarColor,
                          size: 40,
                        ),
                        const SizedBox(width: 12),

                        // Username & Nama
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Tutup sheet
                              // Navigasi ke profil user terpilih
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MobileProfile(userId: user.id),
                                ),
                              );
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.skWhite,
                                    ),
                                  ),
                                  Text(
                                    '@${user.username}',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 11,
                                      color: AppColors.skMuted.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Tombol Ikuti/Mengikuti (jika bukan akun sendiri)
                        if (!isMe)
                          GestureDetector(
                            onTap: () {
                              userProvider.toggleFollow(currentUserId, user.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: isFollowing ? null : AppColors.skGradientBtn,
                                color: isFollowing ? Colors.white.withOpacity(0.06) : null,
                                borderRadius: BorderRadius.circular(8),
                                border: isFollowing
                                    ? Border.all(color: Colors.white.withOpacity(0.12))
                                    : null,
                              ),
                              child: Text(
                                isFollowing ? 'Mengikuti' : 'Ikuti',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isFollowing ? AppColors.skMuted : Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
