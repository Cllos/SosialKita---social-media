import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/utils/dummy_data.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

/// UserProvider — mengelola state follow/unfollow dan pencarian user dengan API Backend MySQL
class UserProvider extends ChangeNotifier {
  final _storage = LocalStorageService.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  UserProvider() {
    // Konstruktor kosong
  }

  /// Toggle follow / unfollow ke database MySQL
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    final currentIdx = dummyUsers.indexWhere((u) => u.id == currentUserId);
    final targetIdx = dummyUsers.indexWhere((u) => u.id == targetUserId);
    
    if (currentIdx == -1 || targetIdx == -1) return;

    final current = dummyUsers[currentIdx];
    final target = dummyUsers[targetIdx];

    final following = List<String>.from(current.following);
    final followers = List<String>.from(target.followers);

    final originallyFollowing = following.contains(targetUserId);

    // Optimistic UI update
    if (originallyFollowing) {
      following.remove(targetUserId);
      followers.remove(currentUserId);
    } else {
      following.add(targetUserId);
      followers.add(currentUserId);
    }

    dummyUsers[currentIdx] = current.copyWith(following: following);
    dummyUsers[targetIdx] = target.copyWith(followers: followers);
    notifyListeners();

    try {
      final res = await ApiService.post('/follows/$targetUserId', null);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final isFollowing = body['data']['is_following'] as bool;
          
          // Sinkronisasi data real dari backend
          final finalFollowing = List<String>.from(dummyUsers[currentIdx].following);
          final finalFollowers = List<String>.from(dummyUsers[targetIdx].followers);

          if (isFollowing) {
            if (!finalFollowing.contains(targetUserId)) finalFollowing.add(targetUserId);
            if (!finalFollowers.contains(currentUserId)) finalFollowers.add(currentUserId);
          } else {
            finalFollowing.remove(targetUserId);
            finalFollowers.remove(currentUserId);
          }

          dummyUsers[currentIdx] = dummyUsers[currentIdx].copyWith(following: finalFollowing);
          dummyUsers[targetIdx] = dummyUsers[targetIdx].copyWith(followers: finalFollowers);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Toggle Follow Error: $e');
      // Rollback jika gagal
      dummyUsers[currentIdx] = current;
      dummyUsers[targetIdx] = target;
      notifyListeners();
    }
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

  /// Memicu fetch profil user secara asinkron dari backend
  Future<UserModel?> fetchUserProfile(String username) async {
    try {
      final res = await ApiService.get('/users/$username');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final data = body['data'];
          upsertUserFromBackend(data, resolveUrl: ApiService.resolveImageUrl);
          return getUserById(data['id'].toString());
        }
      }
    } catch (e) {
      debugPrint('Fetch User Profile Error: $e');
    }
    return null;
  }

  /// Memicu fetch followers/following user
  Future<void> fetchFollowersAndFollowing(String userId) async {
    try {
      final resFollowers = await ApiService.get('/users/$userId/followers');
      final resFollowing = await ApiService.get('/users/$userId/following');

      final followersList = <String>[];
      if (resFollowers.statusCode == 200) {
        final body = jsonDecode(resFollowers.body);
        if (body['success'] == true) {
          for (final f in body['data']) {
            upsertUserFromBackend(f, resolveUrl: ApiService.resolveImageUrl);
            followersList.add(f['id'].toString());
          }
        }
      }

      final followingList = <String>[];
      if (resFollowing.statusCode == 200) {
        final body = jsonDecode(resFollowing.body);
        if (body['success'] == true) {
          for (final f in body['data']) {
            upsertUserFromBackend(f, resolveUrl: ApiService.resolveImageUrl);
            followingList.add(f['id'].toString());
          }
        }
      }

      final idx = dummyUsers.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        dummyUsers[idx] = dummyUsers[idx].copyWith(
          followers: followersList,
          following: followingList,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch Followers/Following Error: $e');
    }
  }

  /// Pencarian user secara asinkron (API) + sinkron (Cache)
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return [];
    
    final q = query.toLowerCase();
    return dummyUsers
        .where((u) =>
            u.username.toLowerCase().contains(q) ||
            u.displayName.toLowerCase().contains(q))
        .toList();
  }

  /// Fungsi untuk memanggil endpoint pencarian backend
  Future<void> searchUsersApi(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final res = await ApiService.get('/users/search?q=$query');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          for (final json in data) {
            upsertUserFromBackend(json, resolveUrl: ApiService.resolveImageUrl);
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Search users API error: $e');
    }
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
