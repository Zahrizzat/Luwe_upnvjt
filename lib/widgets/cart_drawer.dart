import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/order_model.dart';
import '../providers/app_state.dart';
import 'auth_guard_dialog.dart';
import 'order_confirmation_dialog.dart';

class CartDrawer extends StatefulWidget {
  final AppState state;

  const CartDrawer({super.key, required this.state});

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  DeliveryMethod _deliveryMethod = DeliveryMethod.pickup;
  PaymentMethod _paymentMethod = PaymentMethod.qris;
  final TextEditingController _destinationController =
      TextEditingController(text: 'Stan / Toko Usaha Mahasiswa');
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final items = state.cartItems;

    return Drawer(
      width: 480,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Keranjang Kampus (${state.cartCount})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Item List
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'Keranjangmu Masih Kosong',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Ayo jelajahi aneka kuliner lezat khas kampus UPN!',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Cart Items
                        ...items.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final cartItem = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    cartItem.item.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.surfaceMuted,
                                      child: const Icon(Icons.fastfood, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.item.name,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (!state.isItemStoreOpen(cartItem.item))
                                        Container(
                                          margin: const EdgeInsets.symmetric(vertical: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDC2626),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Toko Tutup',
                                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp ${cartItem.item.price} x ${cartItem.quantity} = Rp ${cartItem.subtotal}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 14),
                                      onPressed: () => state.updateCartQuantity(idx, -1),
                                      style: IconButton.styleFrom(
                                        padding: const EdgeInsets.all(4),
                                        minimumSize: Size.zero,
                                      ),
                                    ),
                                    Text(
                                      '${cartItem.quantity}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 14),
                                      onPressed: () => state.updateCartQuantity(idx, 1),
                                      style: IconButton.styleFrom(
                                        padding: const EdgeInsets.all(4),
                                        minimumSize: Size.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),

                        // Delivery Method
                        const Text(
                          'Pilih Metode Pengambilan:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.storefront_rounded, size: 16),
                                    SizedBox(width: 6),
                                    Text('Ambil di Stan (Rp 0)'),
                                  ],
                                ),
                                selected: _deliveryMethod == DeliveryMethod.pickup,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _deliveryMethod = DeliveryMethod.pickup;
                                      _destinationController.text = 'Ambil di Stan Usaha Mahasiswa';
                                    });
                                  }
                                },
                                selectedColor: AppColors.primaryLight,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _deliveryMethod == DeliveryMethod.pickup
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delivery_dining_rounded, size: 16),
                                    SizedBox(width: 6),
                                    Text('Antar Gedung (+Rp 2.000)'),
                                  ],
                                ),
                                selected: _deliveryMethod == DeliveryMethod.delivery,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _deliveryMethod = DeliveryMethod.delivery;
                                      final primary = state.primaryDeliveryLocation;
                                      if (primary != null) {
                                        _destinationController.text = '${primary.title} • ${primary.areaName} (${primary.detailAddress})';
                                        if (_notesController.text.isEmpty && primary.deliveryNote != null) {
                                          _notesController.text = primary.deliveryNote!;
                                        }
                                      } else {
                                        _destinationController.text = 'Gedung Giri Santoso Lt. 2 - Depan Lab RPL';
                                      }
                                    });
                                  }
                                },
                                selectedColor: AppColors.primaryLight,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _deliveryMethod == DeliveryMethod.delivery
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),


                        // Location Details
                        Text(
                          _deliveryMethod == DeliveryMethod.pickup
                              ? 'Lokasi Pengambilan:'
                              : 'Tujuan Pengantaran (Gedung / Ruang):',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _destinationController,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.place_rounded, size: 18, color: AppColors.primary),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Payment Method
                        const Text(
                          'Pilih Metode Pembayaran:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code_2_rounded, size: 16),
                                    SizedBox(width: 6),
                                    Text('QRIS Instant'),
                                  ],
                                ),
                                selected: _paymentMethod == PaymentMethod.qris,
                                onSelected: (val) {
                                  if (val) setState(() => _paymentMethod = PaymentMethod.qris);
                                },
                                selectedColor: const Color(0xFFE0F2FE),
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _paymentMethod == PaymentMethod.qris
                                      ? const Color(0xFF0369A1)
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.payments_outlined, size: 16),
                                    SizedBox(width: 6),
                                    Text('Tunai / Cash'),
                                  ],
                                ),
                                selected: _paymentMethod == PaymentMethod.cash,
                                onSelected: (val) {
                                  if (val) setState(() => _paymentMethod = PaymentMethod.cash);
                                },
                                selectedColor: AppColors.secondaryLight,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _paymentMethod == PaymentMethod.cash
                                      ? AppColors.secondaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Notes
                        const Text('Catatan Tambahan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _notesController,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'Misal: Titipkan di satpam lobi jika sedang ujian...',
                          ),
                        ),

                      ],
                    ),
            ),

            // Footer / Checkout Summary
            if (items.isNotEmpty)
              Builder(
                builder: (context) {
                  final subtotal = state.cartSubtotal;
                  final serviceFee = state.campusServiceFee;
                  final deliveryFee = state.getDeliveryFee(_deliveryMethod);
                  final discount = state.appliedDiscount;
                  final total = state.calculateCartTotal(deliveryMethod: _deliveryMethod);
                  final closedItems = items.where((ci) => !state.isItemStoreOpen(ci.item)).toList();
                  final hasClosedStoreItems = closedItems.isNotEmpty;

                  void executeCheckout() {
                    if (hasClosedStoreItems) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tidak dapat checkout karena ada menu dari toko yang sedang tutup.'),
                          backgroundColor: Color(0xFFDC2626),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final newOrder = state.placeOrder(
                      deliveryMethod: _deliveryMethod,
                      destinationLocation: _destinationController.text,
                      paymentMethod: _paymentMethod,
                      notes: _notesController.text,
                    );
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (ctx) => OrderConfirmationDialog(
                        order: newOrder,
                        state: state,
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.canvas,
                      border: Border(
                        top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (hasClosedStoreItems) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Menu ${closedItems.map((c) => "\"${c.item.name}\"").join(", ")} berasal dari toko yang sedang tutup. Harap hapus item tersebut untuk melanjutkan pesanan.',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal Produk:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('Rp $subtotal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Biaya Layanan LuWe!:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('Rp $serviceFee', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Biaya Pengantaran:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(
                              _deliveryMethod == DeliveryMethod.pickup
                                  ? 'Gratis (Rp 0)'
                                  : 'Rp $deliveryFee',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _deliveryMethod == DeliveryMethod.pickup ? AppColors.secondaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (discount > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Diskon Voucher (${state.appliedVoucherCode}):',
                                style: const TextStyle(fontSize: 12, color: AppColors.secondaryDark, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '-Rp $discount',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.secondaryDark),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                            Text(
                              'Rp $total',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: hasClosedStoreItems
                                ? null
                                : () {
                                    if (!state.isLoggedIn) {
                                      AuthGuardDialog.requireAuth(
                                        context,
                                        state,
                                        message: 'Masuk ke akun Luwe kamu untuk menyelesaikan dan memproses pesanan.',
                                        onAuthenticated: executeCheckout,
                                      );
                                      return;
                                    }
                                    executeCheckout();
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              hasClosedStoreItems
                                  ? 'Toko Penjual Sedang Tutup'
                                  : (_paymentMethod == PaymentMethod.qris
                                      ? 'Lanjut ke QRIS (Rp $total)'
                                      : 'Konfirmasi Pesanan Tunai (Rp $total)'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
