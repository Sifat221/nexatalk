import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/core/constants/app_strings.dart';
import 'package:nexatalk/screens/onboarding/onboarding_screen.dart';
import 'package:nexatalk/services/persistence_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexatalk/controllers/auth_controller.dart';
import 'package:nexatalk/services/auth_service.dart';

void main() {
  testWidgets('OnboardingScreen displays title and advances page on Next tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService(prefs);
    final authService = MockAuthService(persistence);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PersistenceService>.value(value: persistence),
          Provider<AuthService>.value(value: authService),
          ChangeNotifierProvider<AuthController>(
            create: (_) => AuthController(authService),
          ),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Initial page title and welcome strings
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.getStarted), findsOneWidget);
    expect(find.text(AppStrings.skip), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);

    // Tap Get Started
    await tester.tap(find.text(AppStrings.getStarted));
    await tester.pumpAndSettle();

    // Verify persistence onboarding flag set
    expect(persistence.isOnboardingComplete(), isTrue);
  });
}
