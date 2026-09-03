import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

/// Clean uppercase section title for grouping settings and lists.
class SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(left: 16, top: 20, bottom: 8, right: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primaryCyan,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
