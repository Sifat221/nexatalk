import 'package:flutter/material.dart';

/// Centralized color palette for NexaTalk.
/// Built with a midnight-navy dark-first aesthetic and luminous cyan/turquoise accents.
class AppColors {
  AppColors._();

  // Background & Surface Colors (Midnight Dark Spectrum matching reference)
  static const Color background = Color(0xFF08131E); // Deep midnight navy
  static const Color backgroundSecondary = Color(0xFF0B1824); // Secondary background
  static const Color surface = Color(0xFF12222E); // Base card & field surface
  static const Color surfaceElevated = Color(0xFF152836); // Elevated surface for modals/bubbles
  static const Color surfaceHighlight = Color(0xFF1B3446); // Hover & active states
  static const Color surfaceBorder = Color(0xFF1D3648); // Subtle surface borders
  
  // OLED Pure Dark Spectrum (For optional OLED mode)
  static const Color oledBackground = Color(0xFF03070A);
  static const Color oledSurface = Color(0xFF071118);

  // Primary Accent Colors (Vibrant Luminous Turquoise / Cyan matching reference)
  static const Color primary = Color(0xFF00BFA5); // Vibrant turquoise accent
  static const Color primaryCyan = Color(0xFF00D2B4); // Rich cyan
  static const Color primaryDark = Color(0xFF009688); // Deep teal
  static const Color primaryLight = Color(0xFF4EE2CF); // Light glowing cyan
  static const Color primaryGlow = Color(0x3300D2B4); // Glow shadow color
  static const Color buttonPrimary = Color(0xFF00BFA5); // Primary button fill

  // Secondary Accents
  static const Color accentIndigo = Color(0xFF6366F1); // Modern indigo
  static const Color accentPurple = Color(0xFF8B5CF6); // Subtle ambient glow
  static const Color accentBlue = Color(0xFF38BDF8); // Electric sky blue

  // Bubble Colors
  static const Color incomingBubble = Color(0xFF12222E); // Dark midnight slate
  static const Color incomingBubbleBorder = Color(0xFF1B3547); // Subtle border
  static const Color outgoingBubbleStart = Color(0xFF059888); // Rich teal gradient start
  static const Color outgoingBubbleEnd = Color(0xFF0BBFA7); // Rich cyan gradient end

  // Typography / Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Crisp pure white
  static const Color textSecondary = Color(0xFF8E9FA8); // Cool gray for subtexts
  static const Color textTertiary = Color(0xFF576C7C); // Muted slate for timestamps
  static const Color textDisabled = Color(0xFF3D505E); // Inactive text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Crisp white text on primary buttons (matching reference)

  // Status & Utility Colors
  static const Color online = Color(0xFF10B981); // Emerald online indicator
  static const Color offline = Color(0xFF576C7C); // Offline slate
  static const Color busy = Color(0xFFEF4444); // Busy / DND red
  static const Color away = Color(0xFFF59E0B); // Away amber
  static const Color error = Color(0xFFF87171); // Soft error red
  static const Color errorBackground = Color(0x26EF4444);
  static const Color success = Color(0xFF34D399); // Crisp success green
  static const Color successBackground = Color(0x2610B981);
  static const Color warning = Color(0xFFFBBF24); // Warning yellow
  static const Color unreadBadge = Color(0xFF00D2B4); // Badge fill

  // Glassmorphism & Overlay Effects
  static const Color glassFill = Color(0x1AFFFFFF); // 10% white for frosted glass
  static const Color glassBorder = Color(0x26FFFFFF); // 15% white for glass border
  static const Color divider = Color(0x1A576C7C); // Subtle divider

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [outgoingBubbleStart, outgoingBubbleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF00D2B4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF12222E), Color(0xFF0C1923)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFF00F5D4), Color(0xFF00BBF9), Color(0xFF7B2CBF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarGradient1 = LinearGradient(
    colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarGradient2 = LinearGradient(
    colors: [Color(0xFF7209B7), Color(0xFF3F37C9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarGradient3 = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF118AB2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient avatarGradient4 = LinearGradient(
    colors: [Color(0xFFFF006E), Color(0xFF8338EC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
