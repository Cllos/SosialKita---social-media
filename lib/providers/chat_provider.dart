import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import '../models/dm_message_model.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../core/utils/dummy_data.dart';

/// ChatProvider — mengelola state DM & Chatting dengan REST API Backend MySQL
class ChatProvider extends ChangeNotifier {
  List<DmConversation> _conversations = [];
  bool _isLoading = false;
  final _storage = LocalStorageService.instance;

  List<DmConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;

  ChatProvider() {
    fetchConversations();
  }

  /// Memuat semua riwayat percakapan dari backend
  Future<void> fetchConversations() async {
    final token = _storage.getToken();
    if (token == null) return;

    _isLoading = true;
    try {
      final res = await ApiService.get('/messages/conversations');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final myId = _storage.getSession() ?? '';
          final tempConvs = <DmConversation>[];

          for (final c in data) {
            final partnerData = c['partner'];
            if (partnerData != null) {
              upsertUserFromBackend(partnerData, resolveUrl: ApiService.resolveImageUrl);
            }
            final partnerId = partnerData != null ? partnerData['id'].toString() : '';
            
            final lastMsgData = c['last_message'];
            final List<DmMessageModel> messages = [];
            if (lastMsgData != null) {
              final senderId = lastMsgData['sender_id'].toString();
              messages.add(DmMessageModel(
                id: 'last_msg_${partnerId}_${lastMsgData['created_at']}',
                fromUserId: senderId,
                toUserId: senderId == myId ? partnerId : myId,
                text: lastMsgData['text'] as String? ?? '',
                isRead: true, // Last message info
                createdAt: DateTime.parse(lastMsgData['created_at'] as String),
              ));
            }

            tempConvs.add(DmConversation(
              id: '${myId}_$partnerId',
              participantIds: [myId, partnerId],
              messages: messages,
            ));
          }

          _conversations = tempConvs;
        }
      }
    } catch (e) {
      debugPrint('Fetch Conversations Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Memuat daftar pesan detail dengan user tertentu (peerId)
  Future<void> fetchMessages(String peerId) async {
    final token = _storage.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.get('/messages/$peerId');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          final myId = _storage.getSession() ?? '';
          
          final List<DmMessageModel> parsedMessages = data.map((m) {
            return DmMessageModel(
              id: m['id'].toString(),
              fromUserId: m['sender_id'].toString(),
              toUserId: m['receiver_id'].toString(),
              text: m['text'] as String? ?? '',
              isRead: m['is_read'] as bool? ?? false,
              createdAt: DateTime.parse(m['created_at'] as String),
            );
          }).toList();

          final convId = '${myId}_$peerId';
          final idx = _conversations.indexWhere((c) => c.id == convId || (c.participantIds.contains(myId) && c.participantIds.contains(peerId)));
          if (idx != -1) {
            _conversations[idx] = DmConversation(
              id: _conversations[idx].id,
              participantIds: _conversations[idx].participantIds,
              messages: parsedMessages,
            );
          } else {
            _conversations.add(DmConversation(
              id: convId,
              participantIds: [myId, peerId],
              messages: parsedMessages,
            ));
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Fetch Messages Error: $e');
    }
  }

  /// Mendapatkan semua percakapan yang diikuti oleh user tertentu
  List<DmConversation> getConversationsForUser(String userId) {
    final userConvs = _conversations
        .where((c) => c.participantIds.contains(userId))
        .toList();
    userConvs.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return userConvs;
  }

  /// Mendapatkan atau membuat percakapan baru antara dua user
  DmConversation getOrCreateConversation(String myId, String peerId) {
    final convId = '${myId}_$peerId';
    try {
      return _conversations.firstWhere(
        (c) =>
            (c.participantIds.contains(myId) && c.participantIds.contains(peerId)),
      );
    } catch (_) {
      final newConv = DmConversation(
        id: convId,
        participantIds: [myId, peerId],
        messages: [],
      );
      _conversations.add(newConv);
      notifyListeners();
      return newConv;
    }
  }

  /// Mengirim pesan baru ke database MySQL
  Future<void> sendMessage(String conversationId, String fromUserId, String toUserId, String text) async {
    if (text.trim().isEmpty) return;

    final convId = conversationId;
    final idx = _conversations.indexWhere((c) => c.id == convId);

    // Optimistic UI update
    final tempMsg = DmMessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: fromUserId,
      toUserId: toUserId,
      text: text,
      isRead: false,
      createdAt: DateTime.now(),
    );

    if (idx != -1) {
      final updated = List<DmMessageModel>.from(_conversations[idx].messages)..add(tempMsg);
      _conversations[idx] = DmConversation(
        id: _conversations[idx].id,
        participantIds: _conversations[idx].participantIds,
        messages: updated,
      );
      notifyListeners();
    }

    try {
      final res = await ApiService.post('/messages/$toUserId', {
        'text': text,
      });

      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          // Replace optimistic message dengan real message dari database
          final m = body['data'];
          final realMsg = DmMessageModel(
            id: m['id'].toString(),
            fromUserId: m['sender_id'].toString(),
            toUserId: m['receiver_id'].toString(),
            text: m['text'] as String? ?? '',
            isRead: m['is_read'] as bool? ?? false,
            createdAt: DateTime.parse(m['created_at'] as String),
          );

          if (idx != -1) {
            final updated = List<DmMessageModel>.from(_conversations[idx].messages)
              ..removeWhere((msg) => msg.id.startsWith('temp_'))
              ..add(realMsg);

            _conversations[idx] = DmConversation(
              id: _conversations[idx].id,
              participantIds: _conversations[idx].participantIds,
              messages: updated,
            );
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('Send Message Error: $e');
      // Rollback jika error
      if (idx != -1) {
        final updated = List<DmMessageModel>.from(_conversations[idx].messages)
          ..removeWhere((msg) => msg.id == tempMsg.id);
        _conversations[idx] = DmConversation(
          id: _conversations[idx].id,
          participantIds: _conversations[idx].participantIds,
          messages: updated,
        );
        notifyListeners();
      }
    }
  }

  /// Menandai semua pesan dalam percakapan sebagai terbaca di database
  Future<void> markAsReadApi(String peerId) async {
    try {
      final res = await ApiService.put('/messages/$peerId/read', null);
      if (res.statusCode == 200) {
        final myId = _storage.getSession() ?? '';
        final convId = '${myId}_$peerId';
        final idx = _conversations.indexWhere((c) => c.id == convId || (c.participantIds.contains(myId) && c.participantIds.contains(peerId)));
        
        if (idx != -1) {
          final updated = _conversations[idx].messages.map((m) {
            if (m.toUserId == myId && !m.isRead) {
              return m.copyWith(isRead: true);
            }
            return m;
          }).toList();

          _conversations[idx] = DmConversation(
            id: _conversations[idx].id,
            participantIds: _conversations[idx].participantIds,
            messages: updated,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  /// Menandai story sebagai terbaca (mock compatibility)
  void markAsRead(String conversationId, String myId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final partnerId = _conversations[idx].participantIds.firstWhere((id) => id != myId, orElse: () => '');
      if (partnerId.isNotEmpty) {
        markAsReadApi(partnerId);
      }
    }
  }

  /// Mendapatkan total pesan belum dibaca (sync)
  int getTotalUnreadCount(String userId) {
    // Dipicu fetch total count asinkron dari server di background
    _fetchTotalUnreadCountApi();
    
    // Kembalikan count lokal
    int count = 0;
    for (var conv in _conversations) {
      if (conv.participantIds.contains(userId)) {
        count += conv.unreadCount(userId);
      }
    }
    return count;
  }

  Future<void> _fetchTotalUnreadCountApi() async {
    try {
      final res = await ApiService.get('/messages/unread/count');
      if (res.statusCode == 200) {
        // Jika backend memberikan counts detail, kita bisa menyelaraskannya di sini.
      }
    } catch (_) {}
  }
}
