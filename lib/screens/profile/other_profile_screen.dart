import 'package:flutter/material.dart';
import 'profile_screen.dart';

/// OtherProfileScreen — Halaman profil pengguna lain
/// Wrapper sederhana yang meneruskan userId ke ProfileScreen
class OtherProfileScreen extends StatelessWidget {
  final String userId;

  const OtherProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(userId: userId);
  }
}
