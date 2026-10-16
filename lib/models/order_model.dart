import 'cart_item_model.dart';

enum OrderStatus {
  waitingConfirmation,
  processing,
  readyForPickupOrDelivery,
  completed,
  cancelled,
}

enum DeliveryMethod {
  pickup, // Ambil di Kantin
  delivery, // Kirim ke Gedung Kampus
}

enum PaymentMethod {
  qris, // Generative QRIS
  cash, // Tunai saat terima
}

class OrderModel {
  final String id;
  final int? dbOrderId;
  final int? buyerId;
  final int? storeId;
  final String buyerName;
  final String buyerNpm;
  final String buyerPhone;
  final String merchantName;
  final List<CartItemModel> items;
  final int subtotal;
  final int campusServiceFee; // Biaya Layanan Kampus LuWe! Rp 1.000
  final int deliveryFee;
  final int discount;
  final String? voucherCode;
  final int totalAmount;
  final DeliveryMethod deliveryMethod;
  final String destinationLocation; // Contoh: Gedung Giri Santoso Lt. 2
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final OrderStatus status;
  final DateTime createdAt;
  final String? notes;
  final String? cancellationReason;

  const OrderModel({
    required this.id,
    this.dbOrderId,
    this.buyerId,
    this.storeId,
    required this.buyerName,
    required this.buyerNpm,
    required this.buyerPhone,
    required this.merchantName,
    required this.items,
    required this.subtotal,
    this.campusServiceFee = 1000,
    this.deliveryFee = 0,
    this.discount = 0,
    this.voucherCode,
    required this.totalAmount,
    required this.deliveryMethod,
    required this.destinationLocation,
    required this.paymentMethod,
    this.paymentStatus = 'Menunggu Pembayaran',
    required this.status,
    required this.createdAt,
    this.notes,
    this.cancellationReason,
  });

  int get serviceFee => campusServiceFee;

  String get statusText {
    switch (status) {
      case OrderStatus.waitingConfirmation:
        return 'Menunggu Konfirmasi';
      case OrderStatus.processing:
        return 'Sedang Diproses';
      case OrderStatus.readyForPickupOrDelivery:
        return deliveryMethod == DeliveryMethod.pickup
            ? 'Siap Diambil di Kantin'
            : 'Siap Diantar ke Gedung';
      case OrderStatus.completed:
        return 'Pesanan Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  bool get canBeCancelledByBuyer => status == OrderStatus.waitingConfirmation;
  bool get canBeConfirmedByBuyer => status == OrderStatus.readyForPickupOrDelivery;

  OrderModel copyWith({
    String? id,
    int? dbOrderId,
    int? buyerId,
    int? storeId,
    String? buyerName,
    String? buyerNpm,
    String? buyerPhone,
    String? merchantName,
    List<CartItemModel>? items,
    int? subtotal,
    int? campusServiceFee,
    int? deliveryFee,
    int? discount,
    String? voucherCode,
    int? totalAmount,
    DeliveryMethod? deliveryMethod,
    String? destinationLocation,
    PaymentMethod? paymentMethod,
    String? paymentStatus,
    OrderStatus? status,
    DateTime? createdAt,
    String? notes,
    String? cancellationReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      dbOrderId: dbOrderId ?? this.dbOrderId,
      buyerId: buyerId ?? this.buyerId,
      storeId: storeId ?? this.storeId,
      buyerName: buyerName ?? this.buyerName,
      buyerNpm: buyerNpm ?? this.buyerNpm,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      merchantName: merchantName ?? this.merchantName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      campusServiceFee: campusServiceFee ?? this.campusServiceFee,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      voucherCode: voucherCode ?? this.voucherCode,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
