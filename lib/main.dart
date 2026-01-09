import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

import 'app_theme.dart';
import 'helpers/theme_mode_provider.dart';
import 'firebase_options.dart';
import 'services/favorites_cache_service.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  await FavoritesCacheService.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: MyApp()));
  _setupFirebaseMessagingHandler();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void _setupFirebaseMessagingHandler() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('[FCM] Mensaje recibido: ${message.data}');
    print('[FCM] Notificación: ${message.notification}');

    final navigator = navigatorKey.currentState;
    if (navigator != null && message.notification != null) {
      final context = navigator.overlay?.context;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${message.notification!.title ?? ''}\n${message.notification!.body ?? ''}',
            ),
          ),
        );
      }
    }
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noticias',
      navigatorKey: navigatorKey,
      // 🎨 Temas
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      // 🧭 Rutas
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
