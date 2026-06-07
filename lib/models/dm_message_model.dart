/// Model pesan DM — SosialKita
class DmMessageModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  DmMessageModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.text,
    this.isRead = false,
    required this.createdAt,
  });

  DmMessageModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? text,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return DmMessageModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      text: text ?? this.text,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model percakapan DM — mengelompokkan pesan antara dua user
class DmConversation {
  final String id; // gabungan userId dua pihak, misal "u1_u2"
  final List<String> participantIds;
  final List<DmMessageModel> messages;

  DmConversation({
    required this.id,
    required this.participantIds,
    required this.messages,
  });

  DateTime get lastMessageTime => messages.isNotEmpty
      ? messages.last.createdAt
      : DateTime(2024);

  DmMessageModel? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  int unreadCount(String myId) =>
      messages.where((m) => m.toUserId == myId && !m.isRead).length;
}
