import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

/// State controller managing active conversations, search, messages, and responsive layout selection.
class ChatController extends ChangeNotifier {
  final ChatService _chatService;

  List<ConversationModel> _allConversations = [];
  String _searchQuery = '';
  ConversationModel? _selectedConversation;
  List<MessageModel> _activeMessages = [];
  bool _isLoadingMessages = false;

  StreamSubscription<List<ConversationModel>>? _conversationsSub;
  StreamSubscription<List<MessageModel>>? _messagesSub;

  ChatController(this._chatService) {
    _allConversations = _chatService.currentConversations;
    _conversationsSub = _chatService.conversationsStream.listen((convs) {
      _allConversations = convs;

      // Keep selected conversation updated
      if (_selectedConversation != null) {
        final match = convs.where((c) => c.id == _selectedConversation!.id);
        if (match.isNotEmpty) {
          _selectedConversation = match.first;
        }
      }
      notifyListeners();
    });
  }

  List<ConversationModel> get conversations {
    if (_searchQuery.trim().isEmpty) {
      return _allConversations;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _allConversations.where((conv) {
      final nameMatches = conv.participant.name.toLowerCase().contains(query);
      final lastMsgMatches = conv.lastMessage?.text.toLowerCase().contains(query) ?? false;
      return nameMatches || lastMsgMatches;
    }).toList();
  }

  int get totalUnreadCount => _allConversations.fold(0, (sum, c) => sum + c.unreadCount);

  String get searchQuery => _searchQuery;
  ConversationModel? get selectedConversation => _selectedConversation;
  List<MessageModel> get activeMessages => _activeMessages;
  bool get isLoadingMessages => _isLoadingMessages;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void selectConversation(ConversationModel? conversation) {
    _selectedConversation = conversation;
    _messagesSub?.cancel();

    if (conversation != null) {
      _isLoadingMessages = true;
      _activeMessages = _chatService.getMessages(conversation.id);
      _chatService.markConversationAsRead(conversation.id);

      _messagesSub = _chatService.getMessagesStream(conversation.id).listen((msgs) {
        _activeMessages = msgs;
        _isLoadingMessages = false;
        notifyListeners();
      });
    } else {
      _activeMessages = [];
      _isLoadingMessages = false;
    }
    notifyListeners();
  }

  Future<ConversationModel> startChatWithContact(ContactModel contact) async {
    final conversation = await _chatService.getOrCreateConversation(contact);
    selectConversation(conversation);
    return conversation;
  }

  Future<ConversationModel> createGroupChat({
    required String title,
    required List<ContactModel> participants,
  }) async {
    final conversation = await _chatService.createGroupConversation(
      title: title,
      participants: participants,
    );
    selectConversation(conversation);
    return conversation;
  }

  Future<void> sendMessage(
    String text, {
    AttachmentType attachmentType = AttachmentType.none,
    String? attachmentData,
  }) async {
    if (_selectedConversation == null || text.trim().isEmpty) return;

    await _chatService.sendMessage(
      _selectedConversation!.id,
      text.trim(),
      attachmentType: attachmentType,
      attachmentData: attachmentData,
    );
  }

  Future<void> toggleReaction(String messageId, String emoji) async {
    if (_selectedConversation == null) return;
    await _chatService.toggleReaction(_selectedConversation!.id, messageId, emoji);
  }

  Future<void> markAsRead(String conversationId) async {
    await _chatService.markConversationAsRead(conversationId);
  }

  Future<void> togglePin(String conversationId) async {
    await _chatService.togglePinConversation(conversationId);
  }

  Future<void> toggleMute(String conversationId) async {
    await _chatService.toggleMuteConversation(conversationId);
  }

  Future<void> deleteConversation(String conversationId) async {
    if (_selectedConversation?.id == conversationId) {
      _selectedConversation = null;
      _activeMessages = [];
    }
    await _chatService.deleteConversation(conversationId);
  }

  bool _currentTypingState = false;
  Timer? _typingDebounceTimer;

  Future<void> setTyping(bool isTyping) async {
    if (_selectedConversation == null) return;
    final convId = _selectedConversation!.id;

    if (isTyping == _currentTypingState) return;

    _typingDebounceTimer?.cancel();
    if (!isTyping) {
      _currentTypingState = false;
      await _chatService.setTyping(convId, false);
      return;
    }

    _typingDebounceTimer = Timer(const Duration(milliseconds: 250), () async {
      _currentTypingState = true;
      await _chatService.setTyping(convId, true);
    });
  }

  @override
  void dispose() {
    _typingDebounceTimer?.cancel();
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}
