enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

enum AttachmentType {
  none,
  image,
  document,
  voiceNote,
}

/// Represents a chat message within a conversation.
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isOutgoing;
  final List<String> reactions;
  final AttachmentType attachmentType;
  final String? attachmentData; // e.g. duration or file name

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.read,
    required this.isOutgoing,
    this.reactions = const [],
    this.attachmentType = AttachmentType.none,
    this.attachmentData,
  });

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isOutgoing,
    List<String>? reactions,
    AttachmentType? attachmentType,
    String? attachmentData,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      reactions: reactions ?? this.reactions,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentData: attachmentData ?? this.attachmentData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'isOutgoing': isOutgoing,
      'reactions': reactions,
      'attachmentType': attachmentType.name,
      'attachmentData': attachmentData,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? 'msg_0',
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'read'),
        orElse: () => MessageStatus.read,
      ),
      isOutgoing: json['isOutgoing'] as bool? ?? false,
      reactions: (json['reactions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      attachmentType: AttachmentType.values.firstWhere(
        (e) => e.name == (json['attachmentType'] as String? ?? 'none'),
        orElse: () => AttachmentType.none,
      ),
      attachmentData: json['attachmentData'] as String?,
    );
  }
}
