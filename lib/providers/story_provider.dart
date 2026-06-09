import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, Uint8List;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/story_model.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../core/utils/dummy_data.dart';

/// StoryProvider — mengelola state cerita (stories) dari backend REST API MySQL
class StoryProvider extends ChangeNotifier {
  List<StoryModel> _stories = [];
  bool _isLoading = false;
  final _storage = LocalStorageService.instance;

  List<StoryModel> get stories => _stories;
  bool get isLoading => _isLoading;

  StoryProvider() {
    fetchStories();
  }

  /// Memuat stories yang aktif dari backend
  Future<void> fetchStories() async {
    _isLoading = true;
    final token = _storage.getToken();
    if (token == null) {
      _isLoading = false;
      return;
    }

    try {
      final res = await ApiService.get('/stories');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final temp = <StoryModel>[];
          
          for (final userGroup in data) {
            final userData = userGroup['user'];
            if (userData != null) {
              upsertUserFromBackend(userData, resolveUrl: ApiService.resolveImageUrl);
            }
            final List<dynamic> storiesJson = userGroup['stories'];
            for (final s in storiesJson) {
              temp.add(StoryModel(
                id: s['id'].toString(),
                userId: userData != null ? userData['id'].toString() : s['user_id'].toString(),
                mediaUrl: ApiService.resolveImageUrl(s['image_url'] as String?),
                createdAt: DateTime.parse(s['created_at'] as String),
                viewerIds: [], // Kita mock viewerIds lokal
              ));
            }
          }
          _stories = temp;
        }
      }
    } catch (e) {
      debugPrint('Fetch Stories Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mendapatkan seluruh cerita dari user tertentu (aktif 24 jam)
  List<StoryModel> getStoriesByUser(String userId) {
    final activeThreshold = DateTime.now().subtract(const Duration(hours: 24));
    final userStories = _stories
        .where((s) => s.userId == userId && s.createdAt.isAfter(activeThreshold))
        .toList();
    userStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return userStories;
  }

  /// Cek apakah user memiliki story aktif
  bool hasActiveStory(String userId) {
    return getStoriesByUser(userId).isNotEmpty;
  }

  /// Menambahkan cerita baru — upload ke backend MySQL
  Future<bool> addStory(String userId, String imageUrl) async {
    _isLoading = true;
    notifyListeners();

    try {
      Uint8List? fileBytes;
      String? filePath;

      if (imageUrl.startsWith('http')) {
        final res = await http.get(Uri.parse(imageUrl));
        if (res.statusCode == 200) {
          fileBytes = res.bodyBytes;
        }
      } else {
        filePath = imageUrl;
      }

      final res = await ApiService.multipartRequest(
        'POST',
        '/stories',
        fileKey: 'image',
        filePath: filePath,
        fileBytes: fileBytes,
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 201 && body['success'] == true) {
        await fetchStories();
        return true;
      }
    } catch (e) {
      debugPrint('Upload Story Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Menghapus cerita dari backend
  Future<bool> deleteStory(String storyId) async {
    try {
      final res = await ApiService.delete('/stories/$storyId');
      if (res.statusCode == 200) {
        _stories.removeWhere((s) => s.id == storyId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Delete Story Error: $e');
    }
    return false;
  }

  /// Menandai story sudah dilihat (mock lokal)
  void markStoryAsViewed(String storyId, String viewerId) {
    final idx = _stories.indexWhere((s) => s.id == storyId);
    if (idx == -1) return;
    final story = _stories[idx];
    if (!story.viewerIds.contains(viewerId)) {
      final updatedViewers = List<String>.from(story.viewerIds)..add(viewerId);
      _stories[idx] = StoryModel(
        id: story.id,
        userId: story.userId,
        mediaUrl: story.mediaUrl,
        createdAt: story.createdAt,
        viewerIds: updatedViewers,
      );
      notifyListeners();
    }
  }
}
