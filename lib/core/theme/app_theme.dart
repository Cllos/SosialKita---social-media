import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ThemeData dark untuk SosialKita
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.skDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.skRose,
      secondary: AppColors.skViolet,
      surface: AppColors.skDark2,
    ),
    fontFamily: 'DM Sans',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.skDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.skWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.skDark,
      selectedItemColor: AppColors.skRose,
      unselectedItemColor: AppColors.skMuted,
    ),
  );
}
