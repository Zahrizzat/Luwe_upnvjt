class ChatMessageModel {
  final String id;
  final int? dbMessageId;
  final int? conversationId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final String? orderId;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    this.dbMessageId,
    this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.orderId,
    this.isRead = false,
  });

  ChatMessageModel copyWith({
    String? id,
    int? dbMessageId,
    int? conversationId,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? timestamp,
    bool? isMe,
    String? orderId,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      dbMessageId: dbMessageId ?? this.dbMessageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
    );
  }
}
