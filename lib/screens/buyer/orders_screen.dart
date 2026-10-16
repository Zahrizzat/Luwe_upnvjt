import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/qris_dialog.dart';
import '../../widgets/rating_dialog.dart';
import '../auth/login_screen.dart';

class OrdersScreen extends StatelessWidget {
  final AppState state;

  const OrdersScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Riwayat Pesanan Memerlukan Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk ke akun Luwe kamu untuk memantau status pesanan makanan aktif dan melihat riwayat transaksi kampusmu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LoginScreen(state: state),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final orders = state.buyerOrders;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riwayat & Lacak Pesanan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daftar pesanan kuliner milik ${state.currentUser.name} (${state.currentUser.npm.isNotEmpty ? "NPM: ${state.currentUser.npm}" : "Akun Pembeli"}).',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => state.refreshOrders(),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'Muat ulang pesanan',
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.goldenYellow),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 16, color: AppColors.accentOrange),
                        const SizedBox(width: 6),
                        Text(
                          '${orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).length} Pesanan Berjalan',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentOrange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (orders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.primary),
                  ),
                  const SizedBox(height: 18),
                  const Text('Kamu belum memiliki pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Pesanan makanan dan minuman kampus yang kamu buat akan tampil di sini secara real-time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => state.setTabIndex(0),
                    icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
                    label: const Text('Jelajahi Produk Kuliner', style: TextStyle(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            )
          else
            ...orders.map((order) => _buildOrderCard(context, order)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.waitingConfirmation:
        statusColor = AppColors.accentOrange;
        statusBg = AppColors.pastelYellow;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case OrderStatus.processing:
        statusColor = const Color(0xFF0284C7);
        statusBg = const Color(0xFFE0F2FE);
        statusIcon = Icons.soup_kitchen_rounded;
        break;
      case OrderStatus.readyForPickupOrDelivery:
        statusColor = AppColors.primaryRed;
        statusBg = AppColors.cream;
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case OrderStatus.completed:
        statusColor = AppColors.success;
        statusBg = AppColors.successLight;
        statusIcon = Icons.check_circle_rounded;
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusBg = AppColors.errorLight;
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Top Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      order.merchantName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '•  ${order.id}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        order.statusText,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order Tracking Stepper (if active order)
          if (order.status != OrderStatus.cancelled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Row(
                children: [
                  _buildStep(
                    title: '1. Dikonfirmasi',
                    isActive: true,
                    isDone: order.status != OrderStatus.waitingConfirmation,
                  ),
                  _buildStepConnector(isDone: order.status != OrderStatus.waitingConfirmation),
                  _buildStep(
                    title: '2. Dimasak',
                    isActive: order.status == OrderStatus.processing ||
                        order.status == OrderStatus.readyForPickupOrDelivery ||
                        order.status == OrderStatus.completed,
                    isDone: order.status == OrderStatus.readyForPickupOrDelivery ||
                        order.status == OrderStatus.completed,
                  ),
                  _buildStepConnector(
                    isDone: order.status == OrderStatus.readyForPickupOrDelivery ||
                        order.status == OrderStatus.completed,
                  ),
                  _buildStep(
                    title: order.deliveryMethod == DeliveryMethod.pickup ? '3. Siap Ambil' : '3. Diantar',
                    isActive: order.status == OrderStatus.readyForPickupOrDelivery ||
                        order.status == OrderStatus.completed,
                    isDone: order.status == OrderStatus.completed,
                  ),
                  _buildStepConnector(isDone: order.status == OrderStatus.completed),
                  _buildStep(
                    title: '4. Selesai',
                    isActive: order.status == OrderStatus.completed,
                    isDone: order.status == OrderStatus.completed,
                  ),
                ],
              ),
            ),

          // Items summary
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((it) {
                  final isCompleted = order.status == OrderStatus.completed;
                  final userRating = isCompleted ? state.getUserRatingForOrderItem(order.id, it.item.id) : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.surfaceBorder),
                                  ),
                                  child: Text(
                                    '${it.quantity}x',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  it.item.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                if (it.selectedSpiceLevel.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${it.selectedSpiceLevel})',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'Rp ${it.subtotal}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        if (isCompleted) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: AppColors.surfaceBorder),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (userRating != null) ...[
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFFDE68A)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${userRating.stars} Bintang',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (userRating.reviewText.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 280),
                                        child: Text(
                                          '"${userRating.reviewText}"',
                                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => RatingDialog(
                                        orderItem: it,
                                        orderCode: order.id,
                                        storeId: it.item.merchantId,
                                        storeName: order.merchantName,
                                        state: state,
                                        existingRating: userRating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_note_rounded, size: 14),
                                  label: const Text('Ubah Penilaian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  'Pesanan telah selesai! Berikan ulasan menu ini:',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => RatingDialog(
                                        orderItem: it,
                                        orderCode: order.id,
                                        storeId: it.item.merchantId,
                                        storeName: order.merchantName,
                                        state: state,
                                        existingRating: null,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.star_rate_rounded, size: 14),
                                  label: const Text('Beri Penilaian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD97706),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const Divider(height: 20),

                // Delivery Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              order.deliveryMethod == DeliveryMethod.pickup
                                  ? Icons.storefront_rounded
                                  : Icons.place_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order.deliveryMethod == DeliveryMethod.pickup
                                  ? 'Ambil Sendiri di Kantin'
                                  : 'Pengantaran Gedung Kampus:',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.destinationLocation,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Pembayaran:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text(
                          'Rp ${order.totalAmount}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Detail button
                    OutlinedButton.icon(
                      onPressed: () => _showOrderDetailDialog(context, order),
                      icon: const Icon(Icons.receipt_long_outlined, size: 14),
                      label: const Text('Detail Pesanan', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (order.paymentMethod == PaymentMethod.qris &&
                        order.status == OrderStatus.waitingConfirmation) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => QrisPaymentDialog(order: order, state: state),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                        label: const Text('Tampilkan QRIS', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                    ],

                    if (order.status == OrderStatus.waitingConfirmation)
                      OutlinedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Batalkan Pesanan?'),
                              content: Text('Apakah kamu yakin ingin membatalkan pesanan ${order.id}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Kembali')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Ya, Batalkan'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final ok = await state.cancelOrder(order.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok ? 'Pesanan berhasil dibatalkan.' : 'Gagal membatalkan pesanan.'),
                                  backgroundColor: ok ? AppColors.primary : AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        child: const Text('Batalkan Pesanan', style: TextStyle(fontSize: 12)),
                      ),

                    if (order.status == OrderStatus.readyForPickupOrDelivery)
                      ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Konfirmasi Pesanan Diterima'),
                              content: const Text('Apakah makanan/minuman sudah kamu terima dalam kondisi baik?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Belum')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Sudah Diterima'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final ok = await state.confirmOrderReceived(order.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok ? 'Pesanan selesai! Selamat menikmati hidangan kampus.' : 'Gagal konfirmasi pesanan.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        child: const Text('Konfirmasi Diterima', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required String title, required bool isActive, required bool isDone}) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.primary
                : (isActive ? AppColors.primaryOrange : AppColors.surfaceMuted),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : AppColors.textLight,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isDone}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isDone ? AppColors.primary : AppColors.surfaceBorder,
      ),
    );
  }

  void _showOrderDetailDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Detail Pesanan #${order.id}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text('Dibuat pada ${_formatDateTime(order.createdAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store info
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order.merchantName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                  const Text('Stan Kuliner Kampus UPN "Veteran" Jawa Timur', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Daftar Produk:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...order.items.map((it) {
                        final isCompleted = order.status == OrderStatus.completed;
                        final userRating = isCompleted ? state.getUserRatingForOrderItem(order.id, it.item.id) : null;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('${it.quantity}x', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(it.item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                        if (it.selectedSpiceLevel.isNotEmpty)
                                          Text(it.selectedSpiceLevel, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  Text('Rp ${it.subtotal}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                ],
                              ),
                              if (isCompleted) ...[
                                const SizedBox(height: 6),
                                const Divider(height: 1, color: AppColors.surfaceBorder),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (userRating != null) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${userRating.stars} Bintang (${userRating.reviewText.isNotEmpty ? userRating.reviewText : "Tanpa ulasan"})',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          showDialog(
                                            context: context,
                                            builder: (dCtx) => RatingDialog(
                                              orderItem: it,
                                              orderCode: order.id,
                                              storeId: it.item.merchantId,
                                              storeName: order.merchantName,
                                              state: state,
                                              existingRating: userRating,
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Ubah Ulasan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                      ),
                                    ] else ...[
                                      const Text(
                                        'Pesanan selesai. Beri rating:',
                                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          showDialog(
                                            context: context,
                                            builder: (dCtx) => RatingDialog(
                                              orderItem: it,
                                              orderCode: order.id,
                                              storeId: it.item.merchantId,
                                              storeName: order.merchantName,
                                              state: state,
                                              existingRating: null,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFD97706),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Beri Rating', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Delivery & Payment Details
                      const Text('Informasi Pengantaran & Pembayaran:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Metode Pemenuhan', order.deliveryMethod == DeliveryMethod.pickup ? 'Ambil di Kantin' : 'Kirim ke Gedung'),
                            const SizedBox(height: 6),
                            _buildDetailRow('Tujuan Pengantaran', order.destinationLocation),
                            if (order.notes != null && order.notes!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _buildDetailRow('Catatan Pembeli', order.notes!),
                            ],
                            const Divider(height: 16),
                            _buildDetailRow('Metode Pembayaran', order.paymentMethod == PaymentMethod.qris ? 'Simulasi QRIS Kampus' : 'Tunai / COD'),
                            const SizedBox(height: 6),
                            _buildDetailRow('Status Pembayaran', order.paymentStatus),
                            const Divider(height: 16),
                            _buildDetailRow('Subtotal Produk', 'Rp ${order.subtotal}'),
                            const SizedBox(height: 6),
                            _buildDetailRow('Biaya Layanan LuWe!', 'Rp ${order.campusServiceFee}'),
                            const SizedBox(height: 6),
                            _buildDetailRow(
                              'Biaya Pengantaran',
                              order.deliveryFee == 0 ? 'Gratis (Rp 0)' : 'Rp ${order.deliveryFee}',
                            ),
                            if (order.discount > 0) ...[
                              const SizedBox(height: 6),
                              _buildDetailRow(
                                'Diskon Voucher (${order.voucherCode ?? "UPN"})',
                                '-Rp ${order.discount}',
                                isDiscount: true,
                              ),
                            ],
                            const Divider(height: 16),
                            _buildDetailRow('Total Pembayaran Akhir', 'Rp ${order.totalAmount}', isBold: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDiscount ? AppColors.accentOrange : AppColors.textMuted,
            fontWeight: isBold ? FontWeight.w800 : (isDiscount ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              color: isDiscount
                  ? AppColors.accentOrange
                  : (isBold ? AppColors.primary : AppColors.textPrimary),
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
