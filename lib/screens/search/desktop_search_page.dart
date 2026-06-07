import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/time_ago.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../widgets/layout/desktop_sidebar.dart';
import '../profile/other_profile_screen.dart';

/// DesktopSearchPage — Halaman pencarian full-page untuk desktop
/// Layout: sidebar kiri + konten pencarian di tengah
class DesktopSearchPage extends StatefulWidget {
  const DesktopSearchPage({super.key});

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
    setState(() => _query = value.trim());
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: Row(
        children: [
          // ── Sidebar Kiri ──
          DesktopSidebar(
            selectedIndex: 1, // Index Cari
            onItemTap: (idx) {
              if (idx != 1) Navigator.pop(context);
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
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Detail postingan — segera hadir'),
                backgroundColor: AppColors.skCard,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Detail postingan — segera hadir'),
              backgroundColor: AppColors.skCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
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
                Image.network(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.skRose,
                        strokeWidth: 2,
                      ),
                    );
                  },
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
                    child: Image.network(
                      widget.post.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.skMuted.withOpacity(0.4),
                          size: 28,
                        ),
                      ),
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
