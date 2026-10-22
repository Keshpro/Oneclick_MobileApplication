
import 'package:flutter/material.dart';
import 'package:oneclick/core/theme/app_theme.dart';
import 'package:oneclick/shared/models/user_model.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/home_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove debug banner
      debugShowCheckedModeBanner: false,

      // Application title
      title: 'OneClick',

      // Match the existing OneClick teal design and follow system dark mode.
      theme: AppTheme.light,
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryLight,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0C1014),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0C1014),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,

      // First screen when application starts
      initialRoute: '/',

      // Application routes
      routes: {
        // Splash Screen
        '/': (context) => const SplashScreen(),

        // Guest Home / Guest Dashboard
        '/home': (context) => const HomeScreen(),

        // Login Screen
        '/login': (context) => const LoginScreen(),

        // Register Screen
        '/register': (context) => RegisterScreen(role: UserRole.customer),
      },

      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
}
