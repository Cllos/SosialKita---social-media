import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosialkita/core/utils/dummy_data.dart';
import '../../core/theme/app_colors.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../widgets/story/add_story_sheet.dart';
import '../profile/profile_screen.dart';
import '../../providers/chat_provider.dart';

/// StoryViewScreen — Penayang cerita (story viewer) full-screen ala Instagram
class StoryViewScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final UserModel user;

  const StoryViewScreen({super.key, required this.stories, required this.user});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  late List<StoryModel> _localStories;
  int _currentIndex = 0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _localStories = List.from(widget.stories);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Durasi per story: 5 detik
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _startStory();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startStory() {
    _animController.reset();
    _animController.forward();
    _markCurrentStoryAsViewed();
  }

  void _markCurrentStoryAsViewed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      if (currentUser != null && _currentIndex < _localStories.length) {
        final currentStory = _localStories[_currentIndex];
        context.read<StoryProvider>().markStoryAsViewed(
          currentStory.id,
          currentUser.id,
        );
      }
    });
  }

  void _nextStory() {
    if (_currentIndex < _localStories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startStory();
    } else {
      // Selesai melihat seluruh story user ini → tutup halaman
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _startStory();
    } else {
      // Jika di paling pertama → restart progress story tersebut
      _startStory();
    }
  }

  void _deleteStory(BuildContext context, StoryModel story) {
    _animController.stop();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.skCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Text(
          'Hapus Cerita?',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.skWhite,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus cerita ini secara permanen?',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _animController.forward();
            },
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'DM Sans',
                color: AppColors.skMuted,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              // Hapus dari provider
              context.read<StoryProvider>().deleteStory(story.id);

              setState(() {
                _localStories.removeAt(_currentIndex);
              });

              if (_localStories.isEmpty) {
                Navigator.pop(context); // Tutup viewer jika cerita habis
              } else {
                if (_currentIndex >= _localStories.length) {
                  _currentIndex = _localStories.length - 1;
                }
                _startStory();
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'DM Sans',
                color: AppColors.skRose,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewStoryFromViewer(BuildContext context) async {
    _animController.stop();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddStorySheet();
      },
    );
    // Setelah bottom sheet ditutup, perbarui cerita lokal
    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();
    final myStories = storyProvider.getStoriesByUser(
      authProvider.currentUser!.id,
    );

    if (myStories.isNotEmpty) {
      setState(() {
        _localStories = List.from(myStories);
        // Arahkan ke cerita yang baru saja ditambahkan
        _currentIndex = _localStories.length - 1;
      });
      _startStory();
    } else {
      _animController.forward();
    }
  }

  Widget _buildStoryImage(StoryModel story) {
    final isNetwork = story.mediaUrl.startsWith('http') || story.mediaUrl.startsWith('blob:') || kIsWeb;
    if (isNetwork) {
      return Image.network(
        story.mediaUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            // Jalankan animasi hanya saat gambar selesai di-load
            if (!_animController.isAnimating) {
              _animController.forward();
            }
            return child;
          }
          // Pause animasi saat loading gambar
          _animController.stop();
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.skRose,
            ),
          );
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.skMuted,
            size: 48,
          ),
        ),
      );
    } else {
      // Local image file
      // Auto-start animation since local image does not need network loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_animController.isAnimating) {
          _animController.forward();
        }
      });
      return Image.file(
        File(story.mediaUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.skMuted,
            size: 48,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localStories.isEmpty) return const SizedBox.shrink();

    final story = _localStories[_currentIndex];
    final authProvider = context.watch<AuthProvider>();
    final isOwn = authProvider.currentUser?.id == widget.user.id;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Gambar Story Full Screen + Gesture Detector (Tap & Hold to Pause)
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (_) {
                  _animController.stop();
                },
                onTapCancel: () {
                  if (!_animController.isAnimating) {
                    _animController.forward();
                  }
                },
                onTapUp: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx < screenWidth / 3) {
                    // Tap kiri → Sebelumnya
                    _previousStory();
                  } else {
                    // Tap kanan → Selanjutnya
                    _nextStory();
                  }
                },
                onLongPressStart: (_) {
                  _animController.stop();
                },
                onLongPressEnd: (_) {
                  _animController.forward();
                },
                child: Container(
                  color: Colors.black,
                  child: _buildStoryImage(story),
                ),
              ),
            ),

            // Header info & Progress Bar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  // Progress Bars
                  Row(
                    children: List.generate(
                      _localStories.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: index == _currentIndex
                              ? AnimatedBuilder(
                                  animation: _animController,
                                  builder: (context, child) {
                                    return LinearProgressIndicator(
                                      value: _animController.value,
                                      backgroundColor: Colors.white24,
                                      color: Colors.white,
                                      minHeight: 2.5,
                                    );
                                  },
                                )
                              : LinearProgressIndicator(
                                  value: index < _currentIndex ? 1.0 : 0.0,
                                  backgroundColor: Colors.white24,
                                  color: Colors.white,
                                  minHeight: 2.5,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info Profil Pembuat Story & Tombol Close/Hapus
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _animController.stop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileScreen(userId: widget.user.id),
                            ),
                          ).then((_) {
                            if (mounted) {
                              _animController.forward();
                            }
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            SKAvatar(
                              imageUrl: widget.user.avatarUrl,
                              initials: widget.user.avatarInitials,
                              backgroundColor: widget.user.avatarColor,
                              size: 36,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user.displayName,
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _formatStoryTime(story.createdAt),
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 9.5,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Tombol Hapus (sampah) jika milik sendiri
                      if (isOwn) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => _deleteStory(context, story),
                        ),
                        const SizedBox(width: 4),
                      ],

                      // Tombol Tutup (X)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tombol di bagian bawah
            if (isOwn)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Penonton Story
                    GestureDetector(
                      onTap: () => _showStoryViewersBottomSheet(context, story),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Dilihat ${story.viewerIds.length} orang',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tambah Cerita
                    GestureDetector(
                      onTap: () => _addNewStoryFromViewer(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Tambah Cerita',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 16,
                right: 16,
                child: _buildQuickReplyArea(context, story),
              ),
          ],
        ),
      ),
    );
  }

  // Format waktu upload story ringkas
  String _formatStoryTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else {
      return '${diff.inDays} hari lalu';
    }
  }

  void _showStoryViewersBottomSheet(BuildContext context, StoryModel story) {
    _animController.stop();

    // Dapatkan data user dari dummyUsers
    final viewers = dummyUsers
        .where((u) => story.viewerIds.contains(u.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.skCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line pill
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Penonton',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (viewers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'Belum ada penonton',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: AppColors.skMuted,
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: viewers.length,
                    itemBuilder: (context, index) {
                      final viewer = viewers[index];
                      return ListTile(
                        leading: SKAvatar(
                          initials: viewer.avatarInitials,
                          backgroundColor: viewer.avatarColor,
                          imageUrl: viewer.avatarUrl,
                          size: 38,
                        ),
                        title: Text(
                          viewer.displayName,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            color: AppColors.skWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '@${viewer.username}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            color: AppColors.skMuted,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetCtx); // Tutup bottom sheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(userId: viewer.id),
                            ),
                          ).then((_) {
                            if (mounted) {
                              _animController.forward();
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted && !_animController.isAnimating) {
        _animController.forward();
      }
    });
  }

  Widget _buildQuickReplyArea(BuildContext context, StoryModel story) {
    final TextEditingController replyController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: replyController,
              onTap: () {
                _animController.stop();
              },
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.skWhite,
              ),
              decoration: const InputDecoration(
                hintText: 'Balas cerita...',
                hintStyle: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: AppColors.skMuted,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            final msg = replyController.text.trim();
            if (msg.isEmpty) {
              _animController.forward();
              return;
            }

            final authProvider = context.read<AuthProvider>();
            final currentUser = authProvider.currentUser;
            if (currentUser == null) return;

            final chatProvider = context.read<ChatProvider>();
            final conv = chatProvider.getOrCreateConversation(
              currentUser.id,
              story.userId,
            );

            // Kirim pesan DM sebagai balasan story
            chatProvider.sendMessage(
              conv.id,
              currentUser.id,
              story.userId,
              'Membalas Cerita Anda: "$msg"',
            );

            replyController.clear();
            FocusScope.of(context).unfocus(); // Sembunyikan keyboard

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Balasan terkirim ke DM 💬'),
                backgroundColor: AppColors.skCard,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            _animController.forward();
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.skGradient,
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}
