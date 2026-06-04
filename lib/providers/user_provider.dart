import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../core/utils/dummy_data.dart';

/// UserProvider — mengelola state follow/unfollow dan pencarian user
class UserProvider extends ChangeNotifier {
  /// Toggle follow / unfollow
  void toggleFollow(String currentUserId, String targetUserId) {
    final currentIdx = dummyUsers.indexWhere((u) => u.id == currentUserId);
    final targetIdx = dummyUsers.indexWhere((u) => u.id == targetUserId);
    if (currentIdx == -1 || targetIdx == -1) return;

    final current = dummyUsers[currentIdx];
    final target = dummyUsers[targetIdx];

    final following = List<String>.from(current.following);
    final followers = List<String>.from(target.followers);

    if (following.contains(targetUserId)) {
      // Unfollow
      following.remove(targetUserId);
      followers.remove(currentUserId);
    } else {
      // Follow
      following.add(targetUserId);
      followers.add(currentUserId);
    }

    dummyUsers[currentIdx] = current.copyWith(following: following);
    dummyUsers[targetIdx] = target.copyWith(followers: followers);
    notifyListeners();
  }

  /// Cek apakah sudah follow
  bool isFollowing(String currentUserId, String targetUserId) {
    try {
      final user = dummyUsers.firstWhere((u) => u.id == currentUserId);
      return user.following.contains(targetUserId);
    } catch (_) {
      return false;
    }
  }

  /// Mendapatkan user berdasarkan ID
  UserModel? getUserById(String userId) {
    try {
      return dummyUsers.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  /// Pencarian user berdasarkan username / displayName
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return dummyUsers
        .where((u) =>
            u.username.toLowerCase().contains(q) ||
            u.displayName.toLowerCase().contains(q))
        .toList();
  }

  /// Saran user (belum difollow)
  List<UserModel> getSuggestions(String currentUserId) {
    try {
      final current = dummyUsers.firstWhere((u) => u.id == currentUserId);
      return dummyUsers
          .where((u) =>
              u.id != currentUserId &&
              u.role != 'moderator' &&
              !current.following.contains(u.id))
          .take(5)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
