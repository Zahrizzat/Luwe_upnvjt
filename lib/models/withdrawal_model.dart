enum WithdrawalStatus {
  waitingVerification, // Menunggu Verifikasi
  processing,          // Diproses
  completed,           // Selesai
  rejected,            // Ditolak
  pending,             // Alias kompatibilitas
  approved,            // Alias kompatibilitas
}

extension WithdrawalStatusX on WithdrawalStatus {
  String get label {
    switch (this) {
      case WithdrawalStatus.waitingVerification:
      case WithdrawalStatus.pending:
        return 'Menunggu Verifikasi';
      case WithdrawalStatus.processing:
      case WithdrawalStatus.approved:
        return 'Diproses';
      case WithdrawalStatus.completed:
        return 'Selesai';
      case WithdrawalStatus.rejected:
        return 'Ditolak';
    }
  }
}

class WithdrawalModel {
  final int? id;
  final int storeId;
  final int sellerId;
  final int grossAmount;
  final int taxFee;
  final int adminFee;
  final int netAmount;
  final String taxStatus;
  final String adminStatus;
  final String paymentMethod;
  final String accountName;
  final String accountNumber;
  final String? notes;
  final WithdrawalStatus status;
  final String? rejectionReason;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final List<String> auditTrail;

  const WithdrawalModel({
    this.id,
    required this.storeId,
    required this.sellerId,
    required this.grossAmount,
    this.taxFee = 0,
    this.adminFee = 0,
    required this.netAmount,
    this.taxStatus = 'Belum dikonfigurasi (Bebas Pajak)',
    this.adminStatus = 'Belum dikonfigurasi (Bebas Biaya Admin)',
    required this.paymentMethod,
    required this.accountName,
    required this.accountNumber,
    this.notes,
    this.status = WithdrawalStatus.waitingVerification,
    this.rejectionReason,
    required this.requestedAt,
    this.processedAt,
    this.auditTrail = const [],
  });

  /// Kompatibilitas mundur dengan kode yang memanggil `.amount`
  int get amount => grossAmount;

  /// Masked account number untuk keamanan (cth: •••• •••• 4892)
  String get maskedAccountNumber {
    if (accountNumber.isEmpty) return 'Belum terdaftar';
    final clean = accountNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length <= 4) return clean;
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• $last4';
  }

  String get statusText {
    switch (status) {
      case WithdrawalStatus.waitingVerification:
      case WithdrawalStatus.pending:
        return 'Menunggu Verifikasi';
      case WithdrawalStatus.processing:
      case WithdrawalStatus.approved:
        return 'Diproses';
      case WithdrawalStatus.completed:
        return 'Selesai';
      case WithdrawalStatus.rejected:
        return 'Ditolak';
    }
  }

  WithdrawalModel copyWith({
    int? id,
    int? storeId,
    int? sellerId,
    int? grossAmount,
    int? taxFee,
    int? adminFee,
    int? netAmount,
    String? taxStatus,
    String? adminStatus,
    String? paymentMethod,
    String? accountName,
    String? accountNumber,
    String? notes,
    WithdrawalStatus? status,
    String? rejectionReason,
    DateTime? requestedAt,
    DateTime? processedAt,
    List<String>? auditTrail,
  }) {
    return WithdrawalModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      sellerId: sellerId ?? this.sellerId,
      grossAmount: grossAmount ?? this.grossAmount,
      taxFee: taxFee ?? this.taxFee,
      adminFee: adminFee ?? this.adminFee,
      netAmount: netAmount ?? this.netAmount,
      taxStatus: taxStatus ?? this.taxStatus,
      adminStatus: adminStatus ?? this.adminStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      auditTrail: auditTrail ?? this.auditTrail,
    );
  }
}
