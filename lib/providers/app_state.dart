import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/menu_item_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/chat_message_model.dart';
import '../models/promotion_model.dart';
import '../models/delivery_location_model.dart';
import '../models/withdrawal_model.dart';
import '../models/conversation_model.dart';
import '../services/database_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => !_isLoggedIn;

  bool _isDbConnected = false;
  bool get isDbConnected => _isDbConnected;

  // Current active user (defaults to guest if not logged in)
  UserModel _currentUser = UserModel.guest;
  UserModel get currentUser => _isLoggedIn ? _currentUser : UserModel.guest;

  // Active view role (buyer vs seller). Defaults to buyer mode.
  UserRole _activeRole = UserRole.buyer;
  UserRole get activeRole => _isLoggedIn ? _activeRole : UserRole.buyer;

  bool get canSwitchToSeller => _isLoggedIn && _currentUser.isSellerApproved;

  AppState() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final connected = await _dbService.connect();
    _isDbConnected = connected;
    if (connected) {
      final dbProducts = await _dbService.fetchProducts();
      if (dbProducts.isNotEmpty) {
        _menuItems.clear();
        _menuItems.addAll(dbProducts);
      }
    }
    notifyListeners();
  }

  // Authentication Flow: Login
  Future<String?> login(String emailOrNpm, String password) async {
    final user = await _dbService.login(emailOrNpm, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      _activeRole = UserRole.buyer; // Always starts as buyer view on homepage
      _currentTabIndex = 0;
      await _syncProducts();
      await _syncUserData();
      notifyListeners();
      return null;
    } else {
      // Fallback local check for demo/offline test
      if ((emailOrNpm.contains('hafidz') || emailOrNpm == '22081010045') && password == 'password123') {
        _currentUser = const UserModel(
          id: 'user_hafidz',
          dbUserId: 1,
          name: 'Hafidz Ahmad',
          email: 'hafidz@student.upnjatim.ac.id',
          npm: '22081010045',
          faculty: 'Fakultas Ilmu Komputer (FIK)',
          studyProgram: 'Informatika',
          phoneNumber: '081234567890',
          role: UserRole.buyer,
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          verificationStatus: StoreVerificationStatus.none,
        );
        _isLoggedIn = true;
        _activeRole = UserRole.buyer;
        _currentTabIndex = 0;
        await _syncUserData();
        notifyListeners();
        return null;
      } else if ((emailOrNpm.contains('adistya') || emailOrNpm == '22081010088') && password == 'password123') {
        _currentUser = const UserModel(
          id: 'user_adistya',
          dbUserId: 2,
          dbStoreId: 1,
          name: 'Adistya Putri',
          email: 'adistya@student.upnjatim.ac.id',
          npm: '22081010088',
          faculty: 'Fakultas Ilmu Komputer (FIK)',
          studyProgram: 'Informatika',
          phoneNumber: '081987654321',
          role: UserRole.seller,
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
          storeName: 'Warung Sambal Kampus UPN',
          storeLocation: 'Kantin Barat • Gedung Giri Reksa',
          isStoreOpen: true,
          verificationStatus: StoreVerificationStatus.approved,
        );
        _isLoggedIn = true;
        _activeRole = UserRole.buyer;
        _currentTabIndex = 0;
        await _syncUserData();
        notifyListeners();
        return null;
      }
      return 'Email/NPM atau kata sandi tidak sesuai. Silakan periksa kembali.';
    }
  }

  // Authentication Flow: Register (All new users start as Pembeli)
  Future<String?> register({
    required String fullName,
    required String npm,
    required String email,
    required String password,
    required String phone,
    required String userType,
  }) async {
    final newUser = await _dbService.register(
      fullName: fullName,
      npm: npm,
      email: email,
      password: password,
      phone: phone,
      userType: userType,
    );

    if (newUser != null) {
      _currentUser = newUser;
      _isLoggedIn = true;
      _activeRole = UserRole.buyer;
      _currentTabIndex = 0;
      await _syncProducts();
      await _syncUserData();
      notifyListeners();
      return null;
    } else {
      // Local fallback in case DB is unreachable
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: fullName,
        email: email,
        npm: npm,
        faculty: 'UPN "Veteran" Jawa Timur',
        studyProgram: userType.toUpperCase(),
        phoneNumber: phone,
        role: UserRole.buyer,
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        storeName: '',
        storeLocation: '',
        isStoreOpen: false,
        verificationStatus: StoreVerificationStatus.none,
        userType: userType,
      );
      _isLoggedIn = true;
      _activeRole = UserRole.buyer;
      _currentTabIndex = 0;
      notifyListeners();
      return null;
    }
  }

  // Logout: cleanly reset back to Guest
  void logout() {
    _isLoggedIn = false;
    _currentUser = UserModel.guest;
    _activeRole = UserRole.buyer;
    _currentTabIndex = 0;
    _cartItems.clear();
    _buyerOrders.clear();
    _sellerOrders.clear();
    _deliveryLocations.clear();
    _conversations.clear();
    _activeConversation = null;
    _activeChatMessages.clear();
    _sellerTotalOmset = 0;
    _sellerAvailableBalance = 0;
    _sellerPendingWithdrawal = 0;
    _sellerWithdrawals.clear();
    notifyListeners();
  }

  // Mode Toggling (Only permitted if approved seller)
  void switchToSellerMode() {
    if (canSwitchToSeller) {
      _activeRole = UserRole.seller;
      _currentTabIndex = 0;
      refreshSellerFinancials();
      refreshOrders();
      notifyListeners();
    }
  }

  void switchToBuyerMode() {
    _activeRole = UserRole.buyer;
    _currentTabIndex = 0;
    refreshOrders();
    notifyListeners();
  }

  void toggleUserRole() {
    if (_activeRole == UserRole.buyer) {
      if (canSwitchToSeller) {
        switchToSellerMode();
      }
    } else {
      switchToBuyerMode();
    }
  }

  void setRole(UserRole role) {
    if (role == UserRole.seller && !canSwitchToSeller) return;
    _activeRole = role;
    _currentTabIndex = 0;
    notifyListeners();
  }

  // Store Application & Verification
  Future<String?> submitStoreApplication({
    required String storeName,
    required String storeLocation,
    required String description,
    required String contactPhone,
    String? storePhoto,
  }) async {
    if (!_isLoggedIn) return 'Silakan masuk ke akun Anda terlebih dahulu.';

    if (_isDbConnected && _currentUser.dbUserId != null) {
      final updated = await _dbService.submitStoreApplication(
        userId: _currentUser.dbUserId!,
        storeName: storeName,
        storeLocation: storeLocation,
        storeDescription: description,
        contactPhone: contactPhone,
        storePhoto: storePhoto,
      );
      if (updated != null) {
        _currentUser = updated;
        notifyListeners();
        return null;
      }
    }

    // Local state fallback
    _currentUser = _currentUser.copyWith(
      storeName: storeName,
      storeLocation: storeLocation,
      storeDescription: description,
      storeContactPhone: contactPhone,
      verificationStatus: StoreVerificationStatus.pending,
      rejectionReason: null,
      dbStoreId: _currentUser.dbStoreId ?? 99,
    );
    notifyListeners();
    return null;
  }

  Future<void> reviewCurrentStoreApplication(bool approve, {String? reason}) async {
    if (_currentUser.dbStoreId != null && _isDbConnected) {
      final updated = await _dbService.reviewStoreApplication(
        storeId: _currentUser.dbStoreId!,
        approve: approve,
        rejectionReason: reason,
      );
      if (updated != null) {
        _currentUser = updated;
        if (!approve && _activeRole == UserRole.seller) {
          _activeRole = UserRole.buyer;
        }
        notifyListeners();
        return;
      }
    }

    // Local state fallback
    _currentUser = _currentUser.copyWith(
      verificationStatus: approve ? StoreVerificationStatus.approved : StoreVerificationStatus.rejected,
      role: approve ? UserRole.seller : UserRole.buyer,
      rejectionReason: approve ? null : (reason ?? 'Dokumen stan belum lengkap atau lokasi stan belum terdaftar di kantin UPN.'),
    );
    if (!approve && _activeRole == UserRole.seller) {
      _activeRole = UserRole.buyer;
    }
    notifyListeners();
  }

  Future<void> _syncProducts() async {
    if (_isDbConnected) {
      final dbProducts = await _dbService.fetchProducts();
      if (dbProducts.isNotEmpty) {
        _menuItems.clear();
        _menuItems.addAll(dbProducts);
      }
    }
  }

  void toggleStoreStatus() {
    _currentUser = _currentUser.copyWith(isStoreOpen: !_currentUser.isStoreOpen);
    if (_currentUser.dbStoreId != null) {
      _dbService.updateStoreStatus(_currentUser.dbStoreId!, _currentUser.isStoreOpen);
    }
    notifyListeners();
  }

  // Navigation state
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Filtering
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  String _selectedCategory = 'Semua Kategori';
  String get selectedCategory => _selectedCategory;

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  String _selectedFaculty = 'Semua Lokasi';
  String get selectedFaculty => _selectedFaculty;

  void setSelectedFaculty(String faculty) {
    _selectedFaculty = faculty;
    notifyListeners();
  }

  // Menu items catalog
  final List<MenuItemModel> _menuItems = [
    const MenuItemModel(
      id: 'menu_01',
      dbProductId: 1,
      merchantId: 'store_1',
      merchantName: 'Ayam Geprek Giri Reksa',
      merchantLocation: 'Kantin Barat • Gedung Giri Reksa',
      name: 'Ayam Geprek Sambal Bawang UPNVJT',
      description: 'Ayam krispi gurih dengan ulekan cabai rawit pedas segar khas sambal bawang Surabaya, disajikan hangat bersama nasi pulen dan lalapan segar.',
      price: 15000,
      originalPrice: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 4.9,
      reviewCount: 148,
      isPromo: true,
      isReadyStock: true,
      stockCount: 18,
      soldCount: 342,
      tags: ['Halal', 'UPNVJT Terverifikasi', 'Paling Laris'],
    ),
    const MenuItemModel(
      id: 'menu_02',
      dbProductId: 2,
      merchantId: 'store_1',
      merchantName: 'Dapur Mahasiswa FISIP',
      merchantLocation: 'Gedung FISIP Lt. 1',
      name: 'Nasi Bakar Cakalang Suwir Kemangi',
      description: 'Nasi gurih dibungkus daun pisang aroma rempah wangi dengan isian melimpah cakalang asap suwir dan kemangi segar.',
      price: 14000,
      imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 4.8,
      reviewCount: 92,
      isPromo: false,
      isReadyStock: true,
      stockCount: 12,
      soldCount: 215,
      tags: ['Halal', 'Wangi Daun Pisang'],
    ),
    const MenuItemModel(
      id: 'menu_03',
      dbProductId: 3,
      merchantId: 'store_2',
      merchantName: 'Teh Poci Kampus Rungkut',
      merchantLocation: 'Kantin Giri Santoso',
      name: 'Es Teh Melati Jumbo Kampus',
      description: 'Es teh melati seduh tradisional poci tanah liat dengan aroma melati wangi semerbak, pelepas dahaga nomor satu saat terik perkuliahan.',
      price: 5000,
      originalPrice: 6000,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.9,
      reviewCount: 310,
      isPromo: true,
      isReadyStock: true,
      stockCount: 50,
      soldCount: 820,
      tags: ['Halal', 'Favorit Mahasiswa', 'Ukuran Jumbo'],
    ),
    const MenuItemModel(
      id: 'menu_04',
      dbProductId: 4,
      merchantId: 'store_3',
      merchantName: 'Dimsum Santoso Mahasiswa',
      merchantLocation: 'Gedung Teknik Kimia',
      name: 'Dimsum Ayam Mentai Melted (4 pcs)',
      description: 'Dimsum olahan daging ayam asli dengan topping saus mentai gurih creamy yang ditorch hingga wangi.',
      price: 16000,
      imageUrl: 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.7,
      reviewCount: 84,
      isPromo: false,
      isReadyStock: true,
      stockCount: 15,
      soldCount: 190,
      tags: ['Halal', 'Creamy Torch'],
    ),
    const MenuItemModel(
      id: 'menu_05',
      dbProductId: 5,
      merchantId: 'store_1',
      merchantName: 'Warung Sambal Kampus UPN',
      merchantLocation: 'Kantin Giri Reksa • Samping FIK',
      name: 'Paket Hemat: Ayam Krispi + Es Teh Jumbo',
      description: 'Paket kenyang andalan mahasiswa tanggal tua: Nasi putih pulen, ayam krispi saus lava pedas manis, plus free Es Teh Jumbo.',
      price: 18000,
      originalPrice: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=800&q=80',
      category: 'Paket Hemat',
      rating: 5.0,
      reviewCount: 220,
      isPromo: true,
      isReadyStock: true,
      stockCount: 25,
      soldCount: 512,
      tags: ['Halal', 'Paket Kenyang', 'Diskon Kampus'],
    ),
    const MenuItemModel(
      id: 'menu_06',
      dbProductId: 6,
      merchantId: 'store_4',
      merchantName: 'Kopi Seduh FEB',
      merchantLocation: 'Gedung FEB Lt. 2',
      name: 'Es Kopi Susu Gula Aren UPN',
      description: 'Espresso blend Arabika-Robusta lokal dengan susu creamy dan sirup gula aren murni. Teman nugas skripsi & deadline kuliah.',
      price: 12000,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.8,
      reviewCount: 175,
      isPromo: false,
      isReadyStock: true,
      stockCount: 30,
      soldCount: 405,
      tags: ['Halal', 'Double Shot Available'],
    ),
  ];

  List<MenuItemModel> get menuItems {
    return _menuItems.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.merchantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'Semua Kategori' ||
          item.category == _selectedCategory;

      final matchesFaculty = _selectedFaculty == 'Semua Lokasi' ||
          item.merchantLocation.contains(_selectedFaculty.replaceAll('Gedung ', ''));

      return matchesSearch && matchesCategory && matchesFaculty;
    }).toList();
  }

  List<MenuItemModel> get allRawMenuItems => _menuItems;

  void toggleStock(String itemId) {
    if (!canSwitchToSeller && _activeRole != UserRole.seller) return;
    final idx = _menuItems.indexWhere((m) => m.id == itemId);
    if (idx != -1) {
      final current = _menuItems[idx];
      final newReady = !current.isReadyStock;
      _menuItems[idx] = current.copyWith(
        isReadyStock: newReady,
        stockCount: newReady ? 15 : 0,
      );
      if (current.dbProductId != null) {
        _dbService.toggleProductStock(current.dbProductId!, newReady);
      }
      notifyListeners();
    }
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    if (!canSwitchToSeller && _activeRole != UserRole.seller) return;
    _menuItems.insert(0, item);
    if (_currentUser.dbStoreId != null) {
      final saved = await _dbService.addProduct(
        storeId: _currentUser.dbStoreId!,
        name: item.name,
        categoryName: item.category,
        price: item.price,
        description: item.description,
        imageUrl: item.imageUrl,
        stock: item.stockCount,
      );
      if (saved != null) {
        final idx = _menuItems.indexWhere((m) => m.id == item.id);
        if (idx != -1) _menuItems[idx] = saved;
      }
    }
    notifyListeners();
  }

  void deleteMenuItem(String itemId) {
    if (!canSwitchToSeller && _activeRole != UserRole.seller) return;
    final item = _menuItems.firstWhere((m) => m.id == itemId, orElse: () => _menuItems.first);
    if (item.dbProductId != null) {
      _dbService.deleteProduct(item.dbProductId!);
    }
    _menuItems.removeWhere((it) => it.id == itemId);
    notifyListeners();
  }

  // Cart Management
  final List<CartItemModel> _cartItems = [];
  List<CartItemModel> get cartItems => _cartItems;

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get cartSubtotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  int get campusServiceFee => _cartItems.isEmpty ? 0 : 1000;
  int get cartTotal => cartSubtotal + campusServiceFee;

  void addToCart(MenuItemModel item, {int quantity = 1, String level = 'Level 1 (Sedang)', String note = ''}) {
    final existingIdx = _cartItems.indexWhere(
      (ci) => ci.item.id == item.id && ci.selectedSpiceLevel == level,
    );
    if (existingIdx != -1) {
      _cartItems[existingIdx].quantity += quantity;
    } else {
      _cartItems.add(
        CartItemModel(
          item: item,
          quantity: quantity,
          selectedSpiceLevel: level,
          note: note,
        ),
      );
    }
    notifyListeners();
  }

  void updateCartQuantity(int index, int delta) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].quantity += delta;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Data Synchronization per Logged-in User
  Future<void> _syncUserData() async {
    await refreshOrders();
    await refreshDeliveryLocations();
    await refreshConversations();
    if (_currentUser.dbStoreId != null) {
      await refreshSellerFinancials();
    }
  }

  // ==========================================
  // 1 & 2. TOTAL OMSET & TARIK SALDO (SELLER)
  // ==========================================
  int _sellerTotalOmset = 0;
  int get sellerTotalOmset => _sellerTotalOmset;

  int _sellerAvailableBalance = 0;
  int get sellerAvailableBalance => _sellerAvailableBalance;

  int _sellerPendingWithdrawal = 0;
  int get sellerPendingWithdrawal => _sellerPendingWithdrawal;

  List<WithdrawalModel> _sellerWithdrawals = [];
  List<WithdrawalModel> get sellerWithdrawals => _sellerWithdrawals;

  bool _isWithdrawalSubmitting = false;
  bool get isWithdrawalSubmitting => _isWithdrawalSubmitting;

  Future<void> refreshSellerFinancials() async {
    final storeId = _currentUser.dbStoreId;
    if (storeId != null && _isDbConnected) {
      final summary = await _dbService.fetchSellerFinancialSummary(storeId);
      _sellerTotalOmset = summary['totalOmset'] ?? 0;
      _sellerAvailableBalance = summary['availableBalance'] ?? 0;
      _sellerPendingWithdrawal = summary['pendingWithdrawal'] ?? 0;
      _sellerWithdrawals = await _dbService.fetchWithdrawals(storeId);
      notifyListeners();
    }
  }

  Future<String?> requestWithdrawal({
    required int amount,
    required String paymentMethod,
    required String accountName,
    required String accountNumber,
    String? notes,
  }) async {
    if (_isWithdrawalSubmitting) return 'Permintaan sedang diproses...';
    final storeId = _currentUser.dbStoreId;
    final sellerId = _currentUser.dbUserId;
    if (storeId == null || sellerId == null) {
      return 'Toko penjual tidak teridentifikasi.';
    }

    _isWithdrawalSubmitting = true;
    notifyListeners();

    try {
      final error = await _dbService.requestWithdrawal(
        storeId: storeId,
        sellerId: sellerId,
        amount: amount,
        paymentMethod: paymentMethod,
        accountName: accountName,
        accountNumber: accountNumber,
        notes: notes,
      );

      if (error == null) {
        await refreshSellerFinancials();
      }
      return error;
    } finally {
      _isWithdrawalSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> simulateReviewWithdrawal({
    required int withdrawalId,
    required bool approve,
    String? reason,
  }) async {
    await _dbService.simulateReviewWithdrawal(
      withdrawalId: withdrawalId,
      approve: approve,
      rejectionReason: reason,
    );
    await refreshSellerFinancials();
  }

  // ==========================================
  // 3. PESANAN SAYA (BUYER & SELLER)
  // ==========================================
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'LW-UPN-20261010-001',
      buyerName: 'Hafidz Ahmad',
      buyerNpm: '22081010045',
      buyerPhone: '081234567890',
      merchantName: 'Ayam Geprek Giri Reksa',
      items: [
        CartItemModel(
          item: const MenuItemModel(
            id: 'menu_01',
            merchantId: 'merchant_adistya',
            merchantName: 'Ayam Geprek Giri Reksa',
            merchantLocation: 'Kantin Barat • Gedung Giri Reksa',
            name: 'Ayam Geprek Sambal Bawang UPNVJT',
            description: '',
            price: 15000,
            imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80',
            category: 'Makanan Utama',
          ),
          quantity: 2,
          selectedSpiceLevel: 'Level 2 (Pedas)',
        ),
      ],
      subtotal: 30000,
      campusServiceFee: 1000,
      totalAmount: 31000,
      deliveryMethod: DeliveryMethod.delivery,
      destinationLocation: 'Gedung Giri Santoso Lt. 2 - Ruang Lab RPL',
      paymentMethod: PaymentMethod.qris,
      status: OrderStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      notes: 'Sambal jangan terlalu asin, terima kasih kak!',
    ),
  ];

  List<OrderModel> _buyerOrders = [];
  List<OrderModel> get buyerOrders => _buyerOrders.isNotEmpty ? _buyerOrders : (_activeRole == UserRole.buyer ? _orders : []);

  List<OrderModel> _sellerOrders = [];
  List<OrderModel> get sellerOrders => _sellerOrders.isNotEmpty ? _sellerOrders : (_activeRole == UserRole.seller ? _orders : []);

  List<OrderModel> get orders {
    if (_isDbConnected && _currentUser.dbUserId != null) {
      return _activeRole == UserRole.seller ? _sellerOrders : _buyerOrders;
    }
    return _orders;
  }

  Future<void> refreshOrders() async {
    if (_currentUser.dbUserId != null && _isDbConnected) {
      _buyerOrders = await _dbService.fetchOrdersForBuyer(_currentUser.dbUserId!);
      if (_currentUser.dbStoreId != null) {
        _sellerOrders = await _dbService.fetchOrdersForSeller(_currentUser.dbStoreId!);
      } else {
        _sellerOrders = [];
      }
      notifyListeners();
    }
  }

  OrderModel placeOrder({
    required DeliveryMethod deliveryMethod,
    required String destinationLocation,
    required PaymentMethod paymentMethod,
    String? notes,
  }) {
    final newOrder = OrderModel(
      id: 'LW-UPN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      buyerName: _currentUser.name,
      buyerNpm: _currentUser.npm,
      buyerPhone: _currentUser.phoneNumber,
      merchantName: _cartItems.isNotEmpty ? _cartItems.first.item.merchantName : 'Kantin UPN',
      items: List.from(_cartItems),
      subtotal: cartSubtotal,
      campusServiceFee: campusServiceFee,
      totalAmount: cartTotal,
      deliveryMethod: deliveryMethod,
      destinationLocation: destinationLocation,
      paymentMethod: paymentMethod,
      status: OrderStatus.waitingConfirmation,
      createdAt: DateTime.now(),
      notes: notes,
    );

    _orders.insert(0, newOrder);
    _buyerOrders.insert(0, newOrder);

    // Save to database asynchronously
    if (_currentUser.dbUserId != null) {
      int targetStoreId = 1;
      if (_cartItems.isNotEmpty) {
        final mId = _cartItems.first.item.merchantId;
        final parsed = int.tryParse(mId.replaceAll(RegExp(r'[^0-9]'), ''));
        if (parsed != null && parsed > 0) targetStoreId = parsed;
      }
      _dbService.createOrder(
        buyerId: _currentUser.dbUserId!,
        storeId: targetStoreId,
        order: newOrder,
      ).then((_) {
        refreshOrders();
        refreshSellerFinancials();
      });
    }

    clearCart();
    notifyListeners();
    return newOrder;
  }

  Future<bool> cancelOrder(String orderCode, {String reason = 'Dibatalkan oleh pembeli'}) async {
    if (_currentUser.dbUserId == null) return false;
    final ok = await _dbService.cancelOrder(
      orderCode: orderCode,
      reason: reason,
      buyerId: _currentUser.dbUserId!,
    );
    if (ok) {
      await refreshOrders();
      await refreshSellerFinancials();
    } else {
      // Local fallback
      final idx = _orders.indexWhere((o) => o.id == orderCode);
      if (idx != -1) {
        _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled, cancellationReason: reason);
        notifyListeners();
      }
    }
    return ok;
  }

  Future<bool> confirmOrderReceived(String orderCode) async {
    if (_currentUser.dbUserId == null) return false;
    final ok = await _dbService.confirmOrderReceived(
      orderCode: orderCode,
      buyerId: _currentUser.dbUserId!,
    );
    if (ok) {
      await refreshOrders();
      await refreshSellerFinancials();
    } else {
      final idx = _orders.indexWhere((o) => o.id == orderCode);
      if (idx != -1) {
        _orders[idx] = _orders[idx].copyWith(status: OrderStatus.completed);
        notifyListeners();
      }
    }
    return ok;
  }

  Future<bool> updateSellerOrderStatus(String orderCode, OrderStatus newStatus) async {
    if (_currentUser.dbStoreId == null) return false;
    final ok = await _dbService.sellerUpdateOrderStatus(
      orderCode: orderCode,
      status: newStatus,
      storeId: _currentUser.dbStoreId!,
    );
    if (ok) {
      await refreshOrders();
      await refreshSellerFinancials();
    } else {
      final idx = _orders.indexWhere((o) => o.id == orderCode);
      if (idx != -1) {
        _orders[idx] = _orders[idx].copyWith(status: newStatus);
        notifyListeners();
      }
    }
    return ok;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: status);
      _dbService.updateOrderStatus(orderId, status);
      notifyListeners();
    }
  }

  // ==========================================
  // 4. CHAT & PERCAKAPAN
  // ==========================================
  List<ConversationModel> _conversations = [];
  List<ConversationModel> get conversations => _conversations;

  ConversationModel? _activeConversation;
  ConversationModel? get activeConversation => _activeConversation;

  final List<ChatMessageModel> _chatMessages = [
    ChatMessageModel(
      id: 'msg_01',
      senderId: 'seller_adistya',
      senderName: 'Adistya (Warung Sambal Kampus)',
      message: 'Halo kak! Pesanan Paket Ayam Geprek sedang kami siapkan yaa. Cabai rawitnya dibuat pedas level 2 sesuai request.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      isMe: false,
    ),
    ChatMessageModel(
      id: 'msg_02',
      senderId: 'user_hafidz',
      senderName: 'Hafidz Ahmad',
      message: 'Siap kak, nanti kalau sudah selesai langsung diantar ke Lantai 2 Gedung Giri Santoso ya, saya di depan Lab RPL.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
      isMe: true,
    ),
  ];

  List<ChatMessageModel> _activeChatMessages = [];
  List<ChatMessageModel> get chatMessages {
    if (_activeChatMessages.isNotEmpty) return _activeChatMessages;
    return _chatMessages;
  }

  Future<void> refreshConversations() async {
    if (_currentUser.dbUserId != null && _isDbConnected) {
      _conversations = await _dbService.fetchUserConversations(_currentUser.dbUserId!);
      if (_activeConversation != null) {
        final match = _conversations.where((c) => c.id == _activeConversation!.id).firstOrNull;
        if (match != null) {
          _activeConversation = match;
          await loadMessagesForActiveConversation();
        } else if (_conversations.isNotEmpty) {
          _activeConversation = _conversations.first;
          await loadMessagesForActiveConversation();
        }
      } else if (_conversations.isNotEmpty) {
        _activeConversation = _conversations.first;
        await loadMessagesForActiveConversation();
      }
      notifyListeners();
    }
  }

  Future<void> selectConversation(ConversationModel convo) async {
    _activeConversation = convo;
    await loadMessagesForActiveConversation();
    notifyListeners();
  }

  Future<void> loadMessagesForActiveConversation() async {
    if (_activeConversation != null && _currentUser.dbUserId != null && _isDbConnected) {
      _activeChatMessages = await _dbService.fetchMessages(_activeConversation!.id, _currentUser.dbUserId!);
      notifyListeners();
    }
  }

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (_activeConversation != null && _currentUser.dbUserId != null && _isDbConnected) {
      final newMsg = await _dbService.sendMessage(
        conversationId: _activeConversation!.id,
        senderId: _currentUser.dbUserId!,
        senderName: _currentUser.name,
        text: message.trim(),
      );
      if (newMsg != null) {
        _activeChatMessages.add(newMsg);
        await refreshConversations();
        notifyListeners();
        return;
      }
    }

    _activeChatMessages.add(
      ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: _currentUser.id,
        senderName: _currentUser.name,
        message: message.trim(),
        timestamp: DateTime.now(),
        isMe: true,
      ),
    );
    notifyListeners();
  }

  // ==========================================
  // 5. TITIK PENGANTARAN FAVORIT
  // ==========================================
  List<DeliveryLocationModel> _deliveryLocations = [];
  List<DeliveryLocationModel> get deliveryLocations => _deliveryLocations;

  DeliveryLocationModel? get primaryDeliveryLocation {
    if (_deliveryLocations.isEmpty) return null;
    return _deliveryLocations.firstWhere(
      (loc) => loc.isPrimary,
      orElse: () => _deliveryLocations.first,
    );
  }

  Future<void> refreshDeliveryLocations() async {
    if (_currentUser.dbUserId != null && _isDbConnected) {
      _deliveryLocations = await _dbService.fetchDeliveryLocations(_currentUser.dbUserId!);
      notifyListeners();
    }
  }

  Future<bool> addDeliveryLocation({
    required String title,
    required String areaName,
    required String detailAddress,
    String? deliveryNote,
    bool isPrimary = false,
  }) async {
    if (_currentUser.dbUserId == null) return false;
    final ok = await _dbService.addDeliveryLocation(
      userId: _currentUser.dbUserId!,
      title: title,
      areaName: areaName,
      detailAddress: detailAddress,
      deliveryNote: deliveryNote,
      isPrimary: isPrimary,
    );
    if (ok) {
      await refreshDeliveryLocations();
    }
    return ok;
  }

  Future<bool> updateDeliveryLocation({
    required int locationId,
    required String title,
    required String areaName,
    required String detailAddress,
    String? deliveryNote,
    bool isPrimary = false,
  }) async {
    if (_currentUser.dbUserId == null) return false;
    final ok = await _dbService.updateDeliveryLocation(
      locationId: locationId,
      userId: _currentUser.dbUserId!,
      title: title,
      areaName: areaName,
      detailAddress: detailAddress,
      deliveryNote: deliveryNote,
      isPrimary: isPrimary,
    );
    if (ok) {
      await refreshDeliveryLocations();
    }
    return ok;
  }

  Future<bool> deleteDeliveryLocation(int locationId) async {
    if (_currentUser.dbUserId == null) return false;
    final ok = await _dbService.deleteDeliveryLocation(locationId, _currentUser.dbUserId!);
    if (ok) {
      await refreshDeliveryLocations();
    }
    return ok;
  }

  Future<bool> setPrimaryDeliveryLocation(int locationId) async {
    if (_currentUser.dbUserId == null) return false;
    final ok = await _dbService.setPrimaryDeliveryLocation(locationId, _currentUser.dbUserId!);
    if (ok) {
      await refreshDeliveryLocations();
    }
    return ok;
  }

  // ==========================================
  // PROMOTIONS & FAVORITES
  // ==========================================
  final List<PromotionModel> _promotions = [
    const PromotionModel(
      id: 'p_01',
      title: 'Diskon Awal Kuliah 20%',
      description: 'Potongan harga khusus seluruh menu mahasiswa dengan kode VOUCHER-UPN20!',
      discountTag: 'DISKON 20%',
      code: 'UPN20HEMAT',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
      merchantName: 'Ayam Geprek Giri Reksa',
      validUntil: '15 Okt 2026',
    ),
    const PromotionModel(
      id: 'p_02',
      title: 'Gratis Ongkir Antar Fakultas',
      description: 'Pesan antar ke ruang kelas atau lab seluruh gedung UPNVJT tanpa biaya delivery.',
      discountTag: 'FREE ANTAR',
      code: 'ANTARGEDUNG',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
      merchantName: 'Mitra Canteen UPNVJT',
      validUntil: '20 Okt 2026',
    ),
  ];

  List<PromotionModel> get promotions => _promotions;

  final Set<String> _favoriteIds = {'menu_01', 'menu_03'};
  bool isFavorite(String itemId) => _favoriteIds.contains(itemId);

  void toggleFavorite(String itemId) {
    if (_favoriteIds.contains(itemId)) {
      _favoriteIds.remove(itemId);
    } else {
      _favoriteIds.add(itemId);
    }
    notifyListeners();
  }
}
