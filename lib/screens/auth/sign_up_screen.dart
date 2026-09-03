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
import 'otp_verification_screen.dart';

/// Screen 4 — Sign Up / Registration.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            destination: _emailController.text.trim(),
          ),
        ),
      );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.createAccount,
                    style: AppTypography.displayMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.signUpSubtitle,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Full Name
                  CustomTextField(
                    controller: _nameController,
                    labelText: AppStrings.fullName,
                    hintText: 'Alex Morgan',
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textTertiary, size: 20),
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 18),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    hintText: 'alex.morgan@nexatalk.app',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textTertiary, size: 20),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 18),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    hintText: '••••••••',
                    obscureText: !auth.isPasswordVisible,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        auth.isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: auth.togglePasswordVisibility,
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 18),

                  // Confirm Password
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: AppStrings.confirmPassword,
                    hintText: '••••••••',
                    obscureText: !auth.isConfirmPasswordVisible,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        auth.isConfirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: auth.toggleConfirmPasswordVisibility,
                    ),
                    validator: (val) => Validators.validateConfirmPassword(val, _passwordController.text),
                  ),
                  const SizedBox(height: 28),

                  // Sign Up Action
                  PrimaryButton(
                    text: AppStrings.signUp,
                    onPressed: _handleSignUp,
                    isLoading: auth.isLoading,
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: 28),

                  // Footer
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            AppStrings.signIn,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primaryCyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
