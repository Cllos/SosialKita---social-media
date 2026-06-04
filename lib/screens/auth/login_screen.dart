import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/sk_button.dart';
import '../../widgets/common/sk_text_field.dart';

/// Login Screen — SosialKita
/// Sesuai design dari sosialkita_ui.html (section LOGIN)
/// Data dummy: andi@email.com / 123456
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigasi berdasarkan role
      if (authProvider.isModerator) {
        // TODO: Navigator ke ModeratorDashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login berhasil sebagai Moderator! 🛡️'),
            backgroundColor: AppColors.skCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        // TODO: Navigator ke HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selamat datang, ${authProvider.currentUser!.displayName}! 👋',
            ),
            backgroundColor: AppColors.skCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Email/username atau password salah';
      });
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur belum tersedia'),
        backgroundColor: AppColors.skCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Login Google segera hadir'),
        backgroundColor: AppColors.skCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _handleNavigateToRegister() {
    // TODO: Navigator.pushNamed(context, '/register');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Halaman Register belum tersedia'),
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
    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // ── Logo ──
                      _buildLogo(),
                      const SizedBox(height: 20),

                      // ── Greeting ──
                      _buildGreeting(),
                      const SizedBox(height: 28),

                      // ── Form ──
                      _buildLoginForm(),

                      // ── Spacer + Footer ──
                      const SizedBox(height: 24),
                      _buildFooter(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo SosialKita — icon gradient + nama gradient
  Widget _buildLogo() {
    return Row(
      children: [
        // Icon box dengan gradient
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
        // Nama gradient
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

  /// Greeting: "Selamat Datang 👋" + subtitle
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selamat Datang 👋',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.skWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Masuk ke akun kamu',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: AppColors.skMuted.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Form login: email, password, forgot, button, divider, Google, error
  Widget _buildLoginForm() {
    final authProvider = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Email / Username ──
          SKTextField(
            label: 'Email / Username',
            hint: 'Masukkan email atau username',
            prefixIcon: Icons.mail_outline_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email atau username wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Password ──
          SKTextField(
            label: 'Password',
            hint: 'Masukkan password',
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
          const SizedBox(height: 8),

          // ── Lupa password ──
          GestureDetector(
            onTap: _handleForgotPassword,
            child: const Text(
              'Lupa password?',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.skRose,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Error message ──
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
                        color: AppColors.skRose,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Tombol Masuk ──
          SKButton(
            label: 'Masuk',
            icon: Icons.login_rounded,
            isLoading: authProvider.isLoading,
            onTap: _handleLogin,
          ),
          const SizedBox(height: 20),

          // ── Divider ──
          _buildDivider(),
          const SizedBox(height: 20),

          // ── Google Login ──
          _buildGoogleButton(),
        ],
      ),
    );
  }

  /// Divider: "atau lanjutkan dengan"
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.07),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau lanjutkan dengan',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: AppColors.skMuted.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.07),
          ),
        ),
      ],
    );
  }

  /// Tombol Google login
  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleLogin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEA4335),
                    height: 1.15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Google',
              style: TextStyle(
                fontFamily: 'DM Sans',
                color: AppColors.skWhite,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Footer: "Belum punya akun? Daftar sekarang"
  Widget _buildFooter() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Belum punya akun? ',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.skMuted.withOpacity(0.8),
            ),
          ),
          GestureDetector(
            onTap: _handleNavigateToRegister,
            child: const Text(
              'Daftar sekarang',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.skRose,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
