import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/menu_item_model.dart';
import '../../models/store_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/status_badge.dart';

class SellerMenuScreen extends StatefulWidget {
  final AppState state;

  const SellerMenuScreen({super.key, required this.state});

  @override
  State<SellerMenuScreen> createState() => _SellerMenuScreenState();
}

class _SellerMenuScreenState extends State<SellerMenuScreen> {
  String _searchFilter = '';
  String _selectedCategory = 'Semua Kategori';

  AppState get state => widget.state;

  void _showAddMenuDialog(BuildContext context, StoreModel currentStore) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '15000');
    final stockCtrl = TextEditingController(text: '20');
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
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tambah Menu Baru',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Toko: ${currentStore.name}',
                                style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('Nama Menu Makanan / Minuman *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Nasi Kulit Krispi Sambal Bawang',
                        prefixIcon: Icon(Icons.fastfood_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kategori *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCat,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
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
                              const Text('Harga (Rp) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '15000',
                                  prefixText: 'Rp ',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Stok Awal (Porsi) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '20',
                            suffixText: 'porsi',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Deskripsi Menu:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Keterangan porsi, bahan, tingkat kepedasan...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('URL Foto Menu:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: imgCtrl,
                      decoration: const InputDecoration(
                        hintText: 'https://...',
                        prefixIcon: Icon(Icons.image_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                        label: const Text(
                          'Simpan & Publikasikan Menu',
                          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama menu tidak boleh kosong.'), backgroundColor: AppColors.error),
                            );
                            return;
                          }
                          final price = int.tryParse(priceCtrl.text) ?? 15000;
                          final stock = int.tryParse(stockCtrl.text) ?? 20;

                          final newItem = MenuItemModel(
                            id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
                            merchantId: currentStore.id,
                            merchantName: currentStore.name,
                            merchantLocation: currentStore.location,
                            name: name,
                            description: descCtrl.text.trim().isEmpty ? 'Menu lezat buatan wirausaha mahasiswa.' : descCtrl.text.trim(),
                            price: price,
                            imageUrl: imgCtrl.text.trim().isEmpty
                                ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80'
                                : imgCtrl.text.trim(),
                            category: selectedCat,
                            isReadyStock: stock > 0,
                            stockCount: stock,
                          );

                          state.addMenuItem(newItem);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Menu "$name" berhasil ditambahkan ke toko!'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditMenuDialog(BuildContext context, MenuItemModel item) {
    final nameCtrl = TextEditingController(text: item.name);
    final descCtrl = TextEditingController(text: item.description);
    final priceCtrl = TextEditingController(text: item.price.toString());
    final stockCtrl = TextEditingController(text: item.stockCount.toString());
    final imgCtrl = TextEditingController(text: item.imageUrl);
    String selectedCat = item.category;
    bool isReady = item.isReadyStock;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Detail Menu',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('Nama Menu *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.fastfood_outlined, size: 20)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kategori *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCat,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
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
                              const Text('Harga (Rp) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(prefixText: 'Rp '),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Jumlah Stok Tersisa *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: stockCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(suffixText: 'porsi'),
                                onChanged: (val) {
                                  final num = int.tryParse(val) ?? 0;
                                  if (num == 0 && isReady) {
                                    setDialogState(() => isReady = false);
                                  } else if (num > 0 && !isReady) {
                                    setDialogState(() => isReady = true);
                                  }
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
                              const Text('Status Ketersediaan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.surfaceBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isReady ? 'Siap Dijual' : 'Habis',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isReady ? AppColors.secondary : AppColors.error,
                                      ),
                                    ),
                                    Switch(
                                      value: isReady,
                                      activeThumbColor: AppColors.secondary,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          isReady = val;
                                          if (!val) {
                                            stockCtrl.text = '0';
                                          } else if (stockCtrl.text == '0') {
                                            stockCtrl.text = '15';
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Deskripsi Menu:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    const Text('URL Foto Menu:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: imgCtrl,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.image_outlined, size: 20)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text(
                          'Simpan Perubahan Menu',
                          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                        ),
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama menu tidak boleh kosong.'), backgroundColor: AppColors.error),
                            );
                            return;
                          }
                          final price = int.tryParse(priceCtrl.text) ?? item.price;
                          final stock = int.tryParse(stockCtrl.text) ?? item.stockCount;

                          final ok = await state.updateMenuItem(
                            id: item.id,
                            name: name,
                            price: price,
                            category: selectedCat,
                            description: descCtrl.text.trim(),
                            imageUrl: imgCtrl.text.trim(),
                            stockCount: stock,
                            isReadyStock: isReady,
                          );

                          if (ctx.mounted) Navigator.pop(ctx);
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Menu "$name" berhasil diperbarui!'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text('Hapus Menu Toko?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus menu "${item.name}" dari toko Anda? '
          'Menu ini tidak akan lagi ditampilkan kepada pembeli di katalog LuWe!.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              state.deleteMenuItem(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Menu "${item.name}" telah dihapus.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Hapus Menu', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showQuickStockDialog(BuildContext context, MenuItemModel item) {
    final stockCtrl = TextEditingController(text: item.stockCount.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ubah Jumlah Stok: ${item.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan jumlah stok porsi yang siap dijual:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Contoh: 25',
                suffixText: 'porsi',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockCtrl.text) ?? 0;
              state.setStockCount(item.id, newStock);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Stok "${item.name}" diperbarui menjadi $newStock porsi.'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            child: const Text('Simpan Stok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStore = state.currentSellerStore;
    final allStoreItems = state.sellerMenuItems;

    // Apply internal search and category filter on seller's own store items
    final items = allStoreItems.where((it) {
      final matchesSearch = _searchFilter.isEmpty ||
          it.name.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          it.description.toLowerCase().contains(_searchFilter.toLowerCase());
      final matchesCat = _selectedCategory == 'Semua Kategori' || it.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    final readyCount = allStoreItems.where((i) => i.isReadyStock && i.stockCount > 0).length;
    final outCount = allStoreItems.where((i) => !i.isReadyStock || i.stockCount == 0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner & Store Identity
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryContainer,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    currentStore?.bannerUrl ?? 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 72,
                      height: 72,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 36),
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
                          Flexible(
                            child: Text(
                              currentStore?.name ?? state.currentUser.storeName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CampusBadge.verified(),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (currentStore?.isOpen ?? state.currentUser.isStoreOpen)
                                  ? AppColors.secondaryLight
                                  : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (currentStore?.isOpen ?? state.currentUser.isStoreOpen) ? 'Toko Buka' : 'Toko Tutup',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: (currentStore?.isOpen ?? state.currentUser.isStoreOpen)
                                    ? AppColors.secondary
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            currentStore?.location ?? state.currentUser.storeLocation,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          const Text('•', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: 12),
                          Text(
                            '${allStoreItems.length} Menu Terdaftar',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($readyCount Ready • $outCount Habis)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (currentStore != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showAddMenuDialog(context, currentStore),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Tambah Menu Baru', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Filter & Search Controls within Store
          if (allStoreItems.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari menu di toko ${currentStore?.name ?? ""}...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchFilter = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Semua Kategori', child: Text('Semua Kategori Menu')),
                      DropdownMenuItem(value: 'Makanan Utama', child: Text('Makanan Utama')),
                      DropdownMenuItem(value: 'Minuman Segar', child: Text('Minuman Segar')),
                      DropdownMenuItem(value: 'Cemilan & Snack', child: Text('Cemilan & Snack')),
                      DropdownMenuItem(value: 'Paket Hemat', child: Text('Paket Hemat')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // 3. Empty State or Menu Items List
          if (allStoreItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded, size: 42, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum Ada Menu di Toko Anda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Text(
                      'Toko "${currentStore?.name ?? state.currentUser.storeName}" belum memiliki menu aktif. '
                      'Tambahkan produk makanan atau minuman dan atur stok agar pembeli di kampus UPN dapat mulai memesan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (currentStore != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAddMenuDialog(context, currentStore),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Tambah Menu Pertama', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
            )
          else if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('Tidak ada menu yang sesuai dengan kata kunci pencarian.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          else
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x05000000),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Product Photo Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 84,
                          height: 84,
                          color: AppColors.surfaceMuted,
                          child: const Icon(Icons.fastfood, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              item.isReadyStock && item.stockCount > 0 ? CampusBadge.readyStock() : CampusBadge.outOfStock(),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.category,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rp ${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              const Text('•', style: TextStyle(color: AppColors.textMuted)),
                              const SizedBox(width: 8),
                              Text(
                                'Terjual ${item.soldCount} porsi',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Interactive Stock Counter Stepper
                          Row(
                            children: [
                              const Text('Stok:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => state.setStockCount(item.id, item.stockCount - 1),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.surfaceBorder),
                                  ),
                                  child: const Icon(Icons.remove, size: 14, color: AppColors.textPrimary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _showQuickStockDialog(context, item),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.stockCount > 0 ? AppColors.secondaryLight : AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: item.stockCount > 0 ? const Color(0xFFBBF7D0) : const Color(0xFFFCA5A5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item.stockCount} porsi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: item.stockCount > 0 ? AppColors.secondaryDark : AppColors.error,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit, size: 11, color: AppColors.textMuted),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => state.setStockCount(item.id, item.stockCount + 1),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.surfaceBorder),
                                  ),
                                  child: const Icon(Icons.add, size: 14, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Quick Availability Switch & Action Buttons
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.isReadyStock && item.stockCount > 0 ? 'Siap Dijual' : 'Stok Habis',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: item.isReadyStock && item.stockCount > 0 ? AppColors.secondary : AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text('Ubah status instan', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: item.isReadyStock && item.stockCount > 0,
                          onChanged: (_) => state.toggleStock(item.id),
                          activeThumbColor: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        // Edit Menu Button
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                          tooltip: 'Edit Menu',
                          onPressed: () => _showEditMenuDialog(context, item),
                        ),
                        // Delete Menu Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          tooltip: 'Hapus Menu',
                          onPressed: () => _showDeleteConfirmDialog(context, item),
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
