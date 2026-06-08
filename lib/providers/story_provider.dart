import 'package:flutter/material.dart';
import '../models/story_model.dart';

/// StoryProvider — mengelola state cerita (stories) secara in-memory
class StoryProvider extends ChangeNotifier {
  final List<StoryModel> _stories = [
    // Story awal dari Siti Rahma (u2)
    StoryModel(
      id: 's1',
      userId: 'u2',
      mediaUrl: 'https://picsum.photos/seed/culinary/1080/1920',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      viewerIds: ['u1', 'u3', 'u4'], // dummy viewers
    ),
    // Story awal dari Maulana Budi (u3)
    StoryModel(
      id: 's2',
      userId: 'u3',
      mediaUrl: 'https://picsum.photos/seed/streetphoto/1080/1920',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      viewerIds: ['u1', 'u2', 'u5'], // dummy viewers
    ),
    // Story awal dari Fitri Dewi (u4)
    StoryModel(
      id: 's3',
      userId: 'u4',
      mediaUrl: 'https://picsum.photos/seed/beachlife/1080/1920',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      viewerIds: ['u1', 'u3'], // dummy viewers
    ),
    // Story awal dari Reza Hasni (u5)
    StoryModel(
      id: 's4',
      userId: 'u5',
      mediaUrl: 'https://picsum.photos/seed/coffeeart/1080/1920',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      viewerIds: ['u2', 'u3', 'u4'], // dummy viewers
    ),
  ];

  List<StoryModel> get stories => _stories;

  /// Mendapatkan seluruh cerita dari user tertentu (aktif 24 jam)
  List<StoryModel> getStoriesByUser(String userId) {
    final activeThreshold = DateTime.now().subtract(const Duration(hours: 24));
    final userStories = _stories
        .where((s) => s.userId == userId && s.createdAt.isAfter(activeThreshold))
        .toList();
    // Urutkan dari yang paling lama ke paling baru (kronologis)
    userStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return userStories;
  }

  /// Cek apakah user memiliki story aktif
  bool hasActiveStory(String userId) {
    return getStoriesByUser(userId).isNotEmpty;
  }

  /// Menambahkan cerita baru
  void addStory(String userId, String mediaUrl) {
    final newStory = StoryModel(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
      viewerIds: [],
    );
    _stories.insert(0, newStory);
    notifyListeners();
  }

  /// Menghapus cerita kustom berdasarkan ID
  void deleteStory(String storyId) {
    _stories.removeWhere((s) => s.id == storyId);
    notifyListeners();
  }

  /// Menandai story sudah dilihat oleh user tertentu
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
