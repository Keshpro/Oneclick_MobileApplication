import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'pending_approval_screen.dart';
import 'package:oneclick/admin/screens/admin_dashboard.dart';
import 'package:oneclick/features/doctor/doctor/screens/doctor_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ============================================================
    // ANIMATION CONTROLLER
    // ============================================================
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // ============================================================
    // AUTO LOGIN / SESSION CHECK LOGIC
    // ============================================================
    _timer = Timer(
      const Duration(seconds: 3),
      () {
        _checkUserSessionAndNavigate();
      },
    );
  }

  Future<void> _checkUserSessionAndNavigate() async {
    if (!mounted) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    // 1. User ලොග් වී නැත්නම් කෙලින්ම Home / Guest Screen එකට යැවීම
    if (currentUser == null) {
      _navigateTo(const HomeScreen());
      return;
    }

    final uid = currentUser.uid;

    try {
      // 2. Doctor කෙනෙක්දැයි 'doctors' collection එකෙන් පරීක්ෂා කිරීම
      final doctorDoc =
          await FirebaseFirestore.instance.collection('doctors').doc(uid).get();

      if (doctorDoc.exists) {
        final status = doctorDoc.data()?['status'] ?? 'pending';

        if (status == 'active' || status == 'approved') {
          // Active Doctor -> Direct access to Unique Doctor Dashboard
          _navigateTo(const DoctorDashboardScreen());
        } else {
          // Pending Doctor -> Pending Screen
          _navigateTo(const PendingApprovalScreen());
        }
        return;
      }

      // 3. Driver කෙනෙක්දැයි 'drivers' collection එකෙන් පරීක්ෂා කිරීම
      final driverDoc =
          await FirebaseFirestore.instance.collection('drivers').doc(uid).get();

      if (driverDoc.exists) {
        final status = driverDoc.data()?['status'] ?? 'pending';

        if (status == 'active' || status == 'approved') {
          _navigateTo(const HomeScreen());
        } else {
          _navigateTo(const PendingApprovalScreen());
        }
        return;
      }

      // 4. Admin ද Regular User ද කියා 'users' collection එකෙන් පරීක්ෂා කිරීම
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'];
        if (role == 'admin') {
          _navigateTo(const AdminDashboard());
          return;
        }
      }

      // 5. Normal User / Patient
      _navigateTo(const HomeScreen());
    } catch (e) {
      _navigateTo(const HomeScreen());
    }
  }

  void _navigateTo(Widget targetScreen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => targetScreen,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Background Decoration
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                ),
              ),
            ),

            // Bottom Background Decoration
            Positioned(
              bottom: -120,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.08),
                ),
              ),
            ),

            // Center Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          size: 52,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'OneClick',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Everything you need. One click away.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading Indicator
            const Positioned(
              left: 0,
              right: 0,
              bottom: 55,
              child: Column(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}