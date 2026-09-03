import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_typography.dart';

/// Interactive tile used across Settings and Profile menus.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBgColor;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBgColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedL,
          side: BorderSide(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.25)
                : AppColors.surfaceBorder.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor ??
                  (isDestructive
                      ? AppColors.errorBackground
                      : AppColors.surfaceElevated),
              borderRadius: AppRadius.roundedM,
              border: Border.all(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.3)
                    : AppColors.surfaceBorder.withValues(alpha: 0.6),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ??
                  (isDestructive ? AppColors.error : AppColors.primaryCyan),
            ),
          ),
          title: Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          trailing: trailing ??
              (onTap != null
                  ? const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    )
                  : null),
        ),
      ),
    );
  }
}
