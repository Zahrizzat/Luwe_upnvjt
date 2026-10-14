class ChatMessageModel {
  final String id;
  final int? dbMessageId;
  final int? conversationId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  const ChatMessageModel({
    required this.id,
    this.dbMessageId,
    this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });
}
