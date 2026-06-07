import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post/post_card.dart';

/// SavedPostsScreen — Menampilkan seluruh postingan yang disimpan oleh pengguna
class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.skDark,
        body: Center(
          child: Text('Silakan login terlebih dahulu.'),
        ),
      );
    }

    final postProvider = context.watch<PostProvider>();

    // Ambil daftar post berdasarkan ID post yang disimpan
    final savedPosts = currentUser.savedPosts
        .map((postId) => postProvider.getPostById(postId))
        .whereType<dynamic>() // Menghilangkan null jika ada post yang dihapus
        .toList();

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
            'Tersimpan',
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
      body: savedPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: AppColors.skMuted.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada simpanan',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.skMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Postingan yang Anda simpan akan muncul di sini.',
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
              itemCount: savedPosts.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final post = savedPosts[index];
                return PostCard(
                  post: post,
                  currentUserId: currentUser.id,
                );
              },
            ),
    );
  }
}
