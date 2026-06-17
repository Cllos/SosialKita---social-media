import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/time_ago.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../screens/profile/other_profile_screen.dart';
import '../../screens/post/comment_sheet.dart';
import '../../screens/post/share_sheet.dart';
import '../common/sk_avatar.dart';
import 'post_image.dart';

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
      if (widget.post.userId != widget.currentUserId) {
        context.read<NotificationProvider>().addNotification(
          NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.like,
            fromUserId: widget.currentUserId,
            postId: widget.post.id,
            createdAt: DateTime.now(),
            isRead: false,
          ),
        );
      }
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
    final postProvider = context.read<PostProvider>();
    final isCurrentlyLiked = postProvider.isLiked(widget.post.id, widget.currentUserId);
    postProvider.toggleLike(widget.post.id, widget.currentUserId);

    if (!isCurrentlyLiked && widget.post.userId != widget.currentUserId) {
      context.read<NotificationProvider>().addNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: NotificationType.like,
          fromUserId: widget.currentUserId,
          postId: widget.post.id,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );
    }
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
        final isSaved = context.watch<AuthProvider>().isSaved(post.id);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              _buildHeader(user, post, postProvider),
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
              _buildActions(post, isLiked, commentCount, isSaved),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel user, PostModel post, PostProvider postProvider) {
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
                imageUrl: user.avatarUrl,
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
                      color: AppColors.skMuted.withValues(alpha: 0.8),
                    ),
                  )
                else
                  Text(
                    timeAgo(post.createdAt),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.skMuted.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showPostOptions(context, post, postProvider),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.more_horiz,
              color: AppColors.skMuted.withValues(alpha: 0.6),
              size: 18,
            ),
          ),
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
              child: PostImage(
                imageUrl: post.imageUrl,
                fit: BoxFit.cover,
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

  Widget _buildActions(PostModel post, bool isLiked, int commentCount, bool isSaved) {
    return Row(
      children: [
        // Like
        _ActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: post.likes.isNotEmpty ? '${post.likes.length}' : '',
          color: isLiked ? AppColors.skRose : AppColors.skMuted,
          onTap: _onTapLike,
        ),
        const SizedBox(width: 14),

        // Komentar
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: commentCount > 0 ? '$commentCount' : '',
          color: AppColors.skMuted,
          onTap: () => _showCommentsBottomSheet(context, post.id),
        ),
        const SizedBox(width: 14),

        // Share
        _ActionButton(
          icon: Icons.send_outlined,
          label: '',
          color: AppColors.skMuted,
          onTap: () => _showShareBottomSheet(context, post),
        ),

        const Spacer(),

        // Bookmark
        _ActionButton(
          icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
          label: '',
          color: isSaved ? AppColors.skRose : AppColors.skMuted,
          onTap: () {
            context.read<AuthProvider>().toggleSavePost(post.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isSaved ? 'Dihapus dari postingan disimpan' : 'Postingan disimpan'),
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

  void _showCommentsBottomSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75, // 75% dari tinggi layar
          child: CommentSheet(postId: postId),
        );
      },
    );
  }

  void _showShareBottomSheet(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ShareSheet(post: post);
      },
    );
  }

  void _showPostOptions(BuildContext context, PostModel post, PostProvider postProvider) {
    final isOwn = post.userId == widget.currentUserId;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.skCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (isOwn) ...[
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.skRose),
                    title: const Text(
                      'Hapus Postingan',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: AppColors.skRose,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _confirmDeletePost(context, post, postProvider);
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.outlined_flag, color: Colors.amber),
                    title: const Text(
                      'Laporkan Postingan',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: AppColors.skWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _showReportDialog(context, post, postProvider);
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.close, color: AppColors.skMuted),
                  title: const Text(
                    'Batal',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      color: AppColors.skMuted,
                    ),
                  ),
                  onTap: () => Navigator.pop(sheetCtx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePost(BuildContext context, PostModel post, PostProvider postProvider) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.skCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          title: const Text(
            'Hapus Postingan?',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.bold,
              color: AppColors.skWhite,
            ),
          ),
          content: const Text(
            'Tindakan ini permanen dan tidak dapat dibatalkan.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              color: AppColors.skMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.skMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                postProvider.deletePost(post.id);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Postingan berhasil dihapus 🗑️'),
                    backgroundColor: AppColors.skCard,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.skRose,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, PostModel post, PostProvider postProvider) {
    final reasons = [
      'Spam / Iklan tidak diinginkan',
      'Ujaran kebencian / Pelecehan',
      'Konten seksual / Tidak pantas',
      'Kekerasan / Ancaman berbahaya',
      'Lainnya'
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.skCard,
          title: const Text(
            'Pilih Alasan Laporan',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.bold,
              color: AppColors.skWhite,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          contentPadding: const EdgeInsets.only(top: 10, bottom: 20),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reasons.length,
              itemBuilder: (context, index) {
                final reason = reasons[index];
                return ListTile(
                  title: Text(
                    reason,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.skWhite,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.skMuted),
                  onTap: () {
                    postProvider.reportPost(post.id, widget.currentUserId);
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Laporan Anda telah terkirim. Terima kasih! 🛡️'),
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
            ),
          ),
        );
      },
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
