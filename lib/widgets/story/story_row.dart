import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../../screens/story/story_view_screen.dart';
import '../common/sk_avatar.dart';
import 'add_story_sheet.dart';

/// StoryRow — Baris story horizontal di atas feed
/// Menampilkan tombol "+" untuk add/view story Anda, serta avatar teman yang diikuti
class StoryRow extends StatelessWidget {
  final String currentUserId;
  final List<String> following;

  const StoryRow({
    super.key,
    required this.currentUserId,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return const SizedBox.shrink();

    // Ambil user yang diikuti
    final followedUsers = dummyUsers
        .where((u) => following.contains(u.id))
        .toList();

    // Jika belum follow siapa pun, rekomendasikan beberapa user lain
    final displayUsers = followedUsers.isNotEmpty
        ? followedUsers
        : dummyUsers
            .where((u) => u.id != currentUserId && u.role != 'moderator')
            .take(5)
            .toList();

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // ── Cerita Anda (Add / View Story) ──
          _buildMyStoryItem(context, currentUser, storyProvider),
          const SizedBox(width: 12),

          // ── Cerita Pengguna Lain ──
          ...displayUsers.map((user) {
            final hasStory = storyProvider.hasActiveStory(user.id);
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildStoryItem(context, user, hasStory, storyProvider),
            );
          }),
        ],
      ),
    );
  }

  /// Item cerita untuk akun sendiri (menggabungkan fungsi view story dan upload +)
  Widget _buildMyStoryItem(BuildContext context, UserModel me, StoryProvider storyProvider) {
    final myStories = storyProvider.getStoriesByUser(me.id);
    final hasStories = myStories.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasStories) {
          // View story saya
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoryViewScreen(stories: myStories, user: me),
            ),
          );
        } else {
          // Tambah story baru
          _showAddStorySheet(context);
        }
      },
      child: Column(
        children: [
          Stack(
            children: [
              // Avatar lingkaran (ring menyala jika ada story aktif)
              SKAvatar(
                initials: me.avatarInitials,
                backgroundColor: me.avatarColor,
                size: 48,
                showRing: hasStories,
              ),

              // Tombol "+" overlay di pojok kanan bawah
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showAddStorySheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.skDark,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.skRose,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Cerita Anda',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10,
              color: AppColors.skMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Item cerita pengguna lain
  Widget _buildStoryItem(BuildContext context, UserModel user, bool hasStory, StoryProvider storyProvider) {
    return GestureDetector(
      onTap: () {
        if (hasStory) {
          final userStories = storyProvider.getStoriesByUser(user.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoryViewScreen(stories: userStories, user: user),
            ),
          );
        } else {
          // Jika tidak ada story
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('@${user.username} belum mengunggah cerita baru'),
              backgroundColor: AppColors.skCard,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Column(
        children: [
          SKAvatar(
            initials: user.avatarInitials,
            backgroundColor: user.avatarColor,
            size: 48,
            // Ring gradient rose-violet aktif jika user memiliki story baru
            showRing: hasStory,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 56,
            child: Text(
              user.username,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                color: AppColors.skMuted,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Menampilkan sheet pembuatan story baru
  void _showAddStorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddStorySheet();
      },
    );
  }
}
