import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/story_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/layout/desktop_sidebar.dart';
import '../../widgets/layout/desktop_right_panel.dart';
import '../../widgets/post/post_card.dart';
import '../../widgets/story/story_row.dart';
import '../../widgets/common/sk_avatar.dart';
import '../search/desktop_search_page.dart';
import '../profile/desktop_profile.dart';
import '../chat/chat_list_screen.dart';
import 'desktop_saved_page.dart';
import 'desktop_explore_page.dart';

/// DesktopHome — Layout desktop: sidebar kiri + feed tengah + panel kanan
/// Sidebar navigation sekarang benar-benar mengganti halaman/konten
class DesktopHome extends StatefulWidget {
  const DesktopHome({super.key});

  @override
  State<DesktopHome> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<PostProvider>().fetchPosts();
        context.read<StoryProvider>().fetchStories();
        context.read<ChatProvider>().fetchConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: Row(
        children: [
          // ── Sidebar Kiri ──
          DesktopSidebar(
            selectedIndex: _selectedNav,
            onItemTap: _handleNavTap,
          ),

          // ── Konten Tengah (berubah berdasarkan tab) ──
          Expanded(
            child: _buildPageContent(currentUser),
          ),

          // ── Panel Kanan (hanya tampil di Beranda & Eksplorasi) ──
          if (_selectedNav == 0 || _selectedNav == 2)
            DesktopRightPanel(currentUserId: currentUser.id),
        ],
      ),
    );
  }

  /// Handler navigasi sidebar
  void _handleNavTap(int idx) {
    switch (idx) {
      case 0:
        // Beranda — tetap di sini
        setState(() => _selectedNav = 0);
        break;
      case 1:
        // Cari — navigasi ke DesktopSearchPage (punya sidebar sendiri)
        setState(() => _selectedNav = 1);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DesktopSearchPage()),
        ).then((_) {
          if (mounted) setState(() => _selectedNav = 0);
        });
        break;
      case 2:
        // Eksplorasi — tampil inline
        setState(() => _selectedNav = 2);
        break;
      case 3:
        // Pesan — tampil inline
        setState(() => _selectedNav = 3);
        break;
      case 4:
        // Tersimpan — tampil inline
        setState(() => _selectedNav = 4);
        break;
      case 5:
        // Profil — navigasi ke DesktopProfile (punya sidebar sendiri)
        setState(() => _selectedNav = 5);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DesktopProfile()),
        ).then((_) {
          if (mounted) setState(() => _selectedNav = 0);
        });
        break;
    }
  }

  /// Pilih widget konten berdasarkan tab aktif
  Widget _buildPageContent(dynamic currentUser) {
    switch (_selectedNav) {
      case 2:
        // Eksplorasi — semua post (tanpa filter following)
        return const DesktopExplorePage();
      case 3:
        // Pesan — chat list embedded
        return const _EmbeddedChatPage();
      case 4:
        // Tersimpan — post yang disimpan
        return const DesktopSavedPage();
      case 0:
      default:
        // Beranda — feed utama
        return _buildFeedContent(currentUser);
    }
  }

  /// Konten feed beranda
  Widget _buildFeedContent(dynamic currentUser) {
    final postProvider = context.watch<PostProvider>();
    final feed = postProvider.getFeed(currentUser.id, currentUser.following);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Desktop Topbar ──
          _buildDesktopTopbar(currentUser),
          const SizedBox(height: 20),

          // ── Scrollable Content ──
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Stories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: StoryRow(
                      currentUserId: currentUser.id,
                      following: currentUser.following,
                    ),
                  ),
                ),

                // Feed
                if (feed.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.feed_outlined,
                            size: 56,
                            color: AppColors.skMuted.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada postingan',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.skMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
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
                            post: feed[index],
                            currentUserId: currentUser.id,
                          ),
                        );
                      },
                      childCount: feed.length,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTopbar(dynamic currentUser) {
    return Row(
      children: [
        // Search bar — klik navigasi ke search page
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleNavTap(1),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 16,
                      color: AppColors.skMuted.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cari pengguna, postingan, atau tagar...',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.skMuted.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // User avatar — klik navigasi ke profil
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNavTap(5),
            borderRadius: BorderRadius.circular(100),
            child: SKAvatar(
              initials: currentUser.avatarInitials,
              backgroundColor: currentUser.avatarColor,
              imageUrl: currentUser.avatarUrl,
              size: 38,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget embedded untuk tab Pesan di dalam layout DesktopHome
class _EmbeddedChatPage extends StatelessWidget {
  const _EmbeddedChatPage();

  @override
  Widget build(BuildContext context) {
    // ChatListScreen punya Scaffold-nya sendiri, kita tampilkan tanpa Scaffold baru
    return const ChatListScreen();
  }
}
