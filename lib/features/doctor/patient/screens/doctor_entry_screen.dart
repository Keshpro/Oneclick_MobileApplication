import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'patient_home_screen.dart';

class DoctorEntryScreen extends StatefulWidget {
  const DoctorEntryScreen({super.key});

  @override
  State<DoctorEntryScreen> createState() =>
      _DoctorEntryScreenState();
}

class _DoctorEntryScreenState
    extends State<DoctorEntryScreen> {
  late VideoPlayerController _videoController;

  bool _isVideoReady = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
  }

  // ============================================================
  // INITIALIZE VIDEO
  // ============================================================

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'assets/animations/doctor_entry.mp4',
    );

    try {
      await _videoController.initialize();

      // Do not loop.
      // We want to open PatientHome when the video finishes.
      await _videoController.setLooping(false);

      // Entry animation does not need sound.
      await _videoController.setVolume(0);

      _videoController.addListener(
        _videoListener,
      );

      if (!mounted) return;

      setState(() {
        _isVideoReady = true;
      });

      await _videoController.play();
    } catch (error) {
      debugPrint(
        'Doctor entry video error: $error',
      );

      // If video cannot load, don't trap the user
      // on this screen.
      if (mounted) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            if (mounted) {
              _openPatientHome();
            }
          },
        );
      }
    }
  }

  // ============================================================
  // VIDEO LISTENER
  // ============================================================

  void _videoListener() {
    if (!_videoController.value.isInitialized) {
      return;
    }

    final position =
        _videoController.value.position;

    final duration =
        _videoController.value.duration;

    if (duration == Duration.zero) {
      return;
    }

    // Navigate when video is almost finished.
    // 150ms tolerance avoids timing issues.
    if (position >=
        duration -
            const Duration(
              milliseconds: 150,
            )) {
      _openPatientHome();
    }
  }

  // ============================================================
  // OPEN PATIENT HOME
  // ============================================================

  void _openPatientHome() {
    if (!mounted || _hasNavigated) {
      return;
    }

    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 550),

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
          final fadeAnimation =
              CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          final scaleAnimation =
              Tween<double>(
            begin: 0.98,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
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
    if (_videoController.value.isInitialized) {
      _videoController.removeListener(
        _videoListener,
      );
    }

    _videoController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF064E3B),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ====================================================
          // FULL SCREEN VIDEO
          // ====================================================

          if (_isVideoReady)
            _buildFullScreenVideo()
          else
            const ColoredBox(
              color: Color(0xFF064E3B),
            ),

          // ====================================================
          // SUBTLE DARK OVERLAY
          //
          // Keeps loading UI readable.
          // ====================================================

          if (_isVideoReady)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(
                        alpha: 0.03,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ====================================================
          // LOADING INDICATOR
          // ====================================================

          SafeArea(
            child: Align(
              alignment:
                  const Alignment(0, 0.47),
              child: AnimatedOpacity(
                opacity:
                    _isVideoReady ? 1 : 0.7,
                duration:
                    const Duration(
                  milliseconds: 400,
                ),
                child:
                    _buildLoadingIndicator(),
              ),
            ),
          ),

          // ====================================================
          // INITIAL VIDEO LOADING
          // ====================================================

          if (!_isVideoReady)
            const Center(
              child:
                  CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF6EE7B7),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // FULL SCREEN VIDEO
  // ============================================================

  Widget _buildFullScreenVideo() {
    final videoSize =
        _videoController.value.size;

    if (videoSize.width <= 0 ||
        videoSize.height <= 0) {
      return const ColoredBox(
        color: Color(0xFF064E3B),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        // cover = entire phone screen covered.
        // Some edge cropping can happen on different
        // phone aspect ratios.
        fit: BoxFit.cover,

        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(
            _videoController,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING UI
  // ============================================================

  Widget _buildLoadingIndicator() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF064E3B)
            .withValues(
          alpha: 0.82,
        ),

        borderRadius:
            BorderRadius.circular(30),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.10,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 15,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: const Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          SizedBox(
            width: 14,
            height: 14,
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
              color:
                  Color(0xFF6EE7B7),
            ),
          ),

          SizedBox(width: 10),

          Text(
            'Connecting you to care...',
            style: TextStyle(
              color:
                  Color(0xFFD1FAE5),
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}