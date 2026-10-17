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
  String _selectedStatusFilter = 'Menunggu Konfirmasi';
  bool _isProcessingAction = false;

  final List<String> _statusTabs = const [
    'Menunggu Konfirmasi',
    'Siap Diambil / Diantar',
    'Selesai',
  ];

  Future<void> _handleConfirmOrder(OrderModel order) async {
    if (_isProcessingAction) return;
    setState(() => _isProcessingAction = true);
    try {
      final ok = await widget.state.updateSellerOrderStatus(
        order.id,
        OrderStatus.readyForPickupOrDelivery,
      );
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.id} berhasil dikonfirmasi! Stok produk otomatis dikurangi.'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _selectedStatusFilter = 'Siap Diambil / Diantar');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengonfirmasi pesanan. Silakan coba kembali.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('StateError: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _handleRejectOrder(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Pesanan Ini?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Pesanan ${order.id} dari ${order.buyerName} akan dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tolak Pesanan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (_isProcessingAction) return;
    setState(() => _isProcessingAction = true);
    try {
      final ok = await widget.state.updateSellerOrderStatus(order.id, OrderStatus.cancelled);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.id} telah ditolak.'),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _handleCompleteOrder(OrderModel order) async {
    if (_isProcessingAction) return;
    setState(() => _isProcessingAction = true);
    try {
      final ok = await widget.state.updateSellerOrderStatus(order.id, OrderStatus.completed);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.id} telah diselesaikan! Transaksi masuk ke Total Omzet.'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _selectedStatusFilter = 'Selesai');
      }
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final allOrders = state.sellerOrders;

    final filteredOrders = allOrders.where((o) {
      if (_selectedStatusFilter == 'Menunggu Konfirmasi') {
        return o.status == OrderStatus.waitingConfirmation;
      }
      if (_selectedStatusFilter == 'Siap Diambil / Diantar') {
        return o.status == OrderStatus.readyForPickupOrDelivery || o.status == OrderStatus.processing;
      }
      if (_selectedStatusFilter == 'Selesai') {
        return o.status == OrderStatus.completed;
      }
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
            'Konfirmasi pesanan baru, siapkan hidangan, dan selesaikan transaksi mahasiswa UPN "Veteran" Jawa Timur.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          // 3 Status Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusTabs.map((status) {
                final isSel = _selectedStatusFilter == status;
                int count = 0;
                if (status == 'Menunggu Konfirmasi') {
                  count = allOrders.where((o) => o.status == OrderStatus.waitingConfirmation).length;
                } else if (status == 'Siap Diambil / Diantar') {
                  count = allOrders.where((o) => o.status == OrderStatus.readyForPickupOrDelivery || o.status == OrderStatus.processing).length;
                } else if (status == 'Selesai') {
                  count = allOrders.where((o) => o.status == OrderStatus.completed).length;
                }

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(status),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surfaceBorder,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isSel ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedStatusFilter = status);
                    },
                    selectedColor: AppColors.primaryLight,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSel ? AppColors.primary : AppColors.surfaceBorder),
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
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined, size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    Text(
                      'Tidak ada pesanan pada status "$_selectedStatusFilter".',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
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
                                order.buyerName.isNotEmpty ? order.buyerName.substring(0, 1) : 'U',
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
                            color: order.status == OrderStatus.completed
                                ? AppColors.successLight
                                : (order.status == OrderStatus.waitingConfirmation
                                    ? AppColors.pastelYellow
                                    : AppColors.primaryLight),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: order.status == OrderStatus.completed
                                  ? AppColors.successDark
                                  : (order.status == OrderStatus.waitingConfirmation
                                      ? AppColors.terracotta
                                      : AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Destination / Pickup Location Info
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
                                      ? 'Pengambilan Mandiri di Stan Toko:'
                                      : 'Lokasi Pengambilan / Stan Kampus:',
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

                    // Items List without spice levels
                    const Text('Daftar Menu Pesanan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...order.items.map((it) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('•  ${it.quantity}x ${it.item.name}'),
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
                    // Actions: Chat Pembeli & Status Transitions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Chat Pembeli Button
                        OutlinedButton.icon(
                          onPressed: () {
                            widget.state.openOrCreateConversationWithBuyer(
                              buyerId: order.buyerId ?? 1,
                              buyerName: order.buyerName,
                              storeId: order.merchantId,
                              orderId: order.id,
                            );
                          },
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                              if (widget.state.getUnreadCountForOrder(order.id) > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryRed,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                                  ),
                                ),
                            ],
                          ),
                          label: Text(
                            widget.state.getUnreadCountForOrder(order.id) > 0
                                ? 'Chat Pembeli (${widget.state.getUnreadCountForOrder(order.id)})'
                                : 'Chat Pembeli',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryRed,
                            side: const BorderSide(color: AppColors.primaryRed),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        Row(
                          children: [
                            if (order.status == OrderStatus.waitingConfirmation) ...[
                              OutlinedButton(
                                onPressed: _isProcessingAction ? null : () => _handleRejectOrder(order),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                ),
                                child: const Text('Tolak Pesanan'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _isProcessingAction ? null : () => _handleConfirmOrder(order),
                                icon: const Icon(Icons.check_circle_rounded, size: 16),
                                label: const Text('Konfirmasi Pesanan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ] else if (order.status == OrderStatus.readyForPickupOrDelivery || order.status == OrderStatus.processing) ...[
                              ElevatedButton.icon(
                                onPressed: _isProcessingAction ? null : () => _handleCompleteOrder(order),
                                icon: const Icon(Icons.task_alt_rounded, size: 16),
                                label: const Text('Selesaikan Pesanan (Masuk Omset)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ] else if (order.status == OrderStatus.completed) ...[
                              const Row(
                                children: [
                                  Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                                  SizedBox(width: 6),
                                  Text(
                                    'Pesanan Selesai • Omzet Tercatat',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.successDark),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
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
