class PromotionModel {
  final String id;
  final String title;
  final String description;
  final String discountTag;
  final String code;
  final String imageUrl;
  final String merchantName;
  final String validUntil;
  final bool isActive;

  const PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountTag,
    required this.code,
    required this.imageUrl,
    required this.merchantName,
    required this.validUntil,
    this.isActive = true,
  });
}
