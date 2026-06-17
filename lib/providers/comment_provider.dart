import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../core/utils/dummy_data.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import 'post_provider.dart';
import 'auth_provider.dart';
import 'notification_provider.dart';
import '../models/notification_model.dart';

/// CommentProvider — mengelola state komentar dengan API Backend MySQL
class CommentProvider extends ChangeNotifier {
  final Map<String, List<CommentModel>> _commentsCache = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Memuat komentar untuk postingan tertentu dari database MySQL
  Future<void> fetchComments(String postId) async {
    _isLoading = true;
    
    try {
      final res = await ApiService.get('/comments/posts/$postId');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final commentsList = data.map((json) => _commentFromJson(json)).toList();
          _commentsCache[postId] = commentsList;
        }
      }
    } catch (e) {
      debugPrint('Fetch Comments Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mendapatkan komentar untuk post tertentu secara sinkron dari cache
  List<CommentModel> getCommentsForPost(String postId) {
    final list = _commentsCache[postId] ?? [];
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Urut terlama dulu
    return list;
  }

  /// Jumlah komentar per post
  int commentCount(String postId) {
    return _commentsCache[postId]?.length ?? 0;
  }

  /// Tambah komentar baru ke database MySQL
  Future<bool> addComment(BuildContext context, String postId, String text) async {
    if (text.trim().isEmpty) return false;

    try {
      final res = await ApiService.post('/comments/posts/$postId', {
        'text': text,
      });

      final body = jsonDecode(res.body);
      if (res.statusCode == 201 && body['success'] == true) {
        final newComment = _commentFromJson(body['data']);
        
        // Update cache lokal
        if (!_commentsCache.containsKey(postId)) {
          _commentsCache[postId] = [];
        }
        _commentsCache[postId]!.add(newComment);
        
        // Sync jumlah komentar di PostProvider
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        postProvider.incrementCommentCount(postId);

        // Tambah notifikasi komentar baru jika bukan komentar milik diri sendiri
        final currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? '';
        final post = postProvider.getPostById(postId);
        if (post != null && post.userId != currentUserId) {
          Provider.of<NotificationProvider>(context, listen: false).addNotification(
            NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: NotificationType.comment,
              fromUserId: currentUserId,
              postId: postId,
              commentText: text,
              createdAt: DateTime.now(),
              isRead: false,
            ),
          );
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Add Comment Error: $e');
    }
    return false;
  }

  /// Hapus komentar dari database MySQL
  Future<bool> deleteComment(BuildContext context, String commentId, String postId) async {
    try {
      final res = await ApiService.delete('/comments/$commentId');
      if (res.statusCode == 200) {
        // Update cache lokal
        if (_commentsCache.containsKey(postId)) {
          _commentsCache[postId]!.removeWhere((c) => c.id == commentId);
        }

        // Sync jumlah komentar di PostProvider
        Provider.of<PostProvider>(context, listen: false).decrementCommentCount(postId);

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Delete Comment Error: $e');
    }
    return false;
  }

  /// Parser data JSON Comment dari Backend
  CommentModel _commentFromJson(Map<String, dynamic> json) {
    final userData = json['user'];
    if (userData != null) {
      upsertUserFromBackend(userData, resolveUrl: ApiService.resolveImageUrl);
    }
    return CommentModel(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      userId: json['user_id'].toString(),
      text: json['text'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}
