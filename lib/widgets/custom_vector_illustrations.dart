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

/// Screen 2 Onboarding — Two people sitting in chairs chatting with floating speech bubbles.
class TwoPeopleChattingIllustration extends StatelessWidget {
  final double size;
  const TwoPeopleChattingIllustration({super.key, this.size = 230});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size * 1.15,
      child: CustomPaint(
        painter: _TwoPeopleChattingPainter(),
      ),
    );
  }
}

class _TwoPeopleChattingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ambient glow in center
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryCyan.withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.45), radius: w * 0.45));
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), w * 0.45, glow);

    // Subtle floor shadow
    final floorShadow = Paint()..color = const Color(0xFF0D1C28);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.88), width: w * 0.8, height: 18), floorShadow);

    // Left Chair (Person 1 - Female avatar sitting)
    // Left chair seat & back
    final leftChair = Path()
      ..moveTo(w * 0.18, h * 0.58)
      ..lineTo(w * 0.24, h * 0.72)
      ..lineTo(w * 0.38, h * 0.72)
      ..lineTo(w * 0.36, h * 0.88)
      ..lineTo(w * 0.32, h * 0.88)
      ..lineTo(w * 0.22, h * 0.88);
    canvas.drawPath(leftChair, Paint()..color = const Color(0xFF0F2230)..style = PaintingStyle.stroke..strokeWidth = 3);

    // Person 1 (Left - woman sitting, dark hair, teal top)
    const skinColor = Color(0xFFF7D5BA);
    const hairColor = Color(0xFF1E293B);
    const tealColor = AppColors.primaryCyan;
    const pantsColor = Color(0xFF0D2433);

    final skinPaint = Paint()..color = skinColor;
    final hairPaint = Paint()..color = hairColor;
    final tealTop = Paint()..color = tealColor;

    // Left person body
    canvas.drawCircle(Offset(w * 0.28, h * 0.42), 14, skinPaint); // Head
    // Hair
    final leftHair = Path()
      ..addArc(Rect.fromCircle(center: Offset(w * 0.28, h * 0.42), radius: 15), 3.14, 3.14)
      ..lineTo(w * 0.23, h * 0.48)
      ..lineTo(w * 0.28, h * 0.42);
    canvas.drawPath(leftHair, hairPaint);

    // Torso (teal)
    final leftTorso = Path()
      ..moveTo(w * 0.24, h * 0.48)
      ..lineTo(w * 0.33, h * 0.48)
      ..lineTo(w * 0.35, h * 0.65)
      ..lineTo(w * 0.22, h * 0.65)
      ..close();
    canvas.drawPath(leftTorso, tealTop);

    // Legs sitting
    final leftLegs = Path()
      ..moveTo(w * 0.23, h * 0.65)
      ..lineTo(w * 0.38, h * 0.66)
      ..lineTo(w * 0.39, h * 0.84)
      ..lineTo(w * 0.44, h * 0.85);
    canvas.drawPath(leftLegs, Paint()..color = pantsColor..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);

    // Left arm holding phone
    final leftArm = Path()
      ..moveTo(w * 0.28, h * 0.52)
      ..lineTo(w * 0.38, h * 0.58);
    canvas.drawPath(leftArm, Paint()..color = skinColor..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round);
    // Phone
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.39, h * 0.57), width: 6, height: 11), const Radius.circular(2)), Paint()..color = Colors.white);

    // Right Person (Person 2 - man sitting, facing left)
    // Right chair
    final rightChair = Path()
      ..moveTo(w * 0.82, h * 0.58)
      ..lineTo(w * 0.76, h * 0.72)
      ..lineTo(w * 0.62, h * 0.72)
      ..lineTo(w * 0.64, h * 0.88)
      ..lineTo(w * 0.68, h * 0.88)
      ..lineTo(w * 0.78, h * 0.88);
    canvas.drawPath(rightChair, Paint()..color = const Color(0xFF0F2230)..style = PaintingStyle.stroke..strokeWidth = 3);

    // Head
    canvas.drawCircle(Offset(w * 0.72, h * 0.42), 14, skinPaint);
    // Short hair
    final rightHair = Path()
      ..addArc(Rect.fromCircle(center: Offset(w * 0.72, h * 0.41), radius: 14.5), 3.14, 3.14);
    canvas.drawPath(rightHair, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill);

    // Torso (dark turquoise/teal jacket)
    final rightTorso = Path()
      ..moveTo(w * 0.67, h * 0.48)
      ..lineTo(w * 0.76, h * 0.48)
      ..lineTo(w * 0.78, h * 0.65)
      ..lineTo(w * 0.65, h * 0.65)
      ..close();
    canvas.drawPath(rightTorso, Paint()..color = const Color(0xFF0BBFA7));

    // Legs sitting
    final rightLegs = Path()
      ..moveTo(w * 0.77, h * 0.65)
      ..lineTo(w * 0.62, h * 0.66)
      ..lineTo(w * 0.61, h * 0.84)
      ..lineTo(w * 0.56, h * 0.85);
    canvas.drawPath(rightLegs, Paint()..color = pantsColor..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);

    // Right arm holding phone
    final rightArm = Path()
      ..moveTo(w * 0.72, h * 0.52)
      ..lineTo(w * 0.62, h * 0.58);
    canvas.drawPath(rightArm, Paint()..color = skinColor..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round);
    // Phone
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.61, h * 0.57), width: 6, height: 11), const Radius.circular(2)), Paint()..color = Colors.white);

    // FLOATING SPEECH BUBBLES IN BETWEEN!
    // Top Bubble (White/cyan)
    final bubble1 = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.50, h * 0.35), width: 36, height: 22), const Radius.circular(8));
    canvas.drawRRect(bubble1, Paint()..color = Colors.white);
    // Three dots inside top bubble
    canvas.drawCircle(Offset(w * 0.45, h * 0.35), 2.2, Paint()..color = const Color(0xFF08131E));
    canvas.drawCircle(Offset(w * 0.50, h * 0.35), 2.2, Paint()..color = const Color(0xFF08131E));
    canvas.drawCircle(Offset(w * 0.55, h * 0.35), 2.2, Paint()..color = const Color(0xFF08131E));

    // Bottom Bubble (Cyan teal)
    final bubble2 = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.52, h * 0.48), width: 32, height: 20), const Radius.circular(7));
    canvas.drawRRect(bubble2, Paint()..color = AppColors.primaryCyan);
    // Three white dots inside bottom bubble
    canvas.drawCircle(Offset(w * 0.48, h * 0.48), 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.52, h * 0.48), 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.56, h * 0.48), 2, Paint()..color = Colors.white);

    // Sparkle cyan dots
    canvas.drawCircle(Offset(w * 0.44, h * 0.26), 2.5, Paint()..color = AppColors.primaryLight);
    canvas.drawCircle(Offset(w * 0.58, h * 0.28), 3, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Screen 6 Forgot Password — Opened Envelope illustration with paper airplane.
class ForgotEnvelopeIllustration extends StatelessWidget {
  final double size;
  const ForgotEnvelopeIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size * 1.2,
      child: CustomPaint(
        painter: _ForgotEnvelopePainter(),
      ),
    );
  }
}

