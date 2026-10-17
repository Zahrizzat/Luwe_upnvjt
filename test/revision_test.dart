import 'package:flutter_test/flutter_test.dart';
import 'package:luwe_app/models/menu_item_model.dart';
import 'package:luwe_app/models/order_model.dart';
import 'package:luwe_app/providers/app_state.dart';
import 'package:luwe_app/services/database_service.dart';

void main() {
  setUpAll(() async {
    final db = DatabaseService();
    await db.resetTestState();
  });

  setUp(() async {
    final db = DatabaseService();
    await db.resetTestState();
  });

  group('Pengujian Pembaruan LuWe! Sesuai Revisi', () {
    test('4 & 5. Alur pesanan baru, status awal Menunggu Konfirmasi, pengurangan stok atomik, dan proteksi konfirmasi berulang', () async {
      final state = AppState();

      // Login as buyer to create order
      await state.login('hafidz@student.upnjatim.ac.id', 'password123');

      // Ambil menu toko_1
      final targetItem = state.menuItems.firstWhere((m) => m.merchantId == 'store_1' && m.stockCount > 5);
      final initialStock = targetItem.stockCount;
      const orderQty = 3;

      state.addToCart(targetItem, quantity: orderQty);

      // Pastikan stok belum berkurang saat hanya dimasukkan ke keranjang (Aturan #8)
      final stockInCart = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;
      expect(stockInCart, initialStock);

      // Checkout pesanan baru
      final order = state.placeOrder(
        deliveryMethod: DeliveryMethod.pickup,
        destinationLocation: 'Stan Usaha Mandiri FIK',
        paymentMethod: PaymentMethod.qris,
      );

      // Status awal HARUS waitingConfirmation (Menunggu Konfirmasi)
      expect(order.status, OrderStatus.waitingConfirmation);
      expect(order.isStockDeducted, false);

      // Stok MASIH belum berkurang sebelum dikonfirmasi oleh penjual
      final stockBeforeConfirm = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;
      expect(stockBeforeConfirm, initialStock);

      // Beralih ke akun Penjual Toko 1 (Adistya)
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      // Pesanan muncul di daftar pesanan penjual
      final sellerOrder = state.sellerOrders.firstWhere((o) => o.id == order.id);
      expect(sellerOrder.status, OrderStatus.waitingConfirmation);

      // Penjual mengonfirmasi pesanan
      final confirm1 = await state.updateSellerOrderStatus(order.id, OrderStatus.readyForPickupOrDelivery);
      expect(confirm1, true);

      // Status langsung berubah ke Siap Diambil / Diantar (Aturan #4)
      final confirmedOrder = state.sellerOrders.firstWhere((o) => o.id == order.id);
      expect(confirmedOrder.status, OrderStatus.readyForPickupOrDelivery);
      expect(confirmedOrder.isStockDeducted, true);

      // Stok produk berkurang tepat satu kali (Aturan #8)
      final stockAfterConfirm1 = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;
      expect(stockAfterConfirm1, initialStock - orderQty);

      // Uji konfirmasi berulang: Konfirmasi lagi tidak boleh mengurangi stok dua kali (Aturan #8 & D.5)
      final confirm2 = await state.updateSellerOrderStatus(order.id, OrderStatus.readyForPickupOrDelivery);
      expect(confirm2, true);
      final stockAfterConfirm2 = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;
      expect(stockAfterConfirm2, initialStock - orderQty); // Stok tetap sama!
    });

    test('6. Uji pembatalan/penolakan dan pastikan pengembalian stok terjadi tepat satu kali', () async {
      final state = AppState();
      await state.login('hafidz@student.upnjatim.ac.id', 'password123');

      final targetItem = state.menuItems.firstWhere((m) => m.merchantId == 'store_1' && m.stockCount > 5);
      final initialStock = targetItem.stockCount;
      const orderQty = 2;

      state.addToCart(targetItem, quantity: orderQty);
      final order = state.placeOrder(
        deliveryMethod: DeliveryMethod.pickup,
        destinationLocation: 'Stan Usaha Mandiri FIK',
        paymentMethod: PaymentMethod.cash,
      );

      // Switch ke penjual
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      // Konfirmasi -> stok berkurang
      await state.updateSellerOrderStatus(order.id, OrderStatus.readyForPickupOrDelivery);
      expect(state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount, initialStock - orderQty);

      // Pembatalan / Penolakan pesanan oleh penjual
      final cancel1 = await state.updateSellerOrderStatus(order.id, OrderStatus.cancelled);
      expect(cancel1, true);

      // Status pesanan menjadi cancelled
      final cancelledOrder = state.sellerOrders.firstWhere((o) => o.id == order.id);
      expect(cancelledOrder.status, OrderStatus.cancelled);

      // Stok dikembalikan tepat satu kali (Aturan #8 & D.6)
      final stockAfterCancel1 = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;
      expect(stockAfterCancel1, initialStock);

      // Uji pembatalan berulang: stok tidak boleh bertambah lagi secara keliru
      final cancel2 = await state.updateSellerOrderStatus(order.id, OrderStatus.cancelled);
      expect(cancel2, true);
      final stockAfterCancel2 = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;
      expect(stockAfterCancel2, initialStock);
    });

    test('Penyelesaian pesanan: Berpindah ke Selesai tanpa mengurangi stok kembali', () async {
      final state = AppState();
      await state.login('hafidz@student.upnjatim.ac.id', 'password123');

      final targetItem = state.menuItems.firstWhere((m) => m.merchantId == 'store_1' && m.stockCount > 5);
      final initialStock = targetItem.stockCount;
      const orderQty = 1;

      state.addToCart(targetItem, quantity: orderQty);
      final order = state.placeOrder(
        deliveryMethod: DeliveryMethod.pickup,
        destinationLocation: 'Stan Usaha Mandiri FIK',
        paymentMethod: PaymentMethod.qris,
      );

      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      // Konfirmasi pesanan -> stok berkurang 1
      await state.updateSellerOrderStatus(order.id, OrderStatus.readyForPickupOrDelivery);
      expect(state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount, initialStock - orderQty);

      // Selesaikan pesanan -> status Selesai
      final completeOk = await state.updateSellerOrderStatus(order.id, OrderStatus.completed);
      expect(completeOk, true);

      final completedOrder = state.sellerOrders.firstWhere((o) => o.id == order.id);
      expect(completedOrder.status, OrderStatus.completed);

      // Stok TIDAK berkurang lagi saat status berubah menjadi Selesai (Aturan #8 & D.4)
      final stockAfterComplete = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;
      expect(stockAfterComplete, initialStock - orderQty);
    });

    test('7. Uji isolasi minimal 2 toko agar data pesanan dan produk tidak tercampur', () async {
      final state = AppState();

      // Toko 1: Seller Adistya (store_1)
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      final store1Menus = state.sellerMenuItems;
      expect(store1Menus.every((m) => m.merchantId == 'store_1'), true);

      // Toko 2: Toko Baru Terverifikasi
      await state.register(
        fullName: 'Dimas Wicaksono',
        npm: '22081010088',
        email: 'dimas_store2@student.upnjatim.ac.id',
        password: 'password123',
        phone: '081234567899',
        userType: 'mahasiswa',
      );
      await state.submitStoreApplication(
        storeName: 'Danus FISIP Kreatif',
        storeLocation: 'Selasar Gedung FISIP Lt. 1',
        description: 'Usaha danusan mahasiswa FISIP UPN Veteran Jawa Timur',
        contactPhone: '081234567899',
      );
      await state.reviewCurrentStoreApplication(true);
      state.switchToSellerMode(); // Mode Penjual Toko 2

      final store2Menus = state.sellerMenuItems;
      // Toko baru harusnya kosong dan sama sekali tidak melihat produk Toko 1
      expect(store2Menus.isEmpty, true);

      // Tambah menu baru di Toko 2
      const newItem = MenuItemModel(
        id: 'menu_dimsum_fisip',
        merchantId: '',
        merchantName: '',
        merchantLocation: '',
        name: 'Snack Dimsum FISIP',
        description: 'Dimsum lezat danusan FISIP',
        price: 12000,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        category: 'Cemilan dan Snack',
        isReadyStock: true,
        stockCount: 15,
      );
      await state.addMenuItem(newItem);

      // Menu toko 2 sekarang berisi 1 item
      expect(state.sellerMenuItems.length, 1);
      expect(state.sellerMenuItems.first.name, 'Snack Dimsum FISIP');

      // Kembali ke Toko 1: Pastikan produk Toko 1 tetap terisolasi dan tidak kemasukan menu Toko 2
      final stateA = AppState();
      await stateA.login('adistya@student.upnjatim.ac.id', 'password123');
      stateA.switchToSellerMode();
      expect(stateA.sellerMenuItems.any((m) => m.name == 'Snack Dimsum FISIP'), false);
    });

    test('8. Uji edit nama toko, fakultas, lokasi berjualan, dan deskripsi toko penjual', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      const newStoreName = 'Danus SIFO Mandiri';
      const newFaculty = 'Fakultas Ilmu Komputer (FIK)';
      const newLocation = 'Gedung FIK Baru Ruang Danus';
      const newDesc = 'Usaha mandiri mahasiswa Sistem Informasi UPN Veteran Jawa Timur';
      const newSellerName = 'Adistya Eka Putri';
      const newPhone = '081233445566';

      final ok = await state.updateSellerStoreProfile(
        storeName: newStoreName,
        storeFaculty: newFaculty,
        storeLocation: newLocation,
        storeDescription: newDesc,
        sellerName: newSellerName,
        phoneNumber: newPhone,
      );
      expect(ok, true);

      // Periksa profil user
      expect(state.currentUser.storeName, newStoreName);
      expect(state.currentUser.storeLocation, newLocation);
      expect(state.currentUser.storeDescription, newDesc);
      expect(state.currentUser.storeFaculty, newFaculty);
      expect(state.currentUser.name, newSellerName);
      expect(state.currentUser.phoneNumber, newPhone);

      // Periksa katalog toko terupdate
      final storeInCatalog = state.stores.firstWhere((s) => s.id == 'store_1');
      expect(storeInCatalog.name, newStoreName);
      expect(storeInCatalog.location, newLocation);
      expect(storeInCatalog.description, newDesc);
      expect(storeInCatalog.faculty, newFaculty);

      // Periksa produk toko tetap utuh dan kepemilikan tidak rusak
      expect(state.sellerMenuItems.isNotEmpty, true);

      // Restore default store profile for test isolation
      await state.updateSellerStoreProfile(
        storeName: 'Warung Sambal Kampus UPN',
        storeFaculty: 'Fakultas Ilmu Komputer (FIK)',
        storeLocation: 'Selasar Gedung Bersama FIK Lt. 1',
        storeDescription: 'Kuliner pedas nikmat karya mahasiswa wirausaha UPN "Veteran" Jawa Timur.',
        sellerName: 'Adistya Putri',
        phoneNumber: '081987654321',
      );
    });
  });
}
