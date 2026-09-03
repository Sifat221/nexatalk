import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/secondary_button.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

/// Screen 3 — Modern Authentication / Sign In.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'alex.morgan@nexatalk.app');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  Future<void> _handleQuickDemoLogin() async {
    final auth = context.read<AuthController>();
    final success = await auth.quickDemoLogin();
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthController>();
    final success = await auth.googleSignIn();
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    final auth = context.read<AuthController>();
    final success = await auth.appleSignIn();
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return ResponsiveShell(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: AppLogo(
                      size: 60,
                      showText: false,
                      showTagline: false,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.welcomeBack,
                    style: AppTypography.displayMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.signInSubtitle,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

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

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    hintText: 'alex.morgan@nexatalk.app',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textTertiary, size: 20),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
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
                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        AppStrings.forgotPassword,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Primary Sign In Button
                  PrimaryButton(
                    text: AppStrings.signIn,
                    onPressed: _handleSignIn,
                    isLoading: auth.isLoading,
                    icon: Icons.login_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Quick One-Tap Demo Login
                  SecondaryButton(
                    text: AppStrings.quickDemoLogin,
                    onPressed: _handleQuickDemoLogin,
                    icon: Icons.bolt_rounded,
                    borderColor: AppColors.primaryCyan.withValues(alpha: 0.3),
                    textColor: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.divider.withValues(alpha: 0.15)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppStrings.orContinueWith,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.divider.withValues(alpha: 0.15)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: AppStrings.google,
                          icon: Icons.g_mobiledata_rounded,
                          onPressed: _handleGoogleSignIn,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SecondaryButton(
                          text: AppStrings.apple,
                          icon: Icons.apple_rounded,
                          onPressed: _handleAppleSignIn,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Footer Sign Up Link
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                          child: Text(
                            AppStrings.signUp,
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
