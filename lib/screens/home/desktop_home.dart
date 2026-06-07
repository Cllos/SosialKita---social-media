import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/layout/desktop_sidebar.dart';
import '../../widgets/layout/desktop_right_panel.dart';
import '../../widgets/post/post_card.dart';
import '../../widgets/story/story_row.dart';
import '../../widgets/common/sk_avatar.dart';
import '../search/desktop_search_page.dart';

/// DesktopHome — Layout desktop: sidebar kiri + feed tengah + panel kanan
/// Sesuai design sosialkita_ui.html (.desktop-home)
class DesktopHome extends StatefulWidget {
  const DesktopHome({super.key});

  @override
  State<DesktopHome> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  int _selectedNav = 0;

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
            onItemTap: (idx) => setState(() => _selectedNav = idx),
          ),

          // ── Konten Tengah ──
          Expanded(
            child: _buildMainContent(context, currentUser),
          ),

          // ── Panel Kanan ──
          DesktopRightPanel(currentUserId: currentUser.id),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, dynamic currentUser) {
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
        // Search bar
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DesktopSearchPage(),
                ),
              );
            },
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
        const SizedBox(width: 12),

        // User avatar
        SKAvatar(
          initials: currentUser.avatarInitials,
          backgroundColor: currentUser.avatarColor,
          size: 38,
        ),
      ],
    );
  }
}
