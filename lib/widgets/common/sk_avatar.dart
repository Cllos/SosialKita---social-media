import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// SKAvatar — Avatar lingkaran dengan gradient ring (opsional)
/// dan fallback initials jika tidak ada gambar
class SKAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final Color backgroundColor;
  final double size;
  final bool showRing;

  const SKAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    required this.backgroundColor,
    this.size = 36,
    this.showRing = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: showRing
            ? Border.all(color: AppColors.skDark, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'DM Sans',
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (!showRing) return avatar;

    // Wrap dengan gradient ring
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.skGradient,
      ),
      padding: const EdgeInsets.all(2),
      child: avatar,
    );
  }
}
