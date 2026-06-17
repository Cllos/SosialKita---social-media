import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/time_ago.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

/// ModeratorDashboard — Dashboard admin dengan sidebar navigasi
/// Menampilkan statistik, kelola pengguna/postingan/komentar/DM
class ModeratorDashboard extends StatefulWidget {
  const ModeratorDashboard({super.key});

  @override
  State<ModeratorDashboard> createState() => _ModeratorDashboardState();
}

class _ModeratorDashboardState extends State<ModeratorDashboard> {
  // ── State ──
  int _activePage = 0; // 0=Dashboard, 1=Pengguna, 2=Postingan, 3=Komentar, 4=Chat
  bool _isLoading = true;

  // Data dari API
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> _conversations = [];

  // Search
  String _userSearch = '';
  String _postSearch = '';
  String _commentSearch = '';

  // Chat detail
  int? _activeConvoIndex;
  List<Map<String, dynamic>> _convoMessages = [];

  // ── Warna chip/avatar (sesuai mockup) ──
  static const _chipBlue = Color(0xFF185FA5);
  static const _chipBlueBg = Color(0xFF1A2A40);
  static const _chipPink = Color(0xFF993556);
  static const _chipPinkBg = Color(0xFF2A1A24);
  static const _chipGreen = Color(0xFF3B6D11);
  static const _chipGreenBg = Color(0xFF1A2A1A);
  static const _chipAmber = Color(0xFF854F0B);
  static const _chipAmberBg = Color(0xFF2A241A);
  static const _chipTeal = Color(0xFF0F6E56);
  static const _chipRed = Color(0xFFA32D2D);
  static const _chipRedBg = Color(0xFF2A1A1A);

