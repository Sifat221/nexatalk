import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/core/constants/app_strings.dart';
import 'package:nexatalk/screens/onboarding/onboarding_screen.dart';
import 'package:nexatalk/services/persistence_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('OnboardingScreen displays title and advances page on Next tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PersistenceService>.value(value: persistence),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Initial page title
    expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);
    expect(find.text(AppStrings.next), findsOneWidget);
    expect(find.text(AppStrings.skip), findsOneWidget);

    // Tap Next
    await tester.tap(find.text(AppStrings.next));
    await tester.pumpAndSettle();

    // Verify page 2
    expect(find.text(AppStrings.onboardingTitle2), findsOneWidget);
  });
}
