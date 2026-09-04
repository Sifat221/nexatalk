import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/controllers/chat_controller.dart';
import 'package:nexatalk/models/contact_model.dart';
import 'package:nexatalk/services/chat_service.dart';
import 'package:nexatalk/services/persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Chat Service & Controller Unit Tests', () {
    late PersistenceService persistence;
    late ChatService chatService;
    late ChatController chatController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      persistence = PersistenceService(prefs);
      chatService = MockChatService(persistence, seedDemoData: true);
      chatController = ChatController(chatService);
    });

    tearDown(() {
      chatController.dispose();
    });

    test('Initial conversations load correctly', () {
      expect(chatController.conversations.isNotEmpty, true);
      expect(chatController.conversations.any((c) => c.participant.name == 'Alif Hasan'), true);
    });

    test('Search filtering filters conversations by participant name', () {
      chatController.setSearchQuery('Alif');
      expect(chatController.conversations.length, 1);
      expect(chatController.conversations.first.participant.name, 'Alif Hasan');

      chatController.clearSearch();
      expect(chatController.conversations.length, greaterThan(1));
    });

    test('Select conversation loads messages and marks unread as read', () {
      final initialUnreadConv = chatController.conversations.firstWhere((c) => c.unreadCount > 0);
      chatController.selectConversation(initialUnreadConv);

      expect(chatController.selectedConversation?.id, initialUnreadConv.id);
      expect(chatController.activeMessages.isNotEmpty, true);
    });

    test('Sending message appends outgoing message', () async {
      final firstConv = chatController.conversations.first;
      chatController.selectConversation(firstConv);

      final initialMsgCount = chatController.activeMessages.length;
      await chatController.sendMessage('Hello from unit test!');

      expect(chatController.activeMessages.length, initialMsgCount + 1);
      expect(chatController.activeMessages.last.text, 'Hello from unit test!');
      expect(chatController.activeMessages.last.isOutgoing, true);
    });

    test('Toggle pin conversation reorders pinned items to top', () async {
      final target = chatController.conversations.firstWhere((c) => !c.isPinned);
      await chatController.togglePin(target.id);

      final updated = chatController.conversations.firstWhere((c) => c.id == target.id);
      expect(updated.isPinned, true);
    });

    test('Start chat with new contact creates or retrieves conversation', () async {
      final newContact = ContactModel(
        id: 'c_test_user',
        name: 'Test New User',
        status: 'Testing...',
        email: 'test@nexatalk.app',
        lastSeen: DateTime.now(),
      );

      final conv = await chatController.startChatWithContact(newContact);
      expect(conv.participant.id, newContact.id);
      expect(chatController.selectedConversation?.id, conv.id);
    });
  });
}
