import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/order_model.dart';
import '../providers/app_state.dart';
import 'qris_dialog.dart';

/// Dialog Konfirmasi Transaksi Pesanan LuWe! Kampus
/// Menampilkan transparansi rincian biaya:
/// 1. Subtotal produk
/// 2. Biaya layanan LuWe! (terpusat)
/// 3. Biaya pengantaran (antar ke gedung vs ambil sendiri)
/// 4. Diskon voucher (jika digunakan)
/// 5. Total pembayaran akhir
class OrderConfirmationDialog extends StatelessWidget {
  final OrderModel order;
  final AppState state;
  final VoidCallback? onGoToOrders;

  const OrderConfirmationDialog({
    super.key,
    required this.order,
    required this.state,
    this.onGoToOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded, size: 14, color: AppColors.secondary),
                            SizedBox(width: 4),
                            Text(
                              'TRANSAKSI RESMI KAMPUS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondaryDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  children: [
                    // Success Icon Hero
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.check_rounded, size: 36, color: AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pesanan Berhasil Dibuat!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pesanan telah diteruskan ke ${order.merchantName} dan menunggu konfirmasi.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // Order Ticket Header Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KODE TRANSAKSI KAMPUS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    order.id,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: order.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Kode pesanan berhasil disalin!'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded, size: 14),
                                label: const Text('Salin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  side: const BorderSide(color: AppColors.surfaceBorder),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoPill(
                                  icon: Icons.access_time_rounded,
                                  title: 'Status Saat Ini',
                                  value: order.statusText,
                                  color: AppColors.tertiary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildInfoPill(
                                  icon: order.paymentMethod == PaymentMethod.qris
                                      ? Icons.qr_code_2_rounded
                                      : Icons.payments_outlined,
                                  title: 'Metode Bayar',
                                  value: order.paymentMethod == PaymentMethod.qris
                                      ? 'QRIS (Simulasi)'
                                      : 'Tunai di Tempat',
                                  color: order.paymentMethod == PaymentMethod.qris
                                      ? const Color(0xFF0284C7)
                                      : AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                order.deliveryMethod == DeliveryMethod.pickup
                                    ? Icons.storefront_rounded
                                    : Icons.local_shipping_outlined,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  order.deliveryMethod == DeliveryMethod.pickup
                                      ? 'Ambil Sendiri: ${order.destinationLocation}'
                                      : 'Antar ke: ${order.destinationLocation}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ordered Items List
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Menu Dipesan (${order.items.fold(0, (sum, i) => sum + i.quantity)} porsi):',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        children: order.items.map((it) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${it.quantity}x',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        it.item.name,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                      ),
                                      if (it.selectedSpiceLevel.isNotEmpty)
                                        Text(
                                          it.selectedSpiceLevel,
                                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Rp ${it.subtotal}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Transparent Financial Breakdown (5 Core Components)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          const Text(
                            'Rincian Pembayaran Transparan:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        children: [
                          _buildCostRow('Subtotal Produk', 'Rp ${order.subtotal}'),
                          const SizedBox(height: 6),
                          _buildCostRow(
                            'Biaya Layanan LuWe!',
                            'Rp ${order.campusServiceFee}',
                            subtitle: 'Dikelola terpusat untuk sistem kampus',
                          ),
                          const SizedBox(height: 6),
                          _buildCostRow(
                            'Biaya Pengantaran',
                            order.deliveryFee == 0 ? 'Gratis (Rp 0)' : 'Rp ${order.deliveryFee}',
                            subtitle: order.deliveryMethod == DeliveryMethod.pickup
                                ? 'Ambil mandiri di kantin/stan'
                                : 'Kurir mahasiswa antar gedung',
                          ),
                          if (order.discount > 0) ...[
                            const SizedBox(height: 6),
                            _buildCostRow(
                              'Diskon Voucher (${order.voucherCode ?? "UPN"})',
                              '-Rp ${order.discount}',
                              isDiscount: true,
                            ),
                          ],
                          const Divider(height: 16, color: Color(0xFFFCD34D)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Pembayaran Akhir:',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    'Telah divalidasi sistem backend',
                                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              Text(
                                'Rp ${order.totalAmount}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Payment Mechanism Transparency Notice
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            order.paymentMethod == PaymentMethod.qris
                                ? Icons.info_outline_rounded
                                : Icons.handshake_outlined,
                            size: 16,
                            color: const Color(0xFF475569),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.paymentMethod == PaymentMethod.qris
                                  ? 'Catatan QRIS: Pembayaran ini menggunakan simulasi internal LuWe! untuk pengujian kampus UPNVJ. Belum terhubung ke gateway perbankan riil.'
                                  : 'Catatan Tunai: Pembayaran dilakukan secara langsung (COD) saat makanan diserahterimakan di lokasi.',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF475569), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Column(
                children: [
                  if (order.paymentMethod == PaymentMethod.qris &&
                      order.status == OrderStatus.waitingConfirmation) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (ctx) => QrisPaymentDialog(order: order, state: state),
                          );
                        },
                        icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                        label: Text('Buka Simulasi QRIS (Rp ${order.totalAmount})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Lanjut Belanja', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onGoToOrders?.call();
                          },
                          icon: const Icon(Icons.receipt_long_rounded, size: 16),
                          label: const Text('Pesanan Saya'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                Text(
                  value,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String value, {String? subtitle, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isDiscount ? FontWeight.w700 : FontWeight.w600,
                color: isDiscount ? AppColors.secondaryDark : AppColors.textSecondary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDiscount ? AppColors.secondaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
