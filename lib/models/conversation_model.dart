import 'contact_model.dart';
import 'message_model.dart';

/// Represents a chat thread between the current user and a contact.
class ConversationModel {
  final String id;
  final ContactModel participant;
  final MessageModel? lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final DateTime updatedAt;
  final bool isTyping;

  const ConversationModel({
    required this.id,
    required this.participant,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    required this.updatedAt,
    this.isTyping = false,
  });

  ConversationModel copyWith({
    String? id,
    ContactModel? participant,
    MessageModel? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
    DateTime? updatedAt,
    bool? isTyping,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      updatedAt: updatedAt ?? this.updatedAt,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant': participant.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'isMuted': isMuted,
      'updatedAt': updatedAt.toIso8601String(),
      'isTyping': isTyping,
    };
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String? ?? 'conv_0',
      participant: ContactModel.fromJson(json['participant'] as Map<String, dynamic>? ?? {}),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }
}
