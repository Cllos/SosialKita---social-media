import 'package:flutter/material.dart';
import '../../core/utils/responsive_layout.dart';
import 'mobile_home.dart';
import 'desktop_home.dart';

/// HomeScreen — Wrapper responsif yang memilih layout
/// berdasarkan ukuran layar (mobile vs desktop)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: MobileHome(),
      desktop: DesktopHome(),
    );
  }
}
