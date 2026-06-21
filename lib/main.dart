import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/responsive_layout.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/story_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/moderator/moderator_dashboard.dart';
import 'screens/moderator/desktop_only_screen.dart';
import 'services/local_storage_service.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum inisialisasi plugin apapun
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi SharedPreferences
  await LocalStorageService.init();

  // Inisialisasi Firebase Cloud Messaging
  await FcmService.instance.initialize();

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
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: MaterialApp(
        title: 'SosialKita',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        builder: (context, child) {
          // Set notification provider ke FcmService agar bisa update UI
          final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
          FcmService.setNotificationProvider(notificationProvider);
          return child!;
        },
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              if (auth.isModerator) {
                // Admin Panel hanya tersedia di desktop
                return const ResponsiveLayout(
                  mobile: DesktopOnlyScreen(),
                  desktop: ModeratorDashboard(),
                );
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
