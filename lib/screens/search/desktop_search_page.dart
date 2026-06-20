import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/time_ago.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/notification_model.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../widgets/layout/desktop_sidebar.dart';
import '../profile/other_profile_screen.dart';
import '../../widgets/post/post_image.dart';

/// DesktopSearchPage — Halaman pencarian full-page untuk desktop
/// Layout: sidebar kiri + konten pencarian di tengah
class DesktopSearchPage extends StatefulWidget {
  final bool isInline;
  const DesktopSearchPage({super.key, this.isInline = false});

  @override
  State<DesktopSearchPage> createState() => _DesktopSearchPageState();
}

class _DesktopSearchPageState extends State<DesktopSearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late TabController _tabController;
  String _query = '';

  bool get _isSearching => _query.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    setState(() => _query = trimmed);
    if (trimmed.isNotEmpty) {
      context.read<UserProvider>().searchUsersApi(trimmed);
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isInline) {
      return _buildSearchContent();
    }

    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: Row(
        children: [
          // ── Sidebar Kiri ──
          DesktopSidebar(
            selectedIndex: 1, // Index Cari
            onItemTap: (idx) {
              if (idx != 1) {
                context.read<AuthProvider>().setDesktopSelectedIndex(idx);
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),

          // ── Konten Pencarian ──
          Expanded(
            child: _buildSearchContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Back + Search Bar ──
              Row(
                children: [
                  if (!widget.isInline) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: AppColors.skWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: _buildSearchBar()),
                ],
              ),
              const SizedBox(height: 20),

              // ── Konten: Explore Grid atau Search Results ──
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _isSearching
                      ? _buildSearchResults()
                      : _buildExploreGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _searchFocus.hasFocus
              ? AppColors.skViolet.withOpacity(0.5)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: 18,
            color: _query.isNotEmpty
                ? AppColors.skRose
                : AppColors.skMuted.withOpacity(0.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: AppColors.skWhite,
              ),
              decoration: InputDecoration(
                hintText: 'Cari pengguna, postingan, atau tagar...',
                hintStyle: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: AppColors.skMuted.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: _onClearSearch,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.skMuted.withOpacity(0.3),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: AppColors.skWhite,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _buildExploreGrid() {
    final postProvider = context.watch<PostProvider>();
    final allPosts = postProvider.getAllPosts();

    if (allPosts.isEmpty) {
      return Center(
        key: const ValueKey('desktop-explore-empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
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
      );
    }

    return CustomScrollView(
      key: const ValueKey('desktop-explore-grid'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Staggered header
        SliverToBoxAdapter(
          child: _buildStaggeredHeader(allPosts),
        ),

        // Regular 3-column grid
        SliverPadding(
          padding: const EdgeInsets.only(top: 4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final postIndex = index + 3;
                if (postIndex >= allPosts.length) return null;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: _DesktopExploreTile(post: allPosts[postIndex]),
                );
              },
              childCount: max(0, allPosts.length - 3),
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  Widget _buildStaggeredHeader(List<PostModel> posts) {
    if (posts.length < 3) {
      return Row(
        children: posts
            .map((p) => Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _DesktopExploreTile(post: p, isFeatured: true),
                    ),
                  ),
                ))
            .toList(),
      );
    }

    return SizedBox(
      height: 340,
      child: Row(
        children: [
          // Item besar (kiri)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _DesktopExploreTile(
                  post: posts[0],
                  isFeatured: true,
                ),
              ),
            ),
          ),
          // 2 item kecil (kanan)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _DesktopExploreTile(post: posts[1]),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _DesktopExploreTile(post: posts[2]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppColors.skGradientBtn,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.skMuted,
            labelStyle: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: 'Pengguna', height: 36),
              Tab(text: 'Postingan', height: 36),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUserResults(),
              _buildPostResults(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserResults() {
    final userProvider = context.watch<UserProvider>();
    final results = userProvider
        .searchUsers(_query)
        .where((u) => u.role != 'moderator')
        .toList();

    if (results.isEmpty) return _buildEmptyState('pengguna');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return _DesktopUserResultTile(
          user: user,
          onTap: () => _navigateToProfile(user.id),
        );
      },
    );
  }

  Widget _buildPostResults() {
    final postProvider = context.watch<PostProvider>();
    final results = postProvider.searchPosts(_query);

    if (results.isEmpty) return _buildEmptyState('postingan');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        UserModel? postUser;
        try {
          postUser = dummyUsers.firstWhere((u) => u.id == post.userId);
        } catch (_) {}
        if (postUser == null) return const SizedBox.shrink();

        return _DesktopPostResultTile(
          post: post,
          user: postUser,
          query: _query,
          onTap: () => _showDesktopPostDetail(context, post),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.skMuted.withOpacity(0.08),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 36,
              color: AppColors.skMuted.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hasil untuk "$_query"',
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.skWhite,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba kata kunci lain untuk $type',
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

  void _navigateToProfile(String userId) {
    final auth = context.read<AuthProvider>();
    if (userId == auth.currentUser?.id) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtherProfileScreen(userId: userId),
      ),
    );
  }

  /// Menampilkan dialog detail postingan (Instagram-style: gambar kiri + info kanan)
  static void _showDesktopPostDetail(BuildContext context, PostModel post) {
    UserModel? postUser;
    try {
      postUser = dummyUsers.firstWhere((u) => u.id == post.userId);
    } catch (_) {}

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogCtx) {
        return _DesktopPostDetailDialog(
          post: post,
          postUser: postUser,
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  WIDGET PENDUKUNG DESKTOP
// ══════════════════════════════════════════════════════════════

/// Tile thumbnail pada Explore Grid desktop — dengan hover overlay
class _DesktopExploreTile extends StatefulWidget {
  final PostModel post;
  final bool isFeatured;

  const _DesktopExploreTile({
    required this.post,
    this.isFeatured = false,
  });

  @override
  State<_DesktopExploreTile> createState() => _DesktopExploreTileState();
}

class _DesktopExploreTileState extends State<_DesktopExploreTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          _DesktopSearchPageState._showDesktopPostDetail(context, widget.post);
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E103A), Color(0xFF2D1040)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.post.imageUrl.isNotEmpty)
                PostImage(
                  imageUrl: widget.post.imageUrl,
                  fit: BoxFit.cover,
                )
              else
                _buildPlaceholder(),

              // Hover overlay
              if (_hovered)
                Container(
                  color: Colors.black.withOpacity(0.45),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.post.likes.length}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Featured gradient overlay
              if (widget.isFeatured && !_hovered) ...[
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.post.likes.isNotEmpty)
                  Positioned(
                    right: 10, bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.post.likes.length}',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],

              // Collections icon (non-featured)
              if (!widget.isFeatured && widget.post.tags.isNotEmpty && !_hovered)
                Positioned(
                  right: 4, top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.collections_rounded, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        widget.isFeatured ? Icons.image_outlined : Icons.article_outlined,
        color: AppColors.skMuted.withOpacity(0.3),
        size: widget.isFeatured ? 40 : 24,
      ),
    );
  }
}


class _DesktopUserResultTile extends StatefulWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _DesktopUserResultTile({required this.user, required this.onTap});

  @override
  State<_DesktopUserResultTile> createState() => _DesktopUserResultTileState();
}

