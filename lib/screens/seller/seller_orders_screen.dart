import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state.dart';

class SellerOrdersScreen extends StatefulWidget {
  final AppState state;

  const SellerOrdersScreen({super.key, required this.state});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  String _selectedStatusFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final allOrders = state.sellerOrders;

    final filteredOrders = allOrders.where((o) {
      if (_selectedStatusFilter == 'Semua') return true;
      if (_selectedStatusFilter == 'Menunggu') return o.status == OrderStatus.waitingConfirmation;
      if (_selectedStatusFilter == 'Diproses') return o.status == OrderStatus.processing;
      if (_selectedStatusFilter == 'Siap Diantar') return o.status == OrderStatus.readyForPickupOrDelivery;
      if (_selectedStatusFilter == 'Selesai') return o.status == OrderStatus.completed;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Kelola Pesanan Masuk',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Terima pesanan mahasiswa, perbarui proses memasak, dan koordinasikan pengantaran ke gedung kuliah.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Status Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Semua', 'Menunggu', 'Diproses', 'Siap Diantar', 'Selesai'].map((status) {
                final isSel = _selectedStatusFilter == status;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedStatusFilter = status);
                    },
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Orders List
          if (filteredOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Center(child: Text('Tidak ada pesanan pada kategori ini.')),
            )
          else
            ...filteredOrders.map((order) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                order.buyerName.substring(0, 1),
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.buyerName,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'NPM: ${order.buyerNpm} • Telp: ${order.buyerPhone}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.statusText,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Destination Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            order.deliveryMethod == DeliveryMethod.pickup
                                ? Icons.storefront_rounded
                                : Icons.place_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.deliveryMethod == DeliveryMethod.pickup
                                      ? 'Ambil Sendiri di Kantin'
                                      : 'Antar ke Gedung Kuliah UPN:',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  order.destinationLocation,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            order.paymentMethod == PaymentMethod.qris
                                ? 'QRIS: ${order.paymentStatus}'
                                : 'Tunai: ${order.paymentStatus}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: order.paymentMethod == PaymentMethod.qris
                                  ? const Color(0xFF0284C7)
                                  : AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Items
                    const Text('Daftar Menu Pesanan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...order.items.map((it) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('•  ${it.quantity}x ${it.item.name} (${it.selectedSpiceLevel})'),
                            Text('Rp ${it.subtotal}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      );
                    }),

                    // Transparent Financial Snapshot for Seller
                    const SizedBox(height: 8),
                    Container(
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
                              const Text('Subtotal Menu:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('Rp ${order.subtotal}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Biaya Layanan LuWe!:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('Rp ${order.campusServiceFee}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Biaya Pengantaran:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text(
                                order.deliveryFee == 0 ? 'Gratis (Rp 0)' : 'Rp ${order.deliveryFee}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          if (order.discount > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Diskon Voucher (${order.voucherCode ?? "UPN"}):', style: const TextStyle(fontSize: 11, color: AppColors.accentOrange, fontWeight: FontWeight.w700)),
                                Text('-Rp ${order.discount}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentOrange)),
                              ],
                            ),
                          ],
                          const Divider(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Transaksi Pembeli:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              Text('Rp ${order.totalAmount}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.pastelYellow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.goldenYellow),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.note_alt_outlined, size: 14, color: AppColors.accentOrange),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Catatan Khusus: "${order.notes}"',
                                style: const TextStyle(fontSize: 11, color: AppColors.accentOrange, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (order.status == OrderStatus.waitingConfirmation) ...[
                          OutlinedButton(
                            onPressed: () => state.updateSellerOrderStatus(order.id, OrderStatus.cancelled),
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Tolak Pesanan'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => state.updateSellerOrderStatus(order.id, OrderStatus.processing),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Terima & Mulai Masak'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          ),
                        ] else if (order.status == OrderStatus.processing) ...[
                          ElevatedButton.icon(
                            onPressed: () => state.updateSellerOrderStatus(order.id, OrderStatus.readyForPickupOrDelivery),
                            icon: const Icon(Icons.delivery_dining_rounded, size: 16),
                            label: Text(
                              order.deliveryMethod == DeliveryMethod.pickup
                                  ? 'Tandai: Siap Diambil di Kantin'
                                  : 'Tandai: Siap Berangkat Antar ke Gedung',
                            ),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                          ),
                        ] else if (order.status == OrderStatus.readyForPickupOrDelivery) ...[
                          ElevatedButton.icon(
                            onPressed: () => state.updateSellerOrderStatus(order.id, OrderStatus.completed),
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: const Text('Selesaikan Transaksi (Masuk Omset)'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
