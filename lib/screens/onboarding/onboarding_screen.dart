import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../services/persistence_service.dart';
import '../../widgets/custom_vector_illustrations.dart';
import '../../widgets/primary_button.dart';
import '../auth/sign_in_screen.dart';

/// Screen 2 — Polished Onboarding Carousel.
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
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      illustration: OnboardingIllustration1(),
    ),
    _OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      illustration: OnboardingIllustration2(),
    ),
    _OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      illustration: OnboardingIllustration3(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final persistence = context.read<PersistenceService>();
    await persistence.setOnboardingComplete(true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryCyan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.appName.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryLight,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        AppStrings.skip,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          data.illustration,
                          const SizedBox(height: 24),
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineLarge.copyWith(
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data.description,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  // Smooth Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryCyan : AppColors.surfaceHighlight,
                          borderRadius: AppRadius.roundedFull,
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
                  PrimaryButton(
                    text: isLastPage ? AppStrings.getStarted : AppStrings.next,
                    onPressed: _nextPage,
                    icon: isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
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
  final String title;
  final String description;
  final Widget illustration;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}
