import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/controllers/settings_controller.dart';
import 'package:nexatalk/core/constants/app_strings.dart';
import 'package:nexatalk/screens/settings/settings_screen.dart';
import 'package:nexatalk/services/persistence_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SettingsScreen displays preference switches and options', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PersistenceService>.value(value: persistence),
          ChangeNotifierProvider<SettingsController>(
            create: (_) => SettingsController(persistence),
          ),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text(AppStrings.settings), findsOneWidget);
    expect(find.text(AppStrings.notifications), findsOneWidget);
    expect(find.text(AppStrings.oledDarkMode), findsOneWidget);
    expect(find.text(AppStrings.logOut), findsOneWidget);
  });
}
