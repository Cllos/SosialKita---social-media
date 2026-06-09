import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// DesktopOnlyScreen — Ditampilkan saat moderator mencoba
/// mengakses Panel Admin di perangkat mobile/tablet.
class DesktopOnlyScreen extends StatelessWidget {
  const DesktopOnlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Ikon Desktop ──
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.skRose.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.skRose.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.desktop_windows_outlined,
                    color: AppColors.skRose,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Judul ──
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.skGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: const Text(
                    'Panel Admin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Deskripsi ──
                Text(
                  'Panel Admin SosialKita hanya tersedia\ndi perangkat desktop (layar ≥ 1024px).',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: AppColors.skMuted.withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan buka SosialKita di browser desktop\natau perlebar jendela browser Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: AppColors.skMuted.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Badge MOD ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.skRose.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.skRose.withOpacity(0.25),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.skRose, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Akun Moderator Terdeteksi',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.skRose,
                        ),
                      ),
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
}
