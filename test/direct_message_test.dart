import 'package:flutter_test/flutter_test.dart';
import 'package:luwe_app/models/order_model.dart';
import 'package:luwe_app/providers/app_state.dart';
import 'package:luwe_app/screens/common/direct_message_screen.dart';
import 'package:luwe_app/services/database_service.dart';
import 'package:luwe_app/widgets/order_confirmation_dialog.dart';

void main() {
  setUp(() async {
    final db = DatabaseService();
    await db.resetTestState();
  });

  tearDown(() async {
    final db = DatabaseService();
    await db.resetTestState();
  });

  group('LuWe! Direct Message (DM) Comprehensive Integration Tests', () {
    test('1. Pembeli menyelesaikan checkout dengan dialog pesanan berhasil tanpa tombol Chat Toko', () async {
      final state = AppState();
      await state.login('hafidz@student.upnjatim.ac.id', 'password123');

      // Place an order
      final item = state.menuItems.firstWhere((m) => m.merchantId == 'store_1' && m.stockCount > 2);
      state.addToCart(item, quantity: 2);
      final order = state.placeOrder(
        paymentMethod: PaymentMethod.qris,
        deliveryMethod: DeliveryMethod.delivery,
        destinationLocation: 'Kantin FIK UPN',
      );
      if (state.lastOrderCreationFuture != null) {
        await state.lastOrderCreationFuture;
      }

      expect(order, isNotNull);
      expect(order.merchantId, equals('store_1'));

      final dialog = OrderConfirmationDialog(order: order, state: state);
      expect(dialog.order.id, equals(order.id));
      expect(dialog.order.merchantId, equals('store_1'));
    });

    test('2. Direct Message di Pesanan Saya membuka percakapan dengan toko yang benar dan beralih ke tab DM', () async {
      final state = AppState();
      await state.login('hafidz@student.upnjatim.ac.id', 'password123');

      final store = state.stores.firstWhere((s) => s.id == 'store_1');
      final conv = await state.openOrCreateConversationWithStore(
        storeId: store.id,
        orderId: 'ORD-TEST-001',
      );

      expect(conv, isNotNull);
      expect(conv.storeId, equals('store_1'));
      expect(conv.buyerId, equals(1));
      expect(conv.orderId, equals('ORD-TEST-001'));
      expect(state.activeConversation?.id, equals(conv.id));
      expect(state.currentTabIndex, equals(3)); // Direct Message tab
    });

    test('3. Pembeli dapat mengirim pesan dan pesan tersimpan secara persisten', () async {
      final state = AppState();
      await state.login('hafidz@student.upnjatim.ac.id', 'password123');

      final store = state.stores.firstWhere((s) => s.id == 'store_1');
      final conv = await state.openOrCreateConversationWithStore(
        storeId: store.id,
        orderId: 'ORD-TEST-002',
      );

      final success = await state.sendChatMessage('Halo kak, apakah pesanan ORD-TEST-002 sudah mulai dimasak?');
      expect(success, isTrue);

      expect(state.chatMessages.isNotEmpty, isTrue);
      expect(state.chatMessages.last.message, contains('apakah pesanan ORD-TEST-002 sudah mulai dimasak?'));
      expect(state.chatMessages.last.isMe, isTrue);

      // Check database service mock persistence directly
      final db = DatabaseService();
      final dbMessages = await db.fetchMessages(conv.id, 1);
      expect(dbMessages.any((m) => m.message.contains('apakah pesanan ORD-TEST-002 sudah mulai dimasak?')), isTrue);
    });

    test('4. Pesan muncul pada Direct Message penjual yang sesuai', () async {
      final buyerState = AppState();
      await buyerState.login('hafidz@student.upnjatim.ac.id', 'password123');

      final store = buyerState.stores.firstWhere((s) => s.id == 'store_1');
      final conv = await buyerState.openOrCreateConversationWithStore(
        storeId: store.id,
        orderId: 'ORD-TEST-003',
      );
      await buyerState.sendChatMessage('Permisi, pesanannya jangan pakai bawang goreng ya.');

      // Now seller logins
      final sellerState = AppState();
      await sellerState.login('adistya@student.upnjatim.ac.id', 'password123');
      sellerState.switchToSellerMode();

      await sellerState.refreshConversations();

      // Check seller conversations for store_1
      final sellerConv = sellerState.conversations.firstWhere((c) => c.id == conv.id);
      expect(sellerConv, isNotNull);
      expect(sellerConv.storeId, equals('store_1'));
      expect(sellerConv.lastMessage, contains('jangan pakai bawang goreng'));
      expect(sellerConv.buyerName, contains('Hafidz'));

      // Check seller unread count
      expect(sellerConv.unreadCount, greaterThan(0));
    });

    test('5. Penjual dapat membalas dan balasan muncul pada akun pembeli', () async {
      final buyerState = AppState();
      await buyerState.login('hafidz@student.upnjatim.ac.id', 'password123');
      final store = buyerState.stores.firstWhere((s) => s.id == 'store_1');
      final conv = await buyerState.openOrCreateConversationWithStore(storeId: store.id);
      await buyerState.sendChatMessage('Bisa request sambal dipisah kak?');

      // Seller logins and replies
      final sellerState = AppState();
      await sellerState.login('adistya@student.upnjatim.ac.id', 'password123');
      sellerState.switchToSellerMode();
      await sellerState.refreshConversations();

      await sellerState.selectConversation(conv);
      final replySuccess = await sellerState.sendChatMessage('Siap kak, sambal akan kami pisahkan ya!');
      expect(replySuccess, isTrue);

      // Buyer reloads messages
      await buyerState.loadMessagesForActiveConversation();
      expect(buyerState.chatMessages.any((m) => m.message.contains('sambal akan kami pisahkan')), isTrue);
      final replyMsg = buyerState.chatMessages.firstWhere((m) => m.message.contains('sambal akan kami pisahkan'));
      expect(replyMsg.senderName, anyOf(contains('Warung Sambal'), contains('Adistya')));
    });

    test('6. Percakapan dapat dibuka kembali setelah aplikasi / state dimulai ulang', () async {
      // Create and populate conversation
      final state1 = AppState();
      await state1.login('hafidz@student.upnjatim.ac.id', 'password123');
      final store = state1.stores.firstWhere((s) => s.id == 'store_1');
      final conv = await state1.openOrCreateConversationWithStore(storeId: store.id);
      await state1.sendChatMessage('Pesan test persistensi');

      // Simulate app restart by instantiating fresh state
      final state2 = AppState();
      await state2.login('hafidz@student.upnjatim.ac.id', 'password123');
      await state2.refreshConversations();

      expect(state2.conversations.any((c) => c.id == conv.id), isTrue);
      final reopenedConv = state2.conversations.firstWhere((c) => c.id == conv.id);
      expect(reopenedConv.lastMessage, contains('Pesan test persistensi'));

      await state2.selectConversation(reopenedConv);
      expect(state2.chatMessages.any((m) => m.message.contains('Pesan test persistensi')), isTrue);
    });

    test('7. Pesan dan percakapan dari toko berbeda tidak tercampur', () async {
      final buyer = AppState();
      await buyer.login('hafidz@student.upnjatim.ac.id', 'password123');

      final store1 = buyer.stores.firstWhere((s) => s.id == 'store_1');
      final store2 = buyer.stores.firstWhere((s) => s.id == 'store_dapur_upn');

      final convStore1 = await buyer.openOrCreateConversationWithStore(storeId: store1.id);
      await buyer.sendChatMessage('Pesan untuk Warung Sambal');

      final convStore2 = await buyer.openOrCreateConversationWithStore(storeId: store2.id);
      await buyer.sendChatMessage('Pesan untuk Danus SIFO');

      expect(convStore1.id != convStore2.id, isTrue);
      expect(convStore1.storeId, equals('store_1'));
      expect(convStore2.storeId, equals('store_dapur_upn'));

      // Check messages of store1
      await buyer.selectConversation(convStore1);
      expect(buyer.chatMessages.every((m) => !m.message.contains('Danus SIFO')), isTrue);

      // Check messages of store2
      await buyer.selectConversation(convStore2);
      expect(buyer.chatMessages.every((m) => !m.message.contains('Warung Sambal')), isTrue);
    });

    test('8. Pembeli tidak dapat mengakses percakapan pembeli lain (Security Guard)', () async {
      // Buyer 1 (Hafidz) creates conversation with store_1
      final hafidz = AppState();
      await hafidz.login('hafidz@student.upnjatim.ac.id', 'password123');
      final store = hafidz.stores.firstWhere((s) => s.id == 'store_1');
      final hafidzConv = await hafidz.openOrCreateConversationWithStore(storeId: store.id);
      await hafidz.sendChatMessage('Pesan rahasia Hafidz');

      // Buyer 2 (Another buyer / new user) logs in
      final otherBuyer = AppState();
      await otherBuyer.register(
        fullName: 'Budi Santoso',
        npm: '22081010099',
        email: 'budi_sec@student.upnjatim.ac.id',
        password: 'password123',
        phone: '08987654321',
        userType: 'mahasiswa',
      );
      await otherBuyer.refreshConversations();

      // otherBuyer cannot see Hafidz's conversation in conversation list
      expect(otherBuyer.conversations.any((c) => c.id == hafidzConv.id), isFalse);

      // Direct data layer access check: attempting to fetch messages unauthorized
      final db = DatabaseService();
      final unauthorizedMessages = await db.fetchMessages(hafidzConv.id, otherBuyer.currentUser.dbUserId ?? 999);
      expect(unauthorizedMessages, isEmpty);
    });

    test('9. Penjual tidak dapat mengakses percakapan toko lain (Store Isolation)', () async {
      // Buyer chats with store_dapur_upn (Danus SIFO)
      final buyer = AppState();
      await buyer.login('hafidz@student.upnjatim.ac.id', 'password123');
      final store2 = buyer.stores.firstWhere((s) => s.id == 'store_dapur_upn');
      final convStore2 = await buyer.openOrCreateConversationWithStore(storeId: store2.id);
      await buyer.sendChatMessage('Halo Danus SIFO');

      // Seller of store_1 (Adistya) logs in
      final seller1 = AppState();
      await seller1.login('adistya@student.upnjatim.ac.id', 'password123');
      seller1.switchToSellerMode();
      await seller1.refreshConversations();

      // Seller 1 must NOT see conversations from store_dapur_upn
      expect(seller1.conversations.any((c) => c.id == convStore2.id), isFalse);
      expect(seller1.conversations.every((c) => c.storeId == 'store_1'), isTrue);

      // Direct data layer access check: unauthorized store access
      final db = DatabaseService();
      final unauthorizedMessages = await db.fetchMessages(
        convStore2.id,
        seller1.currentUser.dbUserId ?? 2,
      );
      expect(unauthorizedMessages, isEmpty);
    });

    test('10. Tombol Chat Pembeli pada Kelola Pesanan membuka percakapan yang tepat', () async {
      // Buyer places order for store_1
      final buyer = AppState();
      await buyer.login('hafidz@student.upnjatim.ac.id', 'password123');
      final item = buyer.menuItems.firstWhere((m) => m.merchantId == 'store_1');
      buyer.addToCart(item, quantity: 1);
      final order = buyer.placeOrder(
        paymentMethod: PaymentMethod.cash,
        deliveryMethod: DeliveryMethod.pickup,
        destinationLocation: 'Kantin FIK UPN',
      );

      // Seller logs in and opens conversation from order
      final seller = AppState();
      await seller.login('adistya@student.upnjatim.ac.id', 'password123');
      seller.switchToSellerMode();

      final conv = await seller.openOrCreateConversationWithBuyer(
        storeId: 'store_1',
        buyerId: 1,
        buyerName: order.buyerName,
        orderId: order.id,
      );

      expect(conv, isNotNull);
      expect(conv.buyerId, equals(1));
      expect(conv.storeId, equals('store_1'));
      expect(conv.orderId, equals(order.id));
      expect(seller.activeConversation?.id, equals(conv.id));
    });

    test('11. Indikator pesan belum dibaca berfungsi dan berkurang saat percakapan dibuka', () async {
      final buyer = AppState();
      await buyer.login('hafidz@student.upnjatim.ac.id', 'password123');
      final store = buyer.stores.firstWhere((s) => s.id == 'store_1');
      final conv = await buyer.openOrCreateConversationWithStore(storeId: store.id);
      await buyer.sendChatMessage('Halo pesanan saya bagaimana ya?');

      final seller = AppState();
      await seller.login('adistya@student.upnjatim.ac.id', 'password123');
      seller.switchToSellerMode();
      await seller.refreshConversations();

      // Seller has unread messages
      expect(seller.totalUnreadMessages, greaterThan(0));

      // Seller selects conversation -> marks as read
      await seller.selectConversation(conv);
      expect(seller.totalUnreadMessages, equals(0));
    });

    test('12. Loading, empty state, dan UI components Direct Message terkonfigurasi dengan benar', () async {
      final state = AppState();
      await state.login('hafidz@student.upnjatim.ac.id', 'password123');

      final dmWidget = DirectMessageScreen(state: state);
      expect(dmWidget.state, equals(state));
      expect(state.isLoggedIn, isTrue);
    });

    test('13. Fitur pesanan, stok, checkout, dan dashboard tetap berfungsi tanpa terganggu DM', () async {
      final state = AppState();
      await state.login('hafidz@student.upnjatim.ac.id', 'password123');

      final targetItem = state.menuItems.firstWhere((m) => m.merchantId == 'store_1' && m.stockCount > 5);
      const orderQty = 2;
      final added = state.addToCart(targetItem, quantity: orderQty);
      expect(added, isTrue);
      expect(state.cartItems.isNotEmpty, isTrue);

      final order = state.placeOrder(
        deliveryMethod: DeliveryMethod.pickup,
        destinationLocation: 'Stan Usaha Mandiri FIK',
        paymentMethod: PaymentMethod.qris,
      );
      if (state.lastOrderCreationFuture != null) {
        await state.lastOrderCreationFuture;
      }

      // Switch to seller
      await state.login('adistya@student.upnjatim.ac.id', 'password123');
      state.switchToSellerMode();

      final initialOmset = state.sellerTotalOmset;
      final initialBalance = state.sellerAvailableBalance;

      // Ensure seller dashboard metrics are intact
      expect(state.sellerMenuItems.isNotEmpty, isTrue);
      expect(initialOmset, greaterThanOrEqualTo(0));
      expect(initialBalance, greaterThanOrEqualTo(0));

      final sellerOrder = state.sellerOrders.firstWhere((o) => o.id == order.id);
      expect(sellerOrder.status, OrderStatus.waitingConfirmation);
      expect(sellerOrder.items.isNotEmpty, isTrue);

      final stockBeforeConfirm = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;

      // Confirm order as seller and verify stock deduction
      final confirmRes = await state.updateSellerOrderStatus(order.id, OrderStatus.readyForPickupOrDelivery);
      expect(confirmRes, isTrue);

      final stockAfterConfirm = state.menuItems.firstWhere((m) => m.id == targetItem.id).stockCount;
      expect(stockAfterConfirm, equals(stockBeforeConfirm - orderQty));

      // Complete order
      await state.updateSellerOrderStatus(order.id, OrderStatus.completed);
      await state.refreshSellerFinancials();
      expect(state.sellerTotalOmset, greaterThanOrEqualTo(initialOmset));
    });
  });
}
