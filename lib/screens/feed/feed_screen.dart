import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post/post_card.dart';
import '../../widgets/story/story_row.dart';

/// FeedScreen — Daftar postingan (digunakan oleh mobile dan desktop home)
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text(
          'Silakan login terlebih dahulu',
          style: TextStyle(color: AppColors.skMuted),
        ),
      );
    }

    final feed = postProvider.getFeed(currentUser.id, currentUser.following);

    if (feed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed_outlined,
              size: 64,
              color: AppColors.skMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada postingan',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.skMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ikuti pengguna lain untuk melihat postingan mereka',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.skMuted.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: feed.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: feed[index],
          currentUserId: currentUser.id,
        );
      },
    );
  }
}
