class ConversationModel {
  final int id;
  final int buyerId;
  final int sellerId;
  final String storeId;
  final String storeName;
  final String buyerName;
  final String otherPartyName;
  final String otherPartySubtitle;
  final String otherPartyAvatar;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String? orderId;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.storeId = '',
    this.storeName = '',
    this.buyerName = '',
    required this.otherPartyName,
    required this.otherPartySubtitle,
    required this.otherPartyAvatar,
    required this.lastMessage,
    required this.lastMessageAt,
    this.orderId,
    this.unreadCount = 0,
  });

  ConversationModel copyWith({
    int? id,
    int? buyerId,
    int? sellerId,
    String? storeId,
    String? storeName,
    String? buyerName,
    String? otherPartyName,
    String? otherPartySubtitle,
    String? otherPartyAvatar,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? orderId,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      buyerName: buyerName ?? this.buyerName,
      otherPartyName: otherPartyName ?? this.otherPartyName,
      otherPartySubtitle: otherPartySubtitle ?? this.otherPartySubtitle,
      otherPartyAvatar: otherPartyAvatar ?? this.otherPartyAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      orderId: orderId ?? this.orderId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
