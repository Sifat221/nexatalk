import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/responsive_shell.dart';
import '../auth/sign_in_screen.dart';

/// Screen 12 — Settings Screen matching reference layout with unified card and separated logout card.
class SettingsScreen extends StatelessWidget {
  final bool showBackButton;

  const SettingsScreen({super.key, this.showBackButton = true});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 52, showText: true, showTagline: true),
            const SizedBox(height: 16),
            Text(
              'Version ${AppStrings.appVersion}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primaryCyan),
            ),
            const SizedBox(height: 16),
            Text(
              'NexaTalk is a state-of-the-art secure messaging experience with real-time Firebase backend sync, dark-first aesthetics, and fluid micro-animations.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: AppColors.primaryLight)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
        title: const Text('Log Out', style: AppTypography.titleLarge),
        content: const Text(
          AppStrings.logOutConfirm,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthController>();
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(AppStrings.logOut, style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, SettingsController settingsCtrl) {
    final languages = ['English (US)', 'Spanish (ES)', 'French (FR)', 'German (DE)', 'Japanese (JP)'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select Language', style: AppTypography.titleLarge),
                const SizedBox(height: 12),
                ...languages.map((lang) {
                  final isSelected = settingsCtrl.language == lang;
                  return ListTile(
                    title: Text(
                      lang,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryCyan : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.primaryCyan)
                        : null,
                    onTap: () {
                      settingsCtrl.setLanguage(lang);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = context.watch<SettingsController>();

    return ResponsiveShell(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
                  onPressed: () => Navigator.maybePop(context),
                )
              : null,
          title: const Text(
            AppStrings.settings,
            style: AppTypography.titleLarge,
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Main Settings Unified Dark Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Security
                      _buildSettingRow(
                        icon: Icons.shield_outlined,
                        title: AppStrings.security,
                        subtitle: 'Change password',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Two-factor security & passcode active')),
                          );
                        },
                      ),
                      _buildDivider(),

                      // Blocked Users
                      _buildSettingRow(
                        icon: Icons.block_rounded,
                        title: AppStrings.blockedUsers,
                        subtitle: 'Manage blocked users',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No blocked users found')),
                          );
                        },
                      ),
                      _buildDivider(),

                      // Notifications Switch
                      _buildSwitchRow(
                        icon: Icons.notifications_none_rounded,
                        title: AppStrings.notifications,
                        value: settingsCtrl.notificationsEnabled,
                        onChanged: (val) => settingsCtrl.toggleNotifications(val),
                      ),
                      _buildDivider(),

                      // OLED Dark Mode Switch
                      _buildSwitchRow(
                        icon: Icons.dark_mode_outlined,
                        title: AppStrings.oledDarkMode,
                        value: settingsCtrl.oledMode,
                        onChanged: (val) => settingsCtrl.toggleOledMode(val),
                      ),
                      _buildDivider(),

                      // Language
                      _buildSettingRow(
                        icon: Icons.translate_rounded,
                        title: AppStrings.language,
                        subtitle: 'English',
                        onTap: () => _showLanguageSheet(context, settingsCtrl),
                      ),
                      _buildDivider(),

                      // Help & Support
                      _buildSettingRow(
                        icon: Icons.help_outline_rounded,
                        title: AppStrings.helpAndSupport,
                        subtitle: 'Get help',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('NexaTalk Help Center is available 24/7')),
                          );
                        },
                      ),
                      _buildDivider(),

                      // About NexaTalk
                      _buildSettingRow(
                        icon: Icons.info_outline_rounded,
                        title: AppStrings.aboutNexaTalk,
                        subtitle: 'Version 1.0.0',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Visually Separated Bottom Card: Red Log Out
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showLogoutDialog(context),
                      borderRadius: BorderRadius.circular(16),
                      splashColor: AppColors.error.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                AppStrings.logOut,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.error.withValues(alpha: 0.5),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.primaryCyan.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF8E9FA8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF5A7285),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryCyan,
            activeTrackColor: AppColors.primaryDark,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: AppColors.surfaceBorder.withValues(alpha: 0.4),
    );
  }
}
