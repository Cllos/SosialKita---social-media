import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../core/utils/dummy_data.dart';

/// PostProvider — mengelola state postingan
/// Feed, like/unlike, save/unsave, create post, delete post
class PostProvider extends ChangeNotifier {
  List<PostModel> _posts = List.from(dummyPosts);

  List<PostModel> get posts => _posts;

  /// Mendapatkan feed berdasarkan user yang sedang login
  /// Tampilkan postingan dari user yang diikuti + postingan sendiri
  /// Jika belum follow siapapun → tampilkan semua post sebagai rekomendasi
  List<PostModel> getFeed(String currentUserId, List<String> following) {
    List<PostModel> feed;
    if (following.isEmpty) {
      // Belum follow siapapun → tampilkan semua
      feed = List.from(_posts);
    } else {
      // Tampilkan dari following + sendiri
      feed = _posts
          .where(
              (p) => following.contains(p.userId) || p.userId == currentUserId)
          .toList();
    }
    // Urut terbaru
    feed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return feed;
  }

  /// Semua postingan (untuk moderator)
  List<PostModel> getAllPosts() {
    final all = List<PostModel>.from(_posts);
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  /// Postingan milik user tertentu
  List<PostModel> getUserPosts(String userId) {
    return _posts.where((p) => p.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Toggle like
  void toggleLike(String postId, String userId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post = _posts[idx];
    final likes = List<String>.from(post.likes);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    _posts[idx] = post.copyWith(likes: likes);
    notifyListeners();
  }

  /// Cek apakah user sudah like
  bool isLiked(String postId, String userId) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => PostModel(id: '', userId: ''),
    );
    return post.likes.contains(userId);
  }

  /// Tambah postingan baru
  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  /// Hapus postingan (moderator)
  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  /// Melaporkan postingan
  void reportPost(String postId, String userId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    final reports = List<String>.from(post.reports);
    if (!reports.contains(userId)) {
      reports.add(userId);
      _posts[idx] = post.copyWith(reports: reports);
      notifyListeners();
    }
  }

  /// Mendapatkan post berdasarkan ID
  PostModel? getPostById(String postId) {
    try {
      return _posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      return null;
    }
  }

  /// Jumlah komentar (dari CommentProvider data)
  int getCommentCount(String postId) {
    return dummyComments.where((c) => c.postId == postId).length;
  }

  /// Pencarian postingan berdasarkan caption / hashtag
  List<PostModel> searchPosts(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _posts
        .where((p) =>
            p.caption.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q)) ||
            p.location.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
