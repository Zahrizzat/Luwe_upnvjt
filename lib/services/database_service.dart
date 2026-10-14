import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mysql_client/mysql_client.dart';
import '../models/user_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/delivery_location_model.dart';
import '../models/withdrawal_model.dart';
import '../models/conversation_model.dart';
import '../models/chat_message_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  MySQLConnection? _conn;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> connect() async {
    try {
      if (_conn != null && _conn!.connected) {
        return true;
      }
      _conn = await MySQLConnection.createConnection(
        host: '127.0.0.1',
        port: 3306,
        userName: 'luwe',
        password: 'luwe123',
        databaseName: 'luwe_db',
        secure: false,
      );
      await _conn!.connect();
      _isConnected = true;
      await seedInitialDataIfEmpty();
      return true;
    } catch (_) {
      try {
        _conn = await MySQLConnection.createConnection(
          host: '127.0.0.1',
          port: 3306,
          userName: 'root',
          password: '',
          databaseName: 'luwe_db',
          secure: false,
        );
        await _conn!.connect();
        _isConnected = true;
        await seedInitialDataIfEmpty();
        return true;
      } catch (_) {
        _isConnected = false;
        return false;
      }
    }
  }

  Future<void> seedInitialDataIfEmpty() async {
    if (_conn == null || !_conn!.connected) return;

    try {
      final userCheck = await _conn!.execute('SELECT COUNT(*) AS total FROM users');
      int userCount = 0;
      for (final row in userCheck.rows) {
        userCount = int.tryParse(row.assoc()['total'] ?? '0') ?? 0;
      }

      if (userCount == 0) {
        final hash1 = hashPassword('password123');

        // Seed Pembeli (Hafidz)
        await _conn!.execute(
          'INSERT INTO users (full_name, npm, email, password_hash, user_type, role, phone, profile_photo, account_status) '
          'VALUES (:name, :npm, :email, :pass, :utype, :role, :phone, :photo, :status)',
          {
            'name': 'Hafidz Ahmad',
            'npm': '22081010045',
            'email': 'hafidz@student.upnjatim.ac.id',
            'pass': hash1,
            'utype': 'mahasiswa',
            'role': 'pembeli',
            'phone': '081234567890',
            'photo': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
            'status': 'aktif',
          },
        );

        // Seed Penjual (Adistya) - Verified
        final resSeller = await _conn!.execute(
          'INSERT INTO users (full_name, npm, email, password_hash, user_type, role, phone, profile_photo, account_status) '
          'VALUES (:name, :npm, :email, :pass, :utype, :role, :phone, :photo, :status)',
          {
            'name': 'Adistya Putri',
            'npm': '22081010088',
            'email': 'adistya@student.upnjatim.ac.id',
            'pass': hash1,
            'utype': 'mahasiswa',
            'role': 'penjual',
            'phone': '081987654321',
            'photo': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
            'status': 'aktif',
          },
        );
        final sellerId = resSeller.lastInsertID.toInt();

        // Seed Store for Adistya
        final resStore = await _conn!.execute(
          'INSERT INTO stores (seller_id, store_name, slug, description, store_location, store_status, verification_status) '
          'VALUES (:seller_id, :name, :slug, :desc, :loc, :status, "disetujui")',
          {
            'seller_id': sellerId,
            'name': 'Warung Sambal Kampus UPN',
            'slug': 'warung-sambal-kampus-upn',
            'desc': 'Kuliner pedas nikmat khas mahasiswa UPNVJT Kantin Giri Reksa.',
            'loc': 'Kantin Barat • Gedung Giri Reksa',
            'status': 'buka',
          },
        );
        final storeId = resStore.lastInsertID.toInt();

        // Seed Products
        final products = [
          {
            'store_id': storeId,
            'category_id': 1,
            'name': 'Ayam Geprek Sambal Bawang UPNVJT',
            'slug': 'ayam-geprek-sambal-bawang-upnvjt',
            'desc': 'Ayam krispi gurih dengan ulekan cabai rawit pedas segar khas sambal bawang Surabaya, disajikan hangat bersama nasi pulen dan lalapan segar.',
            'price': 15000,
            'stock': 25,
            'img': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80',
          },
          {
            'store_id': storeId,
            'category_id': 1,
            'name': 'Nasi Bakar Cakalang Suwir Kemangi',
            'slug': 'nasi-bakar-cakalang-suwir-kemangi',
            'desc': 'Nasi gurih dibungkus daun pisang aroma rempah wangi dengan isian melimpah cakalang asap suwir dan kemangi segar.',
            'price': 14000,
            'stock': 15,
            'img': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
          },
          {
            'store_id': storeId,
            'category_id': 3,
            'name': 'Es Teh Melati Jumbo Kampus',
            'slug': 'es-teh-melati-jumbo-kampus',
            'desc': 'Es teh melati seduh tradisional poci tanah liat dengan aroma melati wangi semerbak, pelepas dahaga nomor satu saat terik perkuliahan.',
            'price': 5000,
            'stock': 50,
            'img': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=800&q=80',
          },
          {
            'store_id': storeId,
            'category_id': 2,
            'name': 'Dimsum Ayam Mentai Melted (4 pcs)',
            'slug': 'dimsum-ayam-mentai-melted',
            'desc': 'Dimsum olahan daging ayam asli dengan topping saus mentai gurih creamy yang ditorch hingga wangi.',
            'price': 16000,
            'stock': 20,
            'img': 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?auto=format&fit=crop&w=800&q=80',
          },
          {
            'store_id': storeId,
            'category_id': 1,
            'name': 'Paket Hemat: Ayam Krispi + Es Teh Jumbo',
            'slug': 'paket-hemat-ayam-krispi-es-teh',
            'desc': 'Paket kenyang andalan mahasiswa tanggal tua: Nasi putih pulen, ayam krispi saus lava pedas manis, plus free Es Teh Jumbo.',
            'price': 18000,
            'stock': 30,
            'img': 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=800&q=80',
          },
          {
            'store_id': storeId,
            'category_id': 3,
            'name': 'Es Kopi Susu Gula Aren UPN',
            'slug': 'es-kopi-susu-gula-aren-upn',
            'desc': 'Espresso blend Arabika-Robusta lokal dengan susu creamy dan sirup gula aren murni. Teman nugas skripsi & deadline kuliah.',
            'price': 12000,
            'stock': 25,
            'img': 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=80',
          },
        ];

        for (final p in products) {
          final resProd = await _conn!.execute(
            'INSERT INTO products (store_id, category_id, product_name, slug, description, price, stock_quantity, availability, is_active) '
            'VALUES (:store_id, :cat_id, :name, :slug, :desc, :price, :stock, "tersedia", 1)',
            {
              'store_id': p['store_id'],
              'cat_id': p['category_id'],
              'name': p['name'],
              'slug': p['slug'],
              'desc': p['desc'],
              'price': p['price'],
              'stock': p['stock'],
            },
          );
          final pId = resProd.lastInsertID.toInt();

          await _conn!.execute(
            'INSERT INTO product_media (product_id, media_type, media_url, is_primary, display_order) '
            'VALUES (:pId, "foto", :url, 1, 1)',
            {'pId': pId, 'url': p['img']},
          );
        }
      }
    } catch (_) {}
  }

  // Authentication: Login
  Future<UserModel?> login(String emailOrNpm, String password) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return null;
    }

    try {
      final hashed = hashPassword(password);
      final res = await _conn!.execute(
        'SELECT u.*, s.store_id, s.store_name, s.store_location, s.description AS store_desc, '
        's.contact_phone, s.store_photo, s.store_status, s.verification_status, s.rejection_reason '
        'FROM users u '
        'LEFT JOIN stores s ON u.user_id = s.seller_id '
        'WHERE (u.email = :query OR u.npm = :query) AND u.password_hash = :hash AND u.account_status = "aktif"',
        {'query': emailOrNpm.trim(), 'hash': hashed},
      );

      if (res.rows.isEmpty) return null;

      final row = res.rows.first.assoc();
      return _mapRowToUserModel(row);
    } catch (_) {
      return null;
    }
  }

  // Authentication: Register
  // Rule: Semua pendaftar baru dimulai sebagai PEMBELI (role = 'pembeli') tanpa toko.
  Future<UserModel?> register({
    required String fullName,
    required String npm,
    required String email,
    required String password,
    required String phone,
    required String userType,
  }) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return null;
    }

    try {
      final hash = hashPassword(password);

      final res = await _conn!.execute(
        'INSERT INTO users (full_name, npm, email, password_hash, user_type, role, phone, profile_photo, account_status) '
        'VALUES (:name, :npm, :email, :pass, :utype, "pembeli", :phone, :photo, "aktif")',
        {
          'name': fullName.trim(),
          'npm': npm.trim().isEmpty ? null : npm.trim(),
          'email': email.trim(),
          'pass': hash,
          'utype': userType,
          'phone': phone.trim(),
          'photo': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        },
      );

      final newUserId = res.lastInsertID.toInt();

      return UserModel(
        id: 'user_$newUserId',
        dbUserId: newUserId,
        dbStoreId: null,
        name: fullName.trim(),
        email: email.trim(),
        npm: npm.trim(),
        faculty: 'UPN "Veteran" Jawa Timur',
        studyProgram: userType.toUpperCase(),
        phoneNumber: phone.trim(),
        role: UserRole.buyer,
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        storeName: '',
        storeLocation: '',
        isStoreOpen: false,
        verificationStatus: StoreVerificationStatus.none,
        userType: userType,
      );
    } catch (_) {
      return null;
    }
  }

  // Store Application Submission (Alur Verifikasi Toko)
  Future<UserModel?> submitStoreApplication({
    required int userId,
    required String storeName,
    required String storeLocation,
    required String storeDescription,
    required String contactPhone,
    String? storePhoto,
  }) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return null;
    }

    try {
      final slug = '${storeName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')}-${DateTime.now().millisecondsSinceEpoch}';

      // Check if store entry already exists
      final check = await _conn!.execute(
        'SELECT store_id FROM stores WHERE seller_id = :userId',
        {'userId': userId},
      );

      int storeId;
      if (check.rows.isNotEmpty) {
        storeId = int.parse(check.rows.first.assoc()['store_id']!);
        await _conn!.execute(
          'UPDATE stores SET store_name = :name, slug = :slug, description = :desc, '
          'store_location = :loc, contact_phone = :phone, store_photo = :photo, '
          'verification_status = "menunggu_verifikasi", rejection_reason = NULL '
          'WHERE store_id = :storeId',
          {
            'name': storeName.trim(),
            'slug': slug,
            'desc': storeDescription.trim(),
            'loc': storeLocation.trim(),
            'phone': contactPhone.trim(),
            'photo': storePhoto,
            'storeId': storeId,
          },
        );
      } else {
        final res = await _conn!.execute(
          'INSERT INTO stores (seller_id, store_name, slug, description, store_location, contact_phone, store_photo, store_status, verification_status) '
          'VALUES (:userId, :name, :slug, :desc, :loc, :phone, :photo, "buka", "menunggu_verifikasi")',
          {
            'userId': userId,
            'name': storeName.trim(),
            'slug': slug,
            'desc': storeDescription.trim(),
            'loc': storeLocation.trim(),
            'phone': contactPhone.trim(),
            'photo': storePhoto,
          },
        );
        storeId = res.lastInsertID.toInt();
      }

      // Re-fetch user to return updated model
      final userRes = await _conn!.execute(
        'SELECT u.*, s.store_id, s.store_name, s.store_location, s.description AS store_desc, '
        's.contact_phone, s.store_photo, s.store_status, s.verification_status, s.rejection_reason '
        'FROM users u '
        'LEFT JOIN stores s ON u.user_id = s.seller_id '
        'WHERE u.user_id = :userId',
        {'userId': userId},
      );

      if (userRes.rows.isNotEmpty) {
        return _mapRowToUserModel(userRes.rows.first.assoc());
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Admin / Simulation Review of Store Application
  Future<UserModel?> reviewStoreApplication({
    required int storeId,
    required bool approve,
    String? rejectionReason,
  }) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return null;
    }

    try {
      final statusStr = approve ? 'disetujui' : 'ditolak';

      await _conn!.execute(
        'UPDATE stores SET verification_status = :status, rejection_reason = :reason, verified_at = CURRENT_TIMESTAMP WHERE store_id = :storeId',
        {
          'status': statusStr,
          'reason': approve ? null : (rejectionReason ?? 'Dokumen pendukung atau lokasi stan belum terdaftar di pengelola kantin kampus.'),
          'storeId': storeId,
        },
      );

      // If approved, update users.role = 'penjual'. If rejected, keep role = 'pembeli'.
      await _conn!.execute(
        'UPDATE users u '
        'JOIN stores s ON u.user_id = s.seller_id '
        'SET u.role = :role '
        'WHERE s.store_id = :storeId',
        {
          'role': approve ? 'penjual' : 'pembeli',
          'storeId': storeId,
        },
      );

      final res = await _conn!.execute(
        'SELECT u.*, s.store_id, s.store_name, s.store_location, s.description AS store_desc, '
        's.contact_phone, s.store_photo, s.store_status, s.verification_status, s.rejection_reason '
        'FROM stores s '
        'JOIN users u ON s.seller_id = u.user_id '
        'WHERE s.store_id = :storeId',
        {'storeId': storeId},
      );

      if (res.rows.isNotEmpty) {
        return _mapRowToUserModel(res.rows.first.assoc());
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Fetch all products from MySQL
  Future<List<MenuItemModel>> fetchProducts() async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return [];
    }

    try {
      final res = await _conn!.execute(
        'SELECT p.*, s.store_name, s.store_location, c.category_name, '
        '(SELECT media_url FROM product_media WHERE product_id = p.product_id AND media_type = "foto" ORDER BY is_primary DESC LIMIT 1) AS image_url '
        'FROM products p '
        'JOIN stores s ON p.store_id = s.store_id '
        'JOIN categories c ON p.category_id = c.category_id '
        'WHERE p.is_active = 1 '
        'ORDER BY p.product_id DESC',
      );

      final List<MenuItemModel> items = [];
      for (final row in res.rows) {
        final a = row.assoc();
        final pId = a['product_id'] ?? '0';
        final price = double.tryParse(a['price'] ?? '0')?.toInt() ?? 0;
        final stock = int.tryParse(a['stock_quantity'] ?? '0') ?? 0;
        final isAvail = a['availability'] == 'tersedia' && stock > 0;
        final img = a['image_url'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80';

        items.add(
          MenuItemModel(
            id: 'menu_$pId',
            dbProductId: int.tryParse(pId),
            merchantId: 'store_${a['store_id']}',
            merchantName: a['store_name'] ?? 'Kantin UPN',
            merchantLocation: a['store_location'] ?? 'Kantin Kampus',
            name: a['product_name'] ?? 'Menu Kampus',
            description: a['description'] ?? '',
            price: price,
            imageUrl: img,
            category: a['category_name'] ?? 'Makanan Utama',
            isReadyStock: isAvail,
            stockCount: stock,
            rating: 4.9,
            reviewCount: 45,
            soldCount: 120,
            tags: const ['Halal', 'UPNVJT Terverifikasi'],
          ),
        );
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  // Insert product to MySQL (Merchant only)
  Future<MenuItemModel?> addProduct({
    required int storeId,
    required String name,
    required String categoryName,
    required int price,
    required String description,
    required String imageUrl,
    int stock = 20,
  }) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return null;
    }

    try {
      int catId = 1;
      if (categoryName.contains('Minuman')) {
        catId = 3;
      } else if (categoryName.contains('Snack') || categoryName.contains('Cemilan')) {
        catId = 2;
      } else if (categoryName.contains('Dessert')) {
        catId = 4;
      }

      final slug = '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')}-${DateTime.now().millisecondsSinceEpoch}';

      final res = await _conn!.execute(
        'INSERT INTO products (store_id, category_id, product_name, slug, description, price, stock_quantity, availability, is_active) '
        'VALUES (:store_id, :cat_id, :name, :slug, :desc, :price, :stock, "tersedia", 1)',
        {
          'store_id': storeId,
          'cat_id': catId,
          'name': name.trim(),
          'slug': slug,
          'desc': description.trim(),
          'price': price,
          'stock': stock,
        },
      );

      final pId = res.lastInsertID.toInt();

      await _conn!.execute(
        'INSERT INTO product_media (product_id, media_type, media_url, is_primary, display_order) '
        'VALUES (:pId, "foto", :url, 1, 1)',
        {'pId': pId, 'url': imageUrl.trim()},
      );

      return MenuItemModel(
        id: 'menu_$pId',
        dbProductId: pId,
        merchantId: 'store_$storeId',
        merchantName: 'Toko Saya',
        merchantLocation: 'Kantin UPN',
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: categoryName,
        isReadyStock: true,
        stockCount: stock,
      );
    } catch (_) {
      return null;
    }
  }

  // Toggle stock availability
  Future<bool> toggleProductStock(int productId, bool isReady) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      await _conn!.execute(
        'UPDATE products SET availability = :avail, stock_quantity = :stock WHERE product_id = :pId',
        {
          'avail': isReady ? 'tersedia' : 'tidak_tersedia',
          'stock': isReady ? 15 : 0,
          'pId': productId,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(int productId) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      await _conn!.execute('UPDATE products SET is_active = 0 WHERE product_id = :pId', {'pId': productId});
      return true;
    } catch (_) {
      return false;
    }
  }

  // Create Order in MySQL
  Future<OrderModel?> createOrder({
    required int buyerId,
    required int storeId,
    required OrderModel order,
  }) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return null;
    }

    try {
      final fulfillment = order.deliveryMethod == DeliveryMethod.pickup ? 'ambil_sendiri' : 'diantar';
      final res = await _conn!.execute(
        'INSERT INTO orders (order_code, buyer_id, store_id, fulfillment_method, fulfillment_address, buyer_note, subtotal, delivery_fee, total_amount, order_status) '
        'VALUES (:code, :buyerId, :storeId, :method, :addr, :note, :sub, :del, :tot, "menunggu_konfirmasi")',
        {
          'code': order.id,
          'buyerId': buyerId,
          'storeId': storeId,
          'method': fulfillment,
          'addr': order.destinationLocation,
          'note': order.notes ?? '',
          'sub': order.subtotal,
          'del': order.campusServiceFee,
          'tot': order.totalAmount,
        },
      );

      final orderId = res.lastInsertID.toInt();

      // Insert order items
      for (final it in order.items) {
        await _conn!.execute(
          'INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, line_total) '
          'VALUES (:orderId, :pId, :name, :price, :qty, :tot)',
          {
            'orderId': orderId,
            'pId': it.item.dbProductId,
            'name': it.item.name,
            'price': it.item.price,
            'qty': it.quantity,
            'tot': it.subtotal,
          },
        );
      }

      // Insert payment record
      final payMethod = order.paymentMethod == PaymentMethod.qris ? 'qris' : 'tunai';
      await _conn!.execute(
        'INSERT INTO payments (order_id, payment_method, payment_amount, payment_status) '
        'VALUES (:orderId, :method, :amount, "menunggu_pembayaran")',
        {
          'orderId': orderId,
          'method': payMethod,
          'amount': order.totalAmount,
        },
      );

      return order;
    } catch (_) {
      return null;
    }
  }

  // Update order status in MySQL
  Future<bool> updateOrderStatus(String orderCode, OrderStatus status) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      String statusStr = 'menunggu_konfirmasi';
      switch (status) {
        case OrderStatus.waitingConfirmation:
          statusStr = 'menunggu_konfirmasi';
          break;
        case OrderStatus.processing:
          statusStr = 'diproses';
          break;
        case OrderStatus.readyForPickupOrDelivery:
          statusStr = 'siap_diambil';
          break;
        case OrderStatus.completed:
          statusStr = 'selesai';
          break;
        case OrderStatus.cancelled:
          statusStr = 'dibatalkan';
          break;
      }

      await _conn!.execute(
        'UPDATE orders SET order_status = :st WHERE order_code = :code',
        {'st': statusStr, 'code': orderCode},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // Update store open/close status
  Future<bool> updateStoreStatus(int storeId, bool isOpen) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      await _conn!.execute(
        'UPDATE stores SET store_status = :st WHERE store_id = :id',
        {'st': isOpen ? 'buka' : 'tutup', 'id': storeId},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // 1 & 2. SELLER TOTAL OMSET & TARIK SALDO
  // ==========================================

  Future<Map<String, int>> fetchSellerFinancialSummary(int storeId) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return {'totalOmset': 0, 'availableBalance': 0, 'pendingWithdrawal': 0, 'completedWithdrawal': 0};
    }

    try {
      // 1. Total Omset: akumulasi transaksi penjual dengan status transaksi berhasil ('selesai')
      final omsetRes = await _conn!.execute(
        'SELECT COALESCE(SUM(total_amount), 0) AS total_omset FROM orders WHERE store_id = :storeId AND order_status = "selesai"',
        {'storeId': storeId},
      );
      int totalOmset = 0;
      for (final r in omsetRes.rows) {
        totalOmset = double.tryParse(r.assoc()['total_omset'] ?? '0')?.toInt() ?? 0;
      }

      // 2. Pending Withdrawals: penarikan berstatus 'menunggu_proses'
      final pendingRes = await _conn!.execute(
        'SELECT COALESCE(SUM(amount), 0) AS pending_total FROM store_withdrawals WHERE store_id = :storeId AND withdrawal_status = "menunggu_proses"',
        {'storeId': storeId},
      );
      int pendingTotal = 0;
      for (final r in pendingRes.rows) {
        pendingTotal = double.tryParse(r.assoc()['pending_total'] ?? '0')?.toInt() ?? 0;
      }

      // 3. Completed/Approved Withdrawals
      final completedRes = await _conn!.execute(
        'SELECT COALESCE(SUM(amount), 0) AS completed_total FROM store_withdrawals WHERE store_id = :storeId AND withdrawal_status IN ("disetujui", "selesai")',
        {'storeId': storeId},
      );
      int completedTotal = 0;
      for (final r in completedRes.rows) {
        completedTotal = double.tryParse(r.assoc()['completed_total'] ?? '0')?.toInt() ?? 0;
      }

      // Saldo tersedia = Total Omset - (Pending + Completed)
      final availableBalance = (totalOmset - (pendingTotal + completedTotal)).clamp(0, 999999999);

      return {
        'totalOmset': totalOmset,
        'availableBalance': availableBalance,
        'pendingWithdrawal': pendingTotal,
        'completedWithdrawal': completedTotal,
      };
    } catch (_) {
      return {'totalOmset': 0, 'availableBalance': 0, 'pendingWithdrawal': 0, 'completedWithdrawal': 0};
    }
  }

  Future<List<WithdrawalModel>> fetchWithdrawals(int storeId) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return [];
    }

    try {
      final res = await _conn!.execute(
        'SELECT * FROM store_withdrawals WHERE store_id = :storeId ORDER BY withdrawal_id DESC',
        {'storeId': storeId},
      );

      final List<WithdrawalModel> list = [];
      for (final r in res.rows) {
        final a = r.assoc();
        final wId = int.tryParse(a['withdrawal_id'] ?? '0') ?? 0;
        final sId = int.tryParse(a['store_id'] ?? '0') ?? 0;
        final sellerId = int.tryParse(a['seller_id'] ?? '0') ?? 0;
        final amount = double.tryParse(a['amount'] ?? '0')?.toInt() ?? 0;
        final stStr = a['withdrawal_status'] ?? 'menunggu_proses';

        WithdrawalStatus st;
        if (stStr == 'disetujui') {
          st = WithdrawalStatus.approved;
        } else if (stStr == 'ditolak') {
          st = WithdrawalStatus.rejected;
        } else if (stStr == 'selesai') {
          st = WithdrawalStatus.completed;
        } else {
          st = WithdrawalStatus.pending;
        }

        DateTime reqDate = DateTime.now();
        if (a['requested_at'] != null) {
          reqDate = DateTime.tryParse(a['requested_at']!) ?? DateTime.now();
        }
        DateTime? procDate;
        if (a['processed_at'] != null) {
          procDate = DateTime.tryParse(a['processed_at']!);
        }

        list.add(
          WithdrawalModel(
            id: wId,
            storeId: sId,
            sellerId: sellerId,
            amount: amount,
            paymentMethod: a['payment_method'] ?? 'Bank BCA',
            accountName: a['account_name'] ?? '',
            accountNumber: a['account_number'] ?? '',
            notes: a['notes'],
            status: st,
            rejectionReason: a['rejection_reason'],
            requestedAt: reqDate,
            processedAt: procDate,
          ),
        );
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<String?> requestWithdrawal({
    required int storeId,
    required int sellerId,
    required int amount,
    required String paymentMethod,
    required String accountName,
    required String accountNumber,
    String? notes,
  }) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return 'Koneksi database gagal. Silakan coba lagi.';
    }

    if (amount < 10000) {
      return 'Nominal penarikan minimal Rp10.000.';
    }

    try {
      final summary = await fetchSellerFinancialSummary(storeId);
      final available = summary['availableBalance'] ?? 0;
      if (amount > available) {
        return 'Saldo tersedia tidak mencukupi (Saldo: Rp$available, Diajukan: Rp$amount).';
      }

      await _conn!.execute(
        'INSERT INTO store_withdrawals (store_id, seller_id, amount, payment_method, account_name, account_number, notes, withdrawal_status, requested_at) '
        'VALUES (:storeId, :sellerId, :amount, :method, :name, :accNo, :notes, "menunggu_proses", CURRENT_TIMESTAMP)',
        {
          'storeId': storeId,
          'sellerId': sellerId,
          'amount': amount,
          'method': paymentMethod,
          'name': accountName.trim(),
          'accNo': accountNumber.trim(),
          'notes': notes?.trim() ?? '',
        },
      );
      return null;
    } catch (e) {
      return 'Gagal mengajukan penarikan: $e';
    }
  }

  Future<bool> simulateReviewWithdrawal({
    required int withdrawalId,
    required bool approve,
    String? rejectionReason,
  }) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      final statusStr = approve ? 'selesai' : 'ditolak';
      await _conn!.execute(
        'UPDATE store_withdrawals SET withdrawal_status = :st, rejection_reason = :reason, processed_at = CURRENT_TIMESTAMP WHERE withdrawal_id = :id',
        {
          'st': statusStr,
          'reason': approve ? null : (rejectionReason ?? 'Informasi rekening atau nama pemilik tidak valid.'),
          'id': withdrawalId,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // 3. PESANAN SAYA (BUYER & SELLER)
  // ==========================================

  OrderStatus _mapDbStatusToOrderStatus(String? dbStatus) {
    switch (dbStatus) {
      case 'menunggu_konfirmasi':
        return OrderStatus.waitingConfirmation;
      case 'diterima':
      case 'diproses':
        return OrderStatus.processing;
      case 'siap_diambil':
      case 'dalam_pengantaran':
        return OrderStatus.readyForPickupOrDelivery;
      case 'selesai':
        return OrderStatus.completed;
      case 'dibatalkan':
      case 'ditolak':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.waitingConfirmation;
    }
  }

  Future<List<OrderModel>> _buildOrderModelList(IResultSet res) async {
    final List<OrderModel> list = [];
    for (final r in res.rows) {
      final a = r.assoc();
      final oId = int.tryParse(a['order_id'] ?? '0') ?? 0;
      final buyerId = int.tryParse(a['buyer_id'] ?? '0');
      final storeId = int.tryParse(a['store_id'] ?? '0');
      final orderCode = a['order_code'] ?? 'LW-$oId';
      final subtotal = double.tryParse(a['subtotal'] ?? '0')?.toInt() ?? 0;
      final deliveryFee = double.tryParse(a['delivery_fee'] ?? '0')?.toInt() ?? 0;
      final totalAmount = double.tryParse(a['total_amount'] ?? '0')?.toInt() ?? (subtotal + deliveryFee + 1000);
      final fulfillment = a['fulfillment_method'] == 'ambil_sendiri' ? DeliveryMethod.pickup : DeliveryMethod.delivery;
      final payMethod = (a['payment_method'] ?? 'qris') == 'qris' ? PaymentMethod.qris : PaymentMethod.cash;
      final payStatus = a['payment_status'] == 'berhasil' ? 'Lunas' : 'Menunggu Pembayaran';
      final orderStatus = _mapDbStatusToOrderStatus(a['order_status']);

      final itemRes = await _conn!.execute(
        'SELECT oi.*, p.description, p.category_id, c.category_name, '
        '(SELECT media_url FROM product_media WHERE product_id = oi.product_id AND media_type = "foto" ORDER BY is_primary DESC LIMIT 1) AS image_url '
        'FROM order_items oi '
        'LEFT JOIN products p ON oi.product_id = p.product_id '
        'LEFT JOIN categories c ON p.category_id = c.category_id '
        'WHERE oi.order_id = :orderId',
        {'orderId': oId},
      );

      final List<CartItemModel> items = [];
      for (final ir in itemRes.rows) {
        final ia = ir.assoc();
        final unitPrice = double.tryParse(ia['unit_price'] ?? '0')?.toInt() ?? 0;
        final qty = int.tryParse(ia['quantity'] ?? '1') ?? 1;
        final pId = int.tryParse(ia['product_id'] ?? '0') ?? 0;

        items.add(
          CartItemModel(
            item: MenuItemModel(
              id: 'menu_$pId',
              dbProductId: pId,
              merchantId: 'store_$storeId',
              merchantName: a['store_name'] ?? 'Stan Kuliner UPN',
              merchantLocation: a['store_location'] ?? 'Kantin UPN',
              name: ia['product_name'] ?? 'Menu Makanan',
              description: ia['description'] ?? '',
              price: unitPrice,
              imageUrl: ia['image_url'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
              category: ia['category_name'] ?? 'Makanan',
            ),
            quantity: qty,
            selectedSpiceLevel: 'Normal',
          ),
        );
      }

      list.add(
        OrderModel(
          id: orderCode,
          dbOrderId: oId,
          buyerId: buyerId,
          storeId: storeId,
          buyerName: a['buyer_name'] ?? 'Mahasiswa UPN',
          buyerNpm: a['buyer_npm'] ?? '',
          buyerPhone: a['buyer_phone'] ?? '',
          merchantName: a['store_name'] ?? 'Stan Kuliner UPN',
          items: items,
          subtotal: subtotal,
          campusServiceFee: 1000,
          deliveryFee: deliveryFee,
          totalAmount: totalAmount,
          deliveryMethod: fulfillment,
          destinationLocation: a['fulfillment_address'] ?? 'Kantin UPN',
          paymentMethod: payMethod,
          paymentStatus: payStatus,
          status: orderStatus,
          createdAt: DateTime.tryParse(a['ordered_at'] ?? '') ?? DateTime.now(),
          notes: a['buyer_note'],
          cancellationReason: a['cancellation_reason'],
        ),
      );
    }
    return list;
  }

  Future<List<OrderModel>> fetchOrdersForBuyer(int buyerId) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return [];
    }
    try {
      final res = await _conn!.execute(
        'SELECT o.*, s.store_name, s.store_location, p.payment_method, p.payment_status, '
        'u.full_name AS buyer_name, u.npm AS buyer_npm, u.phone AS buyer_phone '
        'FROM orders o '
        'JOIN stores s ON o.store_id = s.store_id '
        'JOIN users u ON o.buyer_id = u.user_id '
        'LEFT JOIN payments p ON o.order_id = p.order_id '
        'WHERE o.buyer_id = :buyerId '
        'ORDER BY o.order_id DESC',
        {'buyerId': buyerId},
      );
      return await _buildOrderModelList(res);
    } catch (_) {
      return [];
    }
  }

  Future<List<OrderModel>> fetchOrdersForSeller(int storeId) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return [];
    }
    try {
      final res = await _conn!.execute(
        'SELECT o.*, s.store_name, s.store_location, p.payment_method, p.payment_status, '
        'u.full_name AS buyer_name, u.npm AS buyer_npm, u.phone AS buyer_phone '
        'FROM orders o '
        'JOIN stores s ON o.store_id = s.store_id '
        'JOIN users u ON o.buyer_id = u.user_id '
        'LEFT JOIN payments p ON o.order_id = p.order_id '
        'WHERE o.store_id = :storeId '
        'ORDER BY o.order_id DESC',
        {'storeId': storeId},
      );
      return await _buildOrderModelList(res);
    } catch (_) {
      return [];
    }
  }

  Future<bool> cancelOrder({required String orderCode, required String reason, required int buyerId}) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      await _conn!.execute(
        'UPDATE orders SET order_status = "dibatalkan", cancellation_reason = :reason '
        'WHERE order_code = :code AND buyer_id = :buyerId AND order_status = "menunggu_konfirmasi"',
        {'code': orderCode, 'reason': reason, 'buyerId': buyerId},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> confirmOrderReceived({required String orderCode, required int buyerId}) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      await _conn!.execute(
        'UPDATE orders SET order_status = "selesai" '
        'WHERE order_code = :code AND buyer_id = :buyerId AND order_status IN ("siap_diambil", "dalam_pengantaran", "diproses")',
        {'code': orderCode, 'buyerId': buyerId},
      );
      await _conn!.execute(
        'UPDATE payments p JOIN orders o ON p.order_id = o.order_id '
        'SET p.payment_status = "berhasil" WHERE o.order_code = :code',
        {'code': orderCode},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sellerUpdateOrderStatus({required String orderCode, required OrderStatus status, required int storeId}) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      String statusStr = 'diproses';
      if (status == OrderStatus.readyForPickupOrDelivery) {
        statusStr = 'siap_diambil';
      } else if (status == OrderStatus.completed) {
        statusStr = 'selesai';
      } else if (status == OrderStatus.cancelled) {
        statusStr = 'ditolak';
      }

      await _conn!.execute(
        'UPDATE orders SET order_status = :st WHERE order_code = :code AND store_id = :storeId',
        {'st': statusStr, 'code': orderCode, 'storeId': storeId},
      );

      if (status == OrderStatus.completed) {
        await _conn!.execute(
          'UPDATE payments p JOIN orders o ON p.order_id = o.order_id '
          'SET p.payment_status = "berhasil" WHERE o.order_code = :code',
          {'code': orderCode},
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // 4. CHAT & DISKUSI TERHUBUNG AKUN
  // ==========================================

  Future<List<ConversationModel>> fetchUserConversations(int userId) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return [];
    }
    try {
      final res = await _conn!.execute(
        'SELECT c.*, '
        'b.full_name AS buyer_name, b.profile_photo AS buyer_photo, '
        's.full_name AS seller_name, s.profile_photo AS seller_photo, '
        'st.store_name, st.store_location, '
        '(SELECT message_text FROM messages WHERE conversation_id = c.conversation_id ORDER BY message_id DESC LIMIT 1) AS last_msg, '
        '(SELECT sent_at FROM messages WHERE conversation_id = c.conversation_id ORDER BY message_id DESC LIMIT 1) AS last_msg_time '
        'FROM conversations c '
        'JOIN users b ON c.buyer_id = b.user_id '
        'JOIN users s ON c.seller_id = s.user_id '
        'LEFT JOIN stores st ON s.user_id = st.seller_id '
        'WHERE c.buyer_id = :userId OR c.seller_id = :userId '
        'ORDER BY COALESCE(c.last_message_at, c.created_at) DESC',
        {'userId': userId},
      );

      final List<ConversationModel> list = [];
      for (final r in res.rows) {
        final a = r.assoc();
        final cId = int.tryParse(a['conversation_id'] ?? '0') ?? 0;
        final buyerId = int.tryParse(a['buyer_id'] ?? '0') ?? 0;
        final sellerId = int.tryParse(a['seller_id'] ?? '0') ?? 0;
        final isMeBuyer = userId == buyerId;

        final otherName = isMeBuyer
            ? (a['store_name']?.isNotEmpty == true ? a['store_name']! : a['seller_name'] ?? 'Penjual Luwe')
            : (a['buyer_name'] ?? 'Mahasiswa UPN');
        final otherSub = isMeBuyer
            ? (a['store_location']?.isNotEmpty == true ? a['store_location']! : 'Stan Kuliner UPNVJT')
            : 'Pembeli Mahasiswa UPN';
        final otherAvatar = isMeBuyer
            ? (a['seller_photo'] ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80')
            : (a['buyer_photo'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80');

        list.add(
          ConversationModel(
            id: cId,
            buyerId: buyerId,
            sellerId: sellerId,
            otherPartyName: otherName,
            otherPartySubtitle: otherSub,
            otherPartyAvatar: otherAvatar,
            lastMessage: a['last_msg'] ?? 'Percakapan baru dimulai',
            lastMessageAt: DateTime.tryParse(a['last_msg_time'] ?? '') ?? DateTime.now(),
          ),
        );
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<ChatMessageModel>> fetchMessages(int conversationId, int currentUserId) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return [];
    }
    try {
      final res = await _conn!.execute(
        'SELECT m.*, u.full_name, u.role '
        'FROM messages m '
        'JOIN users u ON m.sender_id = u.user_id '
        'WHERE m.conversation_id = :cId '
        'ORDER BY m.message_id ASC',
        {'cId': conversationId},
      );

      final List<ChatMessageModel> list = [];
      for (final r in res.rows) {
        final a = r.assoc();
        final mId = int.tryParse(a['message_id'] ?? '0') ?? 0;
        final senderId = int.tryParse(a['sender_id'] ?? '0') ?? 0;
        final isMe = senderId == currentUserId;

        list.add(
          ChatMessageModel(
            id: 'msg_$mId',
            dbMessageId: mId,
            conversationId: conversationId,
            senderId: 'user_$senderId',
            senderName: a['full_name'] ?? 'Pengguna',
            message: a['message_text'] ?? '',
            timestamp: DateTime.tryParse(a['sent_at'] ?? '') ?? DateTime.now(),
            isMe: isMe,
          ),
        );
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<ChatMessageModel?> sendMessage({
    required int conversationId,
    required int senderId,
    required String senderName,
    required String text,
  }) async {
    if (_conn == null || !_conn!.connected) return null;
    try {
      final res = await _conn!.execute(
        'INSERT INTO messages (conversation_id, sender_id, message_text, is_read, sent_at) '
        'VALUES (:cId, :sId, :text, 0, CURRENT_TIMESTAMP)',
        {
          'cId': conversationId,
          'sId': senderId,
          'text': text.trim(),
        },
      );

      await _conn!.execute(
        'UPDATE conversations SET last_message_at = CURRENT_TIMESTAMP WHERE conversation_id = :cId',
        {'cId': conversationId},
      );

      final newMsgId = res.lastInsertID.toInt();
      return ChatMessageModel(
        id: 'msg_$newMsgId',
        dbMessageId: newMsgId,
        conversationId: conversationId,
        senderId: 'user_$senderId',
        senderName: senderName,
        message: text.trim(),
        timestamp: DateTime.now(),
        isMe: true,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // 5. TITIK PENGANTARAN FAVORIT
  // ==========================================

  Future<List<DeliveryLocationModel>> fetchDeliveryLocations(int userId) async {
    if (_conn == null || !_conn!.connected) {
      final ok = await connect();
      if (!ok) return [];
    }
    try {
      final res = await _conn!.execute(
        'SELECT * FROM delivery_locations WHERE user_id = :userId ORDER BY is_primary DESC, location_id DESC',
        {'userId': userId},
      );
      final List<DeliveryLocationModel> list = [];
      for (final r in res.rows) {
        final a = r.assoc();
        list.add(
          DeliveryLocationModel(
            id: int.tryParse(a['location_id'] ?? '0'),
            userId: userId,
            title: a['title'] ?? '',
            areaName: a['area_name'] ?? '',
            detailAddress: a['detail_address'] ?? '',
            deliveryNote: a['delivery_note'],
            isPrimary: (a['is_primary'] ?? '0') == '1',
            createdAt: DateTime.tryParse(a['created_at'] ?? ''),
          ),
        );
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<bool> addDeliveryLocation({
    required int userId,
    required String title,
    required String areaName,
    required String detailAddress,
    String? deliveryNote,
    bool isPrimary = false,
  }) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      if (isPrimary) {
        await _conn!.execute('UPDATE delivery_locations SET is_primary = 0 WHERE user_id = :userId', {'userId': userId});
      }
      await _conn!.execute(
        'INSERT INTO delivery_locations (user_id, title, area_name, detail_address, delivery_note, is_primary) '
        'VALUES (:userId, :title, :area, :detail, :note, :isPrimary)',
        {
          'userId': userId,
          'title': title.trim(),
          'area': areaName.trim(),
          'detail': detailAddress.trim(),
          'note': deliveryNote?.trim() ?? '',
          'isPrimary': isPrimary ? 1 : 0,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateDeliveryLocation({
    required int locationId,
    required int userId,
    required String title,
    required String areaName,
    required String detailAddress,
    String? deliveryNote,
    bool isPrimary = false,
  }) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      if (isPrimary) {
        await _conn!.execute('UPDATE delivery_locations SET is_primary = 0 WHERE user_id = :userId', {'userId': userId});
      }
      await _conn!.execute(
        'UPDATE delivery_locations SET title = :title, area_name = :area, detail_address = :detail, delivery_note = :note, is_primary = :isPrimary '
        'WHERE location_id = :id AND user_id = :userId',
        {
          'id': locationId,
          'userId': userId,
          'title': title.trim(),
          'area': areaName.trim(),
          'detail': detailAddress.trim(),
          'note': deliveryNote?.trim() ?? '',
          'isPrimary': isPrimary ? 1 : 0,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDeliveryLocation(int locationId, int userId) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      await _conn!.execute(
        'DELETE FROM delivery_locations WHERE location_id = :id AND user_id = :userId',
        {'id': locationId, 'userId': userId},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setPrimaryDeliveryLocation(int locationId, int userId) async {
    if (_conn == null || !_conn!.connected) return false;
    try {
      await _conn!.execute('UPDATE delivery_locations SET is_primary = 0 WHERE user_id = :userId', {'userId': userId});
      await _conn!.execute('UPDATE delivery_locations SET is_primary = 1 WHERE location_id = :id AND user_id = :userId', {'id': locationId, 'userId': userId});
      return true;
    } catch (_) {
      return false;
    }
  }

  UserModel _mapRowToUserModel(Map<String, String?> row) {
    final userId = int.tryParse(row['user_id'] ?? '0') ?? 0;
    final storeId = int.tryParse(row['store_id'] ?? '0');
    final roleStr = row['role'] ?? 'pembeli';
    final role = roleStr == 'penjual' ? UserRole.seller : UserRole.buyer;

    final vStatusStr = row['verification_status'];
    StoreVerificationStatus vStatus;
    if (vStatusStr == 'disetujui') {
      vStatus = StoreVerificationStatus.approved;
    } else if (vStatusStr == 'menunggu_verifikasi') {
      vStatus = StoreVerificationStatus.pending;
    } else if (vStatusStr == 'ditolak') {
      vStatus = StoreVerificationStatus.rejected;
    } else {
      vStatus = storeId != null ? StoreVerificationStatus.pending : StoreVerificationStatus.none;
    }

    return UserModel(
      id: 'user_$userId',
      dbUserId: userId,
      dbStoreId: storeId,
      name: row['full_name'] ?? 'Mahasiswa UPN',
      email: row['email'] ?? '',
      npm: row['npm'] ?? '',
      faculty: 'UPN "Veteran" Jawa Timur',
      studyProgram: (row['user_type'] ?? 'Mahasiswa').toUpperCase(),
      phoneNumber: row['phone'] ?? '',
      role: role,
      avatarUrl: row['profile_photo'] ??
          (role == UserRole.seller
              ? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80'
              : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80'),
      storeName: row['store_name'] ?? '',
      storeLocation: row['store_location'] ?? '',
      storeDescription: row['store_desc'],
      storeContactPhone: row['contact_phone'],
      isStoreOpen: (row['store_status'] ?? 'buka') == 'buka',
      verificationStatus: vStatus,
      rejectionReason: row['rejection_reason'],
      userType: row['user_type'] ?? 'mahasiswa',
    );
  }
}
