import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/models/app_settings_model.dart';
import 'package:nexatalk/models/contact_model.dart';
import 'package:nexatalk/models/conversation_model.dart';
import 'package:nexatalk/models/message_model.dart';
import 'package:nexatalk/models/user_model.dart';

void main() {
  group('Data Models Serialization Suite', () {
    test('UserModel serializes to/from JSON correctly', () {
      final user = UserModel(
        id: 'usr_101',
        name: 'Alex Morgan',
        email: 'alex@nexatalk.app',
        username: 'alex_m',
        phone: '+1 555-0100',
        bio: 'Hello world',
        avatarColor: '0xFF00E5D0',
        isOnline: true,
        lastActive: DateTime(2026, 1, 1),
      );

      final json = user.toJson();
      final deserialized = UserModel.fromJson(json);

      expect(deserialized.id, user.id);
      expect(deserialized.name, user.name);
      expect(deserialized.email, user.email);
      expect(deserialized.username, user.username);
      expect(deserialized.bio, user.bio);
      expect(deserialized.isOnline, true);
    });

    test('ContactModel serializes to/from JSON correctly', () {
      final contact = ContactModel(
        id: 'c_maya',
        name: 'Maya Chen',
        status: 'Designing...',
        email: 'maya@nexatalk.app',
        phone: '+1 555-0200',
        avatarGradientIndex: '2',
        isOnline: true,
        lastSeen: DateTime(2026, 1, 1),
        roleOrTag: 'Product Team',
      );

      final json = contact.toJson();
      final deserialized = ContactModel.fromJson(json);

      expect(deserialized.id, contact.id);
      expect(deserialized.name, contact.name);
      expect(deserialized.status, contact.status);
      expect(deserialized.roleOrTag, 'Product Team');
    });

    test('MessageModel and ConversationModel serialize correctly', () {
      final message = MessageModel(
        id: 'msg_1',
        conversationId: 'conv_1',
        senderId: 'usr_me',
        senderName: 'You',
        text: 'Hey Maya!',
        timestamp: DateTime(2026, 1, 1, 10, 30),
        status: MessageStatus.read,
        isOutgoing: true,
        reactions: ['🔥'],
      );

      final contact = ContactModel(
        id: 'c_maya',
        name: 'Maya Chen',
        status: 'Available',
        email: 'maya@nexatalk.app',
        lastSeen: DateTime(2026, 1, 1),
      );

      final conv = ConversationModel(
        id: 'conv_1',
        participant: contact,
        lastMessage: message,
        unreadCount: 3,
        isPinned: true,
        isMuted: false,
        updatedAt: DateTime(2026, 1, 1, 10, 30),
        isTyping: false,
      );

      final json = conv.toJson();
      final deserialized = ConversationModel.fromJson(json);

      expect(deserialized.id, conv.id);
      expect(deserialized.participant.name, 'Maya Chen');
      expect(deserialized.lastMessage?.text, 'Hey Maya!');
      expect(deserialized.unreadCount, 3);
      expect(deserialized.isPinned, true);
    });

    test('AppSettingsModel default and copyWith behavior', () {
      const settings = AppSettingsModel();
      expect(settings.notificationsEnabled, true);
      expect(settings.oledMode, false);

      final updated = settings.copyWith(oledMode: true, language: 'Spanish (ES)');
      expect(updated.oledMode, true);
      expect(updated.language, 'Spanish (ES)');
      expect(updated.notificationsEnabled, true);
    });
  });
}
