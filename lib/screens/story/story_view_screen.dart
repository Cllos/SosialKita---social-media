import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../widgets/story/add_story_sheet.dart';

/// StoryViewScreen — Penayang cerita (story viewer) full-screen ala Instagram
class StoryViewScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final UserModel user;

  const StoryViewScreen({
    super.key,
    required this.stories,
    required this.user,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with SingleTickerProviderStateMixin {
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
    final myStories = storyProvider.getStoriesByUser(authProvider.currentUser!.id);
    
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
                  child: Image.network(
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
                  ),
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
                      const Spacer(),

                      // Tombol Hapus (sampah) jika milik sendiri
                      if (isOwn) ...[
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                          onPressed: () => _deleteStory(context, story),
                        ),
                        const SizedBox(width: 4),
                      ],

                      // Tombol Tutup (X)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tombol "+ Tambah Cerita" di bawah jika milik sendiri
            if (isOwn)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _addNewStoryFromViewer(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Tambah Cerita',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
}
