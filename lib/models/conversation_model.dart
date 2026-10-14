class ConversationModel {
  final int id;
  final int buyerId;
  final int sellerId;
  final String otherPartyName;
  final String otherPartySubtitle;
  final String otherPartyAvatar;
  final String lastMessage;
  final DateTime lastMessageAt;

  const ConversationModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.otherPartyName,
    required this.otherPartySubtitle,
    required this.otherPartyAvatar,
    required this.lastMessage,
    required this.lastMessageAt,
  });
}
