enum WithdrawalStatus {
  pending, // Menunggu Diproses
  approved, // Disetujui
  rejected, // Ditolak
  completed, // Selesai
}

class WithdrawalModel {
  final int? id;
  final int storeId;
  final int sellerId;
  final int amount;
  final String paymentMethod;
  final String accountName;
  final String accountNumber;
  final String? notes;
  final WithdrawalStatus status;
  final String? rejectionReason;
  final DateTime requestedAt;
  final DateTime? processedAt;

  const WithdrawalModel({
    this.id,
    required this.storeId,
    required this.sellerId,
    required this.amount,
    required this.paymentMethod,
    required this.accountName,
    required this.accountNumber,
    this.notes,
    this.status = WithdrawalStatus.pending,
    this.rejectionReason,
    required this.requestedAt,
    this.processedAt,
  });

  String get statusText {
    switch (status) {
      case WithdrawalStatus.pending:
        return 'Menunggu Diproses';
      case WithdrawalStatus.approved:
        return 'Disetujui';
      case WithdrawalStatus.rejected:
        return 'Ditolak';
      case WithdrawalStatus.completed:
        return 'Selesai Ditransfer';
    }
  }

  WithdrawalModel copyWith({
    int? id,
    int? storeId,
    int? sellerId,
    int? amount,
    String? paymentMethod,
    String? accountName,
    String? accountNumber,
    String? notes,
    WithdrawalStatus? status,
    String? rejectionReason,
    DateTime? requestedAt,
    DateTime? processedAt,
  }) {
    return WithdrawalModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      sellerId: sellerId ?? this.sellerId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}
