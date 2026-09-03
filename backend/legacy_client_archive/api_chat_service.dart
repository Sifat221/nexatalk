import 'dart:async';
import '../core/network/api_client.dart';
import '../core/network/realtime_client.dart';
import '../models/contact_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'chat_service.dart';
import 'persistence_service.dart';

class ApiChatService implements ChatService {
  final ApiClient apiClient;
  final RealtimeClient realtimeClient;
  final PersistenceService persistence;

  final StreamController<List<ConversationModel>> _conversationsController =
      StreamController<List<ConversationModel>>.broadcast();

  final Map<String, StreamController<List<MessageModel>>> _messageStreamControllers = {};
  final Map<String, List<MessageModel>> _messagesMap = {};
  List<ConversationModel> _conversations = [];

  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _reactionSub;

  ApiChatService({
    required this.apiClient,
    required this.realtimeClient,
    required this.persistence,
  }) {
    _init();
  }

  void _init() {
    final cached = persistence.getSavedConversations();
    if (cached != null) {
      _conversations = cached;
      Future.microtask(() {
        _conversationsController.add(List.unmodifiable(_conversations));
      });
    }

    // Connect realtime client
    realtimeClient.connect();

    // Subscribe to incoming realtime messages
    _msgSub = realtimeClient.onMessageNew.listen((data) {
      final convId = data['conversationId'] as String?;
      final rawMsg = data['message'];
      if (convId != null && rawMsg is Map<String, dynamic>) {
        final currentUserId = persistence.getSavedUser()?.id;
        final isOutgoing = rawMsg['senderId'] == currentUserId;
        final msg = _parseMessage(rawMsg, isOutgoing);

        if (!_messagesMap.containsKey(convId)) {
          _messagesMap[convId] = [];
        }

        // Avoid duplicates
        final idx = _messagesMap[convId]!.indexWhere((m) => m.id == msg.id);
        if (idx == -1) {
          _messagesMap[convId]!.add(msg);
        } else {
          _messagesMap[convId]![idx] = msg;
        }

        // Update conversation list
        final cIdx = _conversations.indexWhere((c) => c.id == convId);
        if (cIdx != -1) {
          final old = _conversations[cIdx];
          _conversations.removeAt(cIdx);
          _conversations.insert(
            0,
            old.copyWith(
              lastMessage: msg,
              updatedAt: msg.timestamp,
              isTyping: false,
              unreadCount: isOutgoing ? old.unreadCount : old.unreadCount + 1,
            ),
          );
        }

        _notifyMessages(convId);
        _notifyConversations();
        persistence.saveConversations(_conversations);
      }
    });

    // Subscribe to typing updates
    _typingSub = realtimeClient.onTypingUpdate.listen((data) {
      final convId = data['conversationId'] as String?;
      final isTyping = data['isTyping'] as bool? ?? false;
      final typingUserId = data['userId'] as String?;
      final currentUserId = persistence.getSavedUser()?.id;

      if (convId != null && typingUserId != currentUserId) {
        final cIdx = _conversations.indexWhere((c) => c.id == convId);
        if (cIdx != -1) {
          _conversations[cIdx] = _conversations[cIdx].copyWith(isTyping: isTyping);
          _notifyConversations();
        }
      }
    });

    // Subscribe to reaction updates
    _reactionSub = realtimeClient.onReactionUpdated.listen((data) {
      final convId = data['conversationId'] as String?;
      final msgId = data['messageId'] as String?;
      final rawReactions = data['reactions'] as List<dynamic>?;

      if (convId != null && msgId != null && rawReactions != null) {
        final msgs = _messagesMap[convId];
        if (msgs != null) {
          final mIdx = msgs.indexWhere((m) => m.id == msgId);
          if (mIdx != -1) {
            final emojis = rawReactions.map((r) => r['emoji'] as String).toList();
            msgs[mIdx] = msgs[mIdx].copyWith(reactions: emojis);
            _notifyMessages(convId);
          }
        }
      }
    });

    // Initial fetch from backend
    fetchConversations();
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

    final msgs = _messagesMap[conversationId] ?? [];
    Future.microtask(() {
      _messageStreamControllers[conversationId]?.add(List.unmodifiable(msgs));
    });

    // Join room on backend Socket.IO
    realtimeClient.joinConversation(conversationId);

    // Fetch messages from backend
    fetchMessages(conversationId);

    return _messageStreamControllers[conversationId]!.stream;
  }

  @override
  List<MessageModel> getMessages(String conversationId) {
    return List.unmodifiable(_messagesMap[conversationId] ?? []);
  }

