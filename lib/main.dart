import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Role Selection'),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OneClick',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4DFF),
        ),
      ),

      // App starts here
      initialRoute: '/',

      routes: {
        // Splash
        '/': (context) => const SplashScreen(),

        // Guest Dashboard
        '/home': (context) => const HomeScreen(),

        // Common Login
        '/login': (context) => const LoginScreen(),

        // Registration starts from role selection
        '/register': (context) => const RoleSelectionScreen(),
      },

      // Catch unknown routes while developing
      onUnknownRoute: (settings) {
        debugPrint(
          'UNKNOWN ROUTE: ${settings.name}',
        );

        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
}