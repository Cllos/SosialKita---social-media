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
import '../../widgets/layout/desktop_sidebar.dart';
import 'edit_profile_sheet.dart';
import '../post/post_detail_screen.dart';
import '../../widgets/post/post_image.dart';

/// DesktopProfile — Halaman profil pengguna (desktop layout)
/// Menampilkan sidebar kiri + konten profil di tengah
class DesktopProfile extends StatefulWidget {
  final String? userId;
  final bool isInline;

  const DesktopProfile({super.key, this.userId, this.isInline = false});

  @override
  State<DesktopProfile> createState() => _DesktopProfileState();
}

class _DesktopProfileState extends State<DesktopProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _isOwnProfileInit ? 2 : 1,
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

  bool get _isOwnProfileInit {
    // Tidak bisa pakai context.read di initState, jadi cek secara manual
    return widget.userId == null;
  }

  bool _isOwnProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return widget.userId == null || widget.userId == auth.currentUser?.id;
  }

  UserModel? _getUser(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (_isOwnProfile(context)) {
      return auth.currentUser;
    }
    return context.watch<UserProvider>().getUserById(widget.userId!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUser(context);
    if (user == null) return const SizedBox.shrink();

    final postProvider = context.watch<PostProvider>();
    final userPosts = postProvider.getUserPosts(user.id);
    final isOwn = _isOwnProfile(context);

    final savedPosts = isOwn
        ? user.savedPosts
            .map((pid) => postProvider.getPostById(pid))
            .where((p) => p != null)
            .cast<PostModel>()
            .toList()
        : <PostModel>[];

    if (widget.isInline) {
      return _buildProfileContent(
        context,
        user,
        userPosts,
        savedPosts,
        isOwn,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: Row(
        children: [
          // ── Sidebar Kiri ──
          DesktopSidebar(
            selectedIndex: 5, // Index profil di sidebar
            onItemTap: (idx) {
              if (idx != 5) {
                context.read<AuthProvider>().setDesktopSelectedIndex(idx);
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),

          // ── Konten Profil ──
          Expanded(
            child: _buildProfileContent(
              context,
              user,
              userPosts,
              savedPosts,
              isOwn,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserModel user,
    List<PostModel> userPosts,
    List<PostModel> savedPosts,
    bool isOwn,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              // ── Header Profil Desktop ──
              _buildDesktopHeader(context, user, userPosts.length, isOwn),
              const SizedBox(height: 24),

              // ── Divider ──
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.06),
              ),
              const SizedBox(height: 8),

              // ── Tab Bar ──
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.grid_on_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('POSTINGAN'),
                      ],
                    ),
                  ),
                  if (isOwn)
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_border_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('TERSIMPAN'),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Grid Postingan ──
              SizedBox(
                height: 600,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostGrid(userPosts),
                    if (isOwn)
                      _buildPostGrid(savedPosts,
                          emptyMessage: 'Belum ada postingan tersimpan'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(
    BuildContext context,
    UserModel user,
    int postCount,
    bool isOwn,
  ) {
    final storyProvider = context.watch<StoryProvider>();
    final hasStories = storyProvider.hasActiveStory(user.id);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 100,
              showRing: hasStories,
            ),
          ),
        ),
        const SizedBox(width: 40),

        // Info profil
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row: Username + Tombol Aksi + Logout ──
              Row(
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.skWhite,
                    ),
                  ),
                  if (user.role == 'moderator') ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.skGradientBtn,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Moderator 🛡️',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),

                  // Tombol edit profil / follow
                  if (isOwn)
                    _buildDesktopEditButton(context, user)
                  else
                    _buildDesktopFollowButton(context, user),

                  if (isOwn) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: AppColors.skMuted,
                        size: 20,
                      ),
                      onPressed: () => _showLogoutDialog(context),
                      tooltip: 'Keluar',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // ── Stats Row ──
              Row(
                children: [
                  _DesktopStatItem(count: postCount, label: 'postingan'),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () => _showUserListDialog(context, 'Pengikut', user.followers),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: _DesktopStatItem(
                        count: user.followers.length,
                        label: 'pengikut',
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () => _showUserListDialog(context, 'Mengikuti', user.following),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: _DesktopStatItem(
                        count: user.following.length,
                        label: 'mengikuti',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Display Name ──
              Text(
                user.displayName,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.skWhite,
                ),
              ),

              // ── Bio ──
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.bio,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: AppColors.skWhite.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],

              // ── Joined ──
              const SizedBox(height: 4),
              Text(
                'Bergabung ${_formatJoinDate(user.joinedAt)}',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: AppColors.skMuted.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopEditButton(BuildContext context, UserModel user) {
    return GestureDetector(
      onTap: () => _showEditProfileSheet(context, user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Text(
          'Edit Profil',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.skWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFollowButton(BuildContext context, UserModel user) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final currentUserId = auth.currentUser?.id ?? '';
    final isFollowing = userProvider.isFollowing(currentUserId, user.id);

    return GestureDetector(
      onTap: () => userProvider.toggleFollow(currentUserId, user.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
        decoration: BoxDecoration(
          gradient: isFollowing ? null : AppColors.skGradientBtn,
          color: isFollowing ? Colors.white.withOpacity(0.06) : null,
          borderRadius: BorderRadius.circular(8),
          border: isFollowing
              ? Border.all(color: Colors.white.withOpacity(0.1))
              : null,
        ),
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
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _DesktopPostGridTile(post: post);
      },
    );
  }

  void _showEditProfileSheet(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.skCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 480),
          child: EditProfileSheet(user: user),
        ),
      ),
    );
  }

  void _showAddStorySheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.skDark2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
          child: const AddStorySheet(),
        ),
      ),
    );
  }

  void _showUserListDialog(BuildContext context, String title, List<String> userIds) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.skDark2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
          child: UserListSheet(title: title, userIds: userIds),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.skCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
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
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
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
//  KOMPONEN PENDUKUNG DESKTOP
// ══════════════════════════════════════

class _DesktopStatItem extends StatelessWidget {
  final int count;
  final String label;

  const _DesktopStatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$count ',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.skWhite,
            ),
          ),
          TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: AppColors.skMuted.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopPostGridTile extends StatefulWidget {
  final PostModel post;

  const _DesktopPostGridTile({required this.post});

  @override
  State<_DesktopPostGridTile> createState() => _DesktopPostGridTileState();
}

class _DesktopPostGridTileState extends State<_DesktopPostGridTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(postId: widget.post.id),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar
            if (widget.post.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: PostImage(
                  imageUrl: widget.post.imageUrl,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E103A), Color(0xFF2D1040)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    Icons.article_outlined,
                    color: AppColors.skMuted.withOpacity(0.4),
                    size: 28,
                  ),
                ),
              ),

            // Hover overlay dengan statistik
            if (_isHovered)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.post.likes.length}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
