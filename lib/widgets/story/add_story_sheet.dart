import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/common/sk_button.dart';
import '../../widgets/common/sk_text_field.dart';

/// AddStorySheet — Bottom sheet untuk membuat story baru
class AddStorySheet extends StatefulWidget {
  const AddStorySheet({super.key});

  @override
  State<AddStorySheet> createState() => _AddStorySheetState();
}

class _AddStorySheetState extends State<AddStorySheet> {
  final TextEditingController _urlController = TextEditingController();
  String? _selectedSampleUrl;

  final List<String> _sampleUrls = [
    'https://picsum.photos/seed/travelstory/1080/1920',
    'https://picsum.photos/seed/lifestory/1080/1920',
    'https://picsum.photos/seed/citystory/1080/1920',
    'https://picsum.photos/seed/cafestory/1080/1920',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submitStory() {
    final imageUrl = _urlController.text.trim().isNotEmpty
        ? _urlController.text.trim()
        : _selectedSampleUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan pilih contoh gambar atau masukkan URL gambar'),
          backgroundColor: AppColors.skRose,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    storyProvider.addStory(currentUser.id, imageUrl);

    Navigator.pop(context); // Tutup bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Story berhasil diunggah! ✨'),
        backgroundColor: AppColors.skCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeUrl = _urlController.text.trim().isNotEmpty
        ? _urlController.text.trim()
        : _selectedSampleUrl;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.skDark2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
            'Buat Story Baru',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.skWhite,
            ),
          ),
          const SizedBox(height: 16),

          // Area Preview Gambar
          Center(
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: activeUrl != null && activeUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        activeUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.skMuted,
                            size: 32,
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: AppColors.skMuted,
                            size: 32,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              color: AppColors.skMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Pilihan Gambar Contoh
          const Text(
            'Pilih Gambar Contoh',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.skWhite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _sampleUrls.map((url) {
              final isSelected = _selectedSampleUrl == url && _urlController.text.isEmpty;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSampleUrl = url;
                    _urlController.clear();
                  });
                },
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.skRose : Colors.white10,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Custom URL Input
          SKTextField(
            label: 'Atau Masukkan URL Gambar Kustom',
            hint: 'https://example.com/image.jpg',
            prefixIcon: Icons.link,
            controller: _urlController,
            onChanged: (val) {
              setState(() {});
            },
          ),
          const SizedBox(height: 20),

          // Tombol Unggah Story
          SKButton(
            label: 'Unggah Story',
            onTap: _submitStory,
          ),
        ],
      ),
    );
  }
}
