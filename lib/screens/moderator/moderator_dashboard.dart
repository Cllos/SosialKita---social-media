import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/time_ago.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/comment_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../auth/login_screen.dart';

/// ModeratorDashboard — Dashboard khusus untuk pengguna dengan role Moderator
/// Menampilkan statistik aplikasi dan daftar seluruh postingan untuk dimoderasi (dihapus)
class ModeratorDashboard extends StatelessWidget {
  const ModeratorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final commentProvider = context.watch<CommentProvider>();
    
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.skDark,
        body: Center(
          child: Text('Akses Ditolak.', style: TextStyle(color: AppColors.skWhite)),
        ),
      );
    }

    // Ambil data untuk statistik
    final totalUsers = dummyUsers.length;
    final totalPosts = postProvider.posts.length;
    final totalComments = commentProvider.comments.length;
    
    // Ambil semua post urut terbaru
    final allPosts = postProvider.getAllPosts();

    return Scaffold(
      backgroundColor: AppColors.skDark,
      appBar: AppBar(
        backgroundColor: AppColors.skDark,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.skGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'Panel Moderator',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          // Tombol Keluar (Logout)
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.skRose),
            tooltip: 'Keluar',
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withOpacity(0.05),
            height: 1,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Welcome & Info ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SKAvatar(
                    imageUrl: currentUser.avatarUrl,
                    initials: currentUser.avatarInitials,
                    backgroundColor: currentUser.avatarColor,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${currentUser.displayName} 👋',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.skWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Anda masuk sebagai Moderator resmi SosialKita',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.skMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.skRose.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.skRose.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.skRose, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'MOD',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.skRose,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Statistik Cards ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    'Pengguna',
                    totalUsers.toString(),
                    Icons.people_outline,
                    const Color(0xFF8B5CF6),
                  ),
                  _buildStatCard(
                    'Postingan',
                    totalPosts.toString(),
                    Icons.feed_outlined,
                    const Color(0xFFF43F5E),
                  ),
                  _buildStatCard(
                    'Komentar',
                    totalComments.toString(),
                    Icons.chat_bubble_outline,
                    const Color(0xFFFB923C),
                  ),
                ],
              ),
            ),
          ),

          // ── Heading Daftar Moderasi ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Kelola Postingan',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.skWhite,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Total: $totalPosts',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.skMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Daftar Postingan ──
          if (allPosts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Belum ada postingan untuk dimoderasi',
                  style: TextStyle(color: AppColors.skMuted),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = allPosts[index];
                  final author = _getPostAuthor(post.userId);

                  if (author == null) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.skCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail Postingan (jika ada)
                        if (post.imageUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              post.imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: Colors.white10,
                                child: const Icon(Icons.image_not_supported, size: 24, color: Colors.white24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Detail Post & Pembuat
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '@${author.username}',
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.skWhite,
                                    ),
                                  ),
                                  if (post.reports.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.skRose.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: AppColors.skRose.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            size: 10,
                                            color: AppColors.skRose,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Dilaporkan: ${post.reports.length} Kali',
                                            style: const TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.skRose,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (post.location.isNotEmpty) ...[
                                    Text(
                                      ' · ${post.location}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 10,
                                        color: AppColors.skMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                post.caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  color: AppColors.skWhite.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Dibuat: ${timeAgo(post.createdAt)}',
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10,
                                  color: Colors.white30,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Hapus Postingan
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.skRose),
                          onPressed: () => _showDeleteConfirmation(context, postProvider, post.id),
                        ),
                      ],
                    ),
                  );
                },
                childCount: allPosts.length,
              ),
            ),
        ],
      ),
    );
  }

  // Card statistik aplikasi
  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.skCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.skWhite,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 9,
              color: AppColors.skMuted,
            ),
          ),
        ],
      ),
    );
  }

  // Get author detail
  UserModel? _getPostAuthor(String userId) {
    try {
      return dummyUsers.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  // Konfirmasi Logout
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.skDark2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            'Konfirmasi Keluar',
            style: TextStyle(fontFamily: 'Syne', color: AppColors.skWhite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun Moderator?',
            style: TextStyle(fontFamily: 'DM Sans', color: AppColors.skMuted, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.skMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                context.read<AuthProvider>().logout();
                
                // Redirect ke LoginScreen dan bersihkan tumpukan halaman
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Keluar', style: TextStyle(color: AppColors.skRose, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Konfirmasi Hapus Postingan
  void _showDeleteConfirmation(BuildContext context, PostProvider postProvider, String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.skDark2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            'Hapus Postingan?',
            style: TextStyle(fontFamily: 'Syne', color: AppColors.skWhite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Tindakan ini permanen. Postingan terpilih akan dihapus dari platform SosialKita.',
            style: TextStyle(fontFamily: 'DM Sans', color: AppColors.skMuted, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.skMuted)),
            ),
            TextButton(
              onPressed: () {
                postProvider.deletePost(postId);
                Navigator.pop(context); // Tutup dialog
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Postingan berhasil dihapus 🛡️'),
                    backgroundColor: AppColors.skCard,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: AppColors.skRose, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
