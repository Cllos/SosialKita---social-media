import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

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
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasImage ? Colors.transparent : null,
        gradient: hasImage
            ? null
            : LinearGradient(
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
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: _buildAvatarImage(),
            )
          : Center(
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

  Widget _buildAvatarImage() {
    final isNetwork = imageUrl!.startsWith('http') || imageUrl!.startsWith('blob:') || kIsWeb;

    if (isNetwork) {
      return Image.network(
        ApiService.resolveImageUrl(imageUrl!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorFallback(),
      );
    } else {
      return Image.file(
        File(imageUrl!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorFallback(),
      );
    }
  }

  Widget _buildErrorFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
  }
}
