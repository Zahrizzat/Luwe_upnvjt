import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/menu_item_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final totalPrice = item.price * _quantity;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840, maxHeight: 680),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${item.rating} (${item.reviewCount} ulasan)',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${item.soldCount} terjual di kampus',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Configuration Section
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

                    // Description
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const Divider(height: 24),

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

                    const Spacer(),

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
                          // Quantity counter
                          Row(
                            children: [
                              IconButton.outlined(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: Size.zero,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                              ),
                              IconButton.outlined(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () => setState(() => _quantity++),
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: Size.zero,
                                ),
                              ),
                            ],
                          ),

                          // Add button
                          ElevatedButton.icon(
                            onPressed: () {
                              if (!widget.state.isLoggedIn) {
                                AuthGuardDialog.requireAuth(
                                  context,
                                  widget.state,
                                  message: 'Masuk ke akun Luwe kamu untuk menambahkan ${item.name} ke keranjang dan melanjutkan pesanan.',
                                  onAuthenticated: () {
                                    widget.state.addToCart(
                                      item,
                                      quantity: _quantity,
                                      level: _selectedSpiceLevel,
                                      note: _noteController.text,
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Ditambahkan ke keranjang: ${item.name} ($_quantity porsi)'),
                                        backgroundColor: AppColors.primary,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                );
                              } else {
                                widget.state.addToCart(
                                  item,
                                  quantity: _quantity,
                                  level: _selectedSpiceLevel,
                                  note: _noteController.text,
                                );
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
                            icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                            label: Text(
                              '+ Tambah (Rp $totalPrice)',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