  Future<void> fetchConversations() async {
    try {
      final data = await apiClient.get('/conversations');
      if (data is List) {
        final currentUserId = persistence.getSavedUser()?.id;
        _conversations = data.map((item) {
          final rawParticipant = item['participant'] as Map<String, dynamic>?;
          final contact = rawParticipant != null
              ? ContactModel(
                  id: rawParticipant['id'] ?? 'usr_target',
                  name: rawParticipant['displayName'] ?? 'User',
                  email: rawParticipant['email'] ?? 'user@nexatalk.app',
                  status: rawParticipant['status'] ?? 'Available',
                  roleOrTag: rawParticipant['username'] != null ? '@${rawParticipant['username']}' : 'Member',
                  isOnline: rawParticipant['isOnline'] as bool? ?? false,
                  lastSeen: rawParticipant['lastSeenAt'] != null
                      ? DateTime.tryParse(rawParticipant['lastSeenAt']) ?? DateTime.now()
                      : DateTime.now(),
                )
              : ContactModel.mockContacts.first;

          MessageModel? lastMsg;
          if (item['lastMessage'] != null) {
            final rawM = item['lastMessage'] as Map<String, dynamic>;
            final isOut = rawM['senderId'] == currentUserId;
            lastMsg = _parseMessage(rawM, isOut);
          }

          return ConversationModel(
            id: item['id'],
            participant: contact,
            lastMessage: lastMsg,
            unreadCount: (item['unreadCount'] as int?) ?? 0,
            isPinned: item['isPinned'] as bool? ?? false,
            isMuted: item['isMuted'] as bool? ?? false,
            updatedAt: item['updatedAt'] != null
                ? DateTime.tryParse(item['updatedAt']) ?? DateTime.now()
                : DateTime.now(),
            isTyping: false,
          );
        }).toList();

        _notifyConversations();
        await persistence.saveConversations(_conversations);
      }
    } catch (_) {}
  }

  Future<void> fetchMessages(String conversationId) async {
    try {
      final data = await apiClient.get('/conversations/$conversationId/messages');
      if (data is List) {
        final currentUserId = persistence.getSavedUser()?.id;
        final msgs = data.map((raw) {
          final isOut = raw['senderId'] == currentUserId;
          return _parseMessage(raw, isOut);
        }).toList();

        _messagesMap[conversationId] = msgs;
        _notifyMessages(conversationId);
      }
    } catch (_) {}
  }

