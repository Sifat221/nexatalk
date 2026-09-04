import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'chat_service.dart';
import 'persistence_service.dart';

/// Production Cloud Firestore Chat Service.
/// Provides multi-user real-time messaging, typing indicators, presence, read receipts, and reactions.
class FirestoreChatService implements ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PersistenceService persistence;

  final StreamController<List<ConversationModel>> _conversationsController =
      StreamController<List<ConversationModel>>.broadcast();

  final Map<String, StreamController<List<MessageModel>>> _messageStreamControllers = {};
  final Map<String, List<MessageModel>> _messagesMap = {};
  List<ConversationModel> _conversations = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _conversationsSub;
  StreamSubscription<User?>? _authSub;
  String? _activeListeningUid;
  final Map<String, StreamSubscription?> _messageSubs = {};

  FirestoreChatService({required this.persistence}) {
    // 1. Listen to real Firebase Auth changes to bind conversations listener to currentUser
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        if (_activeListeningUid != user.uid) {
          _activeListeningUid = user.uid;
          _initConversationsListener(user.uid);
        }
      } else {
        _activeListeningUid = null;
        _conversationsSub?.cancel();
        for (final sub in _messageSubs.values) {
          sub?.cancel();
        }
        _messageSubs.clear();
        _messagesMap.clear();
        _conversations = [];
        _conversationsController.add([]);
        persistence.saveConversations([]);
      }
    });

    // 2. If already logged in on startup, start listening immediately
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _activeListeningUid = currentUser.uid;
      _initConversationsListener(currentUser.uid);
    } else {
      _conversations = [];
      Future.microtask(() {
        _conversationsController.add([]);
      });
    }
  }

  String get _currentUserId {
    final fbUid = FirebaseAuth.instance.currentUser?.uid;
    if (fbUid != null && fbUid.isNotEmpty) return fbUid;
    return persistence.getSavedUser()?.id ?? '';
  }

  String get _currentUserName {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null && fbUser.displayName != null && fbUser.displayName!.isNotEmpty) {
      return fbUser.displayName!;
    }
    return persistence.getSavedUser()?.name ?? 'User';
  }

  void _initConversationsListener(String uid) {
    _conversationsSub?.cancel();
    if (uid.isEmpty) {
      _conversations = [];
      _conversationsController.add([]);
      return;
    }

    _conversationsSub = _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
      final convs = snapshot.docs
          .map((doc) => _parseConversation(doc, uid))
          .where((conv) => !_isLegacyDemoConversation(conv))
          .toList();

      // Sort: pinned first, then by updatedAt descending
      convs.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

      _conversations = convs;
      _conversationsController.add(List.unmodifiable(_conversations));
      persistence.saveConversations(_conversations);
    }, onError: (e) {
      if (kDebugMode) {
        print('Firestore conversations listener error: $e');
      }
    });
  }

  bool _isLegacyDemoConversation(ConversationModel conv) {
    final p = conv.participant;
    if (p.id.startsWith('contact_')) return true;
    if (p.id == 'contact_maya' || p.name == 'Maya Chen' || p.email == 'maya.chen@nexatalk.app') {
      return true;
    }
    if (p.name == 'Alex Morgan' && p.email == 'alex.morgan@nexatalk.app' && p.id.startsWith('contact_')) {
      return true;
    }
    return false;
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

    // Emit cached messages if available
    final msgs = _messagesMap[conversationId] ?? [];
    Future.microtask(() {
      _messageStreamControllers[conversationId]?.add(List.unmodifiable(msgs));
    });

    // Subscribe to Firestore subcollection if not already subscribed
    if (_messageSubs[conversationId] == null) {
      _messageSubs[conversationId] = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        final currentUserId = _currentUserId;
        final list = snapshot.docs.map((d) {
          final data = d.data();
          final isOut = (data['senderId'] as String?) == currentUserId;
          return _parseMessageFromMap(d.id, conversationId, data, isOut);
        }).toList();

        _messagesMap[conversationId] = list;
        _messageStreamControllers[conversationId]?.add(List.unmodifiable(list));
      }, onError: (_) {});
    }

    return _messageStreamControllers[conversationId]!.stream;
  }

  @override
  List<MessageModel> getMessages(String conversationId) {
    return List.unmodifiable(_messagesMap[conversationId] ?? []);
  }

  @override
  Future<List<ContactModel>> getContacts() async {
    final currentUserId = _currentUserId;
    try {
      final snapshot = await _firestore.collection('users').get();

      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .where((doc) =>
                doc.id != currentUserId &&
                !doc.id.startsWith('contact_') &&
                doc.data()['email'] != 'maya.chen@nexatalk.app' &&
                doc.data()['name'] != 'Maya Chen')
            .map((doc) {
          final data = doc.data();
          final displayName = data['displayName'] ?? data['name'] ?? 'User';
          final username = data['username'] ?? displayName.toLowerCase().replaceAll(' ', '_');
          return ContactModel(
            id: doc.id,
            name: displayName,
            email: data['email'] ?? '${doc.id}@nexatalk.app',
            phone: data['phone'],
            status: data['status'] ?? data['bio'] ?? 'Available',
            roleOrTag: '@$username',
            isOnline: data['isOnline'] as bool? ?? false,
            lastSeen: data['lastActive'] is Timestamp
                ? (data['lastActive'] as Timestamp).toDate()
                : (data['lastActive'] != null
                    ? DateTime.tryParse(data['lastActive'].toString()) ?? DateTime.now()
                    : DateTime.now()),
            avatarGradientIndex: (doc.id.hashCode.abs() % 4 + 1).toString(),
          );
        }).toList();

        return list;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore getContacts error: $e');
      }
    }

    return [];
  }

  @override
  Future<ConversationModel> getOrCreateConversation(ContactModel contact) async {
    final currentUserId = _currentUserId;
    final currentUser = persistence.getSavedUser();

    // 1. Search existing conversation locally
    final existingIdx = _conversations.indexWhere((c) => c.participant.id == contact.id);
    if (existingIdx != -1) {
      return _conversations[existingIdx];
    }

    // 2. Search existing in Firestore
    final query = await _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: currentUserId)
        .get();

    for (final doc in query.docs) {
      final List<dynamic> pIds = doc.data()['participantIds'] ?? [];
      if (pIds.contains(contact.id)) {
        return _parseConversation(doc);
      }
    }

    // 3. Create new conversation document in Firestore
    final convRef = _firestore.collection('conversations').doc();
    final convId = convRef.id;

    final myParticipantData = {
      'id': currentUserId,
      'name': currentUser?.name ?? 'Alex Morgan',
      'email': currentUser?.email ?? 'alex@nexatalk.app',
      'roleOrTag': '@${currentUser?.username ?? 'alex'}',
      'status': currentUser?.bio ?? 'Available',
      'isOnline': true,
    };

    final contactParticipantData = {
      'id': contact.id,
      'name': contact.name,
      'email': contact.email,
      'roleOrTag': contact.roleOrTag,
      'status': contact.status,
      'isOnline': contact.isOnline,
    };

    final newConvData = {
      'id': convId,
      'participantIds': [currentUserId, contact.id],
      'participantMap': {
        currentUserId: myParticipantData,
        contact.id: contactParticipantData,
      },
      'lastMessage': null,
      'unreadCounts': {
        currentUserId: 0,
        contact.id: 0,
      },
      'pinned': {
        currentUserId: false,
        contact.id: false,
      },
      'muted': {
        currentUserId: false,
        contact.id: false,
      },
      'typing': {
        currentUserId: false,
        contact.id: false,
      },
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await convRef.set(newConvData);

    final newConv = ConversationModel(
      id: convId,
      participant: contact,
      lastMessage: null,
      unreadCount: 0,
      updatedAt: DateTime.now(),
      isTyping: false,
    );

    _conversations.insert(0, newConv);
    _conversationsController.add(List.unmodifiable(_conversations));
    persistence.saveConversations(_conversations);
    return newConv;
  }

  @override
  Future<ConversationModel> createGroupConversation({
    required String title,
    required List<ContactModel> participants,
  }) async {
    final currentUserId = _currentUserId;
    final currentUser = persistence.getSavedUser();
    final allParticipantIds = [currentUserId, ...participants.map((p) => p.id)];

    final convRef = _firestore.collection('conversations').doc();
    final convId = convRef.id;

    final participantMap = <String, dynamic>{
      currentUserId: {
        'id': currentUserId,
        'name': currentUser?.name ?? 'You',
        'email': currentUser?.email ?? 'you@nexatalk.app',
        'roleOrTag': '@${currentUser?.username ?? 'you'}',
        'status': 'Available',
        'isOnline': true,
      }
    };

    final unreadMap = <String, int>{currentUserId: 0};
    final pinnedMap = <String, bool>{currentUserId: false};
    final mutedMap = <String, bool>{currentUserId: false};
    final typingMap = <String, bool>{currentUserId: false};

    for (final p in participants) {
      participantMap[p.id] = {
        'id': p.id,
        'name': p.name,
        'email': p.email,
        'roleOrTag': p.roleOrTag,
        'status': p.status,
        'isOnline': p.isOnline,
      };
      unreadMap[p.id] = 0;
      pinnedMap[p.id] = false;
      mutedMap[p.id] = false;
      typingMap[p.id] = false;
    }

    final newConvData = {
      'id': convId,
      'isGroup': true,
      'title': title,
      'participantIds': allParticipantIds,
      'participantMap': participantMap,
      'lastMessage': null,
      'unreadCounts': unreadMap,
      'pinned': pinnedMap,
      'muted': mutedMap,
      'typing': typingMap,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await convRef.set(newConvData);

    final groupContact = ContactModel(
      id: 'grp_$convId',
      name: title,
      email: '$convId@group.nexatalk.app',
      status: '${allParticipantIds.length} members',
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
    persistence.saveConversations(_conversations);
    return newConv;
  }

  @override
  Future<MessageModel> sendMessage(
    String conversationId,
    String text, {
    AttachmentType attachmentType = AttachmentType.none,
    String? attachmentData,
  }) async {
    final currentUserId = _currentUserId;
    final currentUserName = _currentUserName;
    final now = DateTime.now();

    final msgRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      id: msgRef.id,
      conversationId: conversationId,
      senderId: currentUserId,
      senderName: currentUserName,
      text: text.trim(),
      timestamp: now,
      status: MessageStatus.sent,
      isOutgoing: true,
      attachmentType: attachmentType,
      attachmentData: attachmentData,
      reactions: [],
    );

    // Optimistically update local message list
    if (!_messagesMap.containsKey(conversationId)) {
      _messagesMap[conversationId] = [];
    }
    _messagesMap[conversationId]!.add(message);
    _messageStreamControllers[conversationId]?.add(List.unmodifiable(_messagesMap[conversationId]!));

    // Prepare Firestore batch write
    final msgData = {
      'id': msgRef.id,
      'conversationId': conversationId,
      'senderId': currentUserId,
      'senderName': currentUserName,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
      'attachmentType': attachmentType.name,
      'attachmentData': attachmentData,
      'reactions': [],
      'readBy': [currentUserId],
    };

    final convRef = _firestore.collection('conversations').doc(conversationId);

    // Find recipient to increment their unread count
    final convDoc = await convRef.get();
    final Map<String, dynamic> unreadUpdates = {};
    if (convDoc.exists) {
      final List<dynamic> pIds = convDoc.data()?['participantIds'] ?? [];
      for (final p in pIds) {
        if (p != currentUserId) {
          unreadUpdates['unreadCounts.$p'] = FieldValue.increment(1);
        }
      }
    }

    final batch = _firestore.batch();
    batch.set(msgRef, msgData);
    batch.update(convRef, {
      'lastMessage': msgData,
      'updatedAt': FieldValue.serverTimestamp(),
      'typing.$currentUserId': false,
      ...unreadUpdates,
    });

    await batch.commit();
    return message;
  }

  /// Sets typing indicator state for current user in conversation.
  @override
  Future<void> setTyping(String conversationId, bool isTyping) async {
    final currentUserId = _currentUserId;
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'typing.$currentUserId': isTyping,
      });
    } catch (_) {}
  }

  @override
  Future<void> toggleReaction(String conversationId, String messageId, String emoji) async {
    try {
      final msgRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId);

      final doc = await msgRef.get();
      if (!doc.exists) return;

      final List<dynamic> currentReactions = doc.data()?['reactions'] ?? [];
      if (currentReactions.contains(emoji)) {
        await msgRef.update({
          'reactions': FieldValue.arrayRemove([emoji]),
        });
      } else {
        await msgRef.update({
          'reactions': FieldValue.arrayUnion([emoji]),
        });
      }
    } catch (_) {}
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    final currentUserId = _currentUserId;

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1 && _conversations[idx].unreadCount > 0) {
      _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      _conversationsController.add(List.unmodifiable(_conversations));
      persistence.saveConversations(_conversations);
    }

    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.$currentUserId': 0,
      });
    } catch (_) {}
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    _conversations.removeWhere((c) => c.id == conversationId);
    _messagesMap.remove(conversationId);
    _conversationsController.add(List.unmodifiable(_conversations));
    persistence.saveConversations(_conversations);

    try {
      await _firestore.collection('conversations').doc(conversationId).delete();
    } catch (_) {}
  }

  @override
  Future<void> togglePinConversation(String conversationId) async {
    final currentUserId = _currentUserId;
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final nextPinned = !_conversations[idx].isPinned;
      _conversations[idx] = _conversations[idx].copyWith(isPinned: nextPinned);
      _conversations.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      _conversationsController.add(List.unmodifiable(_conversations));
      persistence.saveConversations(_conversations);

      try {
        await _firestore.collection('conversations').doc(conversationId).update({
          'pinned.$currentUserId': nextPinned,
        });
      } catch (_) {}
    }
  }

  @override
  Future<void> toggleMuteConversation(String conversationId) async {
    final currentUserId = _currentUserId;
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final nextMuted = !_conversations[idx].isMuted;
      _conversations[idx] = _conversations[idx].copyWith(isMuted: nextMuted);
      _conversationsController.add(List.unmodifiable(_conversations));
      persistence.saveConversations(_conversations);

      try {
        await _firestore.collection('conversations').doc(conversationId).update({
          'muted.$currentUserId': nextMuted,
        });
      } catch (_) {}
    }
  }

  ConversationModel _parseConversation(DocumentSnapshot<Map<String, dynamic>> doc, [String? currentUid]) {
    final data = doc.data() ?? {};
    final currentUserId = (currentUid != null && currentUid.isNotEmpty) ? currentUid : _currentUserId;

    // Determine other participant
    final participantMap = (data['participantMap'] as Map<String, dynamic>?) ?? {};
    final participantIds = (data['participantIds'] as List<dynamic>?) ?? [];
    String otherUserId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => 'usr_target',
    );

    final bool isGroup = data['isGroup'] == true;
    final String groupTitle = data['title'] as String? ?? 'Group Chat';

    ContactModel contact;
    if (isGroup) {
      contact = ContactModel(
        id: 'grp_${doc.id}',
        name: groupTitle,
        email: '${doc.id}@group.nexatalk.app',
        status: '${participantIds.length} members',
        roleOrTag: 'Group',
        isOnline: true,
        lastSeen: DateTime.now(),
        avatarGradientIndex: (doc.id.hashCode.abs() % 4 + 1).toString(),
      );
    } else {
      final rawP = (participantMap[otherUserId] as Map<String, dynamic>?) ?? {};
      contact = ContactModel(
        id: otherUserId,
        name: rawP['displayName'] ?? rawP['name'] ?? 'User',
        email: rawP['email'] ?? '$otherUserId@nexatalk.app',
        status: rawP['status'] ?? 'Available',
        roleOrTag: rawP['roleOrTag'] ?? '@user',
        isOnline: rawP['isOnline'] as bool? ?? false,
        lastSeen: DateTime.now(),
        avatarGradientIndex: (otherUserId.hashCode.abs() % 4 + 1).toString(),
      );
    }

    // Parse last message
    MessageModel? lastMsg;
    if (data['lastMessage'] != null && data['lastMessage'] is Map) {
      final rawM = data['lastMessage'] as Map<String, dynamic>;
      final isOut = (rawM['senderId'] as String?) == currentUserId;
      lastMsg = _parseMessageFromMap(rawM['id'] ?? 'msg_0', doc.id, rawM, isOut);
    }

    final unreadMap = (data['unreadCounts'] as Map<String, dynamic>?) ?? {};
    final pinnedMap = (data['pinned'] as Map<String, dynamic>?) ?? {};
    final mutedMap = (data['muted'] as Map<String, dynamic>?) ?? {};
    final typingMap = (data['typing'] as Map<String, dynamic>?) ?? {};

    // Check if other participant is typing (either direct or group)
    final isOtherTyping = typingMap.entries.any((e) => e.key != currentUserId && e.value == true);

    DateTime updated = DateTime.now();
    if (data['updatedAt'] is Timestamp) {
      updated = (data['updatedAt'] as Timestamp).toDate();
    }

    return ConversationModel(
      id: doc.id,
      participant: contact,
      lastMessage: lastMsg,
      unreadCount: (unreadMap[currentUserId] as int?) ?? 0,
      isPinned: pinnedMap[currentUserId] as bool? ?? false,
      isMuted: mutedMap[currentUserId] as bool? ?? false,
      updatedAt: updated,
      isTyping: isOtherTyping,
    );
  }

  MessageModel _parseMessageFromMap(
    String id,
    String conversationId,
    Map<String, dynamic> raw,
    bool isOutgoing,
  ) {
    AttachmentType attType = AttachmentType.none;
    final attStr = raw['attachmentType'] as String? ?? 'none';
    if (attStr == 'image') attType = AttachmentType.image;
    if (attStr == 'document') attType = AttachmentType.document;
    if (attStr == 'voiceNote') attType = AttachmentType.voiceNote;

    final reactionsList = <String>[];
    if (raw['reactions'] is List) {
      for (final r in raw['reactions']) {
        if (r is String) reactionsList.add(r);
      }
    }

    DateTime timestamp = DateTime.now();
    if (raw['timestamp'] is Timestamp) {
      timestamp = (raw['timestamp'] as Timestamp).toDate();
    } else if (raw['timestamp'] != null) {
      timestamp = DateTime.tryParse(raw['timestamp'].toString()) ?? DateTime.now();
    }

    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: raw['senderId'] ?? '',
      senderName: raw['senderName'] ?? (isOutgoing ? 'You' : 'Member'),
      text: raw['text'] ?? '',
      timestamp: timestamp,
      status: MessageStatus.read,
      isOutgoing: isOutgoing,
      reactions: reactionsList,
      attachmentType: attType,
      attachmentData: raw['attachmentData'],
    );
  }

  @override
  Future<List<ContactModel>> searchUsers(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return getContacts();

    final currentUserId = _currentUserId;
    try {
      final snapshot = await _firestore.collection('users').limit(50).get();

      return snapshot.docs
          .where((doc) =>
              doc.id != currentUserId &&
              !doc.id.startsWith('contact_') &&
              doc.data()['email'] != 'maya.chen@nexatalk.app' &&
              doc.data()['name'] != 'Maya Chen')
          .map((doc) {
            final data = doc.data();
            final displayName = data['displayName'] ?? data['name'] ?? 'User';
            final username = data['username'] ?? displayName.toLowerCase().replaceAll(' ', '_');
            return ContactModel(
              id: doc.id,
              name: displayName,
              email: data['email'] ?? '${doc.id}@nexatalk.app',
              phone: data['phone'],
              status: data['status'] ?? data['bio'] ?? 'Available',
              roleOrTag: '@$username',
              isOnline: data['isOnline'] as bool? ?? false,
              lastSeen: data['lastActive'] is Timestamp
                  ? (data['lastActive'] as Timestamp).toDate()
                  : DateTime.now(),
              avatarGradientIndex: (doc.id.hashCode.abs() % 4 + 1).toString(),
            );
          })
          .where((contact) =>
              contact.name.toLowerCase().contains(cleanQuery) ||
              contact.roleOrTag.toLowerCase().contains(cleanQuery) ||
              contact.email.toLowerCase().contains(cleanQuery))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Firestore searchUsers error: $e');
      }
      return [];
    }
  }

  void dispose() {
    _authSub?.cancel();
    _conversationsSub?.cancel();
    for (final sub in _messageSubs.values) {
      sub?.cancel();
    }
    _conversationsController.close();
    for (final c in _messageStreamControllers.values) {
      c.close();
    }
  }
}
