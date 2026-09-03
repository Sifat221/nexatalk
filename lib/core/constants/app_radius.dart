import 'package:flutter/material.dart';

/// Border radii tokens for NexaTalk.
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double round = 999.0;

  // BorderRadius helpers
  static final BorderRadius roundedXs = BorderRadius.circular(xs);
  static final BorderRadius roundedS = BorderRadius.circular(s);
  static final BorderRadius roundedM = BorderRadius.circular(m);
  static final BorderRadius roundedL = BorderRadius.circular(l);
  static final BorderRadius roundedXl = BorderRadius.circular(xl);
  static final BorderRadius roundedXxl = BorderRadius.circular(xxl);
  static final BorderRadius roundedFull = BorderRadius.circular(round);

  // Custom Bubble Shapes
  static const BorderRadius incomingBubbleRadius = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(18),
    bottomRight: Radius.circular(18),
    bottomLeft: Radius.circular(4),
  );

  static const BorderRadius outgoingBubbleRadius = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(4),
  );
}
