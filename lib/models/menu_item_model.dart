class MenuItemModel {
  final String id;
  final int? dbProductId;
  final String merchantId;
  final String merchantName;
  final String merchantLocation;
  final String name;
  final String description;
  final int price;
  final int? originalPrice;
  final String imageUrl;
  final String category; // 'Makanan Utama', 'Minuman Segar', 'Cemilan & Snack', 'Paket Hemat'
  final double rating;
  final int reviewCount;
  final bool isPromo;
  final bool isReadyStock;
  final int stockCount;
  final int soldCount;
  final List<String> tags; // ['Halal', 'UPNVJT Verified', 'Pedas Mantap', etc.]
  final List<String> availableSpiceLevels;

  const MenuItemModel({
    required this.id,
    this.dbProductId,
    required this.merchantId,
    required this.merchantName,
    required this.merchantLocation,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    this.rating = 4.8,
    this.reviewCount = 35,
    this.isPromo = false,
    this.isReadyStock = true,
    this.stockCount = 20,
    this.soldCount = 85,
    this.tags = const ['Halal', 'UPNVJT Terverifikasi'],
    this.availableSpiceLevels = const ['Level 0 (Tidak Pedas)', 'Level 1 (Sedang)', 'Level 2 (Pedas)', 'Level 3 (Ekstra Pedas)'],
  });

  MenuItemModel copyWith({
    String? id,
    int? dbProductId,
    String? merchantId,
    String? merchantName,
    String? merchantLocation,
    String? name,
    String? description,
    int? price,
    int? originalPrice,
    String? imageUrl,
    String? category,
    double? rating,
    int? reviewCount,
    bool? isPromo,
    bool? isReadyStock,
    int? stockCount,
    int? soldCount,
    List<String>? tags,
    List<String>? availableSpiceLevels,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      dbProductId: dbProductId ?? this.dbProductId,
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      merchantLocation: merchantLocation ?? this.merchantLocation,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isPromo: isPromo ?? this.isPromo,
      isReadyStock: isReadyStock ?? this.isReadyStock,
      stockCount: stockCount ?? this.stockCount,
      soldCount: soldCount ?? this.soldCount,
      tags: tags ?? this.tags,
      availableSpiceLevels: availableSpiceLevels ?? this.availableSpiceLevels,
    );
  }
}
