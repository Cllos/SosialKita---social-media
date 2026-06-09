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
import '../profile/other_profile_screen.dart';
import '../post/post_detail_screen.dart';
import '../../widgets/post/post_image.dart';

/// SearchScreen — Halaman Search / Explore
///
/// Dua mode tampilan:
/// 1. **Mode Default (Explore Grid)** — grid 3 kolom berisi thumbnail
///    semua postingan, ala Instagram Explore / TikTok
/// 2. **Mode Aktif (Search Results)** — list hasil pencarian dengan
///    tab Pengguna / Postingan
///
/// Transisi antar mode menggunakan AnimatedSwitcher.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
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
      // Rebuild saat focus berubah (untuk border highlight)
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
    return Column(
      children: [
        // ── Search Bar ──
        _buildSearchBar(),

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
    );
  }

  // ══════════════════════════════════════
  //  SEARCH BAR
  // ══════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
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
              size: 20,
              color: _isSearching
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
                  hintText: 'Cari pengguna, postingan, tagar...',
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
            if (_isSearching)
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
      ),
    );
  }

  // ══════════════════════════════════════
  //  EXPLORE GRID (mode default)
  // ══════════════════════════════════════

  Widget _buildExploreGrid() {
    final postProvider = context.watch<PostProvider>();
    final allPosts = postProvider.getAllPosts();

    if (allPosts.isEmpty) {
      return Center(
        key: const ValueKey('explore-empty'),
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
      key: const ValueKey('explore-grid'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Staggered header: 1 item besar + 2 kecil
        SliverToBoxAdapter(
          child: _buildStaggeredHeader(allPosts),
        ),

        // Regular 3-column grid untuk sisa postingan
        SliverPadding(
          padding: const EdgeInsets.only(top: 2),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Skip yang sudah ditampilkan di staggered header
                final postIndex = index + 3;
                if (postIndex >= allPosts.length) return null;
                return _ExploreGridTile(post: allPosts[postIndex]);
              },
              childCount: max(0, allPosts.length - 3),
            ),
          ),
        ),

        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  /// Layout staggered: 1 gambar besar (kiri) + 2 gambar kecil (kanan)
  /// Mirip Instagram Explore header
  Widget _buildStaggeredHeader(List<PostModel> posts) {
    if (posts.length < 3) {
      // Jika kurang dari 3, tampilkan apa adanya
      return Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: posts
              .map((p) => Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _ExploreGridTile(post: p),
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.width * 2 / 3,
      child: Row(
        children: [
          // Item besar (kiri) — 2/3 lebar
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: _ExploreGridTile(
                post: posts[0],
                isFeatured: true,
              ),
            ),
          ),

          // 2 item kecil (kanan) — 1/3 lebar, stacked
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: _ExploreGridTile(post: posts[1]),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: _ExploreGridTile(post: posts[2]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  //  SEARCH RESULTS (mode aktif)
  // ══════════════════════════════════════

  Widget _buildSearchResults() {
    return Column(
      key: const ValueKey('search-results'),
      children: [
        // ── Tab Bar ──
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
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
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: 'Pengguna', height: 36),
              Tab(text: 'Postingan', height: 36),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Tab Content ──
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
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentUser?.id ?? '';
    final results = userProvider.searchUsers(_query);
    final filtered = results.where((u) => u.role != 'moderator').toList();

    if (filtered.isEmpty) return _buildEmptyState('pengguna');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final user = filtered[index];
        return _UserResultTile(
          user: user,
          currentUserId: currentUserId,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        UserModel? postUser;
        try {
          postUser = dummyUsers.firstWhere((u) => u.id == post.userId);
        } catch (_) {
          postUser = null;
        }
        if (postUser == null) return const SizedBox.shrink();

        return _PostResultTile(
          post: post,
          user: postUser,
          query: _query,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: post.id),
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
//  WIDGET PENDUKUNG — EXPLORE GRID
// ══════════════════════════════════════════════════════════════

/// Tile thumbnail pada Explore Grid
/// Murni visual tanpa label/teks — sesuai spec Instagram Explore
class _ExploreGridTile extends StatelessWidget {
  final PostModel post;
  final bool isFeatured;

  const _ExploreGridTile({
    required this.post,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(postId: post.id),
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
            // Gambar thumbnail
            if (post.imageUrl.isNotEmpty)
              PostImage(
                imageUrl: post.imageUrl,
                fit: BoxFit.cover,
              )
            else
              _buildPlaceholder(),

            // Overlay gradient subtle di bawah (agar statistik terlihat)
            if (isFeatured)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Badge like count (pojok kanan bawah, hanya featured)
            if (isFeatured && post.likes.isNotEmpty)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes.length}',
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

            // Badge multi-image (koleksi) — untuk menunjukkan ada gambar
            if (!isFeatured && post.tags.isNotEmpty)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.collections_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        isFeatured ? Icons.image_outlined : Icons.article_outlined,
        color: AppColors.skMuted.withOpacity(0.3),
        size: isFeatured ? 40 : 24,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  WIDGET PENDUKUNG — SEARCH RESULTS
// ══════════════════════════════════════════════════════════════

/// Tile hasil pencarian user
class _UserResultTile extends StatelessWidget {
  final UserModel user;
  final String currentUserId;
  final VoidCallback onTap;

  const _UserResultTile({
    required this.user,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isFollowing = userProvider.isFollowing(currentUserId, user.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SKAvatar(
              imageUrl: user.avatarUrl,
              initials: user.avatarInitials,
              backgroundColor: user.avatarColor,
              size: 44,
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.skMuted.withOpacity(0.7),
                    ),
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      user.bio,
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
            // Tombol Follow / Mengikuti
            GestureDetector(
              onTap: () {
                userProvider.toggleFollow(currentUserId, user.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isFollowing
                      ? Colors.white.withOpacity(0.06)
                      : AppColors.skRose.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isFollowing
                        ? Colors.white.withOpacity(0.08)
                        : AppColors.skRose.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isFollowing ? 'Mengikuti' : 'Follow',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isFollowing ? AppColors.skMuted : AppColors.skRose,
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

/// Tile hasil pencarian postingan
class _PostResultTile extends StatelessWidget {
  final PostModel post;
  final UserModel user;
  final String query;
  final VoidCallback onTap;

  const _PostResultTile({
    required this.post,
    required this.user,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail gambar (jika ada)
            if (post.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E103A), Color(0xFF2D1040)],
                    ),
                  ),
                  child: PostImage(
                    imageUrl: post.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (post.imageUrl.isNotEmpty) const SizedBox(width: 12),

            // Info postingan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      SKAvatar(
                        imageUrl: user.avatarUrl,
                        initials: user.avatarInitials,
                        backgroundColor: user.avatarColor,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.skWhite,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeAgo(post.createdAt),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: AppColors.skMuted.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Caption (highlight query)
                  _buildHighlightedCaption(post.caption),
                  const SizedBox(height: 6),

                  // Stats
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 13,
                        color: AppColors.skMuted.withOpacity(0.5),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${post.likes.length}',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: AppColors.skMuted.withOpacity(0.5),
                        ),
                      ),
                      if (post.location.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.skMuted.withOpacity(0.5),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            post.location,
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
    );
  }

  /// Highlight kata yang cocok dengan query di dalam caption
  Widget _buildHighlightedCaption(String caption) {
    if (query.isEmpty) {
      return Text(
        caption,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12,
          color: AppColors.skWhite.withOpacity(0.7),
          height: 1.4,
        ),
      );
    }

    final lowerCaption = caption.toLowerCase();
    final lowerQuery = query.toLowerCase();
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
        text: caption.substring(matchIdx, matchIdx + query.length),
        style: const TextStyle(
          color: AppColors.skRose,
          fontWeight: FontWeight.w700,
        ),
      ));
      start = matchIdx + query.length;
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12,
          color: AppColors.skWhite.withOpacity(0.7),
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }
}
