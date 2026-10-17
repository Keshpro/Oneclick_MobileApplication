import 'package:flutter/material.dart';
import 'package:oneclick/core/theme/app_theme.dart';

/// Shared Fresh Teal screen header: teal gradient with a soft wave on the
/// bottom edge and an optional [floating] widget (e.g. a search pill) that
/// sits half on the header and half on the page background.
///
/// NEW FILE: pure UI. It reads no data and changes no navigation.
class TealHeader extends StatelessWidget {
  /// Content shown on the teal area (top bar, greeting, ...). White text works best.
  final Widget child;

  /// Optional widget overlapping the wave, usually a search field (~56px tall).
  final Widget? floating;

  const TealHeader({super.key, required this.child, this.floating});

  /// How far the floating widget hangs below the wave line.
  static const double _overlap = 28;

  @override
  Widget build(BuildContext context) {
    final hasFloating = floating != null;
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: hasFloating ? _overlap : 0),
          child: ClipPath(
            clipper: const _WaveClipper(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                topInset,
                AppSpacing.screenH,
                hasFloating ? 64 : 40,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: child,
            ),
          ),
        ),
        if (hasFloating)
          Positioned(
            left: AppSpacing.screenH,
            right: AppSpacing.screenH,
            bottom: 0,
            child: floating!,
          ),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..lineTo(0, h - 24)
      ..quadraticBezierTo(w * 0.25, h, w * 0.5, h - 12)
      ..quadraticBezierTo(w * 0.75, h - 24, w, h - 12)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
