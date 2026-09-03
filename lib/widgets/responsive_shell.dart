import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Responsive wrapper that adapts between mobile single-screen and desktop/tablet dual-pane shell.
class ResponsiveShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveShell({
    super.key,
    required this.child,
    this.maxWidth = 480, // Default mobile shell max width on desktop
  });

  static bool isDesktopOrTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 800) {
      // Desktop / Web layout with clean centered frame or full dual pane
      return Scaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    return child;
  }
}
