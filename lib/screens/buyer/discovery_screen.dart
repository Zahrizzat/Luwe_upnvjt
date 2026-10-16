import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/store_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/store_card.dart';
import 'store_detail_screen.dart';

class DiscoveryScreen extends StatelessWidget {
  final AppState state;

  const DiscoveryScreen({super.key, required this.state});

  void _openStoreDetail(BuildContext context, StoreModel store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => StoreDetailScreen(store: store, state: state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStores = state.stores;
    final topRated = state.topRatedStores;
    final popular = state.popularStores;
    final isSearching = state.searchQuery.trim().isNotEmpty;
    final hasActiveFilters = state.selectedCategory != 'Semua Kategori' ||
        state.selectedFaculty != 'Semua Lokasi' ||
        state.onlyOpenStores ||
        state.minRating > 0 ||
        isSearching;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Campus Hero Promotion Banner (GoFood style for UPN Danusan & Kuliner)
          // 1. Campus Hero Promotion Banner (Based on highest rated store)
          Builder(
            builder: (context) {
              final topStore = state.topRankedStore;
              final topRating = topStore != null ? state.calculateStoreRating(topStore.id) : null;
              final topReviewCount = topStore != null ? state.calculateStoreReviewCount(topStore.id) : 0;
              final hasValidRating = topRating != null && topRating > 0;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryRed, AppColors.secondaryRed, AppColors.accentOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 780;

                    final leftContent = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    hasValidRating ? Icons.star_rounded : Icons.local_fire_department_rounded,
                                    size: 15,
                                    color: Colors.yellowAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    hasValidRating ? 'TOKO RATING TERTINGGI KAMPUS UPN' : 'REKOMENDASI TOKO UNGGULAN',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Open / Closed Status (Explicitly shown)
                            if (topStore != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: topStore.isOpen
                                      ? const Color(0xFF16A34A).withValues(alpha: 0.9)
                                      : const Color(0xFFDC2626).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      topStore.isOpen ? 'Toko Buka' : 'Toko Sedang Tutup',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Store Name Headline
                        Text(
                          topStore?.name ?? 'Pasar Kuliner Mahasiswa UPNVJT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Faculty / Organization & Rating Line
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            if (topStore != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.school_rounded, color: Colors.white70, size: 15),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${topStore.faculty} • ${topStore.organization}',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            if (hasValidRating)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, size: 15, color: AppColors.amberYellow),
                                    const SizedBox(width: 4),
                                    Text(
                                      topRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.accentOrange,
                                      ),
                                    ),
                                    if (topReviewCount > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '($topReviewCount ulasan)',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            else if (topStore != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Toko Pilihan Terverifikasi',
                                  style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Store Description
                        Text(
                          topStore?.description ??
                              'Dukung penggalangan dana kegiatan himpunan (HIMA), BEM, dan usaha kuliner mahasiswa UPN "Veteran" Jawa Timur. Pengantaran cepat langsung ke selasar kelas atau lab!',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 22),

                        // Action Buttons
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            if (topStore != null)
                              ElevatedButton.icon(
                                onPressed: () => _openStoreDetail(context, topStore),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.storefront_rounded, size: 18),
                                label: const Text(
                                  'Lihat Toko',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            OutlinedButton.icon(
                              onPressed: () {
                                state.setSelectedCategory('Danusan Kampus');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.school_rounded, size: 18),
                              label: const Text(
                                'Eksplor Danusan Mahasiswa',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    // Right card with store photo / preview
                    final rightCard = topStore != null
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Image.network(
                                      topStore.bannerUrl,
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        height: 140,
                                        color: Colors.white12,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.storefront_rounded, size: 48, color: Colors.white38),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha: 0.6),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 12,
                                      right: 12,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(topStore.logoUrl),
                                            onBackgroundImageError: (exception, stackTrace) {},
                                            child: Text(
                                              topStore.facultyShort,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              topStore.location,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.speed_rounded, size: 14, color: Colors.yellowAccent),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${topStore.deliveryTimeEstimate} • Siap Antar',
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        topStore.deliveryLocation,
                                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink();

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          leftContent,
                          const SizedBox(height: 20),
                          rightCard,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 3, child: leftContent),
                        const SizedBox(width: 28),
                        Expanded(flex: 2, child: rightCard),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // 2. Category Quick Filters (GoFood-style horizontal chips)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori Toko & Kuliner',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pilih kategori untuk memfilter toko dan usaha kuliner mahasiswa',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: () => state.resetStoreFilters(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset Semua Filter'),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Category Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryPill('Semua Kategori', Icons.restaurant_rounded),
                _buildCategoryPill('Danusan Kampus', Icons.school_rounded),
                _buildCategoryPill('Makanan Utama', Icons.lunch_dining_rounded),
                _buildCategoryPill('Minuman Segar', Icons.local_cafe_rounded),
                _buildCategoryPill('Cemilan & Snack', Icons.cookie_rounded),
                _buildCategoryPill('Paket Hemat', Icons.savings_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Filter Bar: Fakultas, Status Buka, Rating, & Reset
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                // Faculty Filter Dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.apartment_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Fakultas / Lokasi:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedFaculty,
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          items: const [
                            DropdownMenuItem(value: 'Semua Lokasi', child: Text('Semua Fakultas & Kantin')),
                            DropdownMenuItem(value: 'FIK', child: Text('Fakultas Ilmu Komputer (FIK)')),
                            DropdownMenuItem(value: 'FEB', child: Text('Fakultas Ekonomi dan Bisnis (FEB)')),
                            DropdownMenuItem(value: 'FT', child: Text('Fakultas Teknik (FT)')),
                            DropdownMenuItem(value: 'FISIP', child: Text('Fakultas Ilmu Sosial & Politik (FISIP)')),
                            DropdownMenuItem(value: 'FAD', child: Text('Fakultas Arsitektur & Desain (FAD)')),
                            DropdownMenuItem(value: 'Giri Reksa', child: Text('Kantin Giri Reksa')),
                            DropdownMenuItem(value: 'Santoso', child: Text('Kantin Giri Santoso')),
                          ],
                          onChanged: (val) {
                            if (val != null) state.setSelectedFaculty(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Open Stores Only Toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilterChip(
                      selected: state.onlyOpenStores,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: state.onlyOpenStores ? Colors.white : const Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Hanya Toko Buka'),
                        ],
                      ),
                      onSelected: (val) => state.setOnlyOpenStores(val),
                      selectedColor: const Color(0xFF16A34A),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: state.onlyOpenStores ? Colors.white : AppColors.textPrimary,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: state.onlyOpenStores ? const Color(0xFF16A34A) : AppColors.surfaceBorder,
                        ),
                      ),
                    ),
                  ],
                ),

                // Rating Filter Toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilterChip(
                      selected: state.minRating >= 4.8,
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: AppColors.amberYellow),
                          SizedBox(width: 4),
                          Text('Rating 4.8+'),
                        ],
                      ),
                      onSelected: (val) => state.setMinRating(val ? 4.8 : 0.0),
                      selectedColor: AppColors.pastelYellow,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: state.minRating >= 4.8 ? AppColors.accentOrange : AppColors.textPrimary,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: state.minRating >= 4.8 ? AppColors.goldenYellow : AppColors.surfaceBorder,
                        ),
                      ),
                    ),
                  ],
                ),

                // Reset Filters
                if (hasActiveFilters)
                  OutlinedButton.icon(
                    onPressed: () => state.resetStoreFilters(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 15),
                    label: const Text('Hapus Filter', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // If user is searching: display search notification banner
          if (isSearching) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        children: [
                          const TextSpan(text: 'Menampilkan toko yang cocok atau menjual produk: '),
                          TextSpan(
                            text: '"${state.searchQuery}"',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                          TextSpan(text: ' • Ditemukan ${allStores.length} toko'),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => state.setSearchQuery(''),
                    tooltip: 'Hapus Pencarian',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 4. Section: Toko dengan Rating Tertinggi (Only shown when not in deep search filter)
          if (!isSearching && state.minRating == 0 && topRated.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.pastelYellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.goldenYellow),
                  ),
                  child: const Icon(Icons.star_rounded, color: AppColors.amberYellow, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toko & Danusan Rating Tertinggi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Akumulasi ulasan kepuasan rasa & pelayanan terbaik dari mahasiswa UPNVJT',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 380,
                mainAxisExtent: 295,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: topRated.length,
              itemBuilder: (context, index) {
                final store = topRated[index];
                return StoreCard(
                  store: store,
                  state: state,
                  onTap: () => _openStoreDetail(context, store),
                );
              },
            ),
            const SizedBox(height: 32),
          ],

          // 5. Section: Toko Populer & Rekomendasi Danusan (Only shown when no search)
          if (!isSearching && popular.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toko Populer & Rekomendasi Danusan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Pilihan favorit penggalangan dana danusan fakultas & kuliner kampus paling ramai',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 380,
                mainAxisExtent: 295,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: popular.length,
              itemBuilder: (context, index) {
                final store = popular[index];
                return StoreCard(
                  store: store,
                  state: state,
                  onTap: () => _openStoreDetail(context, store),
                );
              },
            ),
            const SizedBox(height: 32),
          ],

          // 6. Section: Daftar Seluruh Toko yang Tersedia (All Stores Grid)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: AppColors.textPrimary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isSearching
                        ? 'Hasil Pencarian Toko (${allStores.length})'
                        : 'Seluruh Toko & Danusan Tersedia (${allStores.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Text(
                '${allStores.where((s) => s.isOpen).length} Toko Buka Sekarang',
                style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (allStores.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  const Icon(Icons.storefront_outlined, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 14),
                  const Text(
                    'Tidak Ada Toko yang Sesuai Filter',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Coba ubah kata kunci pencarian, pilih lokasi fakultas lain, atau matikan filter toko buka.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => state.resetStoreFilters(),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Tampilkan Semua Toko', style: TextStyle(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
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
                mainAxisExtent: 295,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: allStores.length,
              itemBuilder: (context, index) {
                final store = allStores[index];
                return StoreCard(
                  store: store,
                  state: state,
                  onTap: () => _openStoreDetail(context, store),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String title, IconData icon) {
    final isSelected = state.selectedCategory == title;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(title),
          ],
        ),
        onSelected: (val) {
          state.setSelectedCategory(title);
        },
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
      ),
    );
  }
}
