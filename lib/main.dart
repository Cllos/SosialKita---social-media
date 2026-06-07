import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/moderator/moderator_dashboard.dart';

void main() {
  runApp(const SosialKitaApp());
}

class SosialKitaApp extends StatelessWidget {
  const SosialKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'SosialKita',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Jika sudah login → ke HomeScreen (atau ModeratorDashboard jika Moderator), belum → ke LoginScreen
            if (auth.isLoggedIn) {
              if (auth.isModerator) {
                return const ModeratorDashboard();
              }
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
