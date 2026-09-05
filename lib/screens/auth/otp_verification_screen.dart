import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/responsive_shell.dart';
import '../home/home_screen.dart';

/// Screen 5 — Verify OTP matching reference screen layout with custom numeric dialpad.
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

  void _onKeyPress(String digit) {
    if (_otpCode.length < 6) {
      HapticFeedback.selectionClick();
      setState(() {
        _otpCode += digit;
      });
      context.read<AuthController>().clearError();
      if (_otpCode.length == 6) {
        _handleVerify();
      }
    }
  }

  void _onBackspace() {
    if (_otpCode.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _otpCode = _otpCode.substring(0, _otpCode.length - 1);
      });
      context.read<AuthController>().clearError();
    }
  }

  Future<void> _handleVerify() async {
    if (_otpCode.length != 6) return;

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
    final dest = widget.destination.isNotEmpty
        ? widget.destination
        : (auth.currentUser?.email ?? 'your account');
    if (dest.startsWith('+') || RegExp(r'^\d').hasMatch(dest)) {
      auth.sendPhoneOtp(
        dest,
        onCodeSent: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('A verification code has been sent to $dest')),
          );
        },
      );
    } else {
      auth.startOtpCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code resent to $dest')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final displayDestination = widget.destination.isNotEmpty
        ? widget.destination
        : (auth.currentUser?.email ?? 'your account');

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Heading: Verify your number
                const Text(
                  AppStrings.verifyNumber,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter the 6-digit code we sent to\n$displayDestination',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8E9FA8),
                    height: 1.45,
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
                  const SizedBox(height: 16),
                ],

                // 6 Rounded OTP Boxes side-by-side
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final hasChar = index < _otpCode.length;
                    final char = hasChar ? _otpCode[index] : '';
                    final isActive = index == _otpCode.length || (_otpCode.length == 6 && index == 5);

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primaryCyan
                                : hasChar
                                    ? AppColors.primaryCyan.withValues(alpha: 0.5)
                                    : AppColors.surfaceBorder,
                            width: isActive ? 1.8 : 1.2,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryCyan.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            char,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Resend Countdown / Link
                Center(
                  child: auth.otpCountdown > 0
                      ? Text(
                          'Resend code in 00:${auth.otpCountdown.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Color(0xFF5A7285),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : TextButton(
                          onPressed: _handleResend,
                          child: const Text(
                            AppStrings.resendCode,
                            style: TextStyle(
                              color: AppColors.primaryCyan,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const Spacer(),

                // Custom On-Screen Keypad matching reference Screen 5
                _buildKeypad(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          children: [
            _buildKeypadKey('1', ''),
            const SizedBox(width: 8),
            _buildKeypadKey('2', 'ABC'),
            const SizedBox(width: 8),
            _buildKeypadKey('3', 'DEF'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildKeypadKey('4', 'GHI'),
            const SizedBox(width: 8),
            _buildKeypadKey('5', 'JKL'),
            const SizedBox(width: 8),
            _buildKeypadKey('6', 'MNO'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildKeypadKey('7', 'PQRS'),
            const SizedBox(width: 8),
            _buildKeypadKey('8', 'TUV'),
            const SizedBox(width: 8),
            _buildKeypadKey('9', 'WXYZ'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: SizedBox(height: 52)),
            const SizedBox(width: 8),
            _buildKeypadKey('0', ''),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: _onBackspace,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: const Center(
                    child: Icon(Icons.backspace_outlined, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadKey(String number, String letters) {
    return Expanded(
      child: InkWell(
        onTap: () => _onKeyPress(number),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              if (letters.isNotEmpty)
                Text(
                  letters,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A7285),
                    letterSpacing: 0.8,
                    height: 1.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
