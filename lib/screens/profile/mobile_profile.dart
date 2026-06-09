import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../providers/story_provider.dart';
import '../../widgets/story/add_story_sheet.dart';
import '../../widgets/profile/user_list_sheet.dart';
import '../story/story_view_screen.dart';
import 'edit_profile_sheet.dart';
import '../post/post_detail_screen.dart';
import '../../widgets/post/post_image.dart';

/// MobileProfile — Halaman profil pengguna (mobile layout)
/// Menampilkan header profil, statistik, tab postingan/tersimpan, dan grid foto
class MobileProfile extends StatefulWidget {
  final String? userId;

  const MobileProfile({super.key, this.userId});

  @override
  State<MobileProfile> createState() => _MobileProfileState();
}

class _MobileProfileState extends State<MobileProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Apakah ini profil sendiri (tanpa userId = profil sendiri)
  bool get _isOwnProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    // Tab count: profil sendiri → 2 (Postingan + Tersimpan), user lain → 1
    _tabController = TabController(
      length: _isOwnProfile ? 2 : 1,
      vsync: this,
    );
    Future.microtask(() {
      if (mounted) {
        final userId = widget.userId ?? context.read<AuthProvider>().currentUser?.id;
        if (userId != null) {
          context.read<UserProvider>().fetchFollowersAndFollowing(userId);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  UserModel? _getUser(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (_isOwnProfile) {
      return auth.currentUser;
    }
    return context.watch<UserProvider>().getUserById(widget.userId!);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = _getUser(context);
    if (user == null) return const SizedBox.shrink();

    final postProvider = context.watch<PostProvider>();
    final userPosts = postProvider.getUserPosts(user.id);

    // Postingan tersimpan (hanya untuk profil sendiri)
    final savedPosts = _isOwnProfile
        ? user.savedPosts
            .map((pid) => postProvider.getPostById(pid))
            .where((p) => p != null)
            .cast<PostModel>()
            .toList()
        : <PostModel>[];

    final bool isOwn = _isOwnProfile;

    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: AppColors.skDark,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            title: Text(
              user.username,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.skWhite,
              ),
            ),
            actions: [
              if (isOwn)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.skMuted.withOpacity(0.6),
                  ),
                  color: AppColors.skCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: AppColors.skRose, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Keluar',
                            style: TextStyle(
                              color: AppColors.skRose,
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Profile Header ──
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, user, userPosts.length, isOwn),
          ),

          // ── Tab Bar ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.skRose,
                indicatorWeight: 2.5,
                labelColor: AppColors.skWhite,
                unselectedLabelColor: AppColors.skMuted,
                labelStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  const Tab(
                    icon: Icon(Icons.grid_on_rounded, size: 22),
                  ),
                  if (isOwn)
                    const Tab(
                      icon: Icon(Icons.bookmark_border_rounded, size: 22),
                    ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Postingan
            _buildPostGrid(userPosts),

            // Tab 2: Tersimpan (hanya profil sendiri)
            if (isOwn) _buildPostGrid(savedPosts, emptyMessage: 'Belum ada postingan tersimpan'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserModel user,
    int postCount,
    bool isOwn,
  ) {
    final storyProvider = context.watch<StoryProvider>();
    final hasStories = storyProvider.hasActiveStory(user.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: Avatar + Stats ──
          Row(
            children: [
              // Avatar besar (Tap untuk lihat story atau buat story jika kosong)
              GestureDetector(
                onTap: () {
                  final stories = storyProvider.getStoriesByUser(user.id);
                  if (stories.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryViewScreen(stories: stories, user: user),
                      ),
                    );
                  } else if (isOwn) {
                    _showAddStorySheet(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('@${user.username} tidak memiliki cerita baru'),
                        backgroundColor: AppColors.skCard,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SKAvatar(
                    imageUrl: user.avatarUrl,
                    initials: user.avatarInitials,
                    backgroundColor: user.avatarColor,
                    size: 80,
                    showRing: hasStories,
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Statistik: Post, Followers, Following
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      count: postCount.toString(),
                      label: 'Postingan',
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => UserListSheet(
                            title: 'Pengikut',
                            userIds: user.followers,
                          ),
                        );
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: _StatItem(
                          count: user.followers.length.toString(),
                          label: 'Pengikut',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => UserListSheet(
                            title: 'Mengikuti',
                            userIds: user.following,
                          ),
                        );
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: _StatItem(
                          count: user.following.length.toString(),
                          label: 'Mengikuti',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Display Name + Role Badge ──
          Row(
            children: [
              Text(
                user.displayName,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.skWhite,
                ),
              ),
              if (user.role == 'moderator') ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.skGradientBtn,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Moderator 🛡️',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // ── Bio ──
          if (user.bio.isNotEmpty)
            Text(
              user.bio,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.skWhite.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          const SizedBox(height: 4),

          // ── Joined at ──
          Text(
            'Bergabung ${_formatJoinDate(user.joinedAt)}',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: AppColors.skMuted.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),

          // ── Tombol Aksi ──
          if (isOwn)
            _buildEditProfileButton(context, user)
          else
            _buildFollowButton(context, user),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context, UserModel user) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => _showEditProfileSheet(context, user),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: const Center(
            child: Text(
              'Edit Profil',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.skWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, UserModel user) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final currentUserId = auth.currentUser?.id ?? '';
    final isFollowing = userProvider.isFollowing(currentUserId, user.id);

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          userProvider.toggleFollow(currentUserId, user.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isFollowing ? null : AppColors.skGradientBtn,
            color: isFollowing ? Colors.white.withOpacity(0.06) : null,
            borderRadius: BorderRadius.circular(10),
            border: isFollowing
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
          ),
          child: Center(
            child: Text(
              isFollowing ? 'Mengikuti' : 'Follow',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isFollowing ? AppColors.skMuted : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostGrid(List<PostModel> posts, {String? emptyMessage}) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 56,
              color: AppColors.skMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage ?? 'Belum ada postingan',
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.skMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Postingan akan muncul di sini',
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

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: post.id),
              ),
            );
          },
          child: _PostGridTile(post: post),
        );
      },
    );
  }

  void _showEditProfileSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(user: user),
    );
  }

  void _showAddStorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddStorySheet(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.skCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        title: const Text(
          'Keluar dari SosialKita?',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.skWhite,
          ),
        ),
        content: Text(
          'Kamu akan keluar dari akun ini. Yakin ingin keluar?',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: AppColors.skWhite.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.skMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              context.read<AuthProvider>().logout();
              // Karena main.dart menggunakan Consumer<AuthProvider>,
              // saat logout → otomatis redirect ke LoginScreen
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.skRose,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ══════════════════════════════════════
//  KOMPONEN PENDUKUNG
// ══════════════════════════════════════

/// Widget statistik (Postingan, Pengikut, Mengikuti)
class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontFamily: 'Syne',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.skWhite,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            color: AppColors.skMuted.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

/// Tile grid thumbnail postingan
class _PostGridTile extends StatelessWidget {
  final PostModel post;

  const _PostGridTile({required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.imageUrl.isEmpty) {
      // Postingan tanpa gambar → tampilkan icon + warna
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E103A), Color(0xFF2D1040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.article_outlined,
            color: AppColors.skMuted.withOpacity(0.4),
            size: 28,
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E103A), Color(0xFF2D1040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: PostImage(
        imageUrl: post.imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// Delegate untuk TabBar yang sticky saat scroll
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.skDark,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
