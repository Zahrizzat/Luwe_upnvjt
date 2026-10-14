import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/order_model.dart';
import '../providers/app_state.dart';
import 'auth_guard_dialog.dart';
import 'qris_dialog.dart';

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
      TextEditingController(text: 'Kantin Giri Reksa');
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
                                      Text(
                                        cartItem.selectedSpiceLevel,
                                        style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
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
                                    Text('Ambil di Kantin'),
                                  ],
                                ),
                                selected: _deliveryMethod == DeliveryMethod.pickup,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _deliveryMethod = DeliveryMethod.pickup;
                                      _destinationController.text = 'Ambil di Kantin Giri Reksa';
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
                                    Text('Kirim ke Gedung'),
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

                        // Saved Favorite Locations Chips (if delivery selected)
                        if (_deliveryMethod == DeliveryMethod.delivery && state.deliveryLocations.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pilih Titik Favoritmu:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                              Text(
                                '${state.deliveryLocations.length} Tersimpan',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.deliveryLocations.map((loc) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  child: ActionChip(
                                    avatar: Icon(Icons.place_rounded, size: 14, color: loc.isPrimary ? AppColors.secondaryDark : AppColors.primary),
                                    label: Text('${loc.title}${loc.isPrimary ? " (Utama)" : ""}'),
                                    onPressed: () {
                                      setState(() {
                                        _destinationController.text = '${loc.title} • ${loc.areaName} (${loc.detailAddress})';
                                        if (_notesController.text.isEmpty && loc.deliveryNote != null) {
                                          _notesController.text = loc.deliveryNote!;
                                        }
                                      });
                                    },
                                    backgroundColor: loc.isPrimary ? const Color(0xFFF0FDF4) : AppColors.canvas,
                                    side: BorderSide(color: loc.isPrimary ? const Color(0xFF86EFAC) : AppColors.surfaceBorder),
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      fontWeight: loc.isPrimary ? FontWeight.w800 : FontWeight.w600,
                                      color: loc.isPrimary ? AppColors.secondaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.canvas,
                  border: Border(
                    top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Pesanan:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Rp ${state.cartSubtotal}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Layanan Kampus:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Rp ${state.campusServiceFee}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        Text(
                          'Rp ${state.cartTotal}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!state.isLoggedIn) {
                            AuthGuardDialog.requireAuth(
                              context,
                              state,
                              message: 'Masuk ke akun Luwe kamu untuk menyelesaikan dan memproses pesanan.',
                              onAuthenticated: () {
                                final newOrder = state.placeOrder(
                                  deliveryMethod: _deliveryMethod,
                                  destinationLocation: _destinationController.text,
                                  paymentMethod: _paymentMethod,
                                  notes: _notesController.text,
                                );
                                Navigator.pop(context);

                                if (_paymentMethod == PaymentMethod.qris) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => QrisPaymentDialog(order: newOrder, state: state),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Pesanan Berhasil Dibuat: ${newOrder.id}! Siapkan uang pas saat terima.'),
                                      backgroundColor: AppColors.secondary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
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

                          if (_paymentMethod == PaymentMethod.qris) {
                            showDialog(
                              context: context,
                              builder: (ctx) => QrisPaymentDialog(order: newOrder, state: state),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pesanan Berhasil Dibuat: ${newOrder.id}! Siapkan uang pas saat terima.'),
                                backgroundColor: AppColors.secondary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _paymentMethod == PaymentMethod.qris
                              ? 'Lanjut ke QRIS (Rp ${state.cartTotal})'
                              : 'Konfirmasi Pesanan Tunai',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
