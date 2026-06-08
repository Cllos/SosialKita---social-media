import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/dm_message_model.dart';
import '../../models/user_model.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../core/utils/dummy_data.dart';
import 'chat_detail_screen.dart';
import '../profile/profile_screen.dart';

/// ChatListScreen — Menampilkan daftar percakapan DM
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.skDark,
        body: Center(
          child: Text(
            'Silakan login terlebih dahulu.',
            style: TextStyle(color: AppColors.skWhite),
          ),
        ),
      );
    }

    final chatProvider = context.watch<ChatProvider>();
    final conversations = chatProvider.getConversationsForUser(currentUser.id);
    final userProvider = context.read<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: Column(
        children: [
          // AppBar kustom sesuai HTML UI
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.skGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: const Text(
                    'Pesan',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Tombol Tulis Pesan Baru (New Chat)
                GestureDetector(
                  onTap: () => _showNewChatBottomSheet(context, currentUser.id),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.skWhite,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List Percakapan
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.skMuted.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada percakapan',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.skMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _showNewChatBottomSheet(context, currentUser.id),
                          child: const Text(
                            'Mulai obrolan baru',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              color: AppColors.skRose,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      // Cari user peer (pihak lawan)
                      final peerId = conv.participantIds.firstWhere((id) => id != currentUser.id);
                      final peer = userProvider.getUserById(peerId);

                      if (peer == null) return const SizedBox.shrink();

                      final lastMsg = conv.lastMessage;
                      final unreadCount = conv.unreadCount(currentUser.id);
                      final hasUnread = unreadCount > 0;
                      
                      // Siti Rahma (u2) online di spec
                      final isOnline = peer.id == 'u2';

                      return InkWell(
                        onTap: () {
                          // Tandai sebagai dibaca dan navigasi ke Chat Detail
                          chatProvider.markAsRead(conv.id, currentUser.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(
                                conversationId: conv.id,
                                peer: peer,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar dengan indikator online
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(userId: peer.id),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    SKAvatar(
                                      initials: peer.avatarInitials,
                                      backgroundColor: peer.avatarColor,
                                      imageUrl: peer.avatarUrl,
                                      size: 44,
                                      // Beri ring gradient jika belum dibaca
                                      showRing: hasUnread,
                                    ),
                                    if (isOnline)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.skDark,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Info percakapan
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          peer.username,
                                          style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 14,
                                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                            color: hasUnread ? AppColors.skWhite : AppColors.skWhite.withOpacity(0.8),
                                          ),
                                        ),
                                        Text(
                                          _formatRelativeTime(conv.lastMessageTime),
                                          style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 11,
                                            color: AppColors.skMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            lastMsg?.text ?? 'Mulai obrolan...',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 12,
                                              color: hasUnread ? AppColors.skWhite.withOpacity(0.9) : AppColors.skMuted,
                                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (hasUnread)
                                          Container(
                                            width: 18,
                                            height: 18,
                                            margin: const EdgeInsets.only(left: 8),
                                            decoration: const BoxDecoration(
                                              color: AppColors.skRose,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              unreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Format waktu relatif ringkas sesuai HTML UI spec
  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt';
    if (diff.inHours < 24) return '${diff.inHours} jam';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari';
    return '${time.day}/${time.month}';
  }

  /// Menampilkan Bottom Sheet untuk memulai chat dengan user lain
  void _showNewChatBottomSheet(BuildContext context, String currentUserId) {
    // Ambil daftar user dari dummy data
    // import dummy data
    // Filter agar tidak menyertakan diri sendiri
    // import list_dir
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();
    
    // Ambil semua user dari dummy data
    // dummyUsers diimport dari dummy_data.dart
    // Filter agar diri sendiri tidak muncul
    // Kita tampilkan user lain yang bisa di-chat
    // exclude user dengan role moderator jika diinginkan, tapi tampilkan semua user biasa saja
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.skDark2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Ambil semua user selain user saat ini
        final otherUsers = userProvider.searchUsers('').isEmpty 
            ? _getAllOtherUsers(currentUserId)
            : userProvider.searchUsers(''); // backup search

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mulai Obrolan Baru',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.skWhite,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: otherUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada pengguna lain ditemukan',
                          style: TextStyle(color: AppColors.skMuted),
                        ),
                      )
                    : ListView.builder(
                        itemCount: otherUsers.length,
                        itemBuilder: (context, index) {
                          final user = otherUsers[index];
                          return ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(userId: user.id),
                                  ),
                                );
                              },
                              child: SKAvatar(
                                initials: user.avatarInitials,
                                backgroundColor: user.avatarColor,
                                imageUrl: user.avatarUrl,
                                size: 40,
                              ),
                            ),
                            title: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                color: AppColors.skWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '@${user.username}',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                color: AppColors.skMuted,
                                fontSize: 12,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.pop(context); // Tutup bottom sheet
                              
                              // Buat atau dapatkan percakapan
                              final conv = chatProvider.getOrCreateConversation(
                                currentUserId,
                                user.id,
                              );
                              
                              // Buka chat detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    conversationId: conv.id,
                                    peer: user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper untuk mendapatkan semua user lain di dummy data
  List<UserModel> _getAllOtherUsers(String currentUserId) {
    // dummyUsers diimport dari dummy_data.dart
    // return list user selain currentUserId
    // import '../dummy_data.dart'
    // tapi kita import dari dummy_data.dart di atas
    // mari kita filter
    // import static/global variable dummyUsers
    // dummyUsers diimport di dummy_data.dart
    // mari kita filter
    try {
      // dummyUsers diimport global
      // filter
      return dummyUsers.where((u) => u.id != currentUserId).toList();
    } catch (_) {
      return [];
    }
  }
}
