import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/section_header.dart';
import '../../widgets/settings_tile.dart';
import '../auth/sign_in_screen.dart';

/// Screen 11 — Settings and Preferences Screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              'NexaTalk is built with Flutter and designed with a dark-first midnight-navy palette, fluid micro-animations, and clean abstract service layers ready for future Firebase backend integrations.',
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
            child: const Text(AppStrings.logOut, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                AppStrings.settings,
                style: AppTypography.displayMedium.copyWith(fontWeight: FontWeight.w800),
              ),
            ),

            // Account Section
            const SectionHeader(title: AppStrings.account),
            SettingsTile(
              icon: Icons.shield_outlined,
              title: AppStrings.security,
              subtitle: 'Passcode, 2FA, session activity',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Security settings updated')),
                );
              },
            ),
            SettingsTile(
              icon: Icons.block_rounded,
              title: AppStrings.blockedUsers,
              subtitle: '0 blocked contacts',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.translate_rounded,
              title: AppStrings.language,
              subtitle: settingsCtrl.language,
              onTap: () {
                _showLanguageSheet(context, settingsCtrl);
              },
            ),

            // Preferences Section
            const SectionHeader(title: AppStrings.preferences),
            SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: AppStrings.notifications,
              subtitle: 'Push notifications & message badges',
              trailing: Switch(
                value: settingsCtrl.notificationsEnabled,
                activeThumbColor: AppColors.primaryCyan,
                activeTrackColor: AppColors.primaryDark,
                onChanged: (val) => settingsCtrl.toggleNotifications(val),
              ),
            ),
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: AppStrings.oledDarkMode,
              subtitle: 'Ultra-deep black background for OLED screens',
              trailing: Switch(
                value: settingsCtrl.oledMode,
                activeThumbColor: AppColors.primaryCyan,
                activeTrackColor: AppColors.primaryDark,
                onChanged: (val) => settingsCtrl.toggleOledMode(val),
              ),
            ),
            SettingsTile(
              icon: Icons.vibration_rounded,
              title: AppStrings.hapticFeedback,
              subtitle: 'Subtle touch vibrations on actions',
              trailing: Switch(
                value: settingsCtrl.hapticsEnabled,
                activeThumbColor: AppColors.primaryCyan,
                activeTrackColor: AppColors.primaryDark,
                onChanged: (val) => settingsCtrl.toggleHaptics(val),
              ),
            ),
            SettingsTile(
              icon: Icons.done_all_rounded,
              title: AppStrings.readReceipts,
              subtitle: 'Show when messages have been seen',
              trailing: Switch(
                value: settingsCtrl.readReceipts,
                activeThumbColor: AppColors.primaryCyan,
                activeTrackColor: AppColors.primaryDark,
                onChanged: (val) => settingsCtrl.toggleReadReceipts(val),
              ),
            ),

            // Support Section
            const SectionHeader(title: AppStrings.support),
            SettingsTile(
              icon: Icons.help_outline_rounded,
              title: AppStrings.helpAndSupport,
              subtitle: 'FAQs, contact support, guides',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('NexaTalk Help Center is available 24/7')),
                );
              },
            ),
            SettingsTile(
              icon: Icons.info_outline_rounded,
              title: AppStrings.aboutNexaTalk,
              subtitle: 'Version ${AppStrings.appVersion}',
              onTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 16),
            // Danger Zone
            SettingsTile(
              icon: Icons.logout_rounded,
              title: AppStrings.logOut,
              isDestructive: true,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
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
}
