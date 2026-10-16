import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/menu_item_model.dart';
import '../providers/app_state.dart';
import 'auth_guard_dialog.dart';
import 'status_badge.dart';

class FoodCard extends StatelessWidget {
  final MenuItemModel item;
  final AppState state;
  final VoidCallback onTap;

  const FoodCard({
    super.key,
    required this.item,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = state.isFavorite(item.id);
    final isStoreOpen = state.isItemStoreOpen(item);
    final canOrder = item.isReadyStock && isStoreOpen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Overlays
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceMuted,
                        child: const Center(
                          child: Icon(Icons.fastfood_rounded, size: 40, color: AppColors.textLight),
                        ),
                      ),
                    ),
                  ),
                ),
                // Stock Badge / Closed Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: !isStoreOpen
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.storefront_rounded, size: 10, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Toko Tutup',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        )
                      : (item.isReadyStock
                          ? CampusBadge.readyStock()
                          : CampusBadge.outOfStock()),
                ),
                // Favorite Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      if (!state.isLoggedIn) {
                        AuthGuardDialog.requireAuth(
                          context,
                          state,
                          message: 'Masuk ke akun Luwe kamu untuk menambahkan ${item.name} ke daftar favorit.',
                          onAuthenticated: () => state.toggleFavorite(item.id),
                        );
                      } else {
                        state.toggleFavorite(item.id);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16,
                        color: isFav ? AppColors.primary : AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Merchant Location & Verified
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, size: 13, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.merchantName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.tertiary),
                        const SizedBox(width: 2),
                        Text(
                          '${item.rating}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Dish Title
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Brief description
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Price & Add Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.originalPrice != null)
                                Text(
                                  'Rp ${item.originalPrice}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const Text(
                                    'Rp ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    '${item.price}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Add Button
                        ElevatedButton(
                          onPressed: canOrder
                              ? () {
                                  if (!state.isLoggedIn) {
                                    AuthGuardDialog.requireAuth(
                                      context,
                                      state,
                                      message: 'Masuk ke akun Luwe kamu untuk menambahkan pesanan ke keranjang.',
                                      onAuthenticated: () {
                                        final ok = state.addToCart(item);
                                        if (ok) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${item.name} berhasil ditambahkan ke keranjang!'),
                                              duration: const Duration(seconds: 1),
                                              backgroundColor: AppColors.primary,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    final ok = state.addToCart(item);
                                    if (ok) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${item.name} berhasil ditambahkan ke keranjang!'),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: AppColors.primary,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                }
                              : () {
                                  if (!isStoreOpen) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Toko "${item.merchantName}" sedang tutup. Tidak dapat memesan saat ini.'),
                                        backgroundColor: const Color(0xFFDC2626),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canOrder ? AppColors.primary : AppColors.surfaceMuted,
                            foregroundColor: canOrder ? Colors.white : AppColors.textLight,
                            disabledBackgroundColor: AppColors.surfaceMuted,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                !isStoreOpen
                                    ? Icons.lock_clock_rounded
                                    : (item.isReadyStock ? Icons.add_rounded : Icons.block_rounded),
                                size: 14,
                                color: canOrder ? Colors.white : AppColors.textLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                !isStoreOpen
                                    ? 'Tutup'
                                    : (item.isReadyStock ? 'Pesan' : 'Habis'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: canOrder ? Colors.white : AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
