import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/controllers/auth_controller.dart';
import 'package:nexatalk/controllers/chat_controller.dart';
import 'package:nexatalk/controllers/contacts_controller.dart';
import 'package:nexatalk/controllers/settings_controller.dart';
import 'package:nexatalk/core/constants/app_strings.dart';
import 'package:nexatalk/screens/home/home_screen.dart';
import 'package:nexatalk/services/auth_service.dart';
import 'package:nexatalk/services/chat_service.dart';
import 'package:nexatalk/services/persistence_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('HomeScreen renders chats list and bottom navigation tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService(prefs);
    final authService = MockAuthService(persistence);
    final chatService = MockChatService(persistence);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PersistenceService>.value(value: persistence),
          Provider<AuthService>.value(value: authService),
          Provider<ChatService>.value(value: chatService),
          ChangeNotifierProvider<AuthController>(
            create: (_) => AuthController(authService),
          ),
          ChangeNotifierProvider<ChatController>(
            create: (_) => ChatController(chatService),
          ),
          ChangeNotifierProvider<ContactsController>(
            create: (_) => ContactsController(chatService),
          ),
          ChangeNotifierProvider<SettingsController>(
            create: (_) => SettingsController(persistence),
          ),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    // Verify NexaTalk brand title
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Verify Bottom Navigation tabs
    expect(find.text(AppStrings.chatsTab), findsOneWidget);
    expect(find.text(AppStrings.contactsTab), findsOneWidget);
    expect(find.text(AppStrings.profileTab), findsOneWidget);
  });
}
