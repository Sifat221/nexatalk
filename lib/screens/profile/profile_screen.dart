import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_shell.dart';
import '../settings/settings_screen.dart';

/// Screen 11 — Profile Screen matching reference layout with single rounded card.
class ProfileScreen extends StatelessWidget {
  final bool showBackButton;

  const ProfileScreen({super.key, this.showBackButton = false});

  void _showEditProfileSheet(BuildContext context) {
    final auth = context.read<AuthController>();
    final user = auth.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final bioController = TextEditingController(text: user.bio);
    final phoneController = TextEditingController(text: user.phone ?? '+1 (555) 019-2834');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.editProfile, style: AppTypography.headlineMedium),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: nameController,
                labelText: AppStrings.fullName,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: bioController,
                labelText: AppStrings.bio,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: phoneController,
                labelText: AppStrings.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: AppStrings.saveChanges,
                onPressed: () async {
                  await auth.updateProfile(
                    name: nameController.text.trim(),
                    bio: bioController.text.trim(),
                    phone: phoneController.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_rounded, color: AppColors.primaryCyan),
                title: const Text('Change Avatar Style', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Customize your radiant gradient avatar theme', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAvatarStylePicker(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: AppColors.primaryCyan),
                title: const Text('Edit Profile Details', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Update display name, bio, and phone number', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditProfileSheet(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.textTertiary),
                title: const Text('Custom Photo Upload', style: TextStyle(color: AppColors.textTertiary)),
                subtitle: const Text('Requires Firebase Storage (Blaze plan)', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Custom photo upload requires Firebase Storage (Blaze plan). NexaTalk uses radiant, personalized initials avatars on the free Spark plan! ✨'),
                      duration: Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarStylePicker(BuildContext context) {
    final auth = context.read<AuthController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose Avatar Theme', style: AppTypography.headlineMedium),
              const SizedBox(height: 8),
              const Text('Select a vibrant gradient theme for your profile:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 1; i <= 4; i++)
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        await auth.updateProfile(avatarColor: '$i');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Avatar theme $i applied! ✨')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryCyan, width: 2),
                        ),
                        child: CustomAvatar(
                          name: auth.currentUser?.name ?? 'User',
                          radius: 28,
                          gradientIndex: '$i',
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Privacy Settings', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryCyan),
                title: const Text('Two-Factor Verification', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Protected with active session tokens', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                trailing: const Icon(Icons.check_circle_rounded, color: AppColors.online, size: 20),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined, color: AppColors.primaryCyan),
                title: const Text('Last Seen & Online', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Visible to Everyone', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined, color: AppColors.primaryCyan),
                title: const Text('Read Receipts', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Send double blue checkmarks when messages are read', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    final settingsCtrl = context.read<SettingsController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notifications', style: AppTypography.titleLarge),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Push Notifications', style: TextStyle(color: AppColors.textPrimary)),
                    subtitle: const Text('Receive alerts for incoming messages', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                    value: settingsCtrl.notificationsEnabled,
                    activeThumbColor: AppColors.primaryCyan,
                    onChanged: (val) {
                      setSheetState(() {
                        settingsCtrl.toggleNotifications(val);
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Haptic Vibrations', style: TextStyle(color: AppColors.textPrimary)),
                    subtitle: const Text('Vibrate on outgoing and incoming events', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                    value: settingsCtrl.hapticsEnabled,
                    activeThumbColor: AppColors.primaryCyan,
                    onChanged: (val) {
                      setSheetState(() {
                        settingsCtrl.toggleHaptics(val);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDataStorageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data and Storage', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.cloud_done_outlined, color: AppColors.primaryCyan),
                title: Text('Chat Backup', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text('Encrypted and synced with Cloud Firestore', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ),
              const ListTile(
                leading: Icon(Icons.storage_rounded, color: AppColors.primaryCyan),
                title: Text('Local Cache', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text('4.2 MB cached (optimally compressed)', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ResponsiveShell(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: const Text(
            AppStrings.profileTab,
            style: AppTypography.titleLarge,
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen(showBackButton: true)),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Center Avatar with Camera Badge
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () => _showAvatarOptions(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryCyan.withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CustomAvatar(
                            name: user.name,
                            radius: 46,
                            isOnline: true,
                            avatarUrl: user.avatarUrl,
                            gradientIndex: user.avatarColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAvatarOptions(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryCyan,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // User Display Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),

                // Bio / Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    user.bio.isNotEmpty ? user.bio : 'Never give up',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E9FA8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Single Unified Dark Rounded Container with 5 Rows
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
                      // 1. Account
                      _buildMenuTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Account',
                        subtitle: 'Edit your information',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(showBackButton: true),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),

                      // 2. Privacy
                      _buildMenuTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy',
                        subtitle: 'Manage your privacy',
                        onTap: () => _showPrivacySheet(context),
                      ),
                      _buildDivider(),

                      // 3. Notifications
                      _buildMenuTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: 'Manage notification settings',
                        onTap: () => _showNotificationsSheet(context),
                      ),
                      _buildDivider(),

                      // 4. Appearance
                      _buildMenuTile(
                        icon: Icons.palette_outlined,
                        title: 'Appearance',
                        subtitle: 'Theme, wallpaper',
                        onTap: () => _showAvatarStylePicker(context),
                      ),
                      _buildDivider(),

                      // 5. Data and Storage
                      _buildMenuTile(
                        icon: Icons.pie_chart_outline_rounded,
                        title: 'Data and Storage',
                        subtitle: 'Network usage, auto-download',
                        onTap: () => _showDataStorageSheet(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
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
