import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Custom Vector Illustrations drawn with CustomPainter for Onboarding & Branding.
/// 100% original, no third-party copyrighted assets.
class OnboardingIllustration1 extends StatelessWidget {
  const OnboardingIllustration1({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 240,
      child: CustomPaint(
        painter: _IllustrationPainter1(),
      ),
    );
  }
}

class _IllustrationPainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Glowing ambient background circles
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryCyan.withValues(alpha: 0.25),
          AppColors.primaryDark.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 110));
    canvas.drawCircle(center, 110, glowPaint);

    // Outer cyber ring
    final ringPaint = Paint()
      ..color = AppColors.primaryCyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 85, ringPaint);

    // Dashed orbit ring
    final dashedPaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 105, dashedPaint);

    // Main Shield (Privacy & Security)
    final shieldPath = Path();
    final top = center.dy - 50;
    final bottom = center.dy + 45;
    final left = center.dx - 45;
    final right = center.dx + 45;

    shieldPath.moveTo(center.dx, top);
    shieldPath.lineTo(right, top + 15);
    shieldPath.quadraticBezierTo(right, bottom - 15, center.dx, bottom + 15);
    shieldPath.quadraticBezierTo(left, bottom - 15, left, top + 15);
    shieldPath.close();

    final shieldGradient = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D2838), Color(0xFF081822)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(left, top, 90, 110));

    canvas.drawPath(shieldPath, shieldGradient);

    final shieldBorder = Paint()
      ..shader = AppColors.primaryGradient.createShader(Rect.fromLTWH(left, top, 90, 110))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(shieldPath, shieldBorder);

    // Chat bubble inside shield
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 2), width: 38, height: 28),
      const Radius.circular(8),
    );
    final bubblePaint = Paint()..color = AppColors.primaryCyan;
    canvas.drawRRect(bubbleRect, bubblePaint);

    // Chat bubble tail
    final tailPath = Path()
      ..moveTo(center.dx - 8, center.dy + 12)
      ..lineTo(center.dx - 14, center.dy + 20)
      ..lineTo(center.dx + 2, center.dy + 12)
      ..close();
    canvas.drawPath(tailPath, bubblePaint);

    // Lock keyhole
    final lockPaint = Paint()..color = AppColors.background;
    canvas.drawCircle(Offset(center.dx, center.dy - 4), 4, lockPaint);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: 4, height: 6),
      lockPaint,
    );

    // Floating satellite nodes
    final nodePaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(center.dx + 70, center.dy - 40), 6, nodePaint);
    canvas.drawCircle(Offset(center.dx - 65, center.dy + 35), 5, nodePaint);
    canvas.drawCircle(Offset(center.dx - 55, center.dy - 55), 4, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingIllustration2 extends StatelessWidget {
  const OnboardingIllustration2({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 240,
      child: CustomPaint(
        painter: _IllustrationPainter2(),
      ),
    );
  }
}

class _IllustrationPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Ambient glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentBlue.withValues(alpha: 0.25),
          AppColors.primaryCyan.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 110));
    canvas.drawCircle(center, 110, glowPaint);

    // Connection Beams
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryCyan, AppColors.accentBlue],
      ).createShader(Rect.fromCircle(center: center, radius: 80))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final p1 = Offset(center.dx - 60, center.dy - 30);
    final p2 = Offset(center.dx + 60, center.dy - 30);
    final p3 = Offset(center.dx, center.dy + 55);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(path, linePaint);

    // Draw 3 interactive nodes
    void drawNode(Offset offset, Color color, IconData icon) {
      final nodeBg = Paint()..color = AppColors.surfaceElevated;
      canvas.drawCircle(offset, 26, nodeBg);

      final ring = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(offset, 26, ring);

      final innerGlow = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, 20, innerGlow);
    }

    drawNode(p1, AppColors.primaryCyan, Icons.person);
    drawNode(p2, AppColors.accentBlue, Icons.forum);
    drawNode(p3, AppColors.primaryLight, Icons.bolt);

    // Center pulse hub
    final centerHub = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, 12, centerHub);
    final pulseRing = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 20, pulseRing);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingIllustration3 extends StatelessWidget {
  const OnboardingIllustration3({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 240,
      child: CustomPaint(
        painter: _IllustrationPainter3(),
      ),
    );
  }
}

class _IllustrationPainter3 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryCyan.withValues(alpha: 0.2),
          AppColors.accentPurple.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 110));
    canvas.drawCircle(center, 110, glowPaint);

    // Message Card 1 (Outgoing Cyan)
    final bubble1 = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx + 25, center.dy - 35), width: 140, height: 44),
      const Radius.circular(16),
    );
    final paint1 = Paint()
      ..shader = AppColors.primaryGradient.createShader(bubble1.outerRect);
    canvas.drawRRect(bubble1, paint1);

    // Message Card 2 (Incoming Dark Navy)
    final bubble2 = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - 25, center.dy + 25), width: 140, height: 44),
      const Radius.circular(16),
    );
    final paint2 = Paint()..color = AppColors.surfaceElevated;
    canvas.drawRRect(bubble2, paint2);

    final border2 = Paint()
      ..color = AppColors.primaryCyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(bubble2, border2);

    // Text lines inside bubbles
    void drawTextLines(Offset start, Color color, double width) {
      final linePaint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5;
      canvas.drawLine(start, Offset(start.dx + width, start.dy), linePaint);
      canvas.drawLine(
        Offset(start.dx, start.dy + 8),
        Offset(start.dx + (width * 0.6), start.dy + 8),
        linePaint,
      );
    }

    drawTextLines(Offset(center.dx - 30, center.dy - 40), AppColors.background, 75);
    drawTextLines(Offset(center.dx - 80, center.dy + 20), AppColors.textSecondary, 75);

    // Floating reaction emoji pills
    void drawReactionPill(Offset offset, Color color, double radius) {
      final pill = Paint()..color = color;
      canvas.drawCircle(offset, radius, pill);
    }

    drawReactionPill(Offset(center.dx + 80, center.dy - 10), AppColors.primaryLight, 10);
    drawReactionPill(Offset(center.dx - 80, center.dy + 55), AppColors.accentBlue, 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
