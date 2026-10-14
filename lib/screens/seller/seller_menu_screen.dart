import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/status_badge.dart';

class SellerMenuScreen extends StatelessWidget {
  final AppState state;

  const SellerMenuScreen({super.key, required this.state});

  void _showAddMenuDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final imgCtrl = TextEditingController(
      text: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
    );
    String selectedCat = 'Makanan Utama';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Container(
              width: 520,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tambah Menu Baru Toko',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Nama Menu Makanan / Minuman:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: 'Contoh: Nasi Kulit Krispi Sambal Bawang'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kategori:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: selectedCat,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                              items: const [
                                DropdownMenuItem(value: 'Makanan Utama', child: Text('Makanan Utama')),
                                DropdownMenuItem(value: 'Minuman Segar', child: Text('Minuman Segar')),
                                DropdownMenuItem(value: 'Cemilan & Snack', child: Text('Cemilan & Snack')),
                                DropdownMenuItem(value: 'Paket Hemat', child: Text('Paket Hemat')),
                              ],
                              onChanged: (v) {
                                if (v != null) setDialogState(() => selectedCat = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga (Rp):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '15000'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Deskripsi Menu:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Keterangan porsi, bahan, tingkat kepedasan...'),
                  ),
                  const SizedBox(height: 12),
                  const Text('URL Gambar Foto Menu:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: imgCtrl,
                    decoration: const InputDecoration(hintText: 'https://...'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final price = int.tryParse(priceCtrl.text) ?? 15000;
                        final newItem = MenuItemModel(
                          id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
                          merchantId: state.currentUser.id,
                          merchantName: state.currentUser.storeName,
                          merchantLocation: state.currentUser.storeLocation,
                          name: nameCtrl.text.isEmpty ? 'Menu Baru Kampus' : nameCtrl.text,
                          description: descCtrl.text.isEmpty ? 'Menu lezat buatan wirausaha mahasiswa.' : descCtrl.text,
                          price: price,
                          imageUrl: imgCtrl.text,
                          category: selectedCat,
                          isReadyStock: true,
                          stockCount: 20,
                        );
                        state.addMenuItem(newItem);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Menu "${newItem.name}" berhasil dipublikasikan!'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      },
                      child: const Text('Simpan & Publikasikan Menu', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = state.allRawMenuItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kelola Menu & Stok Toko',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Atur ketersediaan menu secara langsung agar pembeli tidak memesan menu yang habis.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMenuDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Menu Baru'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Menu items list
          ...items.map((item) {
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.surfaceMuted,
                        child: const Icon(Icons.fastfood),
                      ),
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
                              item.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 10),
                            item.isReadyStock ? CampusBadge.readyStock() : CampusBadge.outOfStock(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.category} • Rp ${item.price} • Terjual ${item.soldCount} porsi',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stok Tersisa: ${item.stockCount} porsi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: item.isReadyStock ? AppColors.secondary : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stock Toggle Switch
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.isReadyStock ? 'Siap Dijual' : 'Stok Habis',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: item.isReadyStock ? AppColors.secondary : AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text('Ubah status instan', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: item.isReadyStock,
                        onChanged: (_) => state.toggleStock(item.id),
                        activeThumbColor: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        tooltip: 'Hapus Menu',
                        onPressed: () {
                          state.deleteMenuItem(item.id);
                        },
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
}
