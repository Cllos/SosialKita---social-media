import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/time_ago.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/comment_provider.dart';
import '../../screens/profile/other_profile_screen.dart';
import '../common/sk_avatar.dart';

/// PostCard — Card postingan di feed
/// Menampilkan header (avatar, nama, lokasi), gambar, caption, dan aksi
class PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUserId;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimController;
  late Animation<double> _heartScale;
  bool _showHeartOverlay = false;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heartScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartAnimController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  UserModel? get _postUser {
    try {
      return dummyUsers.firstWhere((u) => u.id == widget.post.userId);
    } catch (_) {
      return null;
    }
  }

  void _onDoubleTapImage() {
    final postProvider = context.read<PostProvider>();
    if (!postProvider.isLiked(widget.post.id, widget.currentUserId)) {
      postProvider.toggleLike(widget.post.id, widget.currentUserId);
    }
    setState(() => _showHeartOverlay = true);
    _heartAnimController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _showHeartOverlay = false);
        }
      });
    });
  }

  void _onTapLike() {
    context
        .read<PostProvider>()
        .toggleLike(widget.post.id, widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final user = _postUser;
    if (user == null) return const SizedBox.shrink();

    return Consumer2<PostProvider, CommentProvider>(
      builder: (context, postProvider, commentProvider, _) {
        final post = postProvider.getPostById(widget.post.id) ?? widget.post;
        final isLiked = postProvider.isLiked(post.id, widget.currentUserId);
        final commentCount = commentProvider.commentCount(post.id);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              _buildHeader(user, post),
              const SizedBox(height: 10),

              // ── Gambar ──
              if (post.imageUrl.isNotEmpty) ...[
                _buildImage(post),
                const SizedBox(height: 10),
              ],

              // ── Caption ──
              _buildCaption(user, post),
              const SizedBox(height: 10),

              // ── Aksi ──
              _buildActions(post, isLiked, commentCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel user, PostModel post) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Navigasi ke profil user (jika bukan diri sendiri)
            if (user.id != widget.currentUserId) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtherProfileScreen(userId: user.id),
                ),
              );
            }
          },
          child: Row(
            children: [
              SKAvatar(
                initials: user.avatarInitials,
                backgroundColor: user.avatarColor,
                size: 36,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (user.id != widget.currentUserId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtherProfileScreen(userId: user.id),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.skWhite,
                  ),
                ),
                if (post.location.isNotEmpty)
                  Text(
                    '${post.location} · ${timeAgo(post.createdAt)}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.skMuted.withOpacity(0.8),
                    ),
                  )
                else
                  Text(
                    timeAgo(post.createdAt),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.skMuted.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Icon(
          Icons.more_horiz,
          color: AppColors.skMuted.withOpacity(0.6),
          size: 18,
        ),
      ],
    );
  }

  Widget _buildImage(PostModel post) {
    return GestureDetector(
      onDoubleTap: _onDoubleTapImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E103A), Color(0xFF2D1040)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.skMuted,
                    size: 40,
                  ),
                ),
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
              ),
            ),
          ),
          // Heart overlay animation
          if (_showHeartOverlay)
            ScaleTransition(
              scale: _heartScale,
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 64,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaption(UserModel user, PostModel post) {
    // Parse caption: bold username + teks + hashtag berwarna violet
    final parts = _parseCaptionParts(post.caption);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12.5,
          color: Color(0xFFC4B5D4),
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: '${user.username} ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.skWhite,
            ),
          ),
          ...parts,
        ],
      ),
    );
  }

  List<TextSpan> _parseCaptionParts(String caption) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'#\w+');
    int lastEnd = 0;

    for (final match in regex.allMatches(caption)) {
      // Teks biasa sebelum hashtag
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: caption.substring(lastEnd, match.start)));
      }
      // Hashtag berwarna violet
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(color: AppColors.skViolet),
      ));
      lastEnd = match.end;
    }
    // Sisa teks setelah hashtag terakhir
    if (lastEnd < caption.length) {
      spans.add(TextSpan(text: caption.substring(lastEnd)));
    }
    return spans;
  }

  Widget _buildActions(PostModel post, bool isLiked, int commentCount) {
    return Row(
      children: [
        // Like
        _ActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: post.likes.length > 0 ? '${post.likes.length}' : '',
          color: isLiked ? AppColors.skRose : AppColors.skMuted,
          onTap: _onTapLike,
        ),
        const SizedBox(width: 14),

        // Komentar
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: commentCount > 0 ? '$commentCount' : '',
          color: AppColors.skMuted,
          onTap: () {
            // TODO: Navigasi ke PostDetailScreen
          },
        ),
        const SizedBox(width: 14),

        // Share
        _ActionButton(
          icon: Icons.send_outlined,
          label: '',
          color: AppColors.skMuted,
          onTap: () {},
        ),

        const Spacer(),

        // Bookmark
        _ActionButton(
          icon: Icons.bookmark_border,
          label: '',
          color: AppColors.skMuted,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Postingan disimpan'),
                backgroundColor: AppColors.skCard,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Widget tombol aksi (like, komentar, share, bookmark)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
