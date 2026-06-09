import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, Uint8List;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';

/// CreatePostScreen — Halaman buat postingan baru
///
/// Fitur:
/// - Input URL gambar (fallback karena web tidak support image_picker)
/// - Preview gambar secara real-time
/// - Input caption (multiline, max 500 karakter + counter)
/// - Input lokasi (opsional)
/// - Parse hashtag otomatis dari caption (#...)
/// - Tombol "Bagikan" → tambahkan PostModel baru ke list dummy
/// - Validasi: gambar wajib, caption tidak boleh kosong
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  final _captionFocus = FocusNode();

  bool _isSubmitting = false;
  String _previewUrl = '';
  XFile? _pickedImage;

  // Dummy image URLs untuk quick-pick (memudahkan testing)
  static const List<String> _sampleImages = [
    'https://picsum.photos/seed/post-new-1/600/400',
    'https://picsum.photos/seed/post-new-2/600/400',
    'https://picsum.photos/seed/post-new-3/600/400',
    'https://picsum.photos/seed/post-new-4/600/400',
    'https://picsum.photos/seed/post-new-5/600/400',
    'https://picsum.photos/seed/post-new-6/600/400',
  ];

  @override
  void dispose() {
    _imageUrlController.dispose();
    _captionController.dispose();
    _locationController.dispose();
    _captionFocus.dispose();
    super.dispose();
  }

  /// Parse hashtag dari caption (contoh: #Makassar → 'Makassar')
  List<String> _parseHashtags(String caption) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(caption).map((m) => m.group(1)!).toList();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        if (source == ImageSource.camera) {
          final status = await Permission.camera.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            _showPermissionDialog('Kamera');
            return;
          }
        } else if (source == ImageSource.gallery) {
          PermissionStatus status;
          if (Platform.isAndroid) {
            status = await Permission.photos.request();
            if (status.isDenied) {
              status = await Permission.storage.request();
            }
          } else {
            status = await Permission.photos.request();
          }

          if (status.isDenied || status.isPermanentlyDenied) {
            _showPermissionDialog('Galeri Foto');
            return;
          }
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
          _previewUrl = image.path;
          _imageUrlController.text = ''; // Clear URL input if picking local
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: AppColors.skRoseDark,
        ),
      );
    }
  }

  void _showPermissionDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.skCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: Text(
          'Akses $type Diperlukan',
          style: const TextStyle(
            fontFamily: 'Syne',
            color: AppColors.skWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Aplikasi membutuhkan izin akses $type untuk memilih foto postingan. Harap aktifkan izin di pengaturan aplikasi.',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.skMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(
              'Pengaturan',
              style: TextStyle(color: AppColors.skViolet, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImageWidget() {
    final isNetwork = _previewUrl.startsWith('http') || _previewUrl.startsWith('blob:') || kIsWeb;
    if (isNetwork) {
      return Image.network(
        _previewUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(isError: true),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.skRose,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(_previewUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(isError: true),
      );
    }
  }

  void _onImageUrlChanged(String value) {
    setState(() => _previewUrl = value.trim());
  }

  void _pickSampleImage(String url) {
    _imageUrlController.text = url;
    setState(() => _previewUrl = url);
  }

  void _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_previewUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih atau masukkan URL gambar terlebih dahulu'),
          backgroundColor: AppColors.skRoseDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final caption = _captionController.text.trim();
    final location = _locationController.text.trim();

    Uint8List? imageBytes;
    if (_pickedImage == null && _imageUrlController.text.startsWith('http')) {
      try {
        final response = await http.get(Uri.parse(_imageUrlController.text));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      } catch (e) {
        debugPrint('Failed to download image bytes: $e');
      }
    }

    final success = await postProvider.uploadPost(
      caption: caption,
      location: location,
      imagePath: _pickedImage?.path,
      imageBytes: imageBytes,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Postingan berhasil dibagikan!'),
              ],
            ),
            backgroundColor: AppColors.skViolet,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal membagikan postingan ke database'),
            backgroundColor: AppColors.skRoseDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.skDark,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.skDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.skWhite,
            ),
          ),
        ),
      ),
      title: const Text(
        'Buat Postingan',
        style: TextStyle(
          fontFamily: 'Syne',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.skWhite,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _isSubmitting ? null : _submitPost,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: _isSubmitting ? null : AppColors.skGradientBtn,
                color: _isSubmitting
                    ? AppColors.skMuted.withOpacity(0.3)
                    : null,
                borderRadius: BorderRadius.circular(100),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Bagikan',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════
  //  MOBILE LAYOUT
  // ══════════════════════════════════════

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section ──
            _buildImageSection(),
            const SizedBox(height: 20),

            // ── Caption ──
            _buildCaptionField(),
            const SizedBox(height: 16),

            // ── Location ──
            _buildLocationField(),
            const SizedBox(height: 24),

            // ── Tags Preview ──
            _buildTagsPreview(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  DESKTOP LAYOUT
  // ══════════════════════════════════════

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom kiri: Image preview
                Expanded(
                  flex: 1,
                  child: _buildImageSection(),
                ),
                const SizedBox(width: 24),

                // Kolom kanan: Form fields
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCaptionField(),
                      const SizedBox(height: 16),
                      _buildLocationField(),
                      const SizedBox(height: 24),
                      _buildTagsPreview(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  //  IMAGE SECTION
  // ══════════════════════════════════════

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        _buildLabel('Gambar', Icons.image_outlined, isRequired: true),
        const SizedBox(height: 10),

        // Preview area
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _previewUrl.isNotEmpty
                    ? AppColors.skViolet.withOpacity(0.3)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: _previewUrl.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildPreviewImageWidget(),
                        // Remove button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              _imageUrlController.clear();
                              setState(() {
                                _previewUrl = '';
                                _pickedImage = null;
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Buttons to Pick from Camera / Gallery
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, color: AppColors.skRose, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Kamera',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: AppColors.skWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library_outlined, color: AppColors.skViolet, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Galeri',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: AppColors.skWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // URL input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: TextFormField(
            controller: _imageUrlController,
            onChanged: _onImageUrlChanged,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: AppColors.skWhite,
            ),
            decoration: InputDecoration(
              hintText: 'Masukkan URL gambar...',
              hintStyle: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.skMuted.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.link_rounded,
                size: 18,
                color: AppColors.skMuted.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Quick pick sample images
        _buildLabel(
          'Atau pilih gambar contoh',
          Icons.photo_library_outlined,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _sampleImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final url = _sampleImages[index];
              final isSelected = _previewUrl == url;
              return GestureDetector(
                onTap: () {
                  _pickSampleImage(url);
                  setState(() {
                    _pickedImage = null;
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.skRose
                          : Colors.white.withOpacity(0.08),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSelected ? 8 : 9),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.skCard,
                            child: Icon(
                              Icons.image_outlined,
                              size: 18,
                              color: AppColors.skMuted.withOpacity(0.4),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            color: AppColors.skRose.withOpacity(0.3),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder({bool isError = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isError ? AppColors.skRose : AppColors.skMuted)
                  .withOpacity(0.1),
            ),
            child: Icon(
              isError ? Icons.broken_image_outlined : Icons.add_photo_alternate_outlined,
              size: 28,
              color: (isError ? AppColors.skRose : AppColors.skMuted)
                  .withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isError
                ? 'URL gambar tidak valid'
                : 'Pilih gambar atau masukkan URL',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: (isError ? AppColors.skRose : AppColors.skMuted)
                  .withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  //  FORM FIELDS
  // ══════════════════════════════════════

  Widget _buildCaptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Caption', Icons.edit_outlined, isRequired: true),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _captionFocus.hasFocus
                  ? AppColors.skViolet.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _captionController,
                focusNode: _captionFocus,
                maxLines: 5,
                minLines: 3,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Caption tidak boleh kosong';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: AppColors.skWhite,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Tulis caption postinganmu...\nGunakan #hashtag untuk menambahkan tag',
                  hintStyle: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: AppColors.skMuted.withOpacity(0.4),
                    height: 1.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                  counterText: '',
                  errorStyle: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.skRose,
                  ),
                ),
              ),
              // Character counter
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${_captionController.text.length}/500',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: _captionController.text.length > 450
                            ? AppColors.skRose
                            : AppColors.skMuted.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Lokasi', Icons.location_on_outlined),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: TextFormField(
            controller: _locationController,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: AppColors.skWhite,
            ),
            decoration: InputDecoration(
              hintText: 'Tambahkan lokasi (opsional)',
              hintStyle: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.skMuted.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.skMuted.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsPreview() {
    final caption = _captionController.text;
    final tags = _parseHashtags(caption);

    if (tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Hashtag terdeteksi', Icons.tag_rounded),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.skViolet.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.skViolet.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tag_rounded,
                    size: 12,
                    color: AppColors.skViolet.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tag,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.skViolet.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ══════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════

  Widget _buildLabel(String text, IconData icon, {bool isRequired = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.skMuted),
        const SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.skMuted,
            letterSpacing: 0.8,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.skRose.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}
