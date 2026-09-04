import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/controllers/auth_controller.dart';
import 'package:nexatalk/core/constants/app_strings.dart';
import 'package:nexatalk/screens/auth/sign_in_screen.dart';
import 'package:nexatalk/services/auth_service.dart';
import 'package:nexatalk/services/persistence_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SignInScreen displays welcome headers, fields, and sign in button', (tester) async {
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
          home: SignInScreen(),
        ),
      ),
    );

    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
    expect(find.text(AppStrings.signInSubtitle), findsOneWidget);
    expect(find.text(AppStrings.signIn), findsOneWidget);
    expect(find.text(AppStrings.forgotPassword), findsOneWidget);
    expect(find.text(AppStrings.signUp), findsOneWidget);
  });
}
