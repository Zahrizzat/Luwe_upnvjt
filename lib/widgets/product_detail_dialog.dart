import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/menu_item_model.dart';
import '../models/product_rating_model.dart';
import '../providers/app_state.dart';
import 'auth_guard_dialog.dart';
import 'status_badge.dart';

class ProductDetailDialog extends StatefulWidget {
  final MenuItemModel item;
  final AppState state;

  const ProductDetailDialog({
    super.key,
    required this.item,
    required this.state,
  });

  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  int _quantity = 1;
  late String _selectedSpiceLevel;
  final TextEditingController _noteController = TextEditingController();
  int _activeTab = 0; // 0 = Pesan & Varian, 1 = Ulasan Pembeli

  @override
  void initState() {
    super.initState();
    _selectedSpiceLevel = widget.item.availableSpiceLevels.isNotEmpty
        ? widget.item.availableSpiceLevels[1]
        : 'Level 1 (Sedang)';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isStoreOpen = widget.state.isItemStoreOpen(item);
    final canAddToCart = isStoreOpen && item.isReadyStock && item.stockCount > 0;
    final totalPrice = item.price * _quantity;
    final avgRating = widget.state.getProductAverageRating(item.id);
    final reviewCount = widget.state.getProductRatingCount(item.id);
    final reviews = widget.state.getProductReviews(item.id);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 690),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Image Section
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        color: AppColors.surfaceMuted,
                        child: const Center(child: Icon(Icons.fastfood, size: 64, color: AppColors.textLight)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CampusBadge.verified(),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            avgRating != null ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 16,
                            color: avgRating != null ? AppColors.tertiary : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            avgRating != null
                                ? '${avgRating.toStringAsFixed(1)} ($reviewCount ulasan)'
                                : 'Belum ada ulasan',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            '•  ${item.soldCount} terjual di kampus',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Content Section
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header & Close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Merchant info
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.merchantName,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  item.merchantLocation,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          CampusBadge.halal(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tab Segmented Selector (Pesan vs Ulasan)
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _activeTab == 0 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _activeTab == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Pesan Menu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _activeTab == 0 ? FontWeight.w800 : FontWeight.w600,
                                      color: _activeTab == 0 ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _activeTab == 1 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _activeTab == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Ulasan Pembeli',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: _activeTab == 1 ? FontWeight.w800 : FontWeight.w600,
                                          color: _activeTab == 1 ? AppColors.primary : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: _activeTab == 1
                                              ? AppColors.primary.withValues(alpha: 0.1)
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$reviewCount',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: _activeTab == 1 ? AppColors.primary : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TAB 0: ORDER & CONFIGURATION
                    if (_activeTab == 0) ...[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isStoreOpen)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFCA5A5)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.storefront_rounded, size: 18, color: Color(0xFFDC2626)),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Stan Kuliner ini sedang tutup. Pemesanan menu tidak dapat dilakukan saat ini.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF991B1B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                item.description,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                              ),
                              const Divider(height: 20),

                              // Spice level selector
                              const Text(
                                'Pilih Tingkat Kepedasan / Varian:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: item.availableSpiceLevels.map((lvl) {
                                  final isSelected = _selectedSpiceLevel == lvl;
                                  return ChoiceChip(
                                    label: Text(lvl),
                                    selected: isSelected,
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedSpiceLevel = lvl);
                                    },
                                    selectedColor: AppColors.primaryLight,
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // Notes input
                              const Text(
                                'Catatan Pesanan Khusus (Opsional):',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _noteController,
                                style: const TextStyle(fontSize: 12),
                                decoration: const InputDecoration(
                                  hintText: 'Contoh: Jangan terlalu asin, sambal dipisah, sendok plastik...',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Quantity and CTA
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton.outlined(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: (item.isReadyStock && item.stockCount > 0 && _quantity > 1)
                                      ? () => setState(() => _quantity--)
                                      : null,
                                  style: IconButton.styleFrom(
                                    padding: const EdgeInsets.all(6),
                                    minimumSize: Size.zero,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    '$_quantity',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                IconButton.outlined(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: canAddToCart
                                      ? () => setState(() => _quantity++)
                                      : null,
                                  style: IconButton.styleFrom(
                                    padding: const EdgeInsets.all(6),
                                    minimumSize: Size.zero,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: canAddToCart
                                  ? () {
                                      if (!widget.state.isLoggedIn) {
                                        AuthGuardDialog.requireAuth(
                                          context,
                                          widget.state,
                                          message: 'Masuk ke akun Luwe kamu untuk menambahkan ${item.name} ke keranjang dan melanjutkan pesanan.',
                                          onAuthenticated: () {
                                            final ok = widget.state.addToCart(
                                              item,
                                              quantity: _quantity,
                                              level: _selectedSpiceLevel,
                                              note: _noteController.text,
                                            );
                                            if (ok) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Ditambahkan ke keranjang: ${item.name} ($_quantity porsi)'),
                                                  backgroundColor: AppColors.primary,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      } else {
                                        final ok = widget.state.addToCart(
                                          item,
                                          quantity: _quantity,
                                          level: _selectedSpiceLevel,
                                          note: _noteController.text,
                                        );
                                        if (ok) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Ditambahkan ke keranjang: ${item.name} ($_quantity porsi)'),
                                              backgroundColor: AppColors.primary,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              icon: Icon(
                                !isStoreOpen
                                    ? Icons.lock_clock_rounded
                                    : ((item.isReadyStock && item.stockCount > 0)
                                        ? Icons.add_shopping_cart_rounded
                                        : Icons.block_rounded),
                                size: 18,
                              ),
                              label: Text(
                                !isStoreOpen
                                    ? 'Toko Tutup'
                                    : ((item.isReadyStock && item.stockCount > 0)
                                        ? '+ Tambah (Rp $totalPrice)'
                                        : 'Stok Habis'),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: reviews.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: AppColors.surfaceMuted,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.rate_review_outlined, size: 36, color: AppColors.textLight),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Belum Ada Penilaian',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Hanya pembeli yang telah memesan dan menerima makanan berstatus selesai yang dapat memberikan penilaian.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: reviews.length,
                                separatorBuilder: (ctx, idx) => const Divider(height: 16, color: AppColors.surfaceBorder),
                                itemBuilder: (ctx, idx) {
                                  final review = reviews[idx];
                                  return _buildReviewTile(review);
                                },
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTile(ProductRatingModel review) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
                child: review.userAvatar == null
                    ? Text(
                        review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
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
                        Flexible(
                          child: Text(
                            review.userName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 10, color: Color(0xFF16A34A)),
                              SizedBox(width: 3),
                              Text(
                                'Pembeli Terverifikasi',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (review.userFaculty != null && review.userFaculty!.isNotEmpty)
                      Text(
                        review.userFaculty!,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(fontSize: 10, color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Star Rating
          Row(
            children: List.generate(5, (starIdx) {
              final isFilled = starIdx < review.stars;
              return Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 15,
                color: isFilled ? const Color(0xFFD97706) : Colors.grey.shade400,
              );
            }),
          ),
          if (review.reviewText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.reviewText,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}