  @override
  Future<List<ContactModel>> getContacts() async {
    try {
      final data = await apiClient.get('/users/search', queryParams: {'q': 'a', 'limit': 50});
      if (data is List) {
        return data.map((raw) {
          return ContactModel(
            id: raw['id'],
            name: raw['displayName'] ?? 'User',
            email: raw['email'] ?? 'contact@nexatalk.app',
            status: raw['status'] ?? 'Available',
            roleOrTag: raw['username'] != null ? '@${raw['username']}' : 'Member',
            isOnline: raw['isOnline'] as bool? ?? false,
            lastSeen: raw['lastSeenAt'] != null
                ? DateTime.tryParse(raw['lastSeenAt']) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();
      }
    } catch (_) {}

    return ContactModel.mockContacts;
  }

  @override
  Future<ConversationModel> getOrCreateConversation(ContactModel contact) async {
    try {
      final data = await apiClient.post('/conversations', body: {
        'type': 'DIRECT',
        'recipientId': contact.id,
      });

      final convId = data['id'] as String;
      final existingIdx = _conversations.indexWhere((c) => c.id == convId);

      if (existingIdx != -1) {
        return _conversations[existingIdx];
      }

      final newConv = ConversationModel(
        id: convId,
        participant: contact,
        lastMessage: null,
        unreadCount: 0,
        updatedAt: DateTime.now(),
        isTyping: false,
      );

      _conversations.insert(0, newConv);
      _notifyConversations();
      await persistence.saveConversations(_conversations);
      return newConv;
    } catch (_) {
      // Fallback
      final fallbackConv = ConversationModel(
        id: 'conv_${contact.id}',
        participant: contact,
        lastMessage: null,
        unreadCount: 0,
        updatedAt: DateTime.now(),
        isTyping: false,
      );
      return fallbackConv;
    }
  }

  @override
  Future<MessageModel> sendMessage(
    String conversationId,
    String text, {
    AttachmentType attachmentType = AttachmentType.none,
    String? attachmentData,
  }) async {
    String typeStr = 'TEXT';
    if (attachmentType == AttachmentType.image) typeStr = 'IMAGE';
    if (attachmentType == AttachmentType.document) typeStr = 'DOCUMENT';
    if (attachmentType == AttachmentType.voiceNote) typeStr = 'VOICE_NOTE';

    final now = DateTime.now();
    final tempMsg = MessageModel(
      id: 'temp_${now.millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: persistence.getSavedUser()?.id ?? 'usr_me',
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
    _messagesMap[conversationId]!.add(tempMsg);
    _notifyMessages(conversationId);

    try {
      final data = await apiClient.post('/conversations/$conversationId/messages', body: {
        'text': text.trim(),
        'type': typeStr,
        'attachmentUrl': attachmentData,
      });

      final realMsg = _parseMessage(data, true);
      final idx = _messagesMap[conversationId]!.indexWhere((m) => m.id == tempMsg.id);
      if (idx != -1) {
        _messagesMap[conversationId]![idx] = realMsg;
      }
      _notifyMessages(conversationId);
      return realMsg;
    } catch (e) {
      return tempMsg;
    }
  }

  @override
  Future<void> toggleReaction(String conversationId, String messageId, String emoji) async {
    try {
      final msgs = _messagesMap[conversationId];
      if (msgs == null) return;
      final idx = msgs.indexWhere((m) => m.id == messageId);
      if (idx == -1) return;

      final current = List<String>.from(msgs[idx].reactions);
      final hasEmoji = current.contains(emoji);

      if (hasEmoji) {
        current.remove(emoji);
        msgs[idx] = msgs[idx].copyWith(reactions: current);
        _notifyMessages(conversationId);
        await apiClient.delete('/messages/$messageId/reactions/$emoji');
      } else {
        current.add(emoji);
        msgs[idx] = msgs[idx].copyWith(reactions: current);
        _notifyMessages(conversationId);
        await apiClient.post('/messages/$messageId/reactions', body: {'emoji': emoji});
      }
    } catch (_) {}
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1 && _conversations[idx].unreadCount > 0) {
      _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      _notifyConversations();
      await persistence.saveConversations(_conversations);
    }
    try {
      final msgs = _messagesMap[conversationId];
      final lastMsgId = msgs != null && msgs.isNotEmpty ? msgs.last.id : null;
      if (lastMsgId != null) {
        await apiClient.post('/messages/$lastMsgId/read', body: {'conversationId': conversationId});
      }
    } catch (_) {}
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    _conversations.removeWhere((c) => c.id == conversationId);
    _messagesMap.remove(conversationId);
    _notifyConversations();
    await persistence.saveConversations(_conversations);

    try {
      await apiClient.delete('/conversations/$conversationId');
    } catch (_) {}
  }

  @override
  Future<void> togglePinConversation(String conversationId) async {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final nextPinned = !_conversations[idx].isPinned;
      _conversations[idx] = _conversations[idx].copyWith(isPinned: nextPinned);
      _conversations.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      _notifyConversations();
      await persistence.saveConversations(_conversations);

      try {
        await apiClient.patch('/conversations/$conversationId/settings', body: {'isPinned': nextPinned});
      } catch (_) {}
    }
  }

  @override
  Future<void> toggleMuteConversation(String conversationId) async {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final nextMuted = !_conversations[idx].isMuted;
      _conversations[idx] = _conversations[idx].copyWith(isMuted: nextMuted);
      _notifyConversations();
      await persistence.saveConversations(_conversations);

      try {
        await apiClient.patch('/conversations/$conversationId/settings', body: {'isMuted': nextMuted});
      } catch (_) {}
    }
  }

  MessageModel _parseMessage(Map<String, dynamic> raw, bool isOutgoing) {
    AttachmentType attType = AttachmentType.none;
    final typeStr = raw['type'] as String? ?? 'TEXT';
    if (typeStr == 'IMAGE') attType = AttachmentType.image;
    if (typeStr == 'DOCUMENT') attType = AttachmentType.document;
    if (typeStr == 'VOICE_NOTE') attType = AttachmentType.voiceNote;

    final reactionsList = <String>[];
    if (raw['reactions'] is List) {
      for (final r in raw['reactions']) {
        if (r is Map && r['emoji'] != null) {
          reactionsList.add(r['emoji'] as String);
        } else if (r is String) {
          reactionsList.add(r);
        }
      }
    }

    final rawSender = raw['sender'] as Map<String, dynamic>?;
    final senderName = rawSender?['displayName'] ?? (isOutgoing ? 'You' : 'Member');

    return MessageModel(
      id: raw['id'] ?? 'msg_unknown',
      conversationId: raw['conversationId'] ?? '',
      senderId: raw['senderId'] ?? '',
      senderName: senderName,
      text: raw['text'] ?? '',
      timestamp: raw['createdAt'] != null
          ? DateTime.tryParse(raw['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      status: MessageStatus.read,
      isOutgoing: isOutgoing,
      reactions: reactionsList,
      attachmentType: attType,
      attachmentData: raw['attachmentUrl'] ?? raw['attachmentData'],
    );
  }

  void _notifyConversations() {
    _conversationsController.add(List.unmodifiable(_conversations));
  }

  void _notifyMessages(String conversationId) {
    final msgs = _messagesMap[conversationId] ?? [];
    _messageStreamControllers[conversationId]?.add(List.unmodifiable(msgs));
  }

  void dispose() {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _reactionSub?.cancel();
    _conversationsController.close();
    for (final c in _messageStreamControllers.values) {
      c.close();
    }
  }
}
