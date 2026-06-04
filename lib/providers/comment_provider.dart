import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../core/utils/dummy_data.dart';

/// CommentProvider — mengelola state komentar
class CommentProvider extends ChangeNotifier {
  List<CommentModel> _comments = List.from(dummyComments);

  List<CommentModel> get comments => _comments;

  /// Komentar untuk post tertentu, urut terlama dulu
  List<CommentModel> getCommentsForPost(String postId) {
    return _comments.where((c) => c.postId == postId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Jumlah komentar per post
  int commentCount(String postId) {
    return _comments.where((c) => c.postId == postId).length;
  }

  /// Tambah komentar baru
  void addComment(CommentModel comment) {
    _comments.add(comment);
    notifyListeners();
  }

  /// Hapus komentar (moderator)
  void deleteComment(String commentId) {
    _comments.removeWhere((c) => c.id == commentId);
    notifyListeners();
  }
}
