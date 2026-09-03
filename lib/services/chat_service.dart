import 'dart:async';
import 'dart:math';
import '../models/contact_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'persistence_service.dart';

/// Abstract Chat Service defining the core messaging contracts.
/// Fully decoupled so Firebase Cloud Firestore / Realtime Database can be dropped in later.
abstract class ChatService {
  Stream<List<ConversationModel>> get conversationsStream;
  List<ConversationModel> get currentConversations;
  Stream<List<MessageModel>> getMessagesStream(String conversationId);
  List<MessageModel> getMessages(String conversationId);

  Future<List<ContactModel>> getContacts();
  Future<ConversationModel> getOrCreateConversation(ContactModel contact);
  Future<MessageModel> sendMessage(
    String conversationId,
    String text, {
    AttachmentType attachmentType = AttachmentType.none,
    String? attachmentData,
  });
  Future<void> toggleReaction(String conversationId, String messageId, String emoji);
  Future<void> markConversationAsRead(String conversationId);
  Future<void> deleteConversation(String conversationId);
  Future<void> togglePinConversation(String conversationId);
  Future<void> toggleMuteConversation(String conversationId);
  Future<List<ContactModel>> searchUsers(String query);
  Future<void> setTyping(String conversationId, bool isTyping);
  Future<ConversationModel> createGroupConversation({
    required String title,
    required List<ContactModel> participants,
  });
}

/// Mock Chat Service delivering realistic local chat behaviors, typing simulation, and message persistence.
class MockChatService implements ChatService {
  final PersistenceService _persistence;

  final StreamController<List<ConversationModel>> _conversationsController =
      StreamController<List<ConversationModel>>.broadcast();

  final Map<String, StreamController<List<MessageModel>>> _messageStreamControllers = {};
  final Map<String, List<MessageModel>> _messagesMap = {};
  List<ConversationModel> _conversations = [];
  final List<ContactModel> _contacts = ContactModel.mockContacts;
  final Map<String, Timer?> _typingTimers = {};

  MockChatService(this._persistence) {
    _initializeData();
  }

  void _initializeData() {
    final cached = _persistence.getSavedConversations();
    if (cached != null && cached.isNotEmpty) {
      _conversations = cached;
    } else {
      _conversations = _buildInitialConversations();
    }

    _populateInitialMessages();

    Future.microtask(() {
      _conversationsController.add(List.unmodifiable(_conversations));
    });
  }

  @override
  Stream<List<ConversationModel>> get conversationsStream => _conversationsController.stream;

  @override
  List<ConversationModel> get currentConversations => List.unmodifiable(_conversations);

  @override
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    if (!_messageStreamControllers.containsKey(conversationId)) {
      _messageStreamControllers[conversationId] = StreamController<List<MessageModel>>.broadcast();
    }

    // Emit current messages for this conversation immediately
    final msgs = _messagesMap[conversationId] ?? [];
    Future.microtask(() {
      _messageStreamControllers[conversationId]?.add(List.unmodifiable(msgs));
    });

