import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// DesktopSidebar — Navigasi sidebar kiri untuk layout desktop
/// Sesuai design sosialkita_ui.html (.desk-sidebar)
class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ──
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 20),
            child: ShaderMask(
              shaderCallback: (bounds) => AppColors.skGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: const Text(
                'SosialKita',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ── Nav Items ──
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Beranda',
            isActive: selectedIndex == 0,
            onTap: () => onItemTap(0),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            label: 'Cari',
            isActive: selectedIndex == 1,
            onTap: () => onItemTap(1),
          ),
          _NavItem(
            icon: Icons.explore_outlined,
            label: 'Eksplorasi',
            isActive: selectedIndex == 2,
            onTap: () => onItemTap(2),
          ),
          _NavItem(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            isActive: selectedIndex == 3,
            onTap: () => onItemTap(3),
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Pesan',
            isActive: selectedIndex == 4,
            onTap: () => onItemTap(4),
          ),
          _NavItem(
            icon: Icons.bookmark_border,
            label: 'Tersimpan',
            isActive: selectedIndex == 5,
            onTap: () => onItemTap(5),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            isActive: selectedIndex == 6,
            onTap: () => onItemTap(6),
          ),

          const Spacer(),

          // ── Settings ──
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Pengaturan',
            isActive: false,
            onTap: () {},
          ),
          const SizedBox(height: 8),

          // ── Buat Postingan ──
          GestureDetector(
            onTap: () {
              // TODO: Navigasi ke CreatePostScreen
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.skGradientBtn,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.skRose.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Buat Postingan',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.skRose.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.skRose : AppColors.skMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: isActive ? AppColors.skRose : AppColors.skMuted,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isActive)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.skRose,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
