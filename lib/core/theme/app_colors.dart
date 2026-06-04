import 'package:flutter/material.dart';

/// Palet warna utama SosialKita
/// Diambil dari referensi sosialkita_ui.html
class AppColors {
  AppColors._();

  static const Color skRose = Color(0xFFF43F5E);
  static const Color skRoseLight = Color(0xFFFECDD3);
  static const Color skRoseDark = Color(0xFF9F1239);
  static const Color skOrange = Color(0xFFFB923C);
  static const Color skViolet = Color(0xFF8B5CF6);
  static const Color skVioletLight = Color(0xFFEDE9FE);
  static const Color skDark = Color(0xFF0F0A1A);
  static const Color skDark2 = Color(0xFF1A1028);
  static const Color skCard = Color(0xFF22163A);
  static const Color skMuted = Color(0xFF6B5F82);
  static const Color skWhite = Color(0xFFFAF8FF);
  static const Color skBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  /// Gradient utama (diagonal)
  static const LinearGradient skGradient = LinearGradient(
    colors: [skRose, skViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient tombol (horizontal)
  static const LinearGradient skGradientBtn = LinearGradient(
    colors: [skRose, skViolet],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
