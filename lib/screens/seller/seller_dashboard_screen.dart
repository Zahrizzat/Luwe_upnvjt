import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../models/seller_analytics_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/status_badge.dart';
import 'tarik_saldo_dialog.dart';

class SellerDashboardScreen extends StatelessWidget {
  final AppState state;

  const SellerDashboardScreen({super.key, required this.state});

  String _formatDate(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

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
    final activeOrders = state.activeSellerOrders;
    final sellerStore = state.currentSellerStore;
    final sellerStoreId = sellerStore?.id ?? (user.dbStoreId != null ? 'store_${user.dbStoreId}' : 'store_${user.id}');
    final analytics = state.getSellerRatingAnalytics(sellerStoreId);

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
                    color: user.isStoreOpen ? AppColors.successLight : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: user.isStoreOpen ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isStoreOpen ? 'Status: Toko Buka' : 'Status: Toko Tutup',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: user.isStoreOpen ? AppColors.successDark : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: user.isStoreOpen,
                        onChanged: (v) => state.toggleStoreStatus(),
                        activeThumbColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ],
            )          ),
          const SizedBox(height: 20),

          // 1. Financial Breakdown Banner (Pemisahan Omzet, Saldo Tersedia, Sedang Diproses, Selesai)
          _buildFinancialOverviewBanner(context, user),
          const SizedBox(height: 20),

          // Stat Cards Row
          Row(
            children: [
              Expanded(
                child: _buildOmsetCard(
                  context: context,
                  title: 'Total Omzet',
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
                  subtitle: 'Perlu diproses segera',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Produk Aktif',
                  value: '${state.sellerMenuItems.where((m) => m.isReadyStock).length} Produk',
                  subtitle: 'Dari ${state.sellerMenuItems.length} total menu stan',
                  icon: Icons.restaurant_menu_rounded,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Rating Toko',
                  value: analytics.hasRatings
                      ? '${analytics.averageStoreRating!.toStringAsFixed(1)} ★'
                      : 'Belum ada',
                  subtitle: analytics.hasRatings
                      ? 'Dari ${analytics.totalReviews} ulasan pembeli'
                      : 'Belum ada ulasan pembeli',
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
                              backgroundColor: AppColors.primary,
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
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 28),

          // Reputasi Toko & Analitik Rating Mahasiswa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reputasi Toko & Analitik Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Berdasarkan ulasan asli pembeli dan transaksi pesanan yang telah selesai.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      analytics.hasRatings
                          ? 'Akumulasi: ${analytics.averageStoreRating!.toStringAsFixed(1)} / 5.0'
                          : 'Belum ada rating aktif',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 KPI Reputation Cards
          Row(
            children: [
              // 1. Produk Terlaris Kampus
              Expanded(
                child: _buildReputationCard(
                  title: 'Produk Terlaris (Selesai)',
                  value: analytics.hasSales ? analytics.bestSellingProduct!.name : 'Belum ada pesanan',
                  subtitle: analytics.hasSales
                      ? '${analytics.bestSellingCount} porsi sukses terjual'
                      : 'Dihitung dari transaksi berstatus selesai',
                  badgeText: analytics.hasSales ? 'Best Seller' : 'No Data',
                  badgeColor: const Color(0xFF16A34A),
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 14),

              // 2. Rating Tertinggi
              Expanded(
                child: _buildReputationCard(
                  title: 'Rating Produk Tertinggi',
                  value: analytics.highestRatedProduct != null
                      ? analytics.highestRatedProduct!.name
                      : 'Belum ada rating',
                  subtitle: analytics.highestRatedProduct != null
                      ? '${analytics.highestProductRating!.toStringAsFixed(1)} ★ (${state.getProductRatingCount(analytics.highestRatedProduct!.id)} ulasan)'
                      : 'Rating dihitung dari penilaian pembeli',
                  badgeText: analytics.highestRatedProduct != null ? 'Top Rated' : 'Belum Ada',
                  badgeColor: const Color(0xFFD97706),
                  icon: Icons.thumb_up_alt_rounded,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 14),

              // 3. Rating Terendah / Evaluasi
              Expanded(
                child: _buildReputationCard(
                  title: 'Rating Terendah / Evaluasi',
                  value: analytics.lowestRatedProduct != null
                      ? analytics.lowestRatedProduct!.name
                      : 'Belum ada rating',
                  subtitle: analytics.lowestRatedProduct != null
                      ? '${analytics.lowestProductRating!.toStringAsFixed(1)} ★ (${state.getProductRatingCount(analytics.lowestRatedProduct!.id)} ulasan)'
                      : 'Semua menu memiliki ulasan positif',
                  badgeText: analytics.lowestRatedProduct != null ? 'Perlu Pantau' : 'Optimal',
                  badgeColor: analytics.lowestRatedProduct != null ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  icon: Icons.trending_down_rounded,
                  color: const Color(0xFF9333EA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Ulasan Terbaru dari Pembeli
          Container(
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
                        const Icon(Icons.reviews_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Ulasan Terbaru Pembeli (${analytics.totalReviews})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    if (analytics.hasRatings)
                      Text(
                        'Total ${analytics.totalReviews} Penilaian Terverifikasi',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (analytics.recentReviews.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.rate_review_outlined, size: 42, color: AppColors.textLight),
                        SizedBox(height: 10),
                        Text(
                          'Belum ada ulasan untuk stan kuliner Anda',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rating dan ulasan akan bertambah seiring pembeli menyelesaikan pesanan mereka.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  ...analytics.recentReviews.take(5).map((rev) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: rev.userAvatar != null ? NetworkImage(rev.userAvatar!) : null,
                                child: rev.userAvatar == null
                                    ? Text(
                                        rev.userName.isNotEmpty ? rev.userName[0].toUpperCase() : 'U',
                                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          rev.userName,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            rev.productName,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Order #${rev.orderCode} • ${rev.userFaculty ?? "Mahasiswa UPN"}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD97706)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${rev.stars}.0',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(rev.createdAt),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (rev.reviewText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '"${rev.reviewText}"',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Performa Seluruh Menu Produk (Unit Terjual, Omzet Produk, Rating)
          _buildProductPerformanceTable(context, analytics),
        ],
      ),
    );
  }

  Widget _buildReputationCard({
    required String title,
    required String value,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
                  style: const TextStyle(fontSize: 11, color: AppColors.accentOrange, fontWeight: FontWeight.w700),
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

  Widget _buildFinancialOverviewBanner(BuildContext context, UserModel user) {
    final available = state.sellerAvailableBalance;
    final pending = state.sellerPendingWithdrawal;
    final completed = state.sellerCompletedWithdrawal;
    final totalOmset = state.sellerTotalOmset;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.goldenYellow, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Arus Kas & Rekening Stan',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                        'Pemisahan transparan total omzet historis, saldo tertahan proses, dan saldo tersedia',
                        style: TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white12),
          const SizedBox(height: 14),
          Row(
            children: [
              // 1. Total Omzet
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL OMZET HISTORIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white60, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(_formatRupiah(totalOmset), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 2),
                    const Text('Transaksi valid selesai', style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
              ),
              Container(width: 1, height: 44, color: Colors.white24),
              const SizedBox(width: 16),

              // 2. Saldo Tersedia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SALDO TERSEDIA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldenYellow, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(_formatRupiah(available), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldenYellow)),
                    const SizedBox(height: 2),
                    const Text('Bisa langsung ditarik', style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
              ),
              Container(width: 1, height: 44, color: Colors.white24),
              const SizedBox(width: 16),

              // 3. Saldo Sedang Diproses
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SEDANG DIPROSES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.amberYellow, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(_formatRupiah(pending), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.amberYellow)),
                    const SizedBox(height: 2),
                    const Text('Tertahan proses pengajuan', style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
              ),
              Container(width: 1, height: 44, color: Colors.white24),
              const SizedBox(width: 16),

              // 4. Total Penarikan Selesai
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PENARIKAN SELESAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(_formatRupiah(completed), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF38BDF8))),
                    const SizedBox(height: 2),
                    const Text('Sudah dicairkan ke bank', style: TextStyle(fontSize: 10, color: Colors.white54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Verified Bank Account Badge Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 16, color: AppColors.goldenYellow),
                    const SizedBox(width: 8),
                    Text(
                      'Rekening Terverifikasi: ${user.bankName} • ${user.maskedBankAccountNumber} (a.n. ${user.bankAccountHolder.isNotEmpty ? user.bankAccountHolder : user.name})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => TarikSaldoDialog(state: state),
                    );
                  },
                  child: const Text('Kelola / Ajukan Tarik', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformanceTable(BuildContext context, SellerRatingAnalytics analytics) {
    final performances = analytics.productPerformances;

    return Container(
      padding: const EdgeInsets.all(22),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performa Penjualan & Rating Seluruh Menu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Statistik unit terjual pada pesanan valid, kontribusi omzet produk, dan kepuasan pembeli.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${performances.length} Menu Terdata',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (performances.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              alignment: Alignment.center,
              child: const Text('Belum ada menu produk yang terdaftar pada stan toko ini.'),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2.5),
                4: FlexColumnWidth(2.5),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 1.5)),
                  ),
                  children: [
                    _buildTableHeader('Menu Produk'),
                    _buildTableHeader('Status Stok'),
                    _buildTableHeader('Terjual (Unit)'),
                    _buildTableHeader('Omzet Produk'),
                    _buildTableHeader('Rating & Ulasan'),
                  ],
                ),
                // Rows
                ...performances.map((item) {
                  final isReady = item.product.isReadyStock;
                  return TableRow(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 0.8)),
                    ),
                    children: [
                      // Menu Produk
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 44,
                                  height: 44,
                                  color: AppColors.surfaceMuted,
                                  child: const Icon(Icons.fastfood, size: 20, color: AppColors.textMuted),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.product.category} • ${_formatRupiah(item.product.price)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Stok
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isReady ? AppColors.successLight : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isReady ? 'Stok Tersedia' : 'Habis',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isReady ? AppColors.successDark : AppColors.error,
                            ),
                          ),
                        ),
                      ),

                      // Terjual
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(
                          '${item.totalSoldUnits} unit',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),

                      // Omzet Produk
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(
                          _formatRupiah(item.totalRevenue),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),

                      // Rating & Ulasan
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: item.averageRating != null
                            ? Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD97706)),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.averageRating!.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${item.reviewCount} ulasan)',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              )
                            : const Text(
                                'Belum ada rating',
                                style: TextStyle(fontSize: 11, color: AppColors.textLight, fontStyle: FontStyle.italic),
                              ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.3),
      ),
    );
  }
}
