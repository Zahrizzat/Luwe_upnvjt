import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/status_badge.dart';
import 'tarik_saldo_dialog.dart';

class SellerDashboardScreen extends StatelessWidget {
  final AppState state;

  const SellerDashboardScreen({super.key, required this.state});

  String _formatRupiah(int amount) {
    if (amount == 0) return 'Rp 0';
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    final activeOrders = state.sellerOrders
        .where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Merchant Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.storeName.isNotEmpty ? user.storeName : 'Stan Kuliner Kampus',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 10),
                          CampusBadge.verified(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.storeLocation} • Dikelola oleh ${user.name} (NPM ${user.npm})',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                // Button Tarik Saldo in Merchant Banner
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => TarikSaldoDialog(state: state),
                    );
                  },
                  icon: const Icon(Icons.payments_rounded, size: 16),
                  label: const Text('Tarik Saldo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),

                // Open status toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: user.isStoreOpen ? AppColors.secondaryLight : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: user.isStoreOpen ? AppColors.secondary : AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isStoreOpen ? 'Status: Toko Buka' : 'Status: Toko Tutup',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: user.isStoreOpen ? AppColors.secondaryDark : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: user.isStoreOpen,
                        onChanged: (v) => state.toggleStoreStatus(),
                        activeThumbColor: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stat Cards Row
          Row(
            children: [
              Expanded(
                child: _buildOmsetCard(
                  context: context,
                  title: 'Total Omset',
                  value: _formatRupiah(state.sellerTotalOmset),
                  availableBalance: state.sellerAvailableBalance,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Pesanan Aktif',
                  value: '${activeOrders.length} Pesanan',
                  subtitle: 'Butuh diproses segera',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Menu Terdaftar',
                  value: '${state.allRawMenuItems.length} Menu',
                  subtitle: '${state.allRawMenuItems.where((m) => m.isReadyStock).length} Siap Dipesan',
                  icon: Icons.restaurant_menu_rounded,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Rating Toko',
                  value: '4.9 ★',
                  subtitle: 'Dari 148 Mahasiswa',
                  icon: Icons.star_rounded,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Incoming Orders Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pesanan Masuk Perlu Diproses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () => state.setTabIndex(2), // go to seller orders
                child: const Text('Kelola Semua Pesanan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (activeOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Center(
                child: Text('Tidak ada pesanan tertunda saat ini. Siap menerima order baru!'),
              ),
            )
          else
            ...activeOrders.take(2).map((order) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        order.buyerName.substring(0, 1),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                order.buyerName,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 8),
                              Text('•  ${order.id}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tujuan: ${order.destinationLocation} (${order.deliveryMethod == DeliveryMethod.delivery ? "Antar ke Gedung" : "Ambil Sendiri"})',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            '${order.items.length} item • Total: Rp ${order.totalAmount} (${order.paymentMethod == PaymentMethod.qris ? "QRIS Terverifikasi" : "Bayar Tunai"})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (order.status == OrderStatus.waitingConfirmation)
                          ElevatedButton(
                            onPressed: () {
                              state.updateOrderStatus(order.id, OrderStatus.processing);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                            ),
                            child: const Text('Terima & Mulai Masak'),
                          ),
                        if (order.status == OrderStatus.processing)
                          ElevatedButton(
                            onPressed: () {
                              state.updateOrderStatus(order.id, OrderStatus.readyForPickupOrDelivery);
                            },
                            child: const Text('Set: Siap Diambil/Diantar'),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                          tooltip: 'Chat Pembeli',
                          onPressed: () => state.setTabIndex(3),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOmsetCard({
    required BuildContext context,
    required String title,
    required String value,
    required int availableBalance,
    required Color color,
  }) {
    return Container(
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
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance_wallet_rounded, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Saldo: ${_formatRupiah(availableBalance)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryDark, fontWeight: FontWeight.w700),
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => TarikSaldoDialog(state: state),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tarik',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
