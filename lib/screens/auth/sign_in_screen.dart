import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_shell.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

/// Screen 3 — Sign In matching reference screen layout.
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _handleMailTap() {
    // Focus email input field for direct email sign-in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your email and password above to sign in.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthController>();
    final success = await auth.googleSignIn();
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    final auth = context.read<AuthController>();
    final success = await auth.appleSignIn();
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
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
                  const SizedBox(height: 8),
                  // Heading: Welcome back 👋
                  const Text(
                    AppStrings.welcomeBack,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.signInSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8E9FA8),
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

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    hintText: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    hintText: '••••••••••••',
                    obscureText: !auth.isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        auth.isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF5A7285),
                        size: 20,
                      ),
                      onPressed: auth.togglePasswordVisibility,
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          color: AppColors.primaryCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Primary Sign In Button
                  PrimaryButton(
                    text: AppStrings.signIn,
                    onPressed: _handleSignIn,
                    isLoading: auth.isLoading,
                    height: 52,
                  ),
                  const SizedBox(height: 28),

                  // "or continue with" Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFF1D3546), thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppStrings.orContinueWith,
                          style: const TextStyle(color: Color(0xFF5A7285), fontSize: 13),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFF1D3546), thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 3 Rounded Social Square Tiles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialTile(
                        icon: Icons.g_mobiledata_rounded,
                        iconSize: 32,
                        onTap: _handleGoogleSignIn,
                      ),
                      const SizedBox(width: 16),
                      _buildSocialTile(
                        icon: Icons.apple_rounded,
                        iconSize: 26,
                        onTap: _handleAppleSignIn,
                      ),
                      const SizedBox(width: 16),
                      _buildSocialTile(
                        icon: Icons.mail_outline_rounded,
                        iconSize: 22,
                        onTap: _handleMailTap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Footer: Don't have an account? Sign up
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          AppStrings.dontHaveAccount,
                          style: TextStyle(color: Color(0xFF8E9FA8), fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                          child: Text(
                            AppStrings.signUp,
                            style: const TextStyle(
                              color: AppColors.primaryCyan,
                              fontSize: 14,
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

  Widget _buildSocialTile({
    required IconData icon,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 64,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
      ),
    );
  }
}
