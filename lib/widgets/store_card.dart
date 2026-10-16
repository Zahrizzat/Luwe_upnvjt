import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/store_model.dart';
import '../providers/app_state.dart';

class StoreCard extends StatefulWidget {
  final StoreModel store;
  final AppState state;
  final VoidCallback onTap;

  const StoreCard({
    super.key,
    required this.store,
    required this.state,
    required this.onTap,
  });

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  bool _isHovered = false;

  Color _getFacultyColor(String facultyShort) {
    switch (facultyShort.toUpperCase()) {
      case 'FIK':
        return const Color(0xFF0284C7); // Cyan/Sky blue
      case 'FEB':
        return const Color(0xFF059669); // Emerald green
      case 'FT':
        return const Color(0xFFD97706); // Amber/orange
      case 'FISIP':
        return const Color(0xFF7C3AED); // Purple
      case 'FAD':
        return const Color(0xFFDB2777); // Pink/Rose
      case 'FH':
        return const Color(0xFFDC2626); // Red
      case 'FP':
        return const Color(0xFF16A34A); // Forest green
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final rating = widget.state.calculateStoreRating(store.id);
    final reviews = widget.state.calculateStoreReviewCount(store.id);
    final facultyColor = _getFacultyColor(store.facultyShort);
    final matchingProducts = widget.state.getMatchingProductNamesForStore(store.id, widget.state.searchQuery);
    final isOpen = widget.state.isStoreOpen(store);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? AppColors.primary.withValues(alpha: 0.5) : AppColors.surfaceBorder,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _isHovered ? 18 : 8,
                offset: Offset(0, _isHovered ? 8 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Cover Banner Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: SizedBox(
                      height: 148,
                      width: double.infinity,
                      child: Image.network(
                        store.bannerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: AppColors.surfaceMuted,
                          child: const Center(
                            child: Icon(Icons.storefront_rounded, size: 48, color: AppColors.textLight),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gradient scrim for text readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Open / Closed Status Pill (Top Left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? const Color(0xFF16A34A).withValues(alpha: 0.92)
                            : const Color(0xFFDC2626).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isOpen ? 'BUKA' : 'TUTUP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Danusan / Kantin Tag (Top Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            store.isDanusan ? Icons.school_rounded : Icons.storefront_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.isDanusan ? 'Danusan Mahasiswa' : 'Kantin Kampus',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Store Logo Badge (Bottom Left overlay)
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          store.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            color: AppColors.primary,
                            child: const Icon(Icons.store, size: 22, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Faculty Pill (Bottom Right overlay)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: facultyColor.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        store.facultyShort,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Card Content Body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store / Danusan Name
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Faculty & Organization
                    Row(
                      children: [
                        Icon(Icons.apartment_rounded, size: 12, color: facultyColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            store.organization.isNotEmpty
                                ? '${store.organization} • ${store.faculty}'
                                : store.faculty,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: facultyColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Categories List
                    Text(
                      store.categories.join(' • '),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    const Divider(height: 1, thickness: 0.8, color: AppColors.surfaceBorder),
                    const SizedBox(height: 10),

                    // Rating, Delivery Estimation, Location info row (Flexible to prevent card overflow)
                    Row(
                      children: [
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: rating != null ? AppColors.pastelYellow : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: rating != null ? AppColors.goldenYellow : AppColors.surfaceBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                rating != null ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 12,
                                color: rating != null ? AppColors.amberYellow : AppColors.textMuted,
                              ),
                              const SizedBox(width: 2),
                              if (rating != null) ...[
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '($reviews)',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.accentOrange.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  'Baru',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Delivery Time
                        const Icon(Icons.delivery_dining_rounded, size: 13, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          store.deliveryTimeEstimate,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Location hint (Flexible to gracefully truncate)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  store.location.split('•').first.trim(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // If global search matched products in this store, show product match pills
                    if (matchingProducts.isNotEmpty && widget.state.searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, size: 11, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Menyediakan: ${matchingProducts.take(2).join(', ')}${matchingProducts.length > 2 ? ' +${matchingProducts.length - 2}' : ''}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
