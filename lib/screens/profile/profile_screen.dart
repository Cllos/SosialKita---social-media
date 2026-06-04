import 'package:flutter/material.dart';
import '../../core/utils/responsive_layout.dart';
import 'mobile_profile.dart';
import 'desktop_profile.dart';

/// ProfileScreen — Wrapper responsif yang memilih layout
/// berdasarkan ukuran layar (mobile vs desktop)
class ProfileScreen extends StatelessWidget {
  /// Jika userId null → profil sendiri (currentUser)
  /// Jika userId != null → profil user lain
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: MobileProfile(userId: userId),
      desktop: DesktopProfile(userId: userId),
    );
  }
}