class _ForgotEnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.48, h * 0.60);

    // Soft glow behind envelope
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryCyan.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.4));
    canvas.drawCircle(center, w * 0.4, glow);

    // Ground platform shadow
    final ground = Paint()..color = const Color(0xFF0F2230);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, h * 0.88), width: w * 0.7, height: 14), ground);

    // Letter Paper poking out of envelope
    final letterRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 24), width: 90, height: 75),
      const Radius.circular(8),
    );
    canvas.drawRRect(letterRect, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawRRect(letterRect, Paint()..color = const Color(0xFFCBD5E1)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Horizontal text lines on letter paper
    final textLinePaint = Paint()
      ..color = AppColors.primaryCyan
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    canvas.drawLine(Offset(center.dx - 32, center.dy - 44), Offset(center.dx + 8, center.dy - 44), textLinePaint);

    final grayLinePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(center.dx - 32, center.dy - 34), Offset(center.dx + 28, center.dy - 34), grayLinePaint);
    canvas.drawLine(Offset(center.dx - 32, center.dy - 24), Offset(center.dx + 20, center.dy - 24), grayLinePaint);

    // Envelope Back Flap
    final backFlap = Path()
      ..moveTo(center.dx - 62, center.dy)
      ..lineTo(center.dx, center.dy - 38)
      ..lineTo(center.dx + 62, center.dy)
      ..close();
    canvas.drawPath(backFlap, Paint()..color = const Color(0xFF0B9183));

    // Envelope Main Body (Teal/Turquoise)
    final envBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 16), width: 124, height: 72),
      const Radius.circular(12),
    );
    canvas.drawRRect(envBody, Paint()..color = const Color(0xFF0BBFA7));

    // Envelope Front Bottom Fold
    final frontFold = Path()
      ..moveTo(center.dx - 62, center.dy - 20)
      ..lineTo(center.dx, center.dy + 20)
      ..lineTo(center.dx + 62, center.dy - 20)
      ..lineTo(center.dx + 62, center.dy + 52)
      ..lineTo(center.dx - 62, center.dy + 52)
      ..close();
    canvas.drawPath(frontFold, Paint()..color = const Color(0xFF08A691));

    // Fold Accent Lines
    final foldBorder = Paint()
      ..color = const Color(0xFF008375).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(center.dx - 62, center.dy - 20), Offset(center.dx, center.dy + 20), foldBorder);
    canvas.drawLine(Offset(center.dx + 62, center.dy - 20), Offset(center.dx, center.dy + 20), foldBorder);

    // Paper Airplane flying to the top right!
    final planeOffset = Offset(w * 0.82, h * 0.28);
    final plane = Path()
      ..moveTo(planeOffset.dx, planeOffset.dy)
      ..lineTo(planeOffset.dx - 22, planeOffset.dy + 4)
      ..lineTo(planeOffset.dx - 12, planeOffset.dy + 12)
      ..close();
    canvas.drawPath(plane, Paint()..color = AppColors.primaryCyan);

    final planeFold = Path()
      ..moveTo(planeOffset.dx, planeOffset.dy)
      ..lineTo(planeOffset.dx - 12, planeOffset.dy + 12)
      ..lineTo(planeOffset.dx - 10, planeOffset.dy + 7)
      ..close();
    canvas.drawPath(planeFold, Paint()..color = const Color(0xFF009688));

    // Little flight trail dots
    final dotPaint = Paint()..color = AppColors.primaryLight.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(planeOffset.dx - 28, planeOffset.dy + 16), 1.8, dotPaint);
    canvas.drawCircle(Offset(planeOffset.dx - 36, planeOffset.dy + 24), 2.2, dotPaint);
    canvas.drawCircle(Offset(planeOffset.dx - 45, planeOffset.dy + 30), 2.6, dotPaint);

    // Star/sparkle near top left
    final starPaint = Paint()..color = AppColors.primaryLight;
    canvas.drawCircle(Offset(w * 0.18, h * 0.38), 2.5, starPaint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.55), 2, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
