import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/sk_avatar.dart';
import '../../widgets/common/sk_text_field.dart';

/// EditProfileSheet — Bottom sheet / dialog untuk edit profil pengguna
/// Mengubah displayName, bio, avatarUrl, dan avatarColor
class EditProfileSheet extends StatefulWidget {
  final UserModel user;

  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _avatarUrlController;
  late Color _selectedColor;
  final _formKey = GlobalKey<FormState>();

  final List<String> _sampleAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
  ];

  final List<Color> _avatarColors = [
    AppColors.skRose,
    AppColors.skViolet,
    const Color(0xFFFB923C), // Orange
    const Color(0xFF10B981), // Emerald
    const Color(0xFF0EA5E9), // Sky Blue
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio);
    _avatarUrlController = TextEditingController(text: widget.user.avatarUrl);
    _selectedColor = widget.user.avatarColor;

    // Trigger rebuild saat ada perubahan input nama/url gambar untuk real-time preview
    _nameController.addListener(() => setState(() {}));
    _avatarUrlController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final updated = widget.user.copyWith(
      displayName: name,
      bio: _bioController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim(),
      avatarColor: _selectedColor,
      avatarInitials: _getInitials(name),
    );

    context.read<AuthProvider>().updateProfile(updated);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil diperbarui ✨'),
        backgroundColor: AppColors.skCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.skCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle Bar ──
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Title ──
              const Text(
                'Edit Profil',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.skWhite,
                ),
              ),
              const SizedBox(height: 20),

              // ── Avatar Preview ──
              Center(
                child: Column(
                  children: [
                    SKAvatar(
                      imageUrl: _avatarUrlController.text.trim(),
                      initials: _getInitials(_nameController.text.trim()),
                      backgroundColor: _selectedColor,
                      size: 80,
                      showRing: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '@${widget.user.username}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: AppColors.skMuted.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Nama Lengkap ──
              _buildLabel('NAMA LENGKAP'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: AppColors.skWhite,
                ),
                decoration: _inputDecoration(
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Bio ──
              _buildLabel('BIO'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bioController,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: AppColors.skWhite,
                ),
                maxLines: 2,
                maxLength: 150,
                decoration: _inputDecoration(
                  hint: 'Ceritakan tentang dirimu...',
                  icon: Icons.edit_note_rounded,
                ).copyWith(
                  counterStyle: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.skMuted.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Preset Foto ──
              _buildLabel('PILIH FOTO PROFIL PRESET'),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleAvatars.length,
                  itemBuilder: (context, idx) {
                    final url = _sampleAvatars[idx];
                    final isSelected = _avatarUrlController.text.trim() == url;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _avatarUrlController.text = url;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.skRose : Colors.white12,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ── Preset Warna (Fallback jika tidak ada URL foto) ──
              _buildLabel('WARNA AVATAR (CADANGAN FOTO)'),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatarColors.length,
                  itemBuilder: (context, idx) {
                    final color = _avatarColors[idx];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ── Reset Foto ──
              if (_avatarUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _avatarUrlController.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.skRose, size: 16),
                      label: const Text(
                        'Hapus Foto (Gunakan Inisial)',
                        style: TextStyle(
                          color: AppColors.skRose,
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── URL Foto Kustom ──
              SKTextField(
                label: 'Atau Masukkan URL Foto Kustom',
                hint: 'https://example.com/photo.jpg',
                prefixIcon: Icons.link,
                controller: _avatarUrlController,
              ),
              const SizedBox(height: 24),

              // ── Tombol Simpan ──
              GestureDetector(
                onTap: _onSave,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.skGradientBtn,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.skRose.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Tombol Batal ──
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.skMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.skMuted.withOpacity(0.8),
        letterSpacing: 0.8,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 13,
        color: AppColors.skMuted.withOpacity(0.5),
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.skMuted.withOpacity(0.6),
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.skViolet),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.skRose),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.skRose),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 11,
        color: AppColors.skRose,
      ),
    );
  }
}
