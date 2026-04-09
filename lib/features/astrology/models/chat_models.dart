import 'package:equatable/equatable.dart';

class ChatPartner extends Equatable {
  final String partnerId;
  final String name;
  final String onlineStatus; // "online"
  final bool canAcceptConversation;
  final double ratePerMinute;
  final double rating;

  const ChatPartner({
    required this.partnerId,
    required this.name,
    required this.onlineStatus,
    required this.canAcceptConversation,
    required this.ratePerMinute,
    required this.rating,
  });

  factory ChatPartner.fromJson(Map<String, dynamic> json) {
    return ChatPartner(
      partnerId: json['partnerId'] ?? '',
      name: json['name'] ?? '',
      onlineStatus: json['onlineStatus'] ?? 'offline',
      canAcceptConversation: json['canAcceptConversation'] ?? false,
      ratePerMinute: (json['ratePerMinute'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    partnerId,
    name,
    onlineStatus,
    canAcceptConversation,
    ratePerMinute,
    rating,
  ];
}

class ChatConversation extends Equatable {
  final String conversationId;
  final String? partnerId;
  final String status; // "active", "pending", "ended"
  final String? lastMessage;
  final DateTime? updatedAt;

  const ChatConversation({
    required this.conversationId,
    this.partnerId,
    required this.status,
    this.lastMessage,
    this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      conversationId: json['conversationId'] ?? '',
      partnerId: json['partnerId'],
      status: json['status'] ?? 'pending',
      lastMessage: json['lastMessage'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    conversationId,
    partnerId,
    status,
    lastMessage,
    updatedAt,
  ];
}

class ChatMessage extends Equatable {
  final String messageId;
  final String senderId;
  final String content;
  final String messageType; // "text"
  final DateTime createdAt;
  final bool isRead;
  final bool isDelivered;

  const ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.isRead = false,
    this.isDelivered = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String sender = '';
    if (json['senderId'] is Map) {
      sender = json['senderId']['_id'] ?? '';
    } else if (json['senderId'] is String) {
      sender = json['senderId'] ?? '';
    }

    return ChatMessage(
      messageId: (json['_id'] ?? json['messageId'] ?? '').toString().trim(),
      senderId: sender,
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }

  ChatMessage copyWith({
    String? messageId,
    String? senderId,
    String? content,
    String? messageType,
    DateTime? createdAt,
    bool? isRead,
    bool? isDelivered,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }

  @override
  List<Object?> get props => [
    messageId,
    senderId,
    content,
    messageType,
    createdAt,
    isRead,
    isDelivered,
  ];
}