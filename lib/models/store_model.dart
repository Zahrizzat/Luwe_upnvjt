class StoreModel {
  final String id;
  final int? dbStoreId;
  final int? sellerId;
  final String name;
  final String slug;
  final String description;
  final String faculty;
  final String facultyShort;
  final String organization;
  final List<String> categories;
  final String location;
  final String bannerUrl;
  final String logoUrl;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final String deliveryTimeEstimate;
  final String deliveryLocation;
  final bool isDanusan;
  final bool isVerified;
  final List<String> tags;

  const StoreModel({
    required this.id,
    this.dbStoreId,
    this.sellerId,
    required this.name,
    required this.slug,
    required this.description,
    required this.faculty,
    required this.facultyShort,
    this.organization = '',
    required this.categories,
    required this.location,
    required this.bannerUrl,
    required this.logoUrl,
    this.rating = 4.8,
    this.reviewCount = 50,
    this.isOpen = true,
    this.deliveryTimeEstimate = '10 - 20 mnt',
    this.deliveryLocation = 'Antar ke Seluruh Fakultas & Lab UPNVJT',
    this.isDanusan = false,
    this.isVerified = true,
    this.tags = const ['UPNVJT Terverifikasi', 'Halal'],
  });

  StoreModel copyWith({
    String? id,
    int? dbStoreId,
    int? sellerId,
    String? name,
    String? slug,
    String? description,
    String? faculty,
    String? facultyShort,
    String? organization,
    List<String>? categories,
    String? location,
    String? bannerUrl,
    String? logoUrl,
    double? rating,
    int? reviewCount,
    bool? isOpen,
    String? deliveryTimeEstimate,
    String? deliveryLocation,
    bool? isDanusan,
    bool? isVerified,
    List<String>? tags,
  }) {
    return StoreModel(
      id: id ?? this.id,
      dbStoreId: dbStoreId ?? this.dbStoreId,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      faculty: faculty ?? this.faculty,
      facultyShort: facultyShort ?? this.facultyShort,
      organization: organization ?? this.organization,
      categories: categories ?? this.categories,
      location: location ?? this.location,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isOpen: isOpen ?? this.isOpen,
      deliveryTimeEstimate: deliveryTimeEstimate ?? this.deliveryTimeEstimate,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      isDanusan: isDanusan ?? this.isDanusan,
      isVerified: isVerified ?? this.isVerified,
      tags: tags ?? this.tags,
    );
  }
}
