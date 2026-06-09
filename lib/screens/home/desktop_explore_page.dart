import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post/post_card.dart';

/// DesktopExplorePage — Halaman Eksplorasi yang menampilkan SEMUA postingan
/// Digunakan sebagai konten inline di DesktopHome (tab Eksplorasi)
class DesktopExplorePage extends StatelessWidget {
  const DesktopExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final allPosts = postProvider.getAllPosts();

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
                    'Eksplorasi',
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
                    color: AppColors.skRose.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${allPosts.length} postingan',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.skRose,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Daftar semua post ──
        if (allPosts.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'Belum ada postingan untuk dijelajahi',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  color: AppColors.skMuted,
                ),
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
                      post: allPosts[index],
                      currentUserId: currentUser.id,
                    ),
                  );
                },
                childCount: allPosts.length,
              ),
            ),
          ),
      ],
    );
  }
}
