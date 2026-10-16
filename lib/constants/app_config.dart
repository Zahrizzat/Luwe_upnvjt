import '../models/order_model.dart';

/// Konfigurasi terpusat biaya dan parameter operasional marketplace LuWe!
/// Memastikan biaya layanan, tarif pengantaran, dan voucher dikelola di satu tempat.
class AppConfig {
  AppConfig._();

  /// Biaya layanan sistem terpusat untuk operasional aplikasi LuWe! kampus
  static const int defaultServiceFee = 1000;
  static const String serviceFeeLabel = 'Biaya Layanan LuWe!';

  /// Tarif Pengantaran Kampus UPN "Veteran" Jawa Timur:
  /// - Rp 2.000 untuk pengantaran kurir mahasiswa/danusan antar gedung kuliah UPN
  /// - Rp 0 untuk pengambilan mandiri (pick-up) di stan atau kantin fakultas
  static const int deliveryFeeCampus = 2000;
  static const int pickupFee = 0;

  /// Daftar voucher diskon resmi lingkungan UPN "Veteran" Jawa Timur
  static const Map<String, int> validVouchers = {
    'UPNDIES50': 5000,  // Diskon Rp 5.000 Spesial Dies Natalis UPN
    'LUWEHEMAT': 3000,  // Diskon Rp 3.000 Promo Hemat Mahasiswa Baru
    'DANUSANUPN': 2000, // Diskon Rp 2.000 Dukungan Dana Usaha Mahasiswa
  };

  /// Menghitung biaya pengantaran berdasarkan metode yang dipilih
  static int getDeliveryFee(DeliveryMethod method) {
    switch (method) {
      case DeliveryMethod.delivery:
        return deliveryFeeCampus;
      case DeliveryMethod.pickup:
        return pickupFee;
    }
  }

  /// ==========================================
  /// KONFIGURASI PENARIKAN SALDO PENJUAL
  /// ==========================================

  /// Tarif Pajak Penghasilan / Potongan Resmi
  /// null = belum dikonfigurasi oleh pihak berwenang kampus
  static int? withdrawalTaxRatePercent; // contoh jika ada: 0% / 1%
  static int? fixedTaxFee;
  static String get withdrawalTaxStatus => fixedTaxFee != null || withdrawalTaxRatePercent != null
      ? 'Dikenakan Pajak Resmi'
      : 'Belum dikonfigurasi (Bebas Pajak)';

  /// Biaya Administrasi Perbankan / Kliring (BI-FAST)
  /// null = belum dikonfigurasi resmi (disubsidi operasional LuWe!)
  static int? withdrawalBankAdminFee;
  static String get withdrawalAdminStatus => withdrawalBankAdminFee != null
      ? 'Rp $withdrawalBankAdminFee'
      : 'Belum dikonfigurasi (Bebas Biaya Admin)';

  /// Menghitung estimasi potongan pajak (hanya jika ada aturan resmi)
  static int calculateTaxFee(int grossAmount) {
    if (fixedTaxFee != null) return fixedTaxFee!;
    if (withdrawalTaxRatePercent != null && withdrawalTaxRatePercent! > 0) {
      return (grossAmount * withdrawalTaxRatePercent! / 100).round();
    }
    return 0;
  }

  /// Menghitung estimasi biaya administrasi bank (hanya jika ada ketentuan)
  static int calculateAdminFee(int grossAmount) {
    return withdrawalBankAdminFee ?? 0;
  }

  /// Menghitung nominal bersih = bruto - potongan yang berlaku
  static int calculateNetWithdrawal(int grossAmount) {
    final tax = calculateTaxFee(grossAmount);
    final admin = calculateAdminFee(grossAmount);
    final net = grossAmount - tax - admin;
    return net < 0 ? 0 : net;
  }
}
