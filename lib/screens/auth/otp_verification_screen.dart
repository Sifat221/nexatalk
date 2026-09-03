import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/otp_input_widget.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_shell.dart';
import '../home/home_screen.dart';

/// Screen 5 — OTP 6-Digit Code Verification.
class OtpVerificationScreen extends StatefulWidget {
  final String destination;

  const OtpVerificationScreen({
    super.key,
    required this.destination,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otpCode = '';

  Future<void> _handleVerify() async {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the code')),
      );
      return;
    }

    final auth = context.read<AuthController>();
    final success = await auth.verifyOtp(_otpCode);

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _handleResend() {
    final auth = context.read<AuthController>();
    if (widget.destination.startsWith('+') || RegExp(r'^\d').hasMatch(widget.destination)) {
      auth.sendPhoneOtp(
        widget.destination,
        onCodeSent: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('A verification code has been sent to ${widget.destination}')),
          );
        },
      );
    } else {
      auth.startOtpCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new 6-digit verification code has been sent! (Use 123456)')),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.verifyNumber,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'Enter the 6-digit verification code sent to '),
                      TextSpan(
                        text: widget.destination,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '. (Demo code: 123456)'),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

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
                  const SizedBox(height: 20),
                ],

                // 6-digit OTP Box Input
                OtpInputWidget(
                  length: 6,
                  onCompleted: (code) {
                    setState(() => _otpCode = code);
                    _handleVerify();
                  },
                  onChanged: (code) {
                    setState(() => _otpCode = code);
                    auth.clearError();
                  },
                ),
                const SizedBox(height: 28),

                // Resend Timer & Action
                Center(
                  child: auth.otpCountdown > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.textTertiary),
                            const SizedBox(width: 6),
                            Text(
                              'Resend code in ${auth.otpCountdown}s',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : TextButton.icon(
                          onPressed: _handleResend,
                          icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primaryCyan),
                          label: Text(
                            AppStrings.resendCode,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primaryCyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const Spacer(),

                // Verify Button
                PrimaryButton(
                  text: AppStrings.verify,
                  onPressed: _otpCode.length == 6 ? _handleVerify : null,
                  isLoading: auth.isLoading,
                  icon: Icons.verified_rounded,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
