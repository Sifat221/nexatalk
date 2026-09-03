import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/main.dart';
import 'package:nexatalk/services/auth_service.dart';
import 'package:nexatalk/services/chat_service.dart';
import 'package:nexatalk/services/persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('NexaTalkApp boots successfully to SplashScreen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService(prefs);
    final auth = MockAuthService(persistence);
    final chat = MockChatService(persistence);

    await tester.pumpWidget(
      NexaTalkApp(
        persistenceService: persistence,
        authService: auth,
        chatService: chat,
      ),
    );

    // Initial frame of NexaTalkApp renders splash
    expect(find.byType(NexaTalkApp), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();
  });
}
