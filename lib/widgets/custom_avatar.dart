import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Clean rounded avatar with radiant gradients, initials fallback, and status indicator.
class CustomAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final bool isOnline;
  final bool showOnlineIndicator;
  final String? gradientIndex;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const CustomAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.gradientIndex,
    this.avatarUrl,
    this.onTap,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'N';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  LinearGradient _getGradient(String? index) {
    switch (index) {
      case '1':
        return AppColors.avatarGradient1;
      case '2':
        return AppColors.avatarGradient2;
      case '3':
        return AppColors.avatarGradient3;
      case '4':
        return AppColors.avatarGradient4;
      default:
        // Hash name to pick deterministic gradient
        final hash = name.codeUnits.fold(0, (a, b) => a + b);
        final g = [
          AppColors.avatarGradient1,
          AppColors.avatarGradient2,
          AppColors.avatarGradient3,
          AppColors.avatarGradient4,
          AppColors.primaryGradient,
        ];
        return g[hash % g.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: avatarUrl != null ? null : _getGradient(gradientIndex),
            border: Border.all(
              color: AppColors.primaryCyan.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl!.startsWith('http')
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    width: radius * 2,
                    height: radius * 2,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        _initials,
                        style: TextStyle(
                          fontSize: radius * 0.75,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        fontSize: radius * 0.75,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.65,
              height: radius * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.online : AppColors.offline,
                border: Border.all(
                  color: AppColors.background,
                  width: 2.0,
                ),
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: AppColors.online.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(cursor: SystemMouseCursors.click, child: avatar),
      );
    }

    return avatar;
  }
}
