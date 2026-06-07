import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/time_ago.dart';
import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/comment_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../widgets/post/post_card.dart';

/// PostDetailScreen — Menampilkan detail postingan dan komentar di bawahnya
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final commentProvider = context.read<CommentProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    final newComment = CommentModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.postId,
      userId: currentUser.id,
      text: text,
      createdAt: DateTime.now(),
    );

    commentProvider.addComment(newComment);
    _commentController.clear();

    // Scroll otomatis ke bawah agar komentar baru terlihat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return const Scaffold();

    final postProvider = context.watch<PostProvider>();
    final post = postProvider.getPostById(widget.postId);

    if (post == null) {
      return Scaffold(
        backgroundColor: AppColors.skDark,
        appBar: AppBar(
          backgroundColor: AppColors.skDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.skWhite),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'Postingan tidak ditemukan atau telah dihapus.',
            style: TextStyle(color: AppColors.skWhite),
          ),
        ),
      );
    }

    final commentProvider = context.watch<CommentProvider>();
    final comments = commentProvider.getCommentsForPost(widget.postId);

    return Scaffold(
      backgroundColor: AppColors.skDark,
      appBar: AppBar(
        backgroundColor: AppColors.skDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.skWhite),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.skGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'Postingan',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withOpacity(0.05),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Konten Detail
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Postingan
                  PostCard(
                    post: post,
                    currentUserId: currentUser.id,
                  ),

                  // Divider pemisah komentar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Komentar (${comments.length})',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.skWhite,
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                    margin: const EdgeInsets.only(bottom: 12),
                  ),

                  // List Komentar
                  comments.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 40,
                                  color: AppColors.skMuted.withOpacity(0.3),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Belum ada komentar',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 13,
                                    color: AppColors.skMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final commentUser = _getCommentUser(comment.userId);

                            if (commentUser == null) return const SizedBox.shrink();

                            final isMyComment = comment.userId == currentUser.id;
                            final isModerator = currentUser.role == 'moderator';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SKAvatar(
                                    imageUrl: commentUser.avatarUrl,
                                    initials: commentUser.avatarInitials,
                                    backgroundColor: commentUser.avatarColor,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              commentUser.username,
                                              style: const TextStyle(
                                                fontFamily: 'DM Sans',
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.skWhite,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              timeAgo(comment.createdAt),
                                              style: TextStyle(
                                                fontFamily: 'DM Sans',
                                                fontSize: 10,
                                                color: AppColors.skMuted.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          comment.text,
                                          style: const TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 12.5,
                                            color: Color(0xFFC4B5D4),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isMyComment || isModerator)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.skRose),
                                      onPressed: () {
                                        commentProvider.deleteComment(comment.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Komentar dihapus'),
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
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),

          // Input field komentar di bawah
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.skDark2,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                SKAvatar(
                  imageUrl: currentUser.avatarUrl,
                  initials: currentUser.avatarInitials,
                  backgroundColor: currentUser.avatarColor,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        color: AppColors.skWhite,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan komentar...',
                        hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.5,
                          color: AppColors.skMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitComment,
                  child: ShaderMask(
                    shaderCallback: (bounds) => AppColors.skGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: const Text(
                      'Kirim',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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

  // Helper untuk detail user
  UserModel? _getCommentUser(String userId) {
    try {
      return dummyUsers.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }
}
