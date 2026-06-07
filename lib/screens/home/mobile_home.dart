import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post/post_card.dart';
import '../../widgets/story/story_row.dart';
import '../profile/mobile_profile.dart';
import '../search/search_screen.dart';

/// MobileHome — Layout mobile dengan BottomNavigationBar
/// Menampilkan topbar, stories, feed, dan bottom nav
class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // 0 — Home Feed
            _buildHomeFeed(context),
            // 1 — Search
            const SearchScreen(),
            // 2 — Create Post (placeholder, handled by FAB)
            _buildPlaceholder('Buat Postingan', Icons.add_circle_outline),
            // 3 — Notifications (placeholder)
            _buildPlaceholder('Notifikasi', Icons.notifications_outlined),
            // 4 — Profile
            const MobileProfile(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeFeed(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return const SizedBox.shrink();

    final feed = postProvider.getFeed(currentUser.id, currentUser.following);

    return Column(
      children: [
        // ── Top Bar ──
        _buildTopBar(context),

        // ── Content ──
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Stories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: StoryRow(
                    currentUserId: currentUser.id,
                    following: currentUser.following,
                  ),
                ),
              ),

              // Divider
              SliverToBoxAdapter(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
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
                    (context, index) => PostCard(
                      post: feed[index],
                      currentUserId: currentUser.id,
                    ),
                    childCount: feed.length,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Logo gradient
          ShaderMask(
            shaderCallback: (bounds) => AppColors.skGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: const Text(
              'SosialKita',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),

          // Notification button
          _TopBarButton(
            icon: Icons.notifications_outlined,
            showDot: true,
            onTap: () {},
          ),
          const SizedBox(width: 6),

          // Message button
          _TopBarButton(
            icon: Icons.chat_bubble_outline,
            showDot: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.skDark.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _BottomNavItem(
            icon: Icons.home_rounded,
            isActive: _currentIndex == 0,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          // Search
          _BottomNavItem(
            icon: Icons.search_rounded,
            isActive: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          // Create (gradient button)
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Buat Postingan — segera hadir'),
                  backgroundColor: AppColors.skCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.skGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.skRose.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
          // Notifications
          _BottomNavItem(
            icon: Icons.favorite_border,
            isActive: _currentIndex == 3,
            onTap: () => setState(() => _currentIndex = 3),
          ),
          // Profile
          _BottomNavItem(
            icon: Icons.person_outline,
            isActive: _currentIndex == 4,
            onTap: () => setState(() => _currentIndex = 4),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.skMuted.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.skMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Halaman ini segera hadir',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.skMuted.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;

  const _TopBarButton({
    required this.icon,
    required this.showDot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.06),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(icon, color: AppColors.skWhite, size: 18),
            ),
            if (showDot)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.skRose,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.skDark,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 26,
        color: isActive ? AppColors.skRose : AppColors.skMuted,
      ),
    );
  }
}
