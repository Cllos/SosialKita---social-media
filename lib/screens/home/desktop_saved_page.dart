import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post/post_card.dart';

/// DesktopSavedPage — Halaman Tersimpan yang menampilkan post yang disimpan user
/// Digunakan sebagai konten inline di DesktopHome (tab Tersimpan)
class DesktopSavedPage extends StatelessWidget {
  const DesktopSavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return const SizedBox.shrink();

    final savedPosts = currentUser.savedPosts
        .map((pid) => postProvider.getPostById(pid))
        .where((p) => p != null)
        .map((p) => p!)
        .toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Header ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.skGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: const Text(
                    'Tersimpan',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${savedPosts.length} tersimpan',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.skMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Daftar post tersimpan ──
        if (savedPosts.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 56,
                    color: AppColors.skMuted.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada postingan tersimpan',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.skMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Simpan postingan menarik dengan ikon bookmark 🔖',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.skMuted.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: PostCard(
                      post: savedPosts[index],
                      currentUserId: currentUser.id,
                    ),
                  );
                },
                childCount: savedPosts.length,
              ),
            ),
          ),
      ],
    );
  }
}
