import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/user_model.dart';
import '../../models/dm_message_model.dart';
import '../../widgets/common/sk_avatar.dart';
import '../profile/profile_screen.dart';

/// ChatDetailScreen — Tampilan percakapan/chatting dengan pengguna lain
class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final UserModel peer;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.peer,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChatProvider>().fetchMessages(widget.peer.id);
        context.read<ChatProvider>().markAsReadApi(widget.peer.id);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    // Kirim pesan
    chatProvider.sendMessage(
      widget.conversationId,
      currentUser.id,
      widget.peer.id,
      text,
    );

    _messageController.clear();

    // Scroll otomatis ke bawah
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // Karena ListView reverse, 0.0 adalah bagian paling bawah (terbaru)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return const Scaffold();

    final chatProvider = context.watch<ChatProvider>();
    
    // Ambil percakapan terbaru dari provider
    final conversations = chatProvider.getConversationsForUser(currentUser.id);
    final conv = conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => DmConversation(
        id: widget.conversationId,
        participantIds: [currentUser.id, widget.peer.id],
        messages: [],
      ),
    );

    // Balik urutan pesan agar pesan terbaru ada di bawah (ListView reverse: true)
    final messages = conv.messages.reversed.toList();
    
    // Indikator online: u2 (siti_rahma) online sesuai HTML UI
    final isOnline = widget.peer.id == 'u2';

    return Scaffold(
      backgroundColor: AppColors.skDark,
      // AppBar Kustom sesuai HTML UI
      appBar: AppBar(
        backgroundColor: AppColors.skDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.skWhite),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: widget.peer.id),
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              SKAvatar(
                initials: widget.peer.avatarInitials,
                backgroundColor: widget.peer.avatarColor,
                imageUrl: widget.peer.avatarUrl,
                size: 34,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.peer.username,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.skWhite,
                    ),
                  ),
                  Text(
                    isOnline ? '● Online' : 'Offline',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: isOnline ? const Color(0xFF22C55E) : AppColors.skMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.skMuted),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withOpacity(0.05),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Area Chat Bubble
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppColors.skMuted.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kirim pesan pertama ke @${widget.peer.username}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: AppColors.skMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Urutan dari bawah ke atas
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.fromUserId == currentUser.id;

                      if (isMe) {
                        return _buildMyMessage(msg);
                      } else {
                        return _buildPeerMessage(msg);
                      }
                    },
                  ),
          ),

          // Area Input Field
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Bubble chat untuk pesan keluar (Saya)
  Widget _buildMyMessage(DmMessageModel msg) {
    final timeStr = _formatTime(msg.createdAt);

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.skGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                msg.text,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 9,
                    color: AppColors.skMuted,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.done_all,
                  size: 12,
                  color: AppColors.skViolet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bubble chat untuk pesan masuk (Lawan Bicara)
  Widget _buildPeerMessage(DmMessageModel msg) {
    final timeStr = _formatTime(msg.createdAt);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: widget.peer.id),
                  ),
                );
              },
              child: SKAvatar(
                initials: widget.peer.avatarInitials,
                backgroundColor: widget.peer.avatarColor,
                imageUrl: widget.peer.avatarUrl,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.skCard,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    msg.text,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.skWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 9,
                    color: AppColors.skMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Input area di bagian bawah
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.skDark,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Input text
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: AppColors.skWhite,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: AppColors.skMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Kirim (Send)
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.skGradient,
              ),
              child: const Center(
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format waktu jam dan menit (HH:mm)
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
