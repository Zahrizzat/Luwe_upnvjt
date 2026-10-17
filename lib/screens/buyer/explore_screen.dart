import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_state.dart';
import '../../widgets/food_card.dart';
import '../../widgets/product_detail_dialog.dart';

class ExploreScreen extends StatelessWidget {
  final AppState state;

  const ExploreScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final items = state.menuItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Description
          const Text(
            'Jelajah Katalog Kuliner Kampus',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Temukan menu makanan dan minuman terbaik dari seluruh usaha dan danusan mahasiswa UPNVJT.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Search and Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
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
                    Expanded(
                      child: TextField(
                        onChanged: (val) => state.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Cari menu berdasarkan nama, bahan, atau penjual...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                          suffixIcon: state.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => state.setSearchQuery(''),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        state.setSearchQuery('');
                        state.setSelectedCategory('Semua Kategori');
                        state.setSelectedFaculty('Semua Lokasi');
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Reset Filter'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Category Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Semua Kategori',
                    'Makanan Utama',
                    'Minuman Segar',
                    'Cemilan & Snack',
// Only 3 categories
                  ].map((cat) {
                    final isSel = state.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) state.setSelectedCategory(cat);
                      },
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? AppColors.primary : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Results count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menampilkan ${items.length} Menu Makanan & Minuman',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              if (state.selectedFaculty != 'Semua Lokasi')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.goldenYellow),
                  ),
                  child: Text(
                    'Lokasi: ${state.selectedFaculty}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accentOrange),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Items Grid
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Menu Tidak Ditemukan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Coba gunakan kata kunci lain atau ubah filter lokasi & kategori.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 340,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return FoodCard(
                  item: item,
                  state: state,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => ProductDetailDialog(item: item, state: state),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
