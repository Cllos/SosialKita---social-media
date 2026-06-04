import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../common/sk_avatar.dart';

/// DesktopRightPanel — Panel kanan untuk saran follow & trending tags
/// Sesuai design sosialkita_ui.html (.desk-right)
class DesktopRightPanel extends StatelessWidget {
  final String currentUserId;

  const DesktopRightPanel({
    super.key,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Saran Follow ──
            _buildSuggestionsSection(context),
            const SizedBox(height: 24),

            // ── Trending Tags ──
            _buildTrendingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final suggestions = userProvider.getSuggestions(currentUserId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SARAN UNTUK KAMU',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.skMuted.withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ...suggestions.map(
              (user) => _SuggestUserTile(
                user: user,
                currentUserId: currentUserId,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendingSection() {
    final trendingTags = [
      {'tag': '#Makassar', 'posts': '24.5k postingan'},
      {'tag': '#KulinerSulsel', 'posts': '11.2k postingan'},
      {'tag': '#WisataIndonesia', 'posts': '8.9k postingan'},
      {'tag': '#FotografiJalanan', 'posts': '5.3k postingan'},
      {'tag': '#SunsetLosari', 'posts': '3.1k postingan'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TREN SAAT INI',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.skMuted.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        ...trendingTags.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final tag = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text(
                    '$idx',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.skMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag['tag']!,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.skWhite,
                        ),
                      ),
                      Text(
                        tag['posts']!,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: AppColors.skMuted.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.trending_up,
                  size: 16,
                  color: AppColors.skRose,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SuggestUserTile extends StatelessWidget {
  final UserModel user;
  final String currentUserId;

  const _SuggestUserTile({
    required this.user,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SKAvatar(
            initials: user.avatarInitials,
            backgroundColor: user.avatarColor,
            size: 34,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.skWhite,
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    color: AppColors.skMuted.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final isFollowing = userProvider.isFollowing(
                currentUserId,
                user.id,
              );
              return GestureDetector(
                onTap: () {
                  userProvider.toggleFollow(currentUserId, user.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isFollowing
                        ? Colors.transparent
                        : AppColors.skRose.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isFollowing
                          ? Colors.white.withOpacity(0.12)
                          : AppColors.skRose.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    isFollowing ? 'Unfollow' : 'Follow',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isFollowing ? AppColors.skMuted : AppColors.skRose,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
