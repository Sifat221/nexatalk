import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/status_badge.dart';

/// Screen 10 — Profile Screen with Live Editing Sheet.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  Text(AppStrings.editProfile, style: AppTypography.headlineMedium),
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
              Text('Choose Avatar Theme', style: AppTypography.headlineMedium),
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
            const SizedBox(height: 16),
            // Header Profile Card
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
                            color: AppColors.primaryCyan.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomAvatar(
                        name: user.name,
                        radius: 46,
                        isOnline: true,
                        avatarUrl: user.avatarUrl,
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
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.username}',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryLight),
            ),
            const SizedBox(height: 10),
            const StatusBadge(isOnline: true, customLabel: 'Active on NexaTalk'),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                user.bio,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Sections
            const SectionHeader(title: 'Account Information'),
            SettingsTile(
              icon: Icons.alternate_email_rounded,
              title: 'Email Address',
              subtitle: user.email,
            ),
            SettingsTile(
              icon: Icons.phone_outlined,
              title: 'Phone Number',
              subtitle: user.phone ?? '+1 (555) 019-2834',
            ),
            SettingsTile(
              icon: Icons.edit_note_rounded,
              title: 'Bio & Status',
              subtitle: user.bio,
              onTap: () => _showEditProfileSheet(context),
            ),

            const SectionHeader(title: 'Privacy & Security'),
            SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'Two-Factor Verification',
              subtitle: 'Enabled (Demo Mode)',
              trailing: const Icon(Icons.check_circle_rounded, color: AppColors.online, size: 20),
            ),
            SettingsTile(
              icon: Icons.visibility_outlined,
              title: 'Last Seen & Online',
              subtitle: 'Everyone',
            ),

            const SectionHeader(title: 'Data & Sync'),
            SettingsTile(
              icon: Icons.cloud_done_outlined,
              title: 'Chat Backup',
              subtitle: 'Locally cached & synced',
            ),
          ],
        ),
      ),
    ),
  );
}
}
