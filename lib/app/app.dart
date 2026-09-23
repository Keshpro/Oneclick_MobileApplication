import 'package:flutter/material.dart';
import '../features/auth/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OneClick',
      home: const SplashScreen(),
    );
  }
}