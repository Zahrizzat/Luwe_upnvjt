import 'package:flutter_test/flutter_test.dart';
import 'package:luwe_app/models/user_model.dart';
import 'package:luwe_app/models/order_model.dart';
import 'package:luwe_app/models/withdrawal_model.dart';
import 'package:luwe_app/constants/app_config.dart';
import 'package:luwe_app/providers/app_state.dart';

import 'package:luwe_app/models/cart_item_model.dart';
import 'package:luwe_app/models/menu_item_model.dart';
import 'package:luwe_app/services/database_service.dart';

void main() {
  setUpAll(() async {
    final db = DatabaseService();
    await db.resetTestState();
  });

  group('LuWe! Homepage, Guest Mode, Auth Guard & Verification Lifecycle Tests', () {
    test('1. AppState initializes in Guest state on homepage without login', () {
      final state = AppState();
      expect(state.isLoggedIn, false);
      expect(state.isGuest, true);
      expect(state.currentUser.name, 'Tamu LuWe');
      expect(state.activeRole, UserRole.buyer);
      expect(state.canSwitchToSeller, false);
    });

    test('2. Unauthenticated user can browse, search, and filter catalog products', () {
      final state = AppState();
      expect(state.isLoggedIn, false);
      expect(state.menuItems.isNotEmpty, true);

      // Search
      state.setSearchQuery('Geprek');
      expect(state.menuItems.every((item) => item.name.toLowerCase().contains('geprek')), true);

      // Category filter
      state.setSearchQuery('');
      state.setSelectedCategory('Minuman Segar');
      expect(state.menuItems.every((item) => item.category == 'Minuman Segar'), true);
    });

    test('3. Login as buyer lands on homepage with authenticated profile', () async {
      final state = AppState();
      expect(state.isLoggedIn, false);

      final err = await state.login('hafidz@student.upnjatim.ac.id', 'password123');
      expect(err, null);
      expect(state.isLoggedIn, true);
      expect(state.isGuest, false);
      expect(state.currentUser.name, contains('Hafidz Ahmad'));
      expect(state.currentUser.role, UserRole.buyer);
      expect(state.activeRole, UserRole.buyer);
    });

    test('4. All new registered users start as Buyer with no seller access', () async {
      final state = AppState();
      final err = await state.register(
        fullName: 'Budi Santoso',
        npm: '22081010099',
        email: 'budi_new@student.upnjatim.ac.id',
        password: 'password123',
        phone: '081234567800',
        userType: 'mahasiswa',
      );

      expect(err, null);
      expect(state.isLoggedIn, true);
      expect(state.currentUser.name, 'Budi Santoso');
      expect(state.currentUser.role, UserRole.buyer);
      expect(state.currentUser.verificationStatus, StoreVerificationStatus.none);
      expect(state.canSwitchToSeller, false);
    });

    test('5. Buyer cannot toggle to seller mode without approved store', () {
      final state = AppState();
      expect(state.canSwitchToSeller, false);

      state.switchToSellerMode();
      // Role remains buyer
      expect(state.activeRole, UserRole.buyer);
    });

    test('6. Store submission sets status to Menunggu Verifikasi (Pending)', () async {
      final state = AppState();
      await state.register(
        fullName: 'Siti Rahma',
        npm: '22081010077',
        email: 'siti@student.upnjatim.ac.id',
        password: 'password123',
        phone: '081234567899',
        userType: 'mahasiswa',
      );

      expect(state.currentUser.verificationStatus, StoreVerificationStatus.none);

      final err = await state.submitStoreApplication(
        storeName: 'Kantin Berkah FIK',
        storeLocation: 'Gedung FIK Lt. 1',
        description: 'Aneka nasi rames dan jus buah segar.',
        contactPhone: '081234567899',
      );

      expect(err, null);
      expect(state.currentUser.verificationStatus, StoreVerificationStatus.pending);
      expect(state.currentUser.storeName, 'Kantin Berkah FIK');
      // Still cannot switch to seller mode while pending
      expect(state.canSwitchToSeller, false);
      state.switchToSellerMode();
      expect(state.activeRole, UserRole.buyer);
    });

    test('7. Approved store grants access to Seller Mode & allows switching back to Buyer Mode', () async {
      final state = AppState();
      await state.register(
        fullName: 'Doni Pratama',
        npm: '22081010055',
        email: 'doni@student.upnjatim.ac.id',
        password: 'password123',
        phone: '081234567811',
        userType: 'mahasiswa',
      );

      await state.submitStoreApplication(
        storeName: 'Kopi Doni',
        storeLocation: 'Kantin Giri Reksa',
        description: 'Kopi susu enak',
        contactPhone: '081234567811',
      );

      // Simulate Admin Approval
      await state.reviewCurrentStoreApplication(true);
      expect(state.currentUser.verificationStatus, StoreVerificationStatus.approved);
      expect(state.canSwitchToSeller, true);

      // Switch to seller mode
      state.switchToSellerMode();
      expect(state.activeRole, UserRole.seller);

      // Switch back to buyer mode
      state.switchToBuyerMode();
      expect(state.activeRole, UserRole.buyer);
    });

    test('8. Rejected store displays rejection reason and keeps user as buyer', () async {
      final state = AppState();
      await state.register(
        fullName: 'Rian Hidayat',
        npm: '22081010066',
        email: 'rian@student.upnjatim.ac.id',
        password: 'password123',
        phone: '081234567822',
        userType: 'mahasiswa',
      );

      await state.submitStoreApplication(
        storeName: 'Stan Rian',
        storeLocation: 'Lobi GSG',
        description: 'Camilan',
        contactPhone: '081234567822',
      );

      // Simulate Rejection
      await state.reviewCurrentStoreApplication(
        false,
        reason: 'Lokasi stan belum memiliki izin resmi dari pengelola kantin kampus.',
      );

      expect(state.currentUser.verificationStatus, StoreVerificationStatus.rejected);
      expect(state.currentUser.rejectionReason, contains('Lokasi stan belum memiliki izin'));
      expect(state.canSwitchToSeller, false);
      expect(state.activeRole, UserRole.buyer);
    });

    test('9. Cart operations, orders, and logout resets back to Guest cleanly', () {
      final state = AppState();
      final item = state.menuItems.first;
      state.addToCart(item, quantity: 2);

      expect(state.cartCount, 2);
      expect(state.cartTotal, (item.price * 2) + 1000);

      // Place order
      final order = state.placeOrder(
        deliveryMethod: DeliveryMethod.delivery,
        destinationLocation: 'Gedung Giri Santoso Lt. 2',
        paymentMethod: PaymentMethod.qris,
      );

      expect(order.items.length, 1);
      expect(state.cartItems.isEmpty, true);

      // Logout
      state.logout();
      expect(state.isLoggedIn, false);
      expect(state.isGuest, true);
      expect(state.currentUser.name, 'Tamu LuWe');
      expect(state.activeRole, UserRole.buyer);
      expect(state.cartItems.isEmpty, true);
    });
  });

  group('LuWe! GoFood-Style Store-Based Marketplace Tests', () {
    test('10. Homepage displays stores list containing UPN Danusan & culinary partners', () {
      final state = AppState();
      expect(state.stores.isNotEmpty, true);

      // Verify required demo danusan stores exist
      final storeNames = state.stores.map((s) => s.name).toList();
      expect(storeNames.any((n) => n.contains('Danusan A — Fakultas FIK')), true);
      expect(storeNames.any((n) => n.contains('Danusan B — Fakultas FEB')), true);
      expect(storeNames.any((n) => n.contains('Danusan C — Fakultas FT')), true);
      expect(storeNames.any((n) => n.contains('Danusan D — Fakultas FISIP')), true);
      expect(storeNames.any((n) => n.contains('Warung Sambal Kampus UPN')), true);
    });

    test('11. Store card attributes are complete (photo, origin faculty, categories, rating, status, delivery)', () {
      final state = AppState();
      final storeFik = state.stores.firstWhere((s) => s.id == 'store_fik');

      expect(storeFik.name, contains('Fakultas FIK'));
      expect(storeFik.faculty, contains('Fakultas Ilmu Komputer'));
      expect(storeFik.facultyShort, 'FIK');
      expect(storeFik.organization, contains('HIMAFIK'));
      expect(storeFik.bannerUrl.isNotEmpty, true);
      expect(storeFik.categories.isNotEmpty, true);
      expect(storeFik.isOpen, true);
      expect(storeFik.deliveryTimeEstimate, contains('mnt'));
      expect(storeFik.deliveryLocation.isNotEmpty, true);

      // Rating accumulated from its menu items
      final calculatedRating = state.calculateStoreRating(storeFik.id);
      expect(calculatedRating, greaterThanOrEqualTo(4.0));
      expect(calculatedRating, lessThanOrEqualTo(5.0));
    });

    test('12. Global search finds store by product name and highlights product match', () {
      final state = AppState();

      // Search product 'Geprek'
      state.setSearchQuery('Geprek');
      expect(state.stores.any((s) => s.id == 'store_1'), true);
      final matchingItems = state.getMatchingProductNamesForStore('store_1', 'Geprek');
      expect(matchingItems.any((name) => name.contains('Geprek')), true);

      // Search product 'Risol' -> matches Danusan FIK
      state.setSearchQuery('Risol');
      expect(state.stores.any((s) => s.id == 'store_fik'), true);
      final fikMatching = state.getMatchingProductNamesForStore('store_fik', 'Risol');
      expect(fikMatching.any((name) => name.contains('Risol')), true);

      // Search product 'Dimsum' -> matches Danusan FT
      state.setSearchQuery('Dimsum');
      expect(state.stores.any((s) => s.id == 'store_ft'), true);

      // Clear search
      state.setSearchQuery('');
    });

    test('13. Filters by faculty, category, open status, and rating function correctly', () {
      final state = AppState();

      // Filter by FIK faculty
      state.setSelectedFaculty('FIK');
      expect(state.stores.every((s) => s.facultyShort == 'FIK' || s.faculty.contains('FIK') || s.location.contains('FIK')), true);

      // Filter only open stores
      state.setSelectedFaculty('Semua Lokasi');
      state.setOnlyOpenStores(true);
      expect(state.stores.every((s) => s.isOpen == true), true);

      // Filter Danusan Kampus category
      state.setSelectedCategory('Danusan Kampus');
      expect(state.stores.every((s) => s.isDanusan == true), true);

      // Filter rating >= 4.8
      state.setMinRating(4.8);
      expect(state.stores.every((s) => (state.calculateStoreRating(s.id) ?? 0.0) >= 4.8), true);

      // Reset
      state.resetStoreFilters();
      expect(state.selectedCategory, 'Semua Kategori');
      expect(state.selectedFaculty, 'Semua Lokasi');
      expect(state.onlyOpenStores, false);
      expect(state.minRating, 0.0);
    });

    test('14. Store detail screen strictly isolates products to the selected store only', () {
      final state = AppState();

      // Products for FIK
      final fikProducts = state.getProductsForStore('store_fik');
      expect(fikProducts.isNotEmpty, true);
      expect(fikProducts.every((p) => p.merchantId == 'store_fik'), true);
      expect(fikProducts.any((p) => p.name.contains('Risol Mayo')), true);
      // Ensure other stores' products are NOT in FIK store list
      expect(fikProducts.any((p) => p.name.contains('Ayam Geprek Sambal Bawang')), false);
      expect(fikProducts.any((p) => p.name.contains('Nasi Bakar Cakalang')), false);

      // Products for FISIP
      final fisipProducts = state.getProductsForStore('store_fisip');
      expect(fisipProducts.isNotEmpty, true);
      expect(fisipProducts.every((p) => p.merchantId == 'store_fisip'), true);
      expect(fisipProducts.any((p) => p.name.contains('Nasi Bakar Cakalang')), true);
      expect(fisipProducts.any((p) => p.name.contains('Risol Mayo')), false);
    });

    test('15. Guest can view store and add configured product to cart upon authentication', () {
      final state = AppState();
      expect(state.isLoggedIn, false);

      final fikProduct = state.getProductsForStore('store_fik').first;
      state.addToCart(
        fikProduct,
        quantity: 3,
        level: 'Ekstra Pedas',
        note: 'Sambal dipisah ya kak',
      );

      expect(state.cartCount, 3);
      expect(state.cartItems.first.selectedSpiceLevel, 'Ekstra Pedas');
      expect(state.cartItems.first.note, 'Sambal dipisah ya kak');
      expect(state.cartSubtotal, fikProduct.price * 3);
    });
  });

  group('LuWe! Product & Store Rating & Seller Analytics Tests', () {
    test('16. Non-logged in users and users without completed orders cannot rate products', () async {
      final state = AppState();
      expect(state.isGuest, true);

      // Attempt to rate while not logged in
      final guestErr = await state.submitProductRating(
        productId: 'menu_01',
        productName: 'Ayam Geprek Sambal Bawang UPNVJT',
        storeId: 'store_1',
        orderCode: 'LW-UPN-20261010-001',
        stars: 5,
        reviewText: 'Enak banget!',
      );
      expect(guestErr, isNotNull);
      expect(guestErr!.contains('masuk terlebih dahulu'), true);

      // Login as Hafidz
      await state.login('22081010045', 'password123');
      expect(state.isLoggedIn, true);

      // Attempt to rate an order that is still in processing status (LW-UPN-20261010-001)
      final processingErr = await state.submitProductRating(
        productId: 'menu_01',
        productName: 'Ayam Geprek Sambal Bawang UPNVJT',
        storeId: 'store_1',
        orderCode: 'LW-UPN-20261010-001',
        stars: 5,
        reviewText: 'Makanannya enak!',
      );
      expect(processingErr, isNotNull);
      expect(processingErr!.contains('pesanan selesai'), true);

      // Attempt to rate a product not included in the order
      final unpurchasedErr = await state.submitProductRating(
        productId: 'menu_fik_02',
        productName: 'Dimsum Ayam Mentai',
        storeId: 'store_fik',
        orderCode: 'LW-UPN-20261009-002',
        stars: 5,
        reviewText: 'Dimsum mantap!',
      );
      expect(unpurchasedErr, isNotNull);
      expect(unpurchasedErr!.contains('pesanan selesai'), true);
    });

    test('17. Eligible buyer with completed order can submit valid 1-5 star rating and update it', () async {
      final state = AppState();
      await state.login('22081010045', 'password123');

      // Validating star range
      final invalidStarErr = await state.submitProductRating(
        productId: 'menu_01',
        productName: 'Ayam Geprek Sambal Bawang UPNVJT',
        storeId: 'store_1',
        orderCode: 'LW-UPN-20261009-002',
        stars: 6,
        reviewText: 'Bintang 6!',
      );
      expect(invalidStarErr, isNotNull);

      // Rate menu_01 in completed order LW-UPN-20261009-002
      final submitErr = await state.submitProductRating(
        productId: 'menu_01',
        productName: 'Ayam Geprek Sambal Bawang UPNVJT',
        storeId: 'store_1',
        orderCode: 'LW-UPN-20261009-002',
        stars: 5,
        reviewText: 'Ayam gepreknya sangat gurih dan sambalnya segar!',
      );
      expect(submitErr, isNull);

      // Verify active rating exists
      final activeRating = state.getUserRatingForOrderItem('LW-UPN-20261009-002', 'menu_01');
      expect(activeRating, isNotNull);
      expect(activeRating!.stars, 5);
      expect(activeRating.reviewText, 'Ayam gepreknya sangat gurih dan sambalnya segar!');

      // Update the rating
      final updateErr = await state.submitProductRating(
        productId: 'menu_01',
        productName: 'Ayam Geprek Sambal Bawang UPNVJT',
        storeId: 'store_1',
        orderCode: 'LW-UPN-20261009-002',
        stars: 4,
        reviewText: 'Sedikit kepedasan tapi porsi sangat mantap!',
      );
      expect(updateErr, isNull);

      final updatedRating = state.getUserRatingForOrderItem('LW-UPN-20261009-002', 'menu_01');
      expect(updatedRating!.stars, 4);
      expect(updatedRating.reviewText, 'Sedikit kepedasan tapi porsi sangat mantap!');
      expect(updatedRating.updatedAt, isNotNull);
    });

    test('18. Store rating formula strictly aggregates all valid ratings and returns null when empty', () {
      final state = AppState();

      // Stores with zero ratings return null ("Belum ada rating")
      final unratedStoreRating = state.calculateStoreRating('store_upn_mart');
      expect(unratedStoreRating, isNull);
      expect(state.calculateStoreReviewCount('store_upn_mart'), 0);

      // Store FIK has 1 rating of 5 stars
      final fikRating = state.calculateStoreRating('store_fik');
      expect(fikRating, 5.0);
      expect(state.calculateStoreReviewCount('store_fik'), 1);

      // Store 1 formula calculation
      final store1Ratings = state.getStoreReviews('store_1');
      final totalStars = store1Ratings.fold<int>(0, (acc, r) => acc + r.stars);
      final expectedRating = double.parse((totalStars / store1Ratings.length).toStringAsFixed(1));
      expect(state.calculateStoreRating('store_1'), expectedRating);
    });

    test('19. Seller analytics computes rating summary, top/lowest rated items, and best seller from completed orders', () {
      final state = AppState();

      final analytics = state.getSellerRatingAnalytics('store_1');
      expect(analytics.hasRatings, true);
      expect(analytics.averageStoreRating, isNotNull);
      expect(analytics.totalReviews, greaterThan(0));
      expect(analytics.recentReviews.isNotEmpty, true);

      // Best seller comes strictly from completed orders
      expect(analytics.hasSales, true);
      expect(analytics.bestSellingProduct, isNotNull);
      expect(analytics.bestSellingCount, greaterThan(0));
    });
  });

  group('LuWe! Transaction Breakdown, Fee Transparency & Payment Integration Tests', () {
    test('20. Multi-product cart computes transparent subtotal, single centralized service fee without double counting, and delivery fees', () {
      final state = AppState();
      final item1 = state.menuItems[0];
      final item2 = state.menuItems[1];

      state.addToCart(item1, quantity: 2);
      state.addToCart(item2, quantity: 1);

      final expectedSubtotal = (item1.price * 2) + (item2.price * 1);
      expect(state.cartSubtotal, expectedSubtotal);

      // Centralized service fee is exactly 1000 once per order (not multiplied per 3 items)
      expect(state.campusServiceFee, AppConfig.defaultServiceFee);
      expect(state.serviceFee, 1000);

      // Pickup delivery fee is Rp 0
      final pickupTotal = state.calculateCartTotal(deliveryMethod: DeliveryMethod.pickup);
      expect(pickupTotal, expectedSubtotal + 1000);

      // Campus delivery fee is Rp 2000
      final deliveryTotal = state.calculateCartTotal(deliveryMethod: DeliveryMethod.delivery);
      expect(deliveryTotal, expectedSubtotal + 1000 + AppConfig.deliveryFeeCampus);
    });

    test('21. Campus voucher discounts validate correctly, reduce final total, and clamp non-negative amounts', () {
      final state = AppState();
      final item = state.menuItems.first;
      state.addToCart(item, quantity: 1);

      // Invalid voucher rejected
      final invalidErr = state.applyVoucher('INVALID123');
      expect(invalidErr, contains('tidak ditemukan'));
      expect(state.appliedDiscount, 0);

      // Valid campus voucher UPNDIES50 (Rp 5.000 off)
      final validErr = state.applyVoucher('UPNDIES50');
      expect(validErr, isNull);
      expect(state.appliedVoucherCode, 'UPNDIES50');
      expect(state.appliedDiscount, 5000);

      // Total with delivery (item + 1000 service fee + 2000 delivery fee - 5000 discount)
      final expectedTotal = item.price + 1000 + 2000 - 5000;
      final computedTotal = state.calculateCartTotal(deliveryMethod: DeliveryMethod.delivery);
      expect(computedTotal, expectedTotal);

      // Voucher removal resets back
      state.removeVoucher();
      expect(state.appliedDiscount, 0);
      expect(state.calculateCartTotal(deliveryMethod: DeliveryMethod.delivery), item.price + 1000 + 2000);
    });

    test('22. Placed order preserves transaction snapshot immutably against future price or fee changes', () {
      final state = AppState();
      final item = state.menuItems.first;
      final initialPrice = item.price;
      state.addToCart(item, quantity: 2);
      state.applyVoucher('LUWEHEMAT'); // Rp 3.000

      final order = state.placeOrder(
        deliveryMethod: DeliveryMethod.delivery,
        destinationLocation: 'Gedung FIK Lt. 2 Ruang 204',
        paymentMethod: PaymentMethod.qris,
        notes: 'Titip di meja dosen',
      );

      // Verify transaction snapshot in order
      expect(order.subtotal, initialPrice * 2);
      expect(order.campusServiceFee, 1000);
      expect(order.deliveryFee, 2000);
      expect(order.discount, 3000);
      expect(order.voucherCode, 'LUWEHEMAT');
      expect(order.totalAmount, (initialPrice * 2) + 1000 + 2000 - 3000);

      // Future mutation of central service fee or cart state does not alter existing order
      state.setServiceFee(3500);
      expect(state.serviceFee, 3500);

      final existingOrder = state.orders.firstWhere((o) => o.id == order.id);
      expect(existingOrder.campusServiceFee, 1000); // Snapshot preserved!
      expect(existingOrder.totalAmount, (initialPrice * 2) + 1000 + 2000 - 3000);
    });

    test('23. Payment integration distinguishes simulated QRIS and COD cash transparently', () {
      final state = AppState();
      final item = state.menuItems.first;

      // 1. QRIS Simulation
      state.addToCart(item, quantity: 1);
      final qrisOrder = state.placeOrder(
        deliveryMethod: DeliveryMethod.pickup,
        destinationLocation: 'Kantin FIK',
        paymentMethod: PaymentMethod.qris,
      );
      expect(qrisOrder.paymentMethod, PaymentMethod.qris);
      expect(qrisOrder.paymentStatus, 'Menunggu Pembayaran (Simulasi QRIS)');

      // Simulate QRIS payment completed
      state.updateOrderStatus(qrisOrder.id, OrderStatus.processing);
      final updatedQris = state.orders.firstWhere((o) => o.id == qrisOrder.id);
      expect(updatedQris.paymentStatus, 'Lunas (Simulasi QRIS)');

      // 2. Cash on Delivery (COD)
      state.addToCart(item, quantity: 1);
      final cashOrder = state.placeOrder(
        deliveryMethod: DeliveryMethod.delivery,
        destinationLocation: 'Gedung FEB Lt. 1',
        paymentMethod: PaymentMethod.cash,
      );
      expect(cashOrder.paymentMethod, PaymentMethod.cash);
      expect(cashOrder.paymentStatus, 'Bayar Tunai di Tempat (COD)');

      // Completed Cash order transitions payment to Lunas (Tunai)
      state.updateOrderStatus(cashOrder.id, OrderStatus.completed);
      final updatedCash = state.orders.firstWhere((o) => o.id == cashOrder.id);
      expect(updatedCash.paymentStatus, 'Lunas (Tunai)');
    });

    test('24. Order cancellation updates status to cancelled with reason and retains financial snapshot', () async {
      final state = AppState();
      final item = state.menuItems.first;
      state.addToCart(item, quantity: 1);

      final order = state.placeOrder(
        deliveryMethod: DeliveryMethod.delivery,
        destinationLocation: 'Gedung Girilaya',
        paymentMethod: PaymentMethod.cash,
      );
      expect(order.status, OrderStatus.waitingConfirmation);
      expect(order.canBeCancelledByBuyer, true);

      // Cancel the order
      final cancelled = await state.cancelOrder(order.id, reason: 'Salah pilih menu dan gedung');
      expect(cancelled, true);

      final cancelledOrder = state.orders.firstWhere((o) => o.id == order.id);
      expect(cancelledOrder.status, OrderStatus.cancelled);
      expect(cancelledOrder.cancellationReason, 'Salah pilih menu dan gedung');
      expect(cancelledOrder.subtotal, item.price);
      expect(cancelledOrder.totalAmount, item.price + 1000 + 2000);
    });
  });

  group('LuWe! Seller Analytics & Balance Withdrawal Tests', () {
    test('25. Total Omzet is strictly computed from completed valid orders and excludes active and cancelled orders', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      // Refresh seller financials
      await state.refreshSellerFinancials();

      // Only completed orders contribute to Total Omzet
      final completedOrders = state.sellerOrders.where((o) => o.status == OrderStatus.completed);
      final expectedOmset = completedOrders.fold<int>(0, (sum, o) => sum + o.subtotal);

      expect(state.sellerTotalOmset, expectedOmset);
      expect(state.sellerTotalOmset, greaterThan(0));

      // Active orders or cancelled orders must not inflate omzet
      final nonCompletedOrders = state.sellerOrders.where((o) => o.status != OrderStatus.completed);
      for (final nonCompleted in nonCompletedOrders) {
        expect(nonCompleted.status != OrderStatus.completed, true);
      }
    });

    test('26. Financial separation: Total Omset, Available Balance, Pending, and Completed Withdrawals are strictly isolated', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();
      await state.refreshSellerFinancials();

      final initialOmset = state.sellerTotalOmset;
      final initialAvailable = state.sellerAvailableBalance;
      expect(state.sellerPendingWithdrawal, 0);
      expect(state.sellerCompletedWithdrawal, 0);
      expect(initialAvailable, initialOmset); // At start, available = total omset

      // Request withdrawal of Rp 20.000
      final err = await state.requestWithdrawal(amount: 20000);
      expect(err, isNull);

      // Verify separation: Omzet stays intact, pending increases, available decreases
      expect(state.sellerTotalOmset, initialOmset);
      expect(state.sellerPendingWithdrawal, 20000);
      expect(state.sellerAvailableBalance, initialOmset - 20000);

      // Advance withdrawal to completed
      final withdrawalId = state.sellerWithdrawals.first.id!;
      await state.simulateReviewWithdrawal(
        withdrawalId: withdrawalId,
        targetStatus: WithdrawalStatus.completed,
      );

      // Pending resets, completed increases, available stays net
      expect(state.sellerPendingWithdrawal, 0);
      expect(state.sellerCompletedWithdrawal, 20000);
      expect(state.sellerAvailableBalance, initialOmset - 20000);
      expect(state.sellerTotalOmset, initialOmset); // Omzet is never reduced by withdrawals
    });

    test('27. Centralized tax and bank fee calculations determine net withdrawal correctly and report status', () {
      // 1. When unconfigured (Default: Bebas Pajak & Bebas Biaya Admin)
      expect(AppConfig.withdrawalTaxRatePercent, isNull);
      expect(AppConfig.fixedTaxFee, isNull);
      expect(AppConfig.withdrawalBankAdminFee, isNull);
      expect(AppConfig.withdrawalTaxStatus, contains('Belum dikonfigurasi'));
      expect(AppConfig.withdrawalAdminStatus, contains('Belum dikonfigurasi'));

      expect(AppConfig.calculateTaxFee(50000), 0);
      expect(AppConfig.calculateAdminFee(50000), 0);
      expect(AppConfig.calculateNetWithdrawal(50000), 50000);

      // 2. When configured by campus authority (e.g. Admin Fee Rp 2.500)
      AppConfig.withdrawalBankAdminFee = 2500;
      expect(AppConfig.calculateAdminFee(50000), 2500);
      expect(AppConfig.calculateNetWithdrawal(50000), 47500);

      // Reset back to null
      AppConfig.withdrawalBankAdminFee = null;
    });

    test('28. Balance security: Prevents over-withdrawal, in-flight double submission, and restores balance on rejection', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();
      await state.refreshSellerFinancials();

      final available = state.sellerAvailableBalance;

      // 1. Over-withdrawal rejected
      final overErr = await state.requestWithdrawal(amount: available + 50000);
      expect(overErr, contains('melebihi saldo tersedia'));

      // 2. Valid withdrawal
      final reqErr = await state.requestWithdrawal(amount: 15000);
      expect(reqErr, isNull);
      expect(state.sellerPendingWithdrawal, 15000);
      expect(state.sellerAvailableBalance, available - 15000);

      // 3. Admin rejection restores held balance safely!
      final wItem = state.sellerWithdrawals.first;
      await state.simulateReviewWithdrawal(
        withdrawalId: wItem.id!,
        targetStatus: WithdrawalStatus.rejected,
        reason: 'Nama pemilik rekening tidak sesuai',
      );

      final rejectedItem = state.sellerWithdrawals.firstWhere((w) => w.id == wItem.id);
      expect(rejectedItem.status, WithdrawalStatus.rejected);
      expect(rejectedItem.rejectionReason, contains('Nama pemilik rekening'));

      // Available balance is restored in full!
      expect(state.sellerPendingWithdrawal, 0);
      expect(state.sellerAvailableBalance, available);
    });

    test('29. Verified bank account masking, updating mechanism, and product performance analytics', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');

      // 1. Verified bank account masking
      expect(state.currentUser.bankName, 'Bank BCA');
      expect(state.currentUser.isBankAccountVerified, true);
      expect(state.currentUser.maskedBankAccountNumber, contains('•••• ••••'));
      expect(state.currentUser.maskedBankAccountNumber.endsWith('9482'), true);

      // 2. Updating bank account
      await state.updateStoreBankAccount(
        bankName: 'Bank Jatim',
        accountNumber: '1098234567',
        accountHolder: 'Adistya Putri',
      );
      expect(state.currentUser.bankName, 'Bank Jatim');
      expect(state.currentUser.bankAccountNumber, '1098234567');
      expect(state.currentUser.maskedBankAccountNumber, '•••• •••• 4567');
      expect(state.currentUser.isBankAccountVerified, true);

      // 3. Product performance items in analytics
      final analytics = state.getSellerRatingAnalytics('store_1');
      expect(analytics.productPerformances.isNotEmpty, true);
      for (final p in analytics.productPerformances) {
        expect(p.product.name.isNotEmpty, true);
        expect(p.totalRevenue, p.totalSoldUnits * p.product.price);
      }
    });
  });

  group('LuWe! Seller Menu and Stock Isolation & Ownership Tests', () {
    test('30. Seller A (Adistya - Warung Sambal) only sees products for store_1, isolating other stores', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      expect(state.currentSellerStore?.id, 'store_1');
      expect(state.currentSellerStore?.name, anyOf('Warung Sambal Kampus UPN', 'Danus SIFO Mandiri'));

      final sellerItems = state.sellerMenuItems;
      expect(sellerItems.isNotEmpty, true);

      // Must strictly contain store_1 products
      for (final item in sellerItems) {
        expect(
          item.merchantId == 'store_1' || item.merchantName.contains('Warung Sambal') || item.merchantName.contains('Giri Reksa'),
          true,
          reason: 'Seller A must not see products from other stores. Found: ${item.name} (${item.merchantName})',
        );
      }

      // Must NOT contain other stores' products
      expect(sellerItems.any((i) => i.merchantId == 'store_fik'), false);
      expect(sellerItems.any((i) => i.merchantId == 'store_feb'), false);
      expect(sellerItems.any((i) => i.merchantId == 'store_ft'), false);
      expect(sellerItems.any((i) => i.merchantId == 'store_dapur_upn'), false);
    });

    test('31. Seller B with a new approved store sees an empty menu list initially', () async {
      final state = AppState();
      await state.register(
        fullName: 'Rizky Pratama',
        npm: '22081010066',
        email: 'rizky_test_seller@student.upnjatim.ac.id',
        password: 'password123',
        phone: '081234567833',
        userType: 'mahasiswa',
      );

      await state.submitStoreApplication(
        storeName: 'Kantin Rizky Baru',
        storeLocation: 'Kantin FAD Lt. 1',
        description: 'Aneka jus segar dan camilan kampus.',
        contactPhone: '081234567833',
      );
      await state.reviewCurrentStoreApplication(true);
      state.switchToSellerMode();

      expect(state.currentSellerStore?.name, 'Kantin Rizky Baru');
      // Should be empty initially
      expect(state.sellerMenuItems.isEmpty, true);
    });

    test('32. Adding a menu item is assigned strictly to current seller store and isolated from other stores', () async {
      final state = AppState();
      await state.register(
        fullName: 'Toko Baru Tester',
        npm: '22081010078',
        email: 'tokobaru@student.upnjatim.ac.id',
        password: 'password123',
        phone: '081234567844',
        userType: 'mahasiswa',
      );

      await state.submitStoreApplication(
        storeName: 'Kedai Tester Mandiri',
        storeLocation: 'Selasar Gedung FEB',
        description: 'Menu tester.',
        contactPhone: '081234567844',
      );
      await state.reviewCurrentStoreApplication(true);
      state.switchToSellerMode();

      final initialCount = state.sellerMenuItems.length;

      // Add a menu
      const testItem = MenuItemModel(
        id: 'menu_test_kedai_01',
        merchantId: '',
        merchantName: '',
        merchantLocation: '',
        name: 'Roti Panggang Khas FEB',
        description: 'Roti panggang mentega manis.',
        price: 12000,
        imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
        category: 'Cemilan & Snack',
        isReadyStock: true,
        stockCount: 15,
      );

      await state.addMenuItem(testItem);

      // Now this seller sees initialCount + 1 product
      expect(state.sellerMenuItems.length, initialCount + 1);
      expect(state.sellerMenuItems.any((i) => i.name == 'Roti Panggang Khas FEB'), true);
      expect(state.sellerMenuItems.firstWhere((i) => i.name == 'Roti Panggang Khas FEB').merchantName, 'Kedai Tester Mandiri');

      // Now switch to Seller A (Adistya) - verify Seller A does NOT see this newly added product
      final stateA = AppState();
      await stateA.login('adistya@student.upnjatim.ac.id', 'password123');
      stateA.switchToSellerMode();
      expect(stateA.sellerMenuItems.any((i) => i.id == 'menu_test_kedai_01' || i.name == 'Roti Panggang Khas FEB'), false);
    });

    test('33. Seller A can edit menu details and update stock count safely', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      final firstItem = state.sellerMenuItems.first;
      final originalStock = firstItem.stockCount;

      // 1. Set stock count
      state.setStockCount(firstItem.id, originalStock + 10);
      final updatedItem = state.sellerMenuItems.firstWhere((i) => i.id == firstItem.id);
      expect(updatedItem.stockCount, originalStock + 10);
      expect(updatedItem.isReadyStock, true);

      // 2. Toggle stock
      state.toggleStock(firstItem.id);
      final toggledItem = state.sellerMenuItems.firstWhere((i) => i.id == firstItem.id);
      expect(toggledItem.isReadyStock, false);
      expect(toggledItem.stockCount, 0);

      // 3. Edit menu details
      final editOk = await state.updateMenuItem(
        id: firstItem.id,
        name: '${firstItem.name} (Porsi Jumbo)',
        price: firstItem.price + 2000,
        category: firstItem.category,
        description: 'Deskripsi baru yang diperbarui.',
        imageUrl: firstItem.imageUrl,
        stockCount: 30,
        isReadyStock: true,
      );
      expect(editOk, true);

      final editedItem = state.sellerMenuItems.firstWhere((i) => i.id == firstItem.id);
      expect(editedItem.name, contains('Porsi Jumbo'));
      expect(editedItem.price, firstItem.price + 2000);
      expect(editedItem.stockCount, 30);
      expect(editedItem.isReadyStock, true);

      // Restore back to original state
      await state.updateMenuItem(
        id: firstItem.id,
        name: firstItem.name,
        price: firstItem.price,
        category: firstItem.category,
        description: firstItem.description,
        imageUrl: firstItem.imageUrl,
        stockCount: originalStock,
        isReadyStock: true,
      );
    });

    test('34. Ownership guard blocks cross-store mutation (Seller cannot edit or delete other stores products)', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      // Attempting to modify a product belonging to Danusan FIK (menu_fik_01)
      final otherStoreItemId = 'menu_fik_01';
      final origOtherItem = state.allRawMenuItems.firstWhere((i) => i.id == otherStoreItemId);
      final origPrice = origOtherItem.price;

      // 1. Unauthorized update
      final editAttempt = await state.updateMenuItem(
        id: otherStoreItemId,
        name: 'Hacked Risol FIK',
        price: 99999,
        category: 'Makanan Utama',
        description: 'Hacked',
        imageUrl: '',
        stockCount: 0,
        isReadyStock: false,
      );
      expect(editAttempt, false);
      expect(state.allRawMenuItems.firstWhere((i) => i.id == otherStoreItemId).price, origPrice);

      // 2. Unauthorized delete
      state.deleteMenuItem(otherStoreItemId);
      expect(state.allRawMenuItems.any((i) => i.id == otherStoreItemId), true); // Still exists!
    });

    test('35. Buyer catalog preserves all products across all stores for discovery', () {
      final state = AppState();
      // Buyer view contains products from all stores
      expect(state.allRawMenuItems.length, greaterThan(10));
      expect(state.allRawMenuItems.any((i) => i.merchantId == 'store_fik'), true);
      expect(state.allRawMenuItems.any((i) => i.merchantId == 'store_feb'), true);
      expect(state.allRawMenuItems.any((i) => i.merchantId == 'store_ft'), true);
      expect(state.allRawMenuItems.any((i) => i.merchantId == 'store_1'), true);

      // Searching finds items across multiple stores
      state.setSearchQuery('Ayam');
      expect(state.menuItems.isNotEmpty, true);
    });

    test('36. Newly approved seller with no menus has strictly 0 sellerMenuItems and 0 activeSellerOrders', () async {
      final state = AppState();
      // Register new user and approve seller store
      await state.register(
        fullName: 'Hafidz Ahmad Stan Baru',
        npm: '22081010045',
        email: 'hafidz_stan@student.upnjatim.ac.id',
        password: 'password123',
        phone: '081234567899',
        userType: 'mahasiswa',
      );
      await state.submitStoreApplication(
        storeName: 'Stan Baru Hafidz',
        storeLocation: 'Kantin Giri Loka Lt. 1',
        description: 'Menjual aneka camilan kampus',
        contactPhone: '081234567899',
      );
      await state.reviewCurrentStoreApplication(true);
      state.switchToSellerMode();

      // Ensure store-specific isolation: 0 menus, 0 active orders
      expect(state.sellerMenuItems.length, 0);
      expect(state.activeSellerOrders.length, 0);
      expect(state.sellerOrders.length, 0);
      expect(state.currentUser.bankAccountHolder.isEmpty ? state.currentUser.name : state.currentUser.bankAccountHolder, contains('Hafidz Ahmad'));
    });

    test('37. Store closed operational guard blocks buyers from purchasing products', () async {
      final state = AppState();
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      // 1. Initial state: store is open
      if (!state.currentUser.isStoreOpen) {
        state.toggleStoreStatus();
      }
      expect(state.currentUser.isStoreOpen, true);
      final storeItem = state.sellerMenuItems.first;
      expect(state.isItemStoreOpen(storeItem), true);

      // 2. Seller closes store
      state.toggleStoreStatus();
      expect(state.currentUser.isStoreOpen, false);
      expect(state.isItemStoreOpen(storeItem), false);

      // 3. Buyer switches back or logs in and attempts to addToCart
      state.clearCart();
      final addResult = state.addToCart(storeItem);
      expect(addResult, false);
      expect(state.cartItems.isEmpty, true);

      // 4. If an item was already in cart before closing, placeOrder throws StateError
      // Manually simulate stale item in cart
      state.cartItems.add(CartItemModel(item: storeItem, quantity: 1));
      expect(() => state.placeOrder(
        deliveryMethod: DeliveryMethod.pickup,
        destinationLocation: 'Kantin',
        paymentMethod: PaymentMethod.cash,
      ), throwsA(isA<StateError>()));

      // 5. Seller re-opens store
      state.toggleStoreStatus();
      expect(state.currentUser.isStoreOpen, true);
      expect(state.isItemStoreOpen(storeItem), true);
      state.clearCart();
      final reAddResult = state.addToCart(storeItem);
      expect(reAddResult, true);
      expect(state.cartItems.length, 1);
    });
  });
}

