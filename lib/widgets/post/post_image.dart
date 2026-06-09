import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PostImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PostImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    final isNetwork = imageUrl.startsWith('http') || imageUrl.startsWith('blob:') || kIsWeb;

    if (isNetwork) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildPlaceholder(isError: true),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.skRose,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildPlaceholder(isError: true),
      );
    }
  }

  Widget _buildPlaceholder({bool isError = false}) {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withValues(alpha: 0.02),
      child: Center(
        child: Icon(
          isError ? Icons.broken_image_outlined : Icons.image_outlined,
          color: AppColors.skMuted.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }
}
