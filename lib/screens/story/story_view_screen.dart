import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../widgets/common/sk_avatar.dart';

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
  int _currentIndex = 0;
  late AnimationController _animController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
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
    _timer?.cancel();
    super.dispose();
  }

  void _startStory() {
    _animController.reset();
    _animController.forward();
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
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

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) return const SizedBox.shrink();

    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Gambar Story Full Screen
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx < screenWidth / 3) {
                    // Tap kiri → Sebelumnya
                    _previousStory();
                  } else {
                    // Tap kanan → Selanjutnya
                    _nextStory();
                  }
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
                      widget.stories.length,
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

                  // Info Profil Pembuat Story & Tombol Close
                  Row(
                    children: [
                      SKAvatar(
                        initials: widget.user.avatarInitials,
                        backgroundColor: widget.user.avatarColor,
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.username,
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
