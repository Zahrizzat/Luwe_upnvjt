import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item_model.dart';
import '../../models/store_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/product_detail_dialog.dart';
import '../../widgets/cart_drawer.dart';

class StoreDetailScreen extends StatefulWidget {
  final StoreModel store;
  final AppState state;

  const StoreDetailScreen({
    super.key,
    required this.store,
    required this.state,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _inStoreSearch = '';
  String _selectedCategory = 'Semua Menu';
  bool _onlyReadyStock = false;

  Color _getFacultyColor(String facultyShort) {
    switch (facultyShort.toUpperCase()) {
      case 'FIK':
        return const Color(0xFF0284C7);
      case 'FEB':
        return const Color(0xFF059669);
      case 'FT':
        return const Color(0xFFD97706);
      case 'FISIP':
        return const Color(0xFF7C3AED);
      case 'FAD':
        return const Color(0xFFDB2777);
      case 'FH':
        return const Color(0xFFDC2626);
      case 'FP':
        return const Color(0xFF16A34A);
      default:
        return AppColors.primary;
    }
  }

  void _openDetail(MenuItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => ProductDetailDialog(item: item, state: widget.state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final state = widget.state;
    final facultyColor = _getFacultyColor(store.facultyShort);
    final rating = state.calculateStoreRating(store.id);
    final reviewCount = state.calculateStoreReviewCount(store.id);
    final isStoreOpen = state.isStoreOpen(store);

    // Products STRICTLY from this store
    final rawStoreProducts = state.getProductsForStore(store.id);

    // Extract categories present in this store's products
    final storeCategories = ['Semua Menu', ...store.categories];

    // Filter products
    final filteredProducts = rawStoreProducts.where((item) {
      final matchesSearch = _inStoreSearch.isEmpty ||
          item.name.toLowerCase().contains(_inStoreSearch.toLowerCase()) ||
          item.description.toLowerCase().contains(_inStoreSearch.toLowerCase());

      final matchesCategory = _selectedCategory == 'Semua Menu' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesStock = !_onlyReadyStock || item.isReadyStock;

      return matchesSearch && matchesCategory && matchesStock;
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.canvas,
      endDrawer: CartDrawer(state: state),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Back Button to Stores List
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'Kembali ke Daftar Toko',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Breadcrumb
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Beranda Toko',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textLight),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Open Cart Button
                  ElevatedButton.icon(
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.cartCount > 0 ? AppColors.primary : AppColors.surfaceMuted,
                      foregroundColor: state.cartCount > 0 ? Colors.white : AppColors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: state.cartCount > 0 ? BorderSide.none : const BorderSide(color: AppColors.surfaceBorder),
                      ),
                    ),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 18,
                          color: state.cartCount > 0 ? Colors.white : AppColors.textSecondary,
                        ),
                        if (state.cartCount > 0)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${state.cartCount}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: Text(
                      state.cartCount > 0
                          ? 'Keranjang (Rp ${state.cartTotal})'
                          : 'Keranjang',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: state.cartCount > 0 ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Store Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Hero Header Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Banner image
                          Stack(
                            children: [
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.network(
                                  store.bannerUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    color: AppColors.primaryHover,
                                    child: const Center(
                                      child: Icon(Icons.storefront_rounded, size: 64, color: Colors.white38),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.6),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.75),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0.0, 0.4, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Status badges top
                              Positioned(
                                top: 16,
                                left: 20,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isStoreOpen ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.circle, size: 8, color: Colors.white),
                                          const SizedBox(width: 6),
                                          Text(
                                            isStoreOpen ? 'TOKO BUKA' : 'TOKO TUTUP',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white30),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            store.isDanusan ? Icons.school_rounded : Icons.storefront_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            store.isDanusan ? 'Danusan Mahasiswa UPN' : 'Stan Kuliner Kampus',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Faculty pill bottom-right
                              Positioned(
                                bottom: 16,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: facultyColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    store.faculty,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Store Info details
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Store Logo Avatar
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.surfaceBorder, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      store.logoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        color: AppColors.primary,
                                        child: const Icon(Icons.store, color: Colors.white, size: 36),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Main titles & descriptions
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              store.name,
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textPrimary,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                          if (store.isVerified)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondaryLight,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.verified, size: 14, color: AppColors.secondary),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Terverifikasi Kampus',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.secondaryDark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Organization & Faculty subtitle
                                      if (store.organization.isNotEmpty)
                                        Text(
                                          '${store.organization} • ${store.faculty}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: facultyColor,
                                          ),
                                        ),
                                      const SizedBox(height: 8),

                                      // Description text
                                      Text(
                                        store.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          height: 1.45,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Info badges row (Rating, Delivery estimate, Location)
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: [
                                          // Accumulated rating
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: AppColors.pastelYellow,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.goldenYellow),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star_rounded, size: 16, color: AppColors.amberYellow),
                                                const SizedBox(width: 4),
                                                Text(
                                                  rating != null ? rating.toStringAsFixed(1) : 'Belum ada rating',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.accentOrange,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  rating != null ? '($reviewCount ulasan)' : '(0 penilaian)',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.accentOrange,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Delivery estimation
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.delivery_dining_rounded, size: 16, color: AppColors.primary),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Estimasi ${store.deliveryTimeEstimate}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Location
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceMuted,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.surfaceBorder),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Text(
                                                  store.location,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isStoreOpen) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEE2E2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Color(0xFFDC2626), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Stan Kuliner Sedang Tutup',
                                    style: TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Saat ini ${store.name} tidak menerima pesanan baru. Anda tetap dapat menjelajahi menu yang ada di stan ini.',
                                    style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    // In-Store Search and Category Filters
                    Container(
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
                            children: [
                              // In-store search field
                              Expanded(
                                child: TextField(
                                  onChanged: (val) => setState(() => _inStoreSearch = val),
                                  decoration: InputDecoration(
                                    hintText: 'Cari menu di ${store.name}...',
                                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                                    suffixIcon: _inStoreSearch.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, size: 18),
                                            onPressed: () => setState(() => _inStoreSearch = ''),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Ready Stock only toggle
                              FilterChip(
                                label: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 15),
                                    SizedBox(width: 4),
                                    Text('Hanya Ready Stock'),
                                  ],
                                ),
                                selected: _onlyReadyStock,
                                onSelected: (val) => setState(() => _onlyReadyStock = val),
                                selectedColor: AppColors.secondaryLight,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _onlyReadyStock ? AppColors.secondaryDark : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Category Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: storeCategories.map((cat) {
                                final isSel = _selectedCategory.toLowerCase() == cat.toLowerCase();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(cat),
                                    selected: isSel,
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedCategory = cat);
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                      color: isSel ? Colors.white : AppColors.textPrimary,
                                    ),
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: isSel ? AppColors.primary : AppColors.surfaceBorder,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Products List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Menu Makanan & Minuman (${filteredProducts.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_inStoreSearch.isNotEmpty || _selectedCategory != 'Semua Menu')
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _inStoreSearch = '';
                                _selectedCategory = 'Semua Menu';
                                _onlyReadyStock = false;
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Reset Filter Toko'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Products Grid (ONLY from this store)
                    if (filteredProducts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textLight),
                            const SizedBox(height: 12),
                            const Text(
                              'Menu tidak ditemukan di toko ini',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Coba gunakan kata kunci pencarian lain atau pilih kategori yang berbeda.',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _inStoreSearch = '';
                                  _selectedCategory = 'Semua Menu';
                                  _onlyReadyStock = false;
                                });
                              },
                              child: const Text('Tampilkan Semua Menu Toko'),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 380,
                          mainAxisExtent: 340,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final item = filteredProducts[index];
                          return _buildProductCard(item);
                        },
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

  Widget _buildProductCard(MenuItemModel item) {
    final isStoreOpen = widget.state.isStoreOpen(widget.store);
    final pRating = widget.state.getProductAverageRating(item.id);
    final pReviews = widget.state.getProductRatingCount(item.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product photo & availability overlay
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: AppColors.surfaceMuted,
                    child: const Center(
                      child: Icon(Icons.fastfood_rounded, size: 40, color: AppColors.textLight),
                    ),
                  ),
                ),
              ),

              // Category tag
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              // Availability / Promo tag
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: !isStoreOpen
                        ? const Color(0xFFDC2626)
                        : (item.isReadyStock ? const Color(0xFF16A34A) : Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    !isStoreOpen ? 'Toko Tutup' : (item.isReadyStock ? 'Ready Stock' : 'Habis'),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),

          // Product info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Expanded(
                    child: Text(
                      item.description,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rating & Sold count
                  Row(
                    children: [
                      Icon(
                        pRating != null ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 14,
                        color: pRating != null ? AppColors.tertiary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        pRating != null ? '${pRating.toStringAsFixed(1)} ($pReviews)' : 'Belum ada ulasan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: pRating != null ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•  ${item.soldCount} terjual',
                        style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price and Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.originalPrice != null)
                            Text(
                              'Rp ${item.originalPrice}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textLight,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            'Rp ${item.price}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _openDetail(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (item.isReadyStock && isStoreOpen) ? AppColors.primary : AppColors.surfaceMuted,
                          foregroundColor: (item.isReadyStock && isStoreOpen) ? Colors.white : AppColors.textLight,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          !isStoreOpen
                              ? 'Tutup'
                              : (item.isReadyStock ? '+ Tambah' : 'Habis'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
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
    );
  }
}
