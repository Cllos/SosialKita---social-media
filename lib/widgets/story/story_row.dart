import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../models/user_model.dart';
import '../common/sk_avatar.dart';

/// StoryRow — Baris story horizontal di atas feed
/// Menampilkan tombol "+" untuk add story + avatar user yang diikuti
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
    // Ambil user yang diikuti
    final followedUsers = dummyUsers
        .where((u) => following.contains(u.id))
        .toList();

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Tombol add story
          _buildAddStory(),
          const SizedBox(width: 10),
          // Story dari user yang diikuti
          ...followedUsers.map((user) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildStoryItem(user),
              )),
          // Jika belum follow siapapun, tampilkan semua user
          if (followedUsers.isEmpty)
            ...dummyUsers
                .where((u) => u.id != currentUserId && u.role != 'moderator')
                .take(5)
                .map((user) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildStoryItem(user),
                    )),
        ],
      ),
    );
  }

  Widget _buildAddStory() {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.skMuted,
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kamu',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10,
            color: AppColors.skMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(UserModel user) {
    return Column(
      children: [
        SKAvatar(
          initials: user.avatarInitials,
          backgroundColor: user.avatarColor,
          size: 48,
          showRing: true,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 54,
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
    );
  }
}