class _DesktopUserResultTileState extends State<_DesktopUserResultTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SKAvatar(
                initials: widget.user.avatarInitials,
                backgroundColor: widget.user.avatarColor,
                imageUrl: widget.user.avatarUrl,
                size: 44,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.skWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${widget.user.username}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: AppColors.skMuted.withOpacity(0.7),
                      ),
                    ),
                    if (widget.user.bio.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.user.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: AppColors.skMuted.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.skMuted.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopPostResultTile extends StatefulWidget {
  final PostModel post;
  final UserModel user;
  final String query;
  final VoidCallback onTap;

  const _DesktopPostResultTile({
    required this.post,
    required this.user,
    required this.query,
    required this.onTap,
  });

  @override
  State<_DesktopPostResultTile> createState() => _DesktopPostResultTileState();
}

class _DesktopPostResultTileState extends State<_DesktopPostResultTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (widget.post.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E103A), Color(0xFF2D1040)],
                      ),
                    ),
                    child: PostImage(
                      imageUrl: widget.post.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (widget.post.imageUrl.isNotEmpty) const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User row
                    Row(
                      children: [
                        SKAvatar(
                          initials: widget.user.avatarInitials,
                          backgroundColor: widget.user.avatarColor,
                          imageUrl: widget.user.avatarUrl,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.user.username,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.skWhite,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo(widget.post.createdAt),
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.skMuted.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildHighlightedCaption(widget.post.caption),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded,
                            size: 14,
                            color: AppColors.skMuted.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.post.likes.length} suka',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.skMuted.withOpacity(0.5),
                          ),
                        ),
                        if (widget.post.location.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.skMuted.withOpacity(0.5)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              widget.post.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                color: AppColors.skMuted.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedCaption(String caption) {
    if (widget.query.isEmpty) {
      return Text(
        caption,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          color: AppColors.skWhite.withOpacity(0.7),
          height: 1.4,
        ),
      );
    }

    final lowerCaption = caption.toLowerCase();
    final lowerQuery = widget.query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (start < caption.length) {
      final matchIdx = lowerCaption.indexOf(lowerQuery, start);
      if (matchIdx == -1) {
        spans.add(TextSpan(text: caption.substring(start)));
        break;
      }
      if (matchIdx > start) {
        spans.add(TextSpan(text: caption.substring(start, matchIdx)));
      }
      spans.add(TextSpan(
        text: caption.substring(matchIdx, matchIdx + widget.query.length),
        style: const TextStyle(
          color: AppColors.skRose,
          fontWeight: FontWeight.w700,
        ),
      ));
      start = matchIdx + widget.query.length;
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          color: AppColors.skWhite.withOpacity(0.7),
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DESKTOP POST DETAIL DIALOG — Instagram-style split layout
// ══════════════════════════════════════════════════════════════

class _DesktopPostDetailDialog extends StatefulWidget {
  final PostModel post;
  final UserModel? postUser;

  const _DesktopPostDetailDialog({
    required this.post,
    this.postUser,
  });

  @override
  State<_DesktopPostDetailDialog> createState() => _DesktopPostDetailDialogState();
}

class _DesktopPostDetailDialogState extends State<_DesktopPostDetailDialog> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<CommentProvider>().fetchComments(widget.post.id);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onSubmitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final success = await context
        .read<CommentProvider>()
        .addComment(context, widget.post.id, text);

    if (success) {
      _commentController.clear();
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  void _onToggleLike() {
    final auth = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    final wasLiked = postProvider.isLiked(widget.post.id, currentUserId);
    postProvider.toggleLike(widget.post.id, currentUserId);

    // Tambah notifikasi like jika bukan postingan sendiri
    if (!wasLiked && widget.post.userId != currentUserId) {
      context.read<NotificationProvider>().addNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: NotificationType.like,
          fromUserId: currentUserId,
          postId: widget.post.id,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final commentProvider = context.watch<CommentProvider>();
    final currentUserId = auth.currentUser?.id ?? '';
    final isLiked = postProvider.isLiked(widget.post.id, currentUserId);
    final post = postProvider.getPostById(widget.post.id) ?? widget.post;
    final comments = commentProvider.getCommentsForPost(widget.post.id);
    final commentCount = postProvider.getCommentCount(widget.post.id);
    final user = widget.postUser;

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.7).clamp(600.0, 960.0);
    final dialogHeight = (MediaQuery.of(context).size.height * 0.75).clamp(400.0, 640.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: AppColors.skDark2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // ── Gambar Kiri ──
              Expanded(
                flex: 3,
                child: Container(
                  color: AppColors.skDark,
                  child: post.imageUrl.isNotEmpty
                      ? PostImage(
                          imageUrl: post.imageUrl,
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article_outlined, size: 48,
                                  color: AppColors.skMuted.withOpacity(0.3)),
                              const SizedBox(height: 10),
                              Text(
                                post.caption.length > 60
                                    ? '${post.caption.substring(0, 60)}...'
                                    : post.caption,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  color: AppColors.skMuted.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // ── Divider vertikal ──
              Container(width: 1, color: Colors.white.withOpacity(0.06)),

              // ── Info Kanan ──
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Header — Author info + close
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (user != null) ...[
                            SKAvatar(
                              initials: user.avatarInitials,
                              backgroundColor: user.avatarColor,
                              imageUrl: user.avatarUrl,
                              size: 34,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.skWhite,
                                    ),
                                  ),
                                  if (post.location.isNotEmpty)
                                    Text(
                                      post.location,
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11,
                                        color: AppColors.skMuted.withOpacity(0.6),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ] else
                            const Expanded(
                              child: Text('Pengguna',
                                  style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      color: AppColors.skWhite)),
                            ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                              child: const Icon(Icons.close, size: 14, color: AppColors.skMuted),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Caption
                    if (post.caption.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.caption,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: AppColors.skWhite,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Tags
                            if (post.tags.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                children: post.tags.map((tag) {
                                  return Text(
                                    '#$tag',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12,
                                      color: AppColors.skViolet.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              timeAgo(post.createdAt),
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                color: AppColors.skMuted.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Like & Comment count bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Like button
                          GestureDetector(
                            onTap: _onToggleLike,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                key: ValueKey(isLiked),
                                size: 22,
                                color: isLiked ? AppColors.skRose : AppColors.skMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.likes.length}',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.skWhite,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 20, color: AppColors.skMuted),
                          const SizedBox(width: 6),
                          Text(
                            '${commentCount > 0 ? commentCount : comments.length}',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.skWhite,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Comments section
                    Expanded(
                      child: commentProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.skRose,
                                strokeWidth: 2,
                              ),
                            )
                          : comments.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          size: 28,
                                          color: AppColors.skMuted.withOpacity(0.3)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Belum ada komentar',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 12,
                                          color: AppColors.skMuted.withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Jadilah yang pertama berkomentar!',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 11,
                                          color: AppColors.skMuted.withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    return _buildCommentTile(comments[index]);
                                  },
                                ),
                    ),

                    // Comment input
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.06)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: AppColors.skWhite,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tulis komentar...',
                                hintStyle: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 13,
                                  color: AppColors.skMuted.withOpacity(0.4),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onSubmitted: (_) => _onSubmitComment(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _onSubmitComment,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.skGradientBtn,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    UserModel? commentUser;
    try {
      commentUser = dummyUsers.firstWhere((u) => u.id == comment.userId);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SKAvatar(
            initials: commentUser?.avatarInitials ?? 'U',
            backgroundColor: commentUser?.avatarColor ?? Colors.grey,
            imageUrl: commentUser?.avatarUrl ?? '',
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      color: AppColors.skWhite,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: '${commentUser?.username ?? 'user'} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: comment.text,
                        style: TextStyle(
                          color: AppColors.skWhite.withOpacity(0.8),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeAgo(comment.createdAt),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    color: AppColors.skMuted.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
