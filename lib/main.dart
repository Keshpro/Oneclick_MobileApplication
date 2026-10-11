import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oneclick/shared/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  await Supabase.initialize(
  url: supabaseUrl,
  publishableKey: supabasePublishableKey,
  accessToken: () async {
    return FirebaseAuth.instance.currentUser?.getIdToken();
  },
);

  runApp(const MyApp());
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

      initialRoute: '/',

      routes: {
        // Splash Screen
        '/': (context) => const SplashScreen(),

        // Guest Home Screen
        '/home': (context) => const HomeScreen(),

        // Login Screen
        '/login': (context) => const LoginScreen(),
      },

      onGenerateRoute: (settings) {
        // Normal User Registration
        if (settings.name == '/register') {
          return MaterialPageRoute(
            builder: (context) => RegisterScreen(
              role: UserRole.user,
            ),
          );
        }

        return null;
      },

      onUnknownRoute: (settings) {
        debugPrint('UNKNOWN ROUTE: ${settings.name}');

        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
}