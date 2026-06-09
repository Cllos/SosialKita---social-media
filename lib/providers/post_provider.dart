import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, Uint8List;
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../core/utils/dummy_data.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

/// PostProvider — mengelola state postingan dengan API Backend MySQL
class PostProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  final Map<String, int> _commentCounts = {};

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  PostProvider() {
    fetchPosts();
  }

  /// Memuat semua postingan dari explore endpoint backend
  Future<void> fetchPosts() async {
    _isLoading = true;
    final token = LocalStorageService.instance.getToken();
    if (token == null) {
      _isLoading = false;
      return;
    }

    try {
      final res = await ApiService.get('/posts/explore');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final currentUserId = LocalStorageService.instance.getSession() ?? '';
          
          _posts = data.map((json) => _postFromJson(json, currentUserId)).toList();
          
          // Simpan jumlah komentar untuk getter cepat
          for (final json in data) {
            final postId = json['id'].toString();
            final count = json['comment_count'] as int? ?? 0;
            _commentCounts[postId] = count;
          }
        }
      }
    } catch (e) {
      debugPrint('Fetch Posts Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Reload postingan dari database
  void reload() {
    fetchPosts();
  }

  /// Mendapatkan feed berdasarkan user yang sedang login
  List<PostModel> getFeed(String currentUserId, List<String> following) {
    List<PostModel> feed;
    if (following.isEmpty) {
      feed = List.from(_posts);
    } else {
      feed = _posts
          .where(
              (p) => following.contains(p.userId) || p.userId == currentUserId)
          .toList();
    }
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

  /// Toggle like ke database MySQL
  void toggleLike(String postId, String userId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    try {
      final res = await ApiService.post('/likes/posts/$postId', null);
      final body = jsonDecode(res.body);
      
      if (res.statusCode == 200 && body['success'] == true) {
        // Reload detail post dari database agar data like akurat
        final postRes = await ApiService.get('/posts/$postId');
        if (postRes.statusCode == 200) {
          final postBody = jsonDecode(postRes.body);
          if (postBody['success'] == true) {
            final updatedPost = _postFromJson(postBody['data'], userId);
            _posts[idx] = updatedPost;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('Toggle Like Error: $e');
    }
  }

  /// Cek apakah user sudah like
  bool isLiked(String postId, String userId) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => PostModel(id: '', userId: ''),
    );
    return post.likes.contains(userId);
  }

  /// Tambah postingan baru — upload gambar ke Backend
  Future<bool> uploadPost({
    required String caption,
    required String location,
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fields = {
        'caption': caption,
        'location': location,
      };

      final res = await ApiService.multipartRequest(
        'POST',
        '/posts',
        fields: fields,
        fileKey: 'image',
        filePath: imagePath,
        fileBytes: imageBytes,
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 201 && body['success'] == true) {
        final currentUserId = LocalStorageService.instance.getSession() ?? '';
        final newPost = _postFromJson(body['data'], currentUserId);
        _posts.insert(0, newPost);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Upload Post Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Dummy compatibility method
  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  /// Hapus postingan dari database MySQL
  void deletePost(String postId) async {
    try {
      final res = await ApiService.delete('/posts/$postId');
      if (res.statusCode == 200) {
        _posts.removeWhere((p) => p.id == postId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Delete Post Error: $e');
    }
  }

  /// Melaporkan postingan (mock atau post request jika disupport)
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

  /// Jumlah komentar (dari metadata database)
  int getCommentCount(String postId) {
    return _commentCounts[postId] ?? 0;
  }

  /// Increment count komentar secara lokal setelah sukses posting komentar
  void incrementCommentCount(String postId) {
    _commentCounts[postId] = (_commentCounts[postId] ?? 0) + 1;
    notifyListeners();
  }

  /// Decrement count komentar secara lokal setelah sukses menghapus komentar
  void decrementCommentCount(String postId) {
    final current = _commentCounts[postId] ?? 0;
    if (current > 0) {
      _commentCounts[postId] = current - 1;
      notifyListeners();
    }
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

  /// Parser data JSON Post dari Backend
  PostModel _postFromJson(Map<String, dynamic> json, String currentUserId) {
    final id = json['id'].toString();
    
    // Penanganan relasi author
    final authorData = json['author'];
    final userId = authorData != null ? authorData['id'].toString() : json['user_id'].toString();
    if (authorData != null) {
      upsertUserFromBackend(authorData, resolveUrl: ApiService.resolveImageUrl);
    }

    final imageUrl = ApiService.resolveImageUrl(json['image_url'] as String?);
    final caption = json['caption'] as String? ?? '';
    final location = json['location'] as String? ?? '';
    final createdAt = json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now();

    final isLiked = json['is_liked'] as bool? ?? false;
    final likeCount = json['like_count'] as int? ?? 0;
    
    // Rekonstruksi list likes agar sesuai panjang counts
    final likesList = <String>[];
    if (isLiked) {
      likesList.add(currentUserId);
    }
    final remainingLikes = likeCount - (isLiked ? 1 : 0);
    for (int i = 0; i < remainingLikes; i++) {
      likesList.add('fake_user_$i');
    }

    final tags = List<String>.from(json['tags'] as List? ?? []);
    final reports = List<String>.from((json['reports'] as List?)?.map((e) => e.toString()) ?? []);

    return PostModel(
      id: id,
      userId: userId,
      imageUrl: imageUrl,
      caption: caption,
      likes: likesList,
      tags: tags,
      location: location,
      createdAt: createdAt,
    )..reports.addAll(reports);
  }
}
