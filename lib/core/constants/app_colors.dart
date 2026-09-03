import 'package:flutter/material.dart';

/// Centralized color palette for NexaTalk.
/// Built with a midnight-navy dark-first aesthetic and luminous cyan/turquoise accents.
class AppColors {
  AppColors._();

  // Background & Surface Colors (Midnight Dark Spectrum)
  static const Color background = Color(0xFF07131C); // Deepest midnight navy
  static const Color backgroundSecondary = Color(0xFF0A1824); // Secondary background
  static const Color surface = Color(0xFF0D202B); // Base card surface
  static const Color surfaceElevated = Color(0xFF112B37); // Elevated surface for modals/bubbles
  static const Color surfaceHighlight = Color(0xFF163746); // Hover & active states
  static const Color surfaceBorder = Color(0xFF1D4052); // Subtle surface borders
  
  // OLED Pure Dark Spectrum (For optional OLED mode)
  static const Color oledBackground = Color(0xFF03070A);
  static const Color oledSurface = Color(0xFF071118);

  // Primary Accent Colors (Vibrant Luminous Cyan / Turquoise / Teal)
  static const Color primary = Color(0xFF00E5D0); // Vibrant neon turquoise
  static const Color primaryCyan = Color(0xFF00D2C4); // Rich cyan
  static const Color primaryDark = Color(0xFF0A9396); // Deep teal
  static const Color primaryLight = Color(0xFF5EEAD4); // Light glowing cyan
  static const Color primaryGlow = Color(0x3300E5D0); // Glow shadow color

  // Secondary Accents
  static const Color accentIndigo = Color(0xFF6366F1); // Modern indigo
  static const Color accentPurple = Color(0xFF8B5CF6); // Subtle ambient glow
  static const Color accentBlue = Color(0xFF38BDF8); // Electric sky blue

  // Bubble Colors
  static const Color incomingBubble = Color(0xFF112735); // Dark translucent midnight
  static const Color incomingBubbleBorder = Color(0x2A00E5D0); // Subtle teal border
  static const Color outgoingBubbleStart = Color(0xFF00B4D8); // Gradient start
  static const Color outgoingBubbleEnd = Color(0xFF00E5D0); // Gradient end

  // Typography / Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Crisp pure/near-white
  static const Color textSecondary = Color(0xFF94A3B8); // Cool gray for subtexts
  static const Color textTertiary = Color(0xFF64748B); // Muted slate for timestamps
  static const Color textDisabled = Color(0xFF475569); // Inactive text
  static const Color textOnPrimary = Color(0xFF07131C); // Dark navy text on cyan buttons

  // Status & Utility Colors
  static const Color online = Color(0xFF10B981); // Emerald online indicator
  static const Color offline = Color(0xFF64748B); // Offline slate
  static const Color busy = Color(0xFFEF4444); // Busy / DND red
  static const Color away = Color(0xFFF59E0B); // Away amber
  static const Color error = Color(0xFFF87171); // Soft error red
  static const Color errorBackground = Color(0x26EF4444);
  static const Color success = Color(0xFF34D399); // Crisp success green
  static const Color successBackground = Color(0x2610B981);
  static const Color warning = Color(0xFFFBBF24); // Warning yellow
  static const Color unreadBadge = Color(0xFF00E5D0); // Badge fill

  // Glassmorphism & Overlay Effects
  static const Color glassFill = Color(0x1AFFFFFF); // 10% white for frosted glass
  static const Color glassBorder = Color(0x26FFFFFF); // 15% white for glass border
  static const Color divider = Color(0x1FFFFFFF); // 12% white divider

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [outgoingBubbleStart, outgoingBubbleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF0D2230), Color(0xFF081520)],
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
