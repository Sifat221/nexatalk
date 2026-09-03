import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_typography.dart';

/// NexaTalk Brand Emblem & Title with glowing turquoise accent.
class AppLogo extends StatefulWidget {
  final double size;
  final bool showTagline;
  final bool showText;
  final bool isAnimated;

  const AppLogo({
    super.key,
    this.size = 56,
    this.showTagline = false,
    this.showText = true,
    this.isAnimated = true,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF0F3244),
                    Color(0xFF081926),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primaryCyan.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withValues(
                      alpha: widget.isAnimated ? 0.35 * _glowAnimation.value : 0.3,
                    ),
                    blurRadius: widget.isAnimated ? 20 * _glowAnimation.value : 16,
                    spreadRadius: widget.isAnimated ? 2 * _glowAnimation.value : 1,
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(widget.size * 0.55, widget.size * 0.55),
                  painter: _NexaLogoPainter(),
                ),
              ),
            );
          },
        ),
        if (widget.showText) ...[
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                AppColors.primaryLight,
                AppColors.primaryCyan,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
        if (widget.showTagline) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.appTagline,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _NexaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Connected geometric nodes forming a modern 'N' and chat bubble
    final path = Path();
    final p1 = Offset(size.width * 0.15, size.height * 0.85);
    final p2 = Offset(size.width * 0.15, size.height * 0.20);
    final p3 = Offset(size.width * 0.85, size.height * 0.80);
    final p4 = Offset(size.width * 0.85, size.height * 0.15);

    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.lineTo(p4.dx, p4.dy);

    final linePaint = Paint()
      ..shader = AppColors.primaryGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Glowing Node Caps
    final capPaint = Paint()..color = Colors.white;
    canvas.drawCircle(p2, size.width * 0.10, capPaint);
    canvas.drawCircle(p3, size.width * 0.10, capPaint);

    // Mini cyan chat sparkle dot
    final sparklePaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.20), size.width * 0.08, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