    return _messageStreamControllers[conversationId]!.stream;
  }

  @override
  List<MessageModel> getMessages(String conversationId) {
    return List.unmodifiable(_messagesMap[conversationId] ?? []);
  }

  @override
  Future<List<ContactModel>> getContacts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_contacts);
  }

  @override
  Future<ConversationModel> getOrCreateConversation(ContactModel contact) async {
    final index = _conversations.indexWhere((c) => c.participant.id == contact.id);
    if (index != -1) {
      return _conversations[index];
    }

    final newConvId = 'conv_${contact.id}_${DateTime.now().millisecondsSinceEpoch}';
    final initialMsg = MessageModel(
      id: 'msg_init_$newConvId',
      conversationId: newConvId,
      senderId: contact.id,
      senderName: contact.name,
      text: 'Hey there! Nice to connect with you on NexaTalk 👋',
      timestamp: DateTime.now(),
      status: MessageStatus.read,
      isOutgoing: false,
    );

    final newConv = ConversationModel(
      id: newConvId,
      participant: contact,
      lastMessage: initialMsg,
      unreadCount: 0,
      updatedAt: DateTime.now(),
      isTyping: false,
    );

    _conversations.insert(0, newConv);
    _messagesMap[newConvId] = [initialMsg];

    _notifyConversations();
    _notifyMessages(newConvId);
    await _persistence.saveConversations(_conversations);

    return newConv;
  }

  @override
  Future<MessageModel> sendMessage(
    String conversationId,
    String text, {
    AttachmentType attachmentType = AttachmentType.none,
    String? attachmentData,
  }) async {
    final now = DateTime.now();
    final messageId = 'msg_${now.millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    final message = MessageModel(
      id: messageId,
      conversationId: conversationId,
      senderId: 'usr_me',
      senderName: 'You',
      text: text.trim(),
      timestamp: now,
      status: MessageStatus.sent,
      isOutgoing: true,
      attachmentType: attachmentType,
      attachmentData: attachmentData,
    );

    if (!_messagesMap.containsKey(conversationId)) {
      _messagesMap[conversationId] = [];
    }
    _messagesMap[conversationId]!.add(message);

    // Update conversation last message & timestamp
    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      final old = _conversations[convIndex];
      _conversations.removeAt(convIndex);
      final updated = old.copyWith(
        lastMessage: message,
        updatedAt: now,
        unreadCount: 0,
      );
      _conversations.insert(0, updated);
    }

    _notifyMessages(conversationId);
    _notifyConversations();
    await _persistence.saveConversations(_conversations);

    // Trigger simulated reply after a brief typing indication
    _scheduleSimulatedReply(conversationId, text);

    return message;
  }

  void _scheduleSimulatedReply(String conversationId, String userMessage) {
    _typingTimers[conversationId]?.cancel();

    // Find participant
    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex == -1) return;
    final participant = _conversations[convIndex].participant;

    // Start typing after 700ms
    _typingTimers[conversationId] = Timer(const Duration(milliseconds: 700), () {
      final cIdx = _conversations.indexWhere((c) => c.id == conversationId);
      if (cIdx != -1) {
        _conversations[cIdx] = _conversations[cIdx].copyWith(isTyping: true);
        _notifyConversations();
      }

      // Deliver message after 1800ms
      _typingTimers[conversationId] = Timer(const Duration(milliseconds: 1800), () {
        final cIdx2 = _conversations.indexWhere((c) => c.id == conversationId);
        if (cIdx2 == -1) return;

        final replyText = _generateSmartReply(userMessage, participant.name);
        final now = DateTime.now();
        final replyMsg = MessageModel(
          id: 'msg_${now.millisecondsSinceEpoch}_sim',
          conversationId: conversationId,
          senderId: participant.id,
          senderName: participant.name,
          text: replyText,
          timestamp: now,
          status: MessageStatus.read,
          isOutgoing: false,
        );

        _messagesMap[conversationId]?.add(replyMsg);

        _conversations[cIdx2] = _conversations[cIdx2].copyWith(
          lastMessage: replyMsg,
          updatedAt: now,
          isTyping: false,
          unreadCount: _conversations[cIdx2].unreadCount,
        );

        _notifyMessages(conversationId);
        _notifyConversations();
        _persistence.saveConversations(_conversations);
      });
    });
  }

  String _generateSmartReply(String input, String senderName) {
    final lower = input.toLowerCase();
    if (lower.contains('hey') || lower.contains('hello') || lower.contains('hi')) {
      return "Hey there! How's your day going?";
    } else if (lower.contains('how are you') || lower.contains('how r u')) {
      return "Doing fantastic! Loving the sleek design of NexaTalk ✨ How about you?";
    } else if (lower.contains('design') || lower.contains('ui') || lower.contains('theme')) {
      return "The midnight navy and luminous cyan look incredible! Super fluid and minimal.";
    } else if (lower.contains('free') || lower.contains('meet') || lower.contains('call')) {
      return "I'm free in about 15 minutes! Let's jump on a quick call.";
    } else if (lower.contains('flutter') || lower.contains('code') || lower.contains('dev')) {
      return "Flutter makes building responsive apps so seamless! 🚀";
    } else if (lower.contains('thanks') || lower.contains('thank you')) {
      return "Anytime! Always happy to help 😊";
    } else {
      final canned = [
        "Sounds great! Let's stay in touch.",
        "Got it! Thanks for the update.",
        "That works for me! Talk soon.",
        "Awesome! NexaTalk makes chatting so natural 💬",
        "Couldn't agree more! ✨",
      ];
      return canned[Random().nextInt(canned.length)];
    }
  }

  @override
  Future<void> toggleReaction(String conversationId, String messageId, String emoji) async {
    final msgs = _messagesMap[conversationId];
    if (msgs == null) return;

    final index = msgs.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final currentReactions = List<String>.from(msgs[index].reactions);
    if (currentReactions.contains(emoji)) {
      currentReactions.remove(emoji);
    } else {
      currentReactions.add(emoji);
    }

    msgs[index] = msgs[index].copyWith(reactions: currentReactions);
    _notifyMessages(conversationId);
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1 && _conversations[index].unreadCount > 0) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      _notifyConversations();
      await _persistence.saveConversations(_conversations);
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    _conversations.removeWhere((c) => c.id == conversationId);
    _messagesMap.remove(conversationId);
    _notifyConversations();
    await _persistence.saveConversations(_conversations);
  }

  @override
  Future<void> togglePinConversation(String conversationId) async {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        isPinned: !_conversations[index].isPinned,
      );
      // Sort pinned conversations to the top
      _conversations.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      _notifyConversations();
      await _persistence.saveConversations(_conversations);
    }
  }

  @override
  Future<void> toggleMuteConversation(String conversationId) async {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        isMuted: !_conversations[index].isMuted,
      );
      _notifyConversations();
      await _persistence.saveConversations(_conversations);
    }
  }

  void _notifyConversations() {
    _conversationsController.add(List.unmodifiable(_conversations));
  }

  void _notifyMessages(String conversationId) {
    final msgs = _messagesMap[conversationId] ?? [];
    _messageStreamControllers[conversationId]?.add(List.unmodifiable(msgs));
  }

  List<ConversationModel> _buildInitialConversations() {
    final now = DateTime.now();
    return [
      ConversationModel(
        id: 'conv_maya',
        participant: _contacts[0], // Maya Chen
        lastMessage: MessageModel(
          id: 'msg_maya_last',
          conversationId: 'conv_maya',
          senderId: 'contact_maya',
          senderName: 'Maya Chen',
          text: 'Hey, are you free today? Let’s review the new design prototypes! 🎨',
          timestamp: now.subtract(const Duration(minutes: 8)),
          status: MessageStatus.read,
          isOutgoing: false,
        ),
        unreadCount: 2,
        isPinned: true,
        updatedAt: now.subtract(const Duration(minutes: 8)),
      ),
      ConversationModel(
        id: 'conv_ryan',
        participant: _contacts[1], // Ryan Lee
        lastMessage: MessageModel(
          id: 'msg_ryan_last',
          conversationId: 'conv_ryan',
          senderId: 'usr_me',
          senderName: 'You',
          text: 'Looks great! Deployed the latest build to testing 🚀',
          timestamp: now.subtract(const Duration(minutes: 35)),
          status: MessageStatus.read,
          isOutgoing: true,
        ),
        unreadCount: 0,
        isPinned: true,
        updatedAt: now.subtract(const Duration(minutes: 35)),
      ),
      ConversationModel(
        id: 'conv_sophia',
        participant: _contacts[2], // Sophia Reed
        lastMessage: MessageModel(
          id: 'msg_sophia_last',
          conversationId: 'conv_sophia',
          senderId: 'contact_sophia',
          senderName: 'Sophia Reed',
          text: 'Let’s catch up soon. We have some exciting updates for sprint 12.',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 14)),
          status: MessageStatus.read,
          isOutgoing: false,
        ),
        unreadCount: 1,
        isPinned: false,
        updatedAt: now.subtract(const Duration(hours: 2, minutes: 14)),
      ),
      ConversationModel(
        id: 'conv_noah',
        participant: _contacts[3], // Noah Carter
        lastMessage: MessageModel(
          id: 'msg_noah_last',
          conversationId: 'conv_noah',
          senderId: 'contact_noah',
          senderName: 'Noah Carter',
          text: 'See you tomorrow at 10:00 AM!',
          timestamp: now.subtract(const Duration(hours: 5)),
          status: MessageStatus.read,
          isOutgoing: false,
        ),
        unreadCount: 0,
        isPinned: false,
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      ConversationModel(
        id: 'conv_ethan',
        participant: _contacts[4], // Ethan Cole
        lastMessage: MessageModel(
          id: 'msg_ethan_last',
          conversationId: 'conv_ethan',
          senderId: 'usr_me',
          senderName: 'You',
          text: 'Thanks! Loved the micro-animations.',
          timestamp: now.subtract(const Duration(days: 1, hours: 3)),
          status: MessageStatus.delivered,
          isOutgoing: true,
        ),
        unreadCount: 0,
        isPinned: false,
        updatedAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      ConversationModel(
        id: 'conv_olivia',
        participant: _contacts[5], // Olivia Park
        lastMessage: MessageModel(
          id: 'msg_olivia_last',
          conversationId: 'conv_olivia',
          senderId: 'contact_olivia',
          senderName: 'Olivia Park',
          text: 'Connecting simply and chatting naturally! Loving the vibe ✨',
          timestamp: now.subtract(const Duration(days: 2)),
          status: MessageStatus.read,
          isOutgoing: false,
        ),
        unreadCount: 0,
        isPinned: false,
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  void _populateInitialMessages() {
    final now = DateTime.now();

    // Maya Chen Messages
    _messagesMap['conv_maya'] = [
      MessageModel(
        id: 'm_m1',
        conversationId: 'conv_maya',
        senderId: 'contact_maya',
        senderName: 'Maya Chen',
        text: 'Hi Alex! Have you had a chance to look at the new dark-mode designs?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        status: MessageStatus.read,
        isOutgoing: false,
      ),
      MessageModel(
        id: 'm_m2',
        conversationId: 'conv_maya',
        senderId: 'usr_me',
        senderName: 'You',
        text: 'Yes! The midnight navy background and glowing turquoise accents look stunning.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 12)),
        status: MessageStatus.read,
        isOutgoing: true,
        reactions: ['🔥', '✨'],
      ),
      MessageModel(
        id: 'm_m3',
        conversationId: 'conv_maya',
        senderId: 'contact_maya',
        senderName: 'Maya Chen',
        text: 'Awesome! We aimed for maximum readability and a premium glassmorphic feel.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 5)),
        status: MessageStatus.read,
        isOutgoing: false,
      ),
      MessageModel(
        id: 'm_m4',
        conversationId: 'conv_maya',
        senderId: 'contact_maya',
        senderName: 'Maya Chen',
        text: 'Hey, are you free today? Let’s review the new design prototypes! 🎨',
        timestamp: now.subtract(const Duration(minutes: 8)),
        status: MessageStatus.read,
        isOutgoing: false,
      ),
    ];

    // Ryan Lee Messages
    _messagesMap['conv_ryan'] = [
      MessageModel(
        id: 'm_r1',
        conversationId: 'conv_ryan',
        senderId: 'contact_ryan',
        senderName: 'Ryan Lee',
        text: 'Did we finish the responsive dual-pane layout for web and tablet?',
        timestamp: now.subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
        isOutgoing: false,
      ),
      MessageModel(
        id: 'm_r2',
        conversationId: 'conv_ryan',
        senderId: 'usr_me',
        senderName: 'You',
        text: 'Looks great! Deployed the latest build to testing 🚀',
        timestamp: now.subtract(const Duration(minutes: 35)),
        status: MessageStatus.read,
        isOutgoing: true,
      ),
    ];
  }

  @override
  Future<List<ContactModel>> searchUsers(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _contacts;
    return _contacts.where((c) =>
      c.name.toLowerCase().contains(q) ||
      c.status.toLowerCase().contains(q) ||
      c.roleOrTag.toLowerCase().contains(q) ||
      c.email.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Future<void> setTyping(String conversationId, bool isTyping) async {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(isTyping: isTyping);
      _conversationsController.add(List.unmodifiable(_conversations));
    }
  }

  @override
  Future<ConversationModel> createGroupConversation({
    required String title,
    required List<ContactModel> participants,
  }) async {
    final convId = 'grp_${DateTime.now().millisecondsSinceEpoch}';
    final groupContact = ContactModel(
      id: convId,
      name: title,
      email: '$convId@group.nexatalk.app',
      status: '${participants.length + 1} members',
      roleOrTag: 'Group',
      isOnline: true,
      lastSeen: DateTime.now(),
      avatarGradientIndex: (title.hashCode.abs() % 4 + 1).toString(),
    );

    final newConv = ConversationModel(
      id: convId,
      participant: groupContact,
      lastMessage: null,
      unreadCount: 0,
      updatedAt: DateTime.now(),
      isTyping: false,
    );

    _conversations.insert(0, newConv);
    _conversationsController.add(List.unmodifiable(_conversations));
    return newConv;
  }
}