  // Avatar colors mapping
  static const List<List<Color>> _avatarColors = [
    [_chipBlueBg, _chipBlue],    // 0
    [_chipPinkBg, _chipPink],    // 1
    [_chipGreenBg, _chipGreen],  // 2
    [_chipAmberBg, _chipAmber],  // 3
    [Color(0xFF1A2A2A), _chipTeal], // 4
    [_chipRedBg, _chipRed],      // 5
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadStats(),
      _loadUsers(),
      _loadPosts(),
      _loadComments(),
      _loadConversations(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadStats() async {
    try {
      final res = await ApiService.get('/moderator/stats');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() => _stats = body['data'] ?? {});
      }
    } catch (e) {
      debugPrint('Load stats error: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final res = await ApiService.get('/moderator/users');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        if (data is List) {
          setState(() => _users = data.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint('Load users error: $e');
    }
  }

  Future<void> _loadPosts() async {
    try {
      final res = await ApiService.get('/moderator/posts?limit=100');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data']?['posts'];
        if (data is List) {
          setState(() => _posts = data.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint('Load posts error: $e');
    }
  }

  Future<void> _loadComments() async {
    try {
      final res = await ApiService.get('/moderator/comments');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        if (data is List) {
          setState(() => _comments = data.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint('Load comments error: $e');
    }
  }

  Future<void> _loadConversations() async {
    try {
      final res = await ApiService.get('/messages/conversations');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        if (data is List) {
          setState(() => _conversations = data.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint('Load conversations error: $e');
    }
  }

  // ── API Actions ──

  Future<void> _deletePost(int postId) async {
    try {
      final res = await ApiService.delete('/moderator/posts/$postId');
      if (res.statusCode == 200) {
        _showToast('Postingan berhasil dihapus 🗑️');
        await Future.wait([_loadPosts(), _loadStats()]);
      }
    } catch (e) {
      _showToast('Gagal menghapus postingan');
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      final res = await ApiService.delete('/moderator/comments/$commentId');
      if (res.statusCode == 200) {
        _showToast('Komentar berhasil dihapus 🗑️');
        await Future.wait([_loadComments(), _loadStats()]);
      }
    } catch (e) {
      _showToast('Gagal menghapus komentar');
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final res = await ApiService.delete('/moderator/users/$userId');
      if (res.statusCode == 200) {
        _showToast('Pengguna berhasil dihapus 🗑️');
        await Future.wait([_loadUsers(), _loadStats()]);
      }
    } catch (e) {
      _showToast('Gagal menghapus pengguna');
    }
  }

  Future<void> _toggleUserActive(int userId) async {
    try {
      final res = await ApiService.put('/moderator/users/$userId/deactivate', {});
      if (res.statusCode == 200) {
        _showToast('Status pengguna diperbarui');
        await _loadUsers();
      }
    } catch (e) {
      _showToast('Gagal memperbarui status');
    }
  }

  Future<void> _loadConvoMessages(int otherUserId) async {
    try {
      final res = await ApiService.get('/messages/$otherUserId');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        if (data is List) {
          setState(() => _convoMessages = data.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint('Load messages error: $e');
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13)),
        backgroundColor: AppColors.skCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Helpers ──

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    final initials = parts.map((e) => e.isNotEmpty ? e[0] : '').join();
    return initials.length > 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase();
  }

  List<Color> _getAvatarColor(int index) {
    return _avatarColors[index % _avatarColors.length];
  }

  // ── BUILD ──

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.skDark,
        body: Center(
          child: Text('Akses Ditolak.', style: TextStyle(color: AppColors.skWhite)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: Column(
        children: [
          // ── Top Bar ──
          _buildTopBar(currentUser.displayName),
          // ── Layout: Sidebar + Content ──
          Expanded(
            child: Row(
              children: [
                _buildSidebar(currentUser.displayName, currentUser.avatarInitials),
                // ── Content Area ──
                Expanded(
                  child: Container(
                    color: AppColors.skDark,
                    padding: const EdgeInsets.all(20),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.skRose),
                          )
                        : _buildActivePage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  //  TOP BAR
  // ══════════════════════════════════════

  Widget _buildTopBar(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.skDark2,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: AppColors.skRose, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Panel Moderator — SosialKita',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.skWhite,
            ),
          ),
          const Spacer(),
          // MOD Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _chipAmberBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, color: const Color(0xFF854F0B), size: 13),
                const SizedBox(width: 4),
                const Text(
                  'MOD',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF854F0B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Logout Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showLogoutConfirmation(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.skRose.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, color: _chipRed, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Keluar',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _chipRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  //  SIDEBAR
  // ══════════════════════════════════════

  Widget _buildSidebar(String name, String initials) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.skDark2,
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _chipAmberBg,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF854F0B),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.skWhite,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Moderator resmi',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.skMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Menu Section
          _buildNavSection('MENU'),
          _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
          _buildNavItem(1, Icons.people_outlined, 'Pengguna'),
          _buildNavItem(2, Icons.photo_outlined, 'Postingan'),
          _buildNavItem(3, Icons.chat_bubble_outline, 'Komentar'),
          _buildNavItem(4, Icons.send_outlined, 'Chat / DM'),
          const SizedBox(height: 4),
          // Sistem Section
          _buildNavSection('SISTEM'),
          _buildNavItemStatic(Icons.flag_outlined, 'Laporan', () {
            _showToast('Fitur laporan segera hadir');
          }),
          _buildNavItemStatic(Icons.settings_outlined, 'Pengaturan', () {
            _showToast('Pengaturan segera hadir');
          }),
        ],
      ),
    );
  }

  Widget _buildNavSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.skMuted.withValues(alpha: 0.6),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _activePage == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _activePage = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.skCard : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isActive ? AppColors.skRose : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.skRose : AppColors.skMuted,
              ),
              const SizedBox(width: 9),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  color: isActive ? AppColors.skRose : AppColors.skMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemStatic(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.transparent, width: 2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.skMuted),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: AppColors.skMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  CONTENT PAGES
  // ══════════════════════════════════════

  Widget _buildActivePage() {
    switch (_activePage) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return _buildUsersPage();
      case 2:
        return _buildPostsPage();
      case 3:
        return _buildCommentsPage();
      case 4:
        return _buildDmPage();
      default:
        return _buildDashboardPage();
    }
  }

  // ── Dashboard Page ──
  Widget _buildDashboardPage() {
    final totalUsers = _stats['total_users'] ?? _users.length;
    final totalPosts = _stats['total_posts'] ?? _posts.length;
    final totalComments = _stats['total_comments'] ?? _comments.length;
    final totalConvos = _conversations.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total pengguna',
                  totalUsers.toString(),
                  Icons.people_outlined,
                  _chipBlueBg,
                  _chipBlue,
                  '+${_stats['active_users'] ?? 0} aktif',
                  _chipGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total postingan',
                  totalPosts.toString(),
                  Icons.photo_outlined,
                  _chipPinkBg,
                  _chipPink,
                  '${_posts.isNotEmpty ? '+${_posts.length}' : '0'} total',
                  _chipGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total komentar',
                  totalComments.toString(),
                  Icons.chat_bubble_outline,
                  _chipGreenBg,
                  _chipGreen,
                  '${_comments.isNotEmpty ? '+${_comments.length}' : '0'} total',
                  _chipGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total percakapan',
                  totalConvos.toString(),
                  Icons.send_outlined,
                  _chipAmberBg,
                  _chipAmber,
                  '${_conversations.where((c) => (c['unread_count'] ?? 0) > 0).length} belum dibaca',
                  _chipAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Activity Table
          const Text(
            'Aktivitas terbaru',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.skWhite,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityTable(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconBg,
    Color iconColor,
    String delta,
    Color deltaColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.skDark2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.skWhite,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.skMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            delta,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: deltaColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTable() {
    // Build recent activity from posts and comments
    final List<Map<String, dynamic>> activities = [];

    for (final post in _posts.take(3)) {
      final author = post['author'] as Map<String, dynamic>?;
      activities.add({
        'time': post['created_at'] != null
            ? timeAgo(DateTime.parse(post['created_at']))
            : 'Baru saja',
        'username': author?['username'] ?? '?',
        'initials': _getInitials(author?['display_name'] ?? author?['username']),
        'action': 'Post baru',
        'actionColor': _chipGreen,
        'actionBg': _chipGreenBg,
        'detail': (post['caption'] as String?)?.substring(0, (post['caption'] as String?)!.length > 35 ? 35 : (post['caption'] as String?)!.length) ?? '',
        'colorIdx': (author?['id'] ?? 0) as int,
      });
    }

    for (final comment in _comments.take(2)) {
      final user = comment['user'] as Map<String, dynamic>?;
      activities.add({
        'time': comment['created_at'] != null
            ? timeAgo(DateTime.parse(comment['created_at']))
            : 'Baru saja',
        'username': user?['username'] ?? '?',
        'initials': _getInitials(user?['display_name'] ?? user?['username']),
        'action': 'Komentar',
        'actionColor': _chipBlue,
        'actionBg': _chipBlueBg,
        'detail': (comment['content'] as String?) ?? '',
        'colorIdx': (user?['id'] ?? 0) as int,
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.skDark2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.skCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _tableHeader('Waktu', flex: 2),
                _tableHeader('Pengguna', flex: 3),
                _tableHeader('Aksi', flex: 2),
                _tableHeader('Detail', flex: 4),
              ],
            ),
          ),
          // Rows
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada aktivitas',
                style: TextStyle(color: AppColors.skMuted, fontSize: 13),
              ),
            )
          else
            ...activities.map((a) => _buildActivityRow(a)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(Map<String, dynamic> activity) {
    final colors = _getAvatarColor(activity['colorIdx'] as int);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
        ),
      ),
      child: Row(
        children: [
          // Time
          Expanded(
            flex: 2,
            child: Text(
              activity['time'] ?? '',
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted),
            ),
          ),
          // User
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[0],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    activity['initials'] ?? '',
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 11, fontWeight: FontWeight.w500, color: colors[1]),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    activity['username'] ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skWhite),
                  ),
                ),
              ],
            ),
          ),
          // Action chip
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: activity['actionBg'] as Color,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    activity['action'] ?? '',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: activity['actionColor'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Detail
          Expanded(
            flex: 4,
            child: Text(
              activity['detail'] ?? '',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ── Users Page ──
  Widget _buildUsersPage() {
    final filtered = _userSearch.isEmpty
        ? _users
        : _users.where((u) {
            final q = _userSearch.toLowerCase();
            return (u['username'] ?? '').toString().toLowerCase().contains(q) ||
                (u['display_name'] ?? '').toString().toLowerCase().contains(q) ||
                (u['email'] ?? '').toString().toLowerCase().contains(q);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Kelola pengguna ',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.skWhite,
              ),
            ),
            Text(
              '— ${_users.length} pengguna',
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Search
        _buildSearchBar(
          hint: 'Cari username, nama, atau email...',
          onChanged: (val) => setState(() => _userSearch = val),
        ),
        const SizedBox(height: 12),
        // Table
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.skDark2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.skCard,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      _tableHeader('Pengguna', flex: 4),
                      _tableHeader('Email', flex: 3),
                      _tableHeader('Role', flex: 2),
                      _tableHeader('Status', flex: 2),
                      _tableHeader('Aksi', flex: 2),
                    ],
                  ),
                ),
                // Table body
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 32, color: AppColors.skMuted),
                              SizedBox(height: 8),
                              Text('Tidak ada pengguna ditemukan',
                                  style: TextStyle(color: AppColors.skMuted, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _buildUserRow(filtered[i], i),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user, int index) {
    final name = user['display_name'] ?? user['username'] ?? '';
    final username = user['username'] ?? '';
    final email = user['email'] ?? '';
    final role = user['role'] ?? 'user';
    final isActive = user['is_active'] ?? true;
    final userId = user['id'] as int? ?? 0;
    final initials = _getInitials(name);
    final colors = _getAvatarColor(userId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
        ),
      ),
      child: Row(
        children: [
          // User info
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[0],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 11, fontWeight: FontWeight.w500, color: colors[1]),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.skWhite)),
                      Text('@$username',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.skMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Email
          Expanded(
            flex: 3,
            child: Text(email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted)),
          ),
          // Role chip
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: role == 'moderator' ? _chipAmberBg : _chipBlueBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: role == 'moderator' ? _chipAmber : _chipBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status chip
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive == true ? _chipGreenBg : const Color(0xFF2A2A24),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isActive == true ? 'active' : 'inactive',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isActive == true ? _chipGreen : AppColors.skMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Toggle active/inactive
                _miniButton(
                  icon: isActive == true ? Icons.block : Icons.check_circle_outline,
                  tooltip: isActive == true ? 'Nonaktifkan' : 'Aktifkan',
                  onTap: () => _toggleUserActive(userId),
                ),
                const SizedBox(width: 4),
                // Delete (only non-moderators)
                if (role != 'moderator')
                  _miniButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Hapus',
                    color: _chipRed,
                    bgColor: _chipRedBg,
                    onTap: () => _showDeleteDialog(
                      'Hapus Pengguna?',
                      'Tindakan ini permanen. Pengguna "$name" akan dihapus dari platform.',
                      () => _deleteUser(userId),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Posts Page ──
  Widget _buildPostsPage() {
    final filtered = _postSearch.isEmpty
        ? _posts
        : _posts.where((p) {
            final q = _postSearch.toLowerCase();
            final caption = (p['caption'] ?? '').toString().toLowerCase();
            final author = p['author'] as Map<String, dynamic>?;
            final username = (author?['username'] ?? '').toString().toLowerCase();
            return caption.contains(q) || username.contains(q);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Kelola postingan ',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.skWhite),
            ),
            Text(
              '— ${_posts.length} postingan',
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSearchBar(
          hint: 'Cari caption atau username...',
          onChanged: (val) => setState(() => _postSearch = val),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.skDark2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.skCard,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      _tableHeader('Post', flex: 5),
                      _tableHeader('Pengguna', flex: 3),
                      _tableHeader('Like', flex: 1),
                      _tableHeader('Komentar', flex: 1),
                      _tableHeader('Aksi', flex: 2),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_outlined, size: 32, color: AppColors.skMuted),
                              SizedBox(height: 8),
                              Text('Tidak ada postingan', style: TextStyle(color: AppColors.skMuted, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _buildPostRow(filtered[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostRow(Map<String, dynamic> post) {
    final caption = post['caption'] ?? '';
    final author = post['author'] as Map<String, dynamic>?;
    final username = author?['username'] ?? '?';
    final authorName = author?['display_name'] ?? username;
    final authorId = author?['id'] ?? 0;
    final likeCount = post['like_count'] ?? (post['likes'] is List ? (post['likes'] as List).length : 0);
    final commentCount = post['comment_count'] ?? 0;
    final postId = post['id'] as int? ?? 0;
    final imageUrl = post['image_url'] as String?;
    final colors = _getAvatarColor(authorId is int ? authorId : 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03))),
      ),
      child: Row(
        children: [
          // Post thumb + caption
          Expanded(
            flex: 5,
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          ApiService.resolveImageUrl(imageUrl),
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _postThumbPlaceholder(),
                        )
                      : _postThumbPlaceholder(),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    caption,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted),
                  ),
                ),
              ],
            ),
          ),
          // Author
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: colors[0]),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(authorName),
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 10, fontWeight: FontWeight.w500, color: colors[1]),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('@$username',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skWhite)),
                ),
              ],
            ),
          ),
          // Like
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppColors.skRose, size: 13),
                const SizedBox(width: 3),
                Text('$likeCount', style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skWhite)),
              ],
            ),
          ),
          // Comment
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: _chipBlue, size: 13),
                const SizedBox(width: 3),
                Text('$commentCount', style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skWhite)),
              ],
            ),
          ),
          // Action
          Expanded(
            flex: 2,
            child: _miniButton(
              icon: Icons.delete_outline,
              label: 'Hapus',
              color: _chipRed,
              bgColor: _chipRedBg,
              onTap: () => _showDeleteDialog(
                'Hapus Postingan?',
                'Tindakan ini permanen. Postingan akan dihapus dari platform.',
                () => _deletePost(postId),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _postThumbPlaceholder() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.skCard,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.skMuted, size: 18),
    );
  }

  // ── Comments Page ──
  Widget _buildCommentsPage() {
    final filtered = _commentSearch.isEmpty
        ? _comments
        : _comments.where((c) {
            final q = _commentSearch.toLowerCase();
            final content = (c['content'] ?? '').toString().toLowerCase();
            final user = c['user'] as Map<String, dynamic>?;
            final username = (user?['username'] ?? '').toString().toLowerCase();
            return content.contains(q) || username.contains(q);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Kelola komentar ',
                style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.skWhite)),
            Text('— ${_comments.length} komentar',
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted)),
          ],
        ),
        const SizedBox(height: 12),
        _buildSearchBar(
          hint: 'Cari isi komentar atau username...',
          onChanged: (val) => setState(() => _commentSearch = val),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.skDark2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.skCard,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      _tableHeader('Komentar', flex: 5),
                      _tableHeader('Pengguna', flex: 3),
                      _tableHeader('Di postingan', flex: 3),
                      _tableHeader('Aksi', flex: 2),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 32, color: AppColors.skMuted),
                              SizedBox(height: 8),
                              Text('Tidak ada komentar', style: TextStyle(color: AppColors.skMuted, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _buildCommentRow(filtered[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentRow(Map<String, dynamic> comment) {
    final content = comment['content'] ?? '';
    final user = comment['user'] as Map<String, dynamic>?;
    final post = comment['Post'] as Map<String, dynamic>?;
    final username = user?['username'] ?? '?';
    final userId = user?['id'] ?? 0;
    final postCaption = post?['caption'] ?? '—';
    final commentId = comment['id'] as int? ?? 0;
    final createdAt = comment['created_at'] != null
        ? timeAgo(DateTime.parse(comment['created_at']))
        : '';
    final colors = _getAvatarColor(userId is int ? userId : 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03))),
      ),
      child: Row(
        children: [
          // Comment text
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skWhite)),
                if (createdAt.isNotEmpty)
                  Text(createdAt,
                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.skMuted.withValues(alpha: 0.6))),
              ],
            ),
          ),
          // User
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: colors[0]),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(user?['display_name'] ?? username),
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 10, fontWeight: FontWeight.w500, color: colors[1]),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('@$username',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skWhite)),
                ),
              ],
            ),
          ),
          // Post reference
          Expanded(
            flex: 3,
            child: Text(
              postCaption.length > 30 ? '${postCaption.substring(0, 30)}...' : postCaption,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted),
            ),
          ),
          // Action
          Expanded(
            flex: 2,
            child: _miniButton(
              icon: Icons.delete_outline,
              label: 'Hapus',
              color: _chipRed,
              bgColor: _chipRedBg,
              onTap: () => _showDeleteDialog(
                'Hapus Komentar?',
                'Tindakan ini permanen. Komentar akan dihapus dari platform.',
                () => _deleteComment(commentId),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DM Page ──
  Widget _buildDmPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Monitor chat / DM',
                style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.skWhite)),
            const SizedBox(width: 12),
            Text('Moderator dapat melihat percakapan yang melanggar aturan',
                style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted)),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conversation list
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.skDark2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: _conversations.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_outlined, size: 32, color: AppColors.skMuted),
                              SizedBox(height: 8),
                              Text('Belum ada percakapan', style: TextStyle(color: AppColors.skMuted, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, i) => _buildConvoItem(i),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Conversation detail
              Expanded(
                flex: 3,
                child: _activeConvoIndex != null
                    ? _buildConvoDetail()
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.skDark2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: const Center(
                          child: Text(
                            'Pilih percakapan untuk melihat detail',
                            style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skMuted),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConvoItem(int index) {
    final convo = _conversations[index];
    final otherUser = convo['other_user'] as Map<String, dynamic>?;
    final name = otherUser?['display_name'] ?? otherUser?['username'] ?? 'Pengguna';
    final initials = _getInitials(name);
    final lastMsg = convo['last_message']?['content'] ?? '';
    final unread = convo['unread_count'] ?? 0;
    final isSelected = _activeConvoIndex == index;
    final userId = otherUser?['id'] ?? 0;
    final colors = _getAvatarColor(userId is int ? userId : 0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _activeConvoIndex = index);
          final otherId = otherUser?['id'];
          if (otherId != null) {
            _loadConvoMessages(otherId);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.skCard : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: colors[0]),
                alignment: Alignment.center,
                child: Text(initials,
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w500, color: colors[1])),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.skWhite)),
                    const SizedBox(height: 2),
                    Text(lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.skMuted)),
                  ],
                ),
              ),
              if (unread > 0)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.skRose),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConvoDetail() {
    if (_activeConvoIndex == null || _activeConvoIndex! >= _conversations.length) {
      return const SizedBox.shrink();
    }
    final convo = _conversations[_activeConvoIndex!];
    final otherUser = convo['other_user'] as Map<String, dynamic>?;
    final name = otherUser?['display_name'] ?? otherUser?['username'] ?? 'Pengguna';
    final authProvider = context.read<AuthProvider>();
    final myId = authProvider.currentUser?.id;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.skDark2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                Text(
                  'Percakapan dengan $name',
                  style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.skWhite),
                ),
                const Spacer(),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: _convoMessages.isEmpty
                ? const Center(
                    child: Text('Memuat pesan...',
                        style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _convoMessages.length,
                    itemBuilder: (context, i) {
                      final msg = _convoMessages[i];
                      final senderId = msg['sender_id']?.toString();
                      final isMine = senderId == myId;
                      final content = msg['content'] ?? '';
                      final senderUser = msg['sender'] as Map<String, dynamic>?;
                      final senderName = senderUser?['username'] ?? 'user';

                      return Align(
                        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.35),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            color: isMine ? _chipPinkBg : AppColors.skCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMine
                                  ? const Color(0x33993556)
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                senderName,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isMine ? _chipPink : AppColors.skMuted,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                content,
                                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skWhite),
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

  // ══════════════════════════════════════
  //  SHARED WIDGETS
  // ══════════════════════════════════════

  Widget _buildSearchBar({required String hint, required ValueChanged<String> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.skCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: AppColors.skMuted.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skWhite),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.skMuted.withValues(alpha: 0.6)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.skMuted.withValues(alpha: 0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _miniButton({
    required IconData icon,
    String? label,
    String? tooltip,
    Color color = AppColors.skWhite,
    Color bgColor = const Color(0x00000000),
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip ?? label ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor != const Color(0x00000000) ? bgColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: color),
                if (label != null) ...[
                  const SizedBox(width: 4),
                  Text(label,
                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 11, fontWeight: FontWeight.w500, color: color)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  DIALOGS
  // ══════════════════════════════════════

  void _showDeleteDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.skDark2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title,
            style: const TextStyle(fontFamily: 'DM Sans', color: AppColors.skWhite, fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text(content,
            style: const TextStyle(fontFamily: 'DM Sans', color: AppColors.skMuted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.skMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.skRose, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.skDark2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Konfirmasi Keluar',
            style: TextStyle(fontFamily: 'DM Sans', color: AppColors.skWhite, fontSize: 16, fontWeight: FontWeight.w500)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Moderator?',
            style: TextStyle(fontFamily: 'DM Sans', color: AppColors.skMuted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.skMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Keluar',
                style: TextStyle(color: AppColors.skRose, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
