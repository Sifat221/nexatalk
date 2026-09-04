import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

/// Reusable glassmorphic & glowing decoration utilities.
class GlassEffects {
  GlassEffects._();

  /// Standard glass container decoration with subtle translucent fill and crisp border.
  static BoxDecoration glassCardDecoration({
    BorderRadius? borderRadius,
    Color? fillColor,
    Color? borderColor,
    double borderWidth = 1.0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: fillColor ?? AppColors.surface.withValues(alpha: 0.85),
      borderRadius: borderRadius ?? AppRadius.roundedL,
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder.withValues(alpha: 0.12),
        width: borderWidth,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
    );
  }

  /// Elevated surface decoration with subtle cyan rim lighting.
  static BoxDecoration elevatedSurfaceDecoration({
    BorderRadius? borderRadius,
    bool isGlowing = false,
  }) {
    return BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: borderRadius ?? AppRadius.roundedL,
      border: Border.all(
        color: isGlowing
            ? AppColors.primaryCyan.withValues(alpha: 0.4)
            : AppColors.surfaceBorder.withValues(alpha: 0.6),
        width: isGlowing ? 1.5 : 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: isGlowing
              ? AppColors.primaryCyan.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.4),
          blurRadius: isGlowing ? 20 : 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Outgoing message bubble decoration with smooth gradient.
  static BoxDecoration outgoingBubbleDecoration({bool isGlowing = false}) {
    return BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: AppRadius.outgoingBubbleRadius,
      boxShadow: [
        BoxShadow(
          color: isGlowing
              ? AppColors.primaryCyan.withValues(alpha: 0.4)
              : AppColors.primaryGlow.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  /// Incoming message bubble decoration with dark midnight glass style.
  static BoxDecoration incomingBubbleDecoration() {
    return BoxDecoration(
      color: AppColors.incomingBubble,
      borderRadius: AppRadius.incomingBubbleRadius,
      border: Border.all(
        color: AppColors.incomingBubbleBorder,
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Glowing cyan button decoration.
  static BoxDecoration primaryButtonDecoration({
    bool isHovered = false,
    bool isPressed = false,
    bool isDisabled = false,
  }) {
    if (isDisabled) {
      return BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
      );
    }

    return BoxDecoration(
      gradient: AppColors.buttonGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isPressed
              ? AppColors.primaryCyan.withValues(alpha: 0.2)
              : isHovered
                  ? AppColors.primaryCyan.withValues(alpha: 0.45)
                  : AppColors.primaryCyan.withValues(alpha: 0.28),
          blurRadius: isHovered ? 16 : 10,
          spreadRadius: isHovered ? 1 : 0,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
