import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TextStyle standar SosialKita
/// Heading/Logo → Syne, Body → DM Sans
class AppTextStyles {
  AppTextStyles._();

  // ── Logo ──
  static const TextStyle logoName = TextStyle(
    fontFamily: 'Syne',
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  // ── Headings ──
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Syne',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.skWhite,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Syne',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.skWhite,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.skWhite,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.skWhite,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.skMuted,
  );

  // ── Label ──
  static const TextStyle label = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.skMuted,
    letterSpacing: 0.8,
  );

  // ── Button ──
  static const TextStyle button = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
