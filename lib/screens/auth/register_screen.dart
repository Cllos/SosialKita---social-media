import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/sk_button.dart';
import '../../widgets/common/sk_text_field.dart';

/// Register Screen — SosialKita
/// Sesuai design dari sosialkita_ui.html (section REGISTER)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _nameController.text.trim(),
      _usernameController.text.trim().toLowerCase(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi berhasil! Selamat datang, ${_nameController.text.trim()} 👋'),
          backgroundColor: AppColors.skCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
      // Kembali ke root. main.dart akan mendeteksi authProvider.isLoggedIn == true
      // dan mengarahkan ke HomeScreen secara otomatis.
      Navigator.pop(context); 
    } else {
      setState(() {
        _errorMessage = 'Email atau username sudah terdaftar';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo & Nama Aplikasi
                _buildHeaderLogo(),
                const SizedBox(height: 28),

                // Salam Sambutan
                _buildGreeting(),
                const SizedBox(height: 24),

                // Form Register
                _buildRegisterForm(),
                const SizedBox(height: 24),

                // Link ke Halaman Login
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header Logo: Icon + Nama "SosialKita"
  Widget _buildHeaderLogo() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.skGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.skRose.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.people_alt_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.skGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'SosialKita',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Greeting: "Buat Akun Baru ✨" + subtitle
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buat Akun Baru ✨',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.skWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Daftar untuk mulai terhubung',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: AppColors.skMuted.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Form register: nama, username, email, password, konfirmasi, button, error
  Widget _buildRegisterForm() {
    final authProvider = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nama Lengkap ──
          SKTextField(
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap Anda',
            prefixIcon: Icons.person_outline_rounded,
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama lengkap wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Username ──
          SKTextField(
            label: 'Username',
            hint: 'Buat username (misal: andi_y)',
            prefixIcon: Icons.alternate_email_rounded,
            controller: _usernameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username wajib diisi';
              }
              if (value.trim().contains(' ')) {
                return 'Username tidak boleh mengandung spasi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Email ──
          SKTextField(
            label: 'Email',
            hint: 'Masukkan alamat email aktif',
            prefixIcon: Icons.mail_outline_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email wajib diisi';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Password ──
          SKTextField(
            label: 'Password',
            hint: 'Masukkan password (min 6 karakter)',
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            obscureText: _obscurePassword,
            controller: _passwordController,
            onSuffixTap: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password wajib diisi';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Konfirmasi Password ──
          SKTextField(
            label: 'Konfirmasi Password',
            hint: 'Masukkan ulang password',
            prefixIcon: Icons.lock_reset_rounded,
            suffixIcon: _obscureConfirmPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            obscureText: _obscureConfirmPassword,
            controller: _confirmPasswordController,
            onSuffixTap: () {
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password wajib diisi';
              }
              if (value != _passwordController.text) {
                return 'Password tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // ── Error Message ──
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.skRose.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.skRose.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.skRose,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: AppColors.skRose,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Tombol Daftar ──
          SKButton(
            label: 'Daftar',
            isLoading: authProvider.isLoading,
            onTap: _handleRegister,
          ),
        ],
      ),
    );
  }

  /// Teks navigasi kembali ke login: "Sudah punya akun? Masuk"
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12.5,
            color: AppColors.skMuted.withOpacity(0.8),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Masuk',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.5,
              color: AppColors.skRose,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
