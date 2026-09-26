import 'dart:async';

import 'package:flutter/material.dart';

import 'patient_home_screen.dart';

class DoctorEntryScreen extends StatefulWidget {
  const DoctorEntryScreen({super.key});

  @override
  State<DoctorEntryScreen> createState() => _DoctorEntryScreenState();
}

class _DoctorEntryScreenState extends State<DoctorEntryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // ============================================================
    // SCREEN ENTRANCE ANIMATION
    // ============================================================

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
    );

    _mainController.forward();

    // ============================================================
    // AUTO OPEN PATIENT HOME
    //
    // Change this duration according to your GIF duration.
    // Example:
    // 5 second GIF -> 5000
    // 5.5 second GIF -> 5500
    // 6 second GIF -> 6000
    // ============================================================

    _navigationTimer = Timer(
      const Duration(milliseconds: 5500),
      _openPatientHome,
    );
  }

  // ============================================================
  // OPEN PATIENT HOME
  // ============================================================

  void _openPatientHome() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 650,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const PatientHomeScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _mainController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF064E3B),

      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // TOP BACKGROUND CIRCLE
            // ==================================================

            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.04,
                  ),
                ),
              ),
            ),

            // ==================================================
            // BOTTOM BACKGROUND CIRCLE
            // ==================================================

            Positioned(
              bottom: -110,
              left: -100,
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981)
                      .withValues(
                    alpha: 0.10,
                  ),
                ),
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ========================================
                        // FUNNY DOCTOR GIF
                        // ========================================

                        SizedBox(
                          width: 330,
                          height: 270,
                          child: Image.asset(
                            'assets/animations/doctor_entry.gif',
                            fit: BoxFit.contain,

                            // Prevents flicker between GIF frames
                            gaplessPlayback: true,

                            // Error UI if asset path is wrong
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Center(
                                child: Container(
                                  width: 105,
                                  height: 105,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(
                                      30,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .medical_services_rounded,
                                    color: Color(0xFF059669),
                                    size: 52,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ========================================
                        // APP NAME
                        // ========================================

                        const Text(
                          'OneClick Health',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ========================================
                        // TAGLINE
                        // ========================================

                        const Text(
                          'Healthcare made easier.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFA7F3D0),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ========================================
                        // LOADING STATUS
                        // ========================================

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius:
                                BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6EE7B7),
                                ),
                              ),

                              SizedBox(width: 10),

                              Text(
                                'Connecting you to care...',
                                style: TextStyle(
                                  color: Color(0xFFD1FAE5),
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // POWERED BY FOOTER
            // ==================================================

            const Positioned(
              left: 0,
              right: 0,
              bottom: 25,
              child: Column(
                children: [
                  Text(
                    'POWERED BY',
                    style: TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'ONECLICK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
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