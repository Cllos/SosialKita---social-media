import 'package:flutter/material.dart';
import '../../models/dm_message_model.dart';
import '../../core/utils/dummy_data.dart';

/// ChatProvider — mengelola state DM & Chatting
class ChatProvider extends ChangeNotifier {
  /// Mendapatkan semua percakapan yang diikuti oleh user tertentu
  List<DmConversation> getConversationsForUser(String userId) {
    // Kembalikan percakapan yang diurutkan dari pesan terbaru
    final userConvs = dummyConversations
        .where((c) => c.participantIds.contains(userId))
        .toList();
    userConvs.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return userConvs;
  }

  /// Mendapatkan atau membuat percakapan baru antara dua user
  DmConversation getOrCreateConversation(String myId, String peerId) {
    // Cari percakapan yang ada
    try {
      return dummyConversations.firstWhere(
        (c) =>
            c.participantIds.contains(myId) &&
            c.participantIds.contains(peerId),
      );
    } catch (_) {
      // Jika belum ada, buat percakapan baru
      final newId = '${myId}_$peerId';
      final newConv = DmConversation(
        id: newId,
        participantIds: [myId, peerId],
        messages: [],
      );
      dummyConversations.add(newConv);
      notifyListeners();
      return newConv;
    }
  }

  /// Mengirim pesan baru
  void sendMessage(String conversationId, String fromUserId, String toUserId, String text) {
    if (text.trim().isEmpty) return;

    final idx = dummyConversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final conversation = dummyConversations[idx];
    final newMessage = DmMessageModel(
      id: 'dm_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: fromUserId,
      toUserId: toUserId,
      text: text,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final updatedMessages = List<DmMessageModel>.from(conversation.messages)..add(newMessage);
    dummyConversations[idx] = DmConversation(
      id: conversation.id,
      participantIds: conversation.participantIds,
      messages: updatedMessages,
    );

    notifyListeners();
  }

  /// Menandai semua pesan dalam percakapan sebagai terbaca
  void markAsRead(String conversationId, String myId) {
    final idx = dummyConversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final conversation = dummyConversations[idx];
    bool hasUnread = false;

    final updatedMessages = conversation.messages.map((msg) {
      if (msg.toUserId == myId && !msg.isRead) {
        hasUnread = true;
        return msg.copyWith(isRead: true);
      }
      return msg;
    }).toList();

    if (hasUnread) {
      dummyConversations[idx] = DmConversation(
        id: conversation.id,
        participantIds: conversation.participantIds,
        messages: updatedMessages,
      );
      notifyListeners();
    }
  }

  /// Mendapatkan jumlah total pesan belum dibaca untuk user tertentu
  int getTotalUnreadCount(String userId) {
    int count = 0;
    for (var conv in dummyConversations) {
      if (conv.participantIds.contains(userId)) {
        count += conv.unreadCount(userId);
      }
    }
    return count;
  }
}
