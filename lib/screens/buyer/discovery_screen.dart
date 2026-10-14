import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/food_card.dart';
import '../../widgets/product_detail_dialog.dart';
import '../../widgets/status_badge.dart';

class DiscoveryScreen extends StatelessWidget {
  final AppState state;

  const DiscoveryScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final promoItems = state.menuItems.where((i) => i.isPromo).toList();
    final allItems = state.menuItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Campus Culinary Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFF9A3412)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 14, color: Colors.yellowAccent),
                            SizedBox(width: 4),
                            Text(
                              'KULINER KAMPUS UPN "VETERAN" JAWA TIMUR',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'LuWe! Solusi Cepat Lapar\nAntar Sampai Depan Kelas.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pesan makanan & minuman langsung dari wirausaha mahasiswa & kantin fakultas tanpa antre panjang di jam jeda kuliah.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => state.setTabIndex(1), // Go to catalog
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                        child: const Text('Jelajahi Semua Menu', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Hero Illustration Graphic / Stats
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mitra Kantin Aktif',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.location_city_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Kantin Giri Reksa & Giri Santoso', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.school_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('7 Fakultas Terjangkau Pengantaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, color: AppColors.secondary, size: 14),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '100% Penjual Mahasiswa Terverifikasi',
                                  style: TextStyle(color: AppColors.secondaryDark, fontSize: 11, fontWeight: FontWeight.w700),
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
          const SizedBox(height: 28),

          // Category Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kategori Kuliner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () {
                  state.setSelectedCategory('Semua Kategori');
                  state.setTabIndex(1);
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryPill('Semua Kategori', Icons.restaurant_rounded),
                _buildCategoryPill('Makanan Utama', Icons.lunch_dining_rounded),
                _buildCategoryPill('Minuman Segar', Icons.local_cafe_rounded),
                _buildCategoryPill('Cemilan & Snack', Icons.cookie_rounded),
                _buildCategoryPill('Paket Hemat', Icons.savings_rounded),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Promo Mahasiswa Section
          if (promoItems.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 6),
                const Text(
                  'Promo Spesial Mahasiswa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                CampusBadge.promo('Hemat s/d 25%'),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 340,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: promoItems.length,
              itemBuilder: (context, index) {
                final item = promoItems[index];
                return FoodCard(
                  item: item,
                  state: state,
                  onTap: () => _openDetail(context, item),
                );
              },
            ),
            const SizedBox(height: 28),
          ],

          // All Campus Dishes Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Menu Pilihan Kampus Terlaris',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                '${allItems.length} Menu Tersedia',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 340,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final item = allItems[index];
              return FoodCard(
                item: item,
                state: state,
                onTap: () => _openDetail(context, item),
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
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

  void _openDetail(BuildContext context, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => ProductDetailDialog(item: item, state: state),
    );
  }
}
