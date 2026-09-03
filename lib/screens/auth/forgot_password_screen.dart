import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/secondary_button.dart';

/// Screen 6 — Forgot Password & Email Recovery.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.sendPasswordReset(_emailController.text.trim());

    if (success && mounted) {
      setState(() => _isSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return ResponsiveShell(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _isSent ? _buildSuccessState() : _buildFormState(auth),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(AuthController auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.forgotPasswordTitle,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.forgotPasswordSubtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            controller: _emailController,
            labelText: AppStrings.email,
            hintText: 'alex.morgan@nexatalk.app',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textTertiary, size: 20),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 28),

          PrimaryButton(
            text: AppStrings.sendResetLink,
            onPressed: _handleSendReset,
            isLoading: auth.isLoading,
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceElevated,
              border: Border.all(color: AppColors.primaryCyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 42,
              color: AppColors.primaryCyan,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.resetLinkSentTitle,
            style: AppTypography.headlineLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We have sent password recovery instructions to ${_emailController.text}. ${AppStrings.resetLinkSentDesc}',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          SecondaryButton(
            text: AppStrings.backToSignIn,
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.arrow_back_rounded,
          ),
        ],
      ),
    );
  }
}
