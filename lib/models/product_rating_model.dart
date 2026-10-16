class ProductRatingModel {
  final String id;
  final String userId;
  final int? dbUserId;
  final String userName;
  final String? userAvatar;
  final String? userFaculty;
  final String productId;
  final int? dbProductId;
  final String productName;
  final String storeId;
  final int? dbStoreId;
  final String orderCode;
  final int stars; // 1 - 5
  final String reviewText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductRatingModel({
    required this.id,
    required this.userId,
    this.dbUserId,
    required this.userName,
    this.userAvatar,
    this.userFaculty,
    required this.productId,
    this.dbProductId,
    required this.productName,
    required this.storeId,
    this.dbStoreId,
    required this.orderCode,
    required this.stars,
    required this.reviewText,
    required this.createdAt,
    this.updatedAt,
  });

  ProductRatingModel copyWith({
    String? id,
    String? userId,
    int? dbUserId,
    String? userName,
    String? userAvatar,
    String? userFaculty,
    String? productId,
    int? dbProductId,
    String? productName,
    String? storeId,
    int? dbStoreId,
    String? orderCode,
    int? stars,
    String? reviewText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductRatingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dbUserId: dbUserId ?? this.dbUserId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userFaculty: userFaculty ?? this.userFaculty,
      productId: productId ?? this.productId,
      dbProductId: dbProductId ?? this.dbProductId,
      productName: productName ?? this.productName,
      storeId: storeId ?? this.storeId,
      dbStoreId: dbStoreId ?? this.dbStoreId,
      orderCode: orderCode ?? this.orderCode,
      stars: stars ?? this.stars,
      reviewText: reviewText ?? this.reviewText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
