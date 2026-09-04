import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../services/persistence_service.dart';
import '../../widgets/custom_vector_illustrations.dart';
import '../../widgets/primary_button.dart';
import '../auth/sign_in_screen.dart';
import '../auth/sign_up_screen.dart';

/// Screen 2 — Onboarding matching reference screen layout.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      welcomePrefix: 'Welcome to',
      title: AppStrings.appName,
      description: 'Simple, fast and secure\nmessaging for everyone.',
      illustration: TwoPeopleChattingIllustration(size: 240),
    ),
    _OnboardingPageData(
      welcomePrefix: 'Connect with',
      title: 'Real-time Chat',
      description: 'Instant message delivery, presence status,\nand live typing indicators.',
      illustration: OnboardingIllustration1(),
    ),
    _OnboardingPageData(
      welcomePrefix: 'Safe & Secure',
      title: 'Private & Direct',
      description: 'Your chats, profiles, and data\nsynced effortlessly in real time.',
      illustration: OnboardingIllustration2(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _navigateToSignUp() async {
    final persistence = context.read<PersistenceService>();
    await persistence.setOnboardingComplete(true);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  Future<void> _navigateToSignIn() async {
    final persistence = context.read<PersistenceService>();
    await persistence.setOnboardingComplete(true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _navigateToSignIn,
                    child: Text(
                      AppStrings.skip,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View with Heading, Illustration, and Subtitle
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Heading: Welcome to \n NexaTalk
                            Text(
                              data.welcomePrefix,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE2E8F0),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF8E9FA8),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Centered Illustration
                            data.illustration,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls matching reference
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  // 3 Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryCyan : const Color(0xFF1D3546),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryCyan.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Large Cyan "Get Started" CTA Button
                  PrimaryButton(
                    text: AppStrings.getStarted,
                    onPressed: _navigateToSignUp,
                    height: 52,
                  ),
                  const SizedBox(height: 14),

                  // "I already have an account" Secondary Link
                  TextButton(
                    onPressed: _navigateToSignIn,
                    child: const Text(
                      'I already have an account',
                      style: TextStyle(
                        color: Color(0xFF8E9FA8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String welcomePrefix;
  final String title;
  final String description;
  final Widget illustration;

  const _OnboardingPageData({
    required this.welcomePrefix,
    required this.title,
    required this.description,
    required this.illustration,
  });
}
