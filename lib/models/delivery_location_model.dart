class DeliveryLocationModel {
  final int? id;
  final int userId;
  final String title;
  final String areaName;
  final String detailAddress;
  final String? deliveryNote;
  final bool isPrimary;
  final DateTime? createdAt;

  const DeliveryLocationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.areaName,
    required this.detailAddress,
    this.deliveryNote,
    this.isPrimary = false,
    this.createdAt,
  });

  DeliveryLocationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? areaName,
    String? detailAddress,
    String? deliveryNote,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return DeliveryLocationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      areaName: areaName ?? this.areaName,
      detailAddress: detailAddress ?? this.detailAddress,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
