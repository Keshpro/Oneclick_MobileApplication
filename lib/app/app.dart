import 'package:flutter/material.dart';

import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OneClick',

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),

        '/home': (context) => const HomeScreen(),

        // Temporary Login Screen
        '/login': (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Login'),
              ),
              body: const SafeArea(
                child: Center(
                  child: Text(
                    'Login Screen',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

        // Temporary Register Screen
        '/register': (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Register'),
              ),
              body: const SafeArea(
                child: Center(
                  child: Text(
                    'Register Screen',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
      },
    );
  }
}