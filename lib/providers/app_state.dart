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
import '../models/store_model.dart';
import '../models/product_rating_model.dart';
import '../models/seller_analytics_model.dart';
import '../constants/app_config.dart';
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

  Future<void>? _initDbFuture;
  Future<void>? get initDbFuture => _initDbFuture;

  AppState() {
    _initDbFuture = _initDatabase();
  }

  Future<void> _initDatabase() async {
    final connected = await _dbService.connect();
    _isDbConnected = connected;
    if (connected) {
      await _syncStores();
      await _syncProducts();
    }
    notifyListeners();
  }

  // Authentication Flow: Login
  Future<String?> login(String emailOrNpm, String password) async {
    if (_initDbFuture != null) {
      try {
        await _initDbFuture;
      } catch (_) {}
    }
    final user = await _dbService.login(emailOrNpm, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      _activeRole = UserRole.buyer; // Always starts as buyer view on homepage
      _currentTabIndex = 0;
      await _syncStores();
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
          storeLocation: 'Selasar Gedung Bersama FIK Lt. 1',
          storeFaculty: 'Fakultas Ilmu Komputer (FIK)',
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
    if (_initDbFuture != null) {
      try {
        await _initDbFuture;
      } catch (_) {}
    }
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

  Future<void> syncSellerProducts() async {
    final store = currentSellerStore;
    if (store != null && store.dbStoreId != null && _isDbConnected) {
      final storeProds = await _dbService.fetchProductsByStore(store.dbStoreId!);
      if (storeProds.isNotEmpty) {
        for (final p in storeProds) {
          final idx = _menuItems.indexWhere((m) => m.id == p.id || (m.dbProductId != null && m.dbProductId == p.dbProductId));
          if (idx != -1) {
            _menuItems[idx] = p;
          } else {
            _menuItems.insert(0, p);
          }
        }
        notifyListeners();
      }
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

  Future<void> _syncStores() async {
    if (_isDbConnected) {
      final dbStores = await _dbService.fetchStores();
      if (dbStores.isNotEmpty) {
        for (final dbS in dbStores) {
          final idx = _stores.indexWhere((s) => s.id == dbS.id || s.slug == dbS.slug || s.name == dbS.name);
          if (idx != -1) {
            _stores[idx] = dbS;
          } else {
            _stores.add(dbS);
          }
        }
      }
    }
  }

  Future<void> _syncProducts() async {
    if (_isDbConnected) {
      final dbProducts = await _dbService.fetchProducts();
      if (dbProducts.isNotEmpty) {
        for (final dbP in dbProducts) {
          final idx = _menuItems.indexWhere((p) => p.id == dbP.id || (p.dbProductId != null && p.dbProductId == dbP.dbProductId));
          if (idx != -1) {
            _menuItems[idx] = dbP;
          } else {
            _menuItems.add(dbP);
          }
        }
      }
    }
  }

  void toggleStoreStatus() {
    final newStatus = !_currentUser.isStoreOpen;
    _currentUser = _currentUser.copyWith(isStoreOpen: newStatus);

    final currentStore = currentSellerStore;
    if (currentStore != null) {
      for (int i = 0; i < _stores.length; i++) {
        final s = _stores[i];
        if (s.id == currentStore.id ||
            (currentStore.dbStoreId != null && s.dbStoreId == currentStore.dbStoreId) ||
            s.name.trim().toLowerCase() == currentStore.name.trim().toLowerCase()) {
          _stores[i] = s.copyWith(isOpen: newStatus);
        }
      }
    }

    if (_currentUser.dbStoreId != null) {
      _dbService.updateStoreStatus(_currentUser.dbStoreId!, newStatus);
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

  bool _onlyOpenStores = false;
  bool get onlyOpenStores => _onlyOpenStores;

  void setOnlyOpenStores(bool val) {
    _onlyOpenStores = val;
    notifyListeners();
  }

  double _minRating = 0.0;
  double get minRating => _minRating;

  void setMinRating(double val) {
    _minRating = val;
    notifyListeners();
  }

  void resetStoreFilters() {
    _searchQuery = '';
    _selectedCategory = 'Semua Kategori';
    _selectedFaculty = 'Semua Lokasi';
    _onlyOpenStores = false;
    _minRating = 0.0;
    notifyListeners();
  }

  // Stores Catalog (GoFood-style Campus Marketplace)
  final List<StoreModel> _stores = [
    const StoreModel(
      id: 'store_fik',
      name: 'Danusan FIK (Danusan A — Fakultas FIK)',
      slug: 'danusan-fik',
      description: 'Penggalangan dana resmi Himpunan Mahasiswa Informatika (HIMAFIK) untuk Informatics Festival 2026. Aneka risol mayo beef melted, makaroni pedas daun jeruk, dan fudgy brownies lezat.',
      faculty: 'Fakultas Ilmu Komputer (FIK)',
      facultyShort: 'FIK',
      organization: 'Himpunan Mahasiswa Informatika (HIMAFIK)',
      categories: ['Cemilan & Snack', 'Minuman Segar', 'Makanan Utama'],
      location: 'Selasar Depan Lab Gedung FIK Lt. 1',
      bannerUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?auto=format&fit=crop&w=400&q=80',
      rating: 5.0,
      reviewCount: 168,
      isOpen: true,
      deliveryTimeEstimate: '10 - 20 mnt',
      deliveryLocation: 'Antar Selasar/Kelas Gedung FIK',
      isDanusan: true,
      isVerified: true,
      tags: ['Danusan Resmi FIK', 'UPNVJT Verified', 'Dana Informatics Fest'],
    ),
    const StoreModel(
      id: 'store_feb',
      name: 'Danusan FEB (Danusan B — Fakultas FEB)',
      slug: 'danusan-feb',
      description: 'Wirausaha mahasiswa & danusan BEM Fakultas Ekonomi dan Bisnis UPNVJT. Menyajikan es kopi susu gula aren, croffle caramel butter renyah, dan chicken teriyaki rice bowl hangat.',
      faculty: 'Fakultas Ekonomi dan Bisnis (FEB)',
      facultyShort: 'FEB',
      organization: 'BEM FEB UPN "Veteran" Jawa Timur',
      categories: ['Makanan Utama', 'Minuman Segar', 'Cemilan & Snack'],
      location: 'Lobby Utama Gedung FEB Lt. 1',
      bannerUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&q=80',
      rating: 4.8,
      reviewCount: 142,
      isOpen: true,
      deliveryTimeEstimate: '10 - 15 mnt',
      deliveryLocation: 'Antar Area Gedung FEB & Perpustakaan',
      isDanusan: true,
      isVerified: true,
      tags: ['Danusan BEM FEB', 'Kopi & Croffle', 'Siap Antar Kelas'],
    ),
    const StoreModel(
      id: 'store_ft',
      name: 'Danusan FT (Danusan C — Fakultas FT)',
      slug: 'danusan-ft',
      description: 'Danusan angkatan mahasiswa Teknik Kimia & Industri UPNVJT. Spesialis dimsum mentai melted hangat, mie pedas jebew nampol, dan minuman segar pelepas dahaga.',
      faculty: 'Fakultas Teknik (FT)',
      facultyShort: 'FT',
      organization: 'Danusan Mahasiswa Fakultas Teknik',
      categories: ['Makanan Utama', 'Cemilan & Snack', 'Minuman Segar'],
      location: 'Gazebo Gedung Teknik Kimia & Industri',
      bannerUrl: 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=400&q=80',
      rating: 4.8,
      reviewCount: 126,
      isOpen: true,
      deliveryTimeEstimate: '15 - 25 mnt',
      deliveryLocation: 'Antar Gedung FT, Laboratorium & Bengkel',
      isDanusan: true,
      isVerified: true,
      tags: ['Danusan FT', 'Dimsum & Mie Pedas', 'UPNVJT Verified'],
    ),
    const StoreModel(
      id: 'store_fad',
      name: 'Danusan FAD',
      slug: 'danusan-fad',
      description: 'Danusan mahasiswa Arsitektur dan Desain (FAD) UPNVJT. Donat kentang cokelat keju dan kopi susu pandan studio maket.',
      faculty: 'Fakultas Arsitektur dan Desain (FAD)',
      facultyShort: 'FAD',
      organization: 'Himpunan Mahasiswa Arsitektur (HIMASITEK)',
      categories: ['Cemilan & Snack', 'Minuman Segar', 'Makanan Utama'],
      location: 'Gedung FAD Lt. 2 • Selasar Studio Desain',
      bannerUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
      rating: 4.7,
      reviewCount: 88,
      isOpen: false,
      deliveryTimeEstimate: '15 - 25 mnt',
      deliveryLocation: 'Antar Studio Maket FAD & Bengkel Desain',
      isDanusan: true,
      isVerified: true,
      tags: ['Danusan FAD', 'Studio Snack', 'Tutup Sementara'],
    ),
    const StoreModel(
      id: 'store_fisip',
      name: 'Danusan FISIP (Danusan D — Fakultas FISIP)',
      slug: 'danusan-fisip',
      description: 'Danusan mahasiswa FISIP UPNVJT menghadirkan kuliner favorit mahasiswa: nasi bakar cakalang suwir kemangi gurih, cireng pedas crispy, dan es matcha latte segar.',
      faculty: 'Fakultas Ilmu Sosial dan Ilmu Politik (FISIP)',
      facultyShort: 'FISIP',
      organization: 'Komunitas Danusan Komunikasi FISIP',
      categories: ['Makanan Utama', 'Cemilan & Snack', 'Minuman Segar'],
      location: 'Gedung FISIP Lt. 1 Selasar Kampus',
      bannerUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
      rating: 4.8,
      reviewCount: 110,
      isOpen: true,
      deliveryTimeEstimate: '10 - 20 mnt',
      deliveryLocation: 'Antar Selasar FISIP & Gedung Kuliah Bersama',
      isDanusan: true,
      isVerified: true,
      tags: ['Danusan FISIP', 'Nasi Bakar Cakalang', 'Halal 100%'],
    ),
    const StoreModel(
      id: 'store_fh',
      name: 'Danusan FH',
      slug: 'danusan-fh',
      description: 'Danusan penggalangan dana Dewan Mahasiswa & Peradilan Semu Fakultas Hukum UPNVJT. Nasi ayam geprek sambal matah Bali, toast roti bakar, dan es red velvet macchiato.',
      faculty: 'Fakultas Hukum (FH)',
      facultyShort: 'FH',
      organization: 'Himpunan Mahasiswa Ilmu Hukum (HIMA FH)',
      categories: ['Makanan Utama', 'Cemilan & Snack', 'Minuman Segar'],
      location: 'Selasar Gedung FH Lt. 1',
      bannerUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
      rating: 4.6,
      reviewCount: 64,
      isOpen: true,
      deliveryTimeEstimate: '10 - 20 mnt',
      deliveryLocation: 'Antar Gedung FH & Selasar Peradilan Semu',
      isDanusan: true,
      isVerified: true,
      tags: ['Danusan FH', 'Ayam Sambal Matah', 'UPNVJT Verified'],
    ),
    const StoreModel(
      id: 'store_1',
      dbStoreId: 1,
      sellerId: 2,
      name: 'Warung Sambal Kampus UPN',
      slug: 'warung-sambal-kampus-upn',
      description: 'Kuliner pedas nikmat karya mahasiswa wirausaha UPN "Veteran" Jawa Timur. Ayam geprek sambal bawang pedas segar, ayam lava, dan penyetan bebek gurih.',
      faculty: 'Fakultas Ilmu Komputer (FIK)',
      facultyShort: 'FIK',
      organization: 'Usaha Mandiri Mahasiswa FIK',
      categories: ['Makanan Utama', 'Cemilan & Snack', 'Minuman Segar'],
      location: 'Selasar Gedung Bersama FIK Lt. 1',
      bannerUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=400&q=80',
      rating: 4.9,
      reviewCount: 348,
      isOpen: true,
      deliveryTimeEstimate: '10 - 20 mnt',
      deliveryLocation: 'Selasar Gedung Kuliah & Lab UPNVJT',
      isDanusan: true,
      isVerified: true,
      tags: ['Paling Laris UPN', 'Ayam Geprek Pedas', 'Terverifikasi Kampus'],
    ),
    const StoreModel(
      id: 'store_dapur_upn',
      dbStoreId: 2,
      sellerId: 3,
      name: 'Danus SIFO',
      slug: 'danus-sifo',
      description: 'Usaha danusan mahasiswa Sistem Informasi UPN "Veteran" Jawa Timur. Aneka hidangan nusantara rumahan porsi kenyang harga mahasiswa: nasi ayam katsu sambal geprek, rice bowl teriyaki, dan aneka minuman segar nugas.',
      faculty: 'Fakultas Ilmu Komputer (FIK)',
      facultyShort: 'FIK',
      organization: 'Himpunan Mahasiswa Sistem Informasi (HIMASIFO)',
      categories: ['Makanan Utama', 'Minuman Segar', 'Cemilan & Snack'],
      location: 'Selasar Lab Sistem Informasi Gedung FIK Lt. 2',
      bannerUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      rating: 4.7,
      reviewCount: 92,
      isOpen: true,
      deliveryTimeEstimate: '10 - 15 mnt',
      deliveryLocation: 'Selasar Gedung FIK & Perpustakaan',
      isDanusan: true,
      isVerified: true,
      tags: ['Danus SIFO', 'Nasi Goreng Kampus', 'Porsi Kenyang'],
    ),
    const StoreModel(
      id: 'store_tehpoci',
      name: 'Danus FP — Teh Poci Kampus',
      slug: 'danus-fp-teh-poci',
      description: 'Pelepas dahaga legendaris wirausaha mahasiswa Fakultas Pertanian UPNVJT. Es teh melati seduhan poci tanah liat tradisional ukuran jumbo porsi puas harga pas di kantong mahasiswa.',
      faculty: 'Fakultas Pertanian (FP)',
      facultyShort: 'FP',
      organization: 'Danusan Mahasiswa Agroteknologi FP',
      categories: ['Minuman Segar', 'Cemilan & Snack'],
      location: 'Selasar Gazebo Fakultas Pertanian',
      bannerUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=800&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=400&q=80',
      rating: 4.9,
      reviewCount: 310,
      isOpen: true,
      deliveryTimeEstimate: '5 - 15 mnt',
      deliveryLocation: 'Selasar Area Fakultas Pertanian',
      isDanusan: true,
      isVerified: true,
      tags: ['Danus FP', 'Es Jumbo', 'Favorit Mahasiswa'],
    ),
  ];

  List<StoreModel> get allRawStores => _stores;

  List<StoreModel> get stores {
    final query = _searchQuery.trim().toLowerCase();
    return _stores.where((store) {
      // 1. Search Query: matches store name, danusan name, faculty, organization, categories, or ANY product sold by this store!
      bool matchesSearch = true;
      if (query.isNotEmpty) {
        final matchesStoreInfo = store.name.toLowerCase().contains(query) ||
            store.faculty.toLowerCase().contains(query) ||
            store.facultyShort.toLowerCase().contains(query) ||
            store.organization.toLowerCase().contains(query) ||
            store.categories.any((c) => c.toLowerCase().contains(query));

        final matchingProducts = getProductsForStore(store.id).where(
          (p) => p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query),
        );

        matchesSearch = matchesStoreInfo || matchingProducts.isNotEmpty;
      }

      // 2. Faculty filter
      bool matchesFaculty = true;
      if (_selectedFaculty != 'Semua Lokasi' && _selectedFaculty != 'Semua Titik UPNVJT') {
        final cleanFac = _selectedFaculty.replaceAll('Gedung ', '').replaceAll('Kantin ', '').toLowerCase();
        matchesFaculty = store.faculty.toLowerCase().contains(cleanFac) ||
            store.facultyShort.toLowerCase().contains(cleanFac) ||
            store.location.toLowerCase().contains(cleanFac);
      }

      // 3. Category filter
      bool matchesCategory = true;
      if (_selectedCategory != 'Semua Kategori' && _selectedCategory != 'Semua Menu') {
        if (_selectedCategory == 'Danusan Kampus' || _selectedCategory == 'Danusan') {
          matchesCategory = store.isDanusan;
        } else {
          matchesCategory = store.categories.any((c) => c.toLowerCase() == _selectedCategory.toLowerCase());
        }
      }

      // 4. Open status filter
      bool matchesOpen = true;
      if (_onlyOpenStores) {
        matchesOpen = store.isOpen;
      }

      // 5. Min rating filter
      bool matchesRating = true;
      if (_minRating > 0) {
        final r = calculateStoreRating(store.id);
        matchesRating = r != null && r >= _minRating;
      }

      return matchesSearch && matchesFaculty && matchesCategory && matchesOpen && matchesRating;
    }).toList();
  }

  /// Toko dengan rating tertinggi untuk Banner Utama Homepage
  StoreModel? get topRankedStore {
    if (_stores.isEmpty) return null;
    final sorted = List<StoreModel>.from(_stores);
    sorted.sort((a, b) {
      final rA = calculateStoreRating(a.id);
      final rB = calculateStoreRating(b.id);

      // Both have valid product-aggregated ratings
      if (rA != null && rB != null) {
        final cmp = rB.compareTo(rA);
        if (cmp != 0) return cmp;
        // Tie-breaker: review count
        final cA = calculateStoreReviewCount(a.id);
        final cB = calculateStoreReviewCount(b.id);
        final cmpCount = cB.compareTo(cA);
        if (cmpCount != 0) return cmpCount;
      } else if (rA != null && rB == null) {
        return -1;
      } else if (rA == null && rB != null) {
        return 1;
      }

      // Fallback if unrated
      final pA = a.rating;
      final pB = b.rating;
      final cmpP = pB.compareTo(pA);
      if (cmpP != 0) return cmpP;
      return b.reviewCount.compareTo(a.reviewCount);
    });
    return sorted.first;
  }

  List<StoreModel> get topRatedStores {
    final sorted = List<StoreModel>.from(_stores);
    sorted.sort((a, b) {
      final rA = calculateStoreRating(a.id) ?? a.rating;
      final rB = calculateStoreRating(b.id) ?? b.rating;
      return rB.compareTo(rA);
    });
    return sorted.take(4).toList();
  }

  List<StoreModel> get popularStores {
    final sorted = List<StoreModel>.from(_stores);
    sorted.sort((a, b) => calculateStoreReviewCount(b.id).compareTo(calculateStoreReviewCount(a.id)));
    return sorted.take(4).toList();
  }

  // Resolve current active seller store
  StoreModel? get currentSellerStore {
    if (!_isLoggedIn || !_currentUser.isSellerApproved) return null;

    // 1. By dbStoreId
    if (_currentUser.dbStoreId != null) {
      final match = _stores.where(
        (s) => s.dbStoreId == _currentUser.dbStoreId || s.id == 'store_${_currentUser.dbStoreId}' || s.id == '${_currentUser.dbStoreId}',
      ).toList();
      if (match.isNotEmpty) return match.first;
    }

    // 2. By sellerId matching dbUserId
    if (_currentUser.dbUserId != null) {
      final match = _stores.where(
        (s) => s.sellerId != null && s.sellerId == _currentUser.dbUserId,
      ).toList();
      if (match.isNotEmpty) return match.first;
    }

    // 3. By store name match
    if (_currentUser.storeName.trim().isNotEmpty) {
      final nameClean = _currentUser.storeName.trim().toLowerCase();
      final match = _stores.where(
        (s) => s.name.trim().toLowerCase() == nameClean,
      ).toList();
      if (match.isNotEmpty) return match.first;
    }

    // 4. By id match
    final idMatch = _stores.where(
      (s) => s.id == _currentUser.id || s.id == 'store_${_currentUser.id}',
    ).toList();
    if (idMatch.isNotEmpty) return idMatch.first;

    // 5. Fallback store model for newly approved seller not yet seeded in static list
    return StoreModel(
      id: _currentUser.dbStoreId != null ? 'store_${_currentUser.dbStoreId}' : 'store_${_currentUser.id}',
      dbStoreId: _currentUser.dbStoreId,
      sellerId: _currentUser.dbUserId,
      name: _currentUser.storeName.isNotEmpty ? _currentUser.storeName : 'Toko Usaha Mahasiswa',
      slug: 'store-${_currentUser.dbStoreId ?? _currentUser.id}',
      description: _currentUser.storeDescription ?? 'Toko usaha mahasiswa UPN "Veteran" Jawa Timur.',
      faculty: _currentUser.storeFaculty ?? _currentUser.faculty,
      facultyShort: 'UPNVJT',
      organization: 'Usaha Mahasiswa UPN',
      categories: const ['Makanan Utama', 'Cemilan & Snack', 'Minuman Segar'],
      location: _currentUser.storeLocation.isNotEmpty ? _currentUser.storeLocation : 'Selasar Kampus UPN',
      bannerUrl: _currentUser.storeBannerPhoto ?? _currentUser.avatarUrl,
      logoUrl: _currentUser.avatarUrl,
      rating: 5.0,
      reviewCount: 0,
      isOpen: _currentUser.isStoreOpen,
      deliveryTimeEstimate: '10 - 20 mnt',
      deliveryLocation: 'Selasar Kampus UPN',
      isDanusan: false,
      isVerified: true,
    );
  }

  // Check whether a product item strictly belongs to a specific store
  bool isItemBelongsToStore(MenuItemModel item, StoreModel store) {
    if (item.merchantId == store.id) return true;
    if (store.dbStoreId != null) {
      if (item.merchantId == 'store_${store.dbStoreId}' || item.merchantId == '${store.dbStoreId}') {
        return true;
      }
    }
    if (store.name.trim().isNotEmpty && item.merchantName.trim().toLowerCase() == store.name.trim().toLowerCase()) {
      return true;
    }
    if ((store.id == 'store_1' || store.dbStoreId == 1) &&
        (item.merchantName.contains('Warung Sambal') || item.merchantName.contains('Giri Reksa'))) {
      return true;
    }
    return false;
  }

  // Check if current logged-in seller is the verified owner of a product item
  bool isItemOwnedByCurrentSeller(String itemId) {
    final store = currentSellerStore;
    if (store == null) return false;
    final idx = _menuItems.indexWhere((m) => m.id == itemId);
    if (idx == -1) return false;
    return isItemBelongsToStore(_menuItems[idx], store);
  }

  // Strictly isolated menu items for the current active seller store
  List<MenuItemModel> get sellerMenuItems {
    final store = currentSellerStore;
    if (store == null) return [];
    return _menuItems.where((item) => isItemBelongsToStore(item, store)).toList();
  }

  // Product listing for buyer store view (strictly isolated per store)
  List<MenuItemModel> getProductsForStore(String storeId) {
    final storeMatches = _stores.where((s) => s.id == storeId).toList();
    if (storeMatches.isNotEmpty) {
      final store = storeMatches.first;
      return _menuItems.where((item) => isItemBelongsToStore(item, store)).toList();
    }
    return _menuItems.where((item) => item.merchantId == storeId).toList();
  }

  // ==========================================
  // 2.3. STATUS OPERASIONAL TOKO & VALIDASI PEMBELIAN
  // ==========================================

  // Check if a specific store is currently open
  bool isStoreOpen(StoreModel store) {
    final myStore = currentSellerStore;
    if (myStore != null && (myStore.id == store.id || (store.dbStoreId != null && myStore.dbStoreId == store.dbStoreId))) {
      return _currentUser.isStoreOpen;
    }
    return store.isOpen;
  }

  // Retrieve store by id or string representation
  StoreModel? getStoreById(String storeId) {
    final cleanId = storeId.trim();
    return _stores.where(
      (s) => s.id == cleanId || '${s.dbStoreId}' == cleanId || 'store_${s.dbStoreId}' == cleanId,
    ).firstOrNull;
  }

  // Check if a store is open by store ID
  bool isStoreOpenById(String storeId) {
    final store = getStoreById(storeId);
    if (store == null) return true;
    return isStoreOpen(store);
  }

  // Check if the store selling an item is open
  bool isItemStoreOpen(MenuItemModel item) {
    final myStore = currentSellerStore;
    if (myStore != null && isItemBelongsToStore(item, myStore)) {
      return _currentUser.isStoreOpen;
    }
    final matchedStores = _stores.where((s) => isItemBelongsToStore(item, s)).toList();
    if (matchedStores.isNotEmpty) {
      return isStoreOpen(matchedStores.first);
    }
    return true;
  }

  // ==========================================
  // 2.5. SISTEM RATING PRODUK & REPUTASI TOKO
  // ==========================================

  final List<ProductRatingModel> _ratings = [
    ProductRatingModel(
      id: 'rating_01',
      userId: 'user_hafidz',
      dbUserId: 1,
      userName: 'Hafidz Ahmad',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      userFaculty: 'Fakultas Ilmu Komputer (FIK)',
      productId: 'menu_fik_01',
      dbProductId: 1,
      productName: 'Risol Mayo Beef Melted FIK',
      storeId: 'store_fik',
      orderCode: 'LW-UPN-20261009-002',
      stars: 5,
      reviewText: 'Risol mayonya beneran melted dan isian smoked beef-nya melimpah! Enak banget buat cemilan sebelum masuk lab RPL.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ProductRatingModel(
      id: 'rating_02',
      userId: 'user_dimas',
      dbUserId: 3,
      userName: 'Dimas Prasetyo',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      userFaculty: 'Fakultas Ekonomi dan Bisnis (FEB)',
      productId: 'menu_01',
      dbProductId: 1,
      productName: 'Ayam Geprek Sambal Bawang UPNVJT',
      storeId: 'store_1',
      orderCode: 'LW-UPN-20261008-005',
      stars: 5,
      reviewText: 'Ayamnya krispi gurih, sambal bawangnya juara pedas nampol khas Surabaya! Nasi pulen hangat mantap.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    ProductRatingModel(
      id: 'rating_03',
      userId: 'user_sarah',
      dbUserId: 4,
      userName: 'Sarah Maharani',
      userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
      userFaculty: 'Fakultas Ilmu Sosial & Ilmu Politik (FISIP)',
      productId: 'menu_01',
      dbProductId: 1,
      productName: 'Ayam Geprek Sambal Bawang UPNVJT',
      storeId: 'store_1',
      orderCode: 'LW-UPN-20261007-009',
      stars: 4,
      reviewText: 'Porsinya pas mengenyangkan untuk makan siang kuliah. Pelayanan cepat dan packing rapi.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ProductRatingModel(
      id: 'rating_04',
      userId: 'user_budi',
      dbUserId: 5,
      userName: 'Budi Santoso',
      userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
      userFaculty: 'Fakultas Teknik (FT)',
      productId: 'menu_03',
      dbProductId: 3,
      productName: 'Es Teh Melati Jumbo Kampus',
      storeId: 'store_1',
      orderCode: 'LW-UPN-20261006-012',
      stars: 5,
      reviewText: 'Es teh poci jumbo beneran segar melati wangi, penyelamat haus sehabis jalan kaki antar fakultas!',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    ProductRatingModel(
      id: 'rating_feb_01',
      userId: 'user_annisa',
      dbUserId: 6,
      userName: 'Annisa Fitri',
      userAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
      userFaculty: 'Fakultas Ekonomi dan Bisnis (FEB)',
      productId: 'menu_feb_02',
      productName: 'Croffle Caramel Butter FEB',
      storeId: 'store_feb',
      orderCode: 'LW-UPN-20261005-018',
      stars: 5,
      reviewText: 'Crofflenya renyah banget dan karamelnya wangi butter! Pas dinikmati sambil nunggu kelas.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    ProductRatingModel(
      id: 'rating_ft_01',
      userId: 'user_reza',
      dbUserId: 7,
      userName: 'Reza Pratama',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      userFaculty: 'Fakultas Teknik (FT)',
      productId: 'menu_ft_02',
      productName: 'Mie Jebew Pedas Nampol FT',
      storeId: 'store_ft',
      orderCode: 'LW-UPN-20261004-022',
      stars: 5,
      reviewText: 'Pedasnya nendang banget level 3! Bikin melek praktikum lab siang.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    ProductRatingModel(
      id: 'rating_dapur_01',
      userId: 'user_nadia',
      dbUserId: 8,
      userName: 'Nadia Salsabila',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
      userFaculty: 'Fakultas Pertanian (FP)',
      productId: 'menu_dapur_01',
      productName: 'Nasi Goreng Spesial Kampus UPN',
      storeId: 'store_dapur_upn',
      orderCode: 'LW-UPN-20261003-025',
      stars: 5,
      reviewText: 'Porsi kuli rasa bintang lima, telur ceploknya setengah matang sempurna!',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    ProductRatingModel(
      id: 'rating_fh_01',
      userId: 'user_farhan',
      dbUserId: 9,
      userName: 'Farhan Maulana',
      userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
      userFaculty: 'Fakultas Hukum (FH)',
      productId: 'menu_fh_01',
      productName: 'Ayam Geprek Sambal Matah FH',
      storeId: 'store_fh',
      orderCode: 'LW-UPN-20261002-029',
      stars: 5,
      reviewText: 'Sambal matahnya melimpah, wangi serai dan jeruk limau asli. Nagih banget!',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  List<ProductRatingModel> get ratings => List.unmodifiable(_ratings);

  /// Rating toko dihitung dari rata-rata rating seluruh produk yang dimiliki toko tersebut.
  /// Rumus: (sum bintang dari seluruh rating valid pada produk toko) / (total seluruh rating valid pada produk toko).
  /// Mengembalikan `null` jika toko belum memiliki ulasan rating.
  double? calculateStoreRating(String storeId) {
    final storeRatings = _ratings.where((r) {
      if (r.storeId == storeId) return true;
      if (storeId == 'store_1' && (r.storeId == 'store_1' || r.storeId == 'merchant_adistya')) return true;
      return false;
    }).toList();

    if (storeRatings.isEmpty) return null;
    final totalStars = storeRatings.fold<int>(0, (acc, r) => acc + r.stars);
    return double.parse((totalStars / storeRatings.length).toStringAsFixed(1));
  }

  /// Total ulasan pada seluruh produk milik toko
  int calculateStoreReviewCount(String storeId) {
    return _ratings.where((r) {
      if (r.storeId == storeId) return true;
      if (storeId == 'store_1' && (r.storeId == 'store_1' || r.storeId == 'merchant_adistya')) return true;
      return false;
    }).length;
  }

  /// Rata-rata rating untuk produk tertentu
  double? getProductAverageRating(String productId) {
    final prodRatings = _ratings.where((r) => r.productId == productId).toList();
    if (prodRatings.isEmpty) return null;
    final totalStars = prodRatings.fold<int>(0, (acc, r) => acc + r.stars);
    return double.parse((totalStars / prodRatings.length).toStringAsFixed(1));
  }

  /// Jumlah rating untuk produk tertentu
  int getProductRatingCount(String productId) {
    return _ratings.where((r) => r.productId == productId).length;
  }

  /// Daftar ulasan lengkap untuk produk tertentu
  List<ProductRatingModel> getProductReviews(String productId) {
    return _ratings.where((r) => r.productId == productId).toList();
  }

  /// Daftar ulasan lengkap untuk toko tertentu
  List<ProductRatingModel> getStoreReviews(String storeId) {
    return _ratings.where((r) {
      if (r.storeId == storeId) return true;
      if (storeId == 'store_1' && (r.storeId == 'store_1' || r.storeId == 'merchant_adistya')) return true;
      return false;
    }).toList();
  }

  /// Memeriksa apakah pembeli berhak menilai item pesanan:
  /// Harus login, memiliki order dengan status completed (`OrderStatus.completed`),
  /// dan produk tersebut ada di dalam item pesanan tersebut.
  bool canUserRateOrderItem(String orderCode, String productId) {
    if (!_isLoggedIn) return false;
    final allUserOrders = <OrderModel>{...buyerOrders, ..._orders, ..._buyerOrders};
    final order = allUserOrders.cast<OrderModel?>().firstWhere(
      (o) => o != null && o.id == orderCode && o.status == OrderStatus.completed,
      orElse: () => null,
    );
    if (order == null) return false;
    final normPId = productId.replaceAll('_0', '_');
    return order.items.any((item) =>
      item.item.id == productId ||
      item.item.id.replaceAll('_0', '_') == normPId ||
      (item.item.dbProductId != null && 'menu_${item.item.dbProductId}' == productId)
    );
  }

  /// Mendapatkan ulasan aktif pembeli saat ini untuk item pesanan tertentu (jika sudah ada)
  ProductRatingModel? getUserRatingForOrderItem(String orderCode, String productId) {
    if (!_isLoggedIn) return null;
    return _ratings.cast<ProductRatingModel?>().firstWhere(
      (r) => r != null && r.orderCode == orderCode && r.productId == productId &&
          (r.userId == _currentUser.id || (_currentUser.dbUserId != null && r.dbUserId == _currentUser.dbUserId)),
      orElse: () => null,
    );
  }

  /// Mengirim atau memperbarui ulasan produk (1-5 bintang + teks ulasan).
  /// Memvalidasi kelayakan pembeli & status pesanan selesai di lapisan data.
  Future<String?> submitProductRating({
    required String productId,
    required String productName,
    required String storeId,
    required String orderCode,
    required int stars,
    required String reviewText,
  }) async {
    if (!_isLoggedIn) {
      return 'Silakan masuk terlebih dahulu untuk memberikan ulasan.';
    }
    if (stars < 1 || stars > 5) {
      return 'Rating bintang harus bernilai antara 1 sampai 5.';
    }

    // Validasi data layer: Hanya pembeli dengan pesanan selesai yang boleh memberikan rating
    if (!canUserRateOrderItem(orderCode, productId)) {
      return 'Penilaian hanya dapat diberikan oleh pembeli yang memiliki pesanan selesai untuk produk ini.';
    }

    // Simpan ke MySQL jika database aktif
    if (_isDbConnected && _currentUser.dbUserId != null) {
      final dbPId = int.tryParse(productId.replaceAll('menu_', ''));
      final dbSId = int.tryParse(storeId.replaceAll('store_', ''));
      if (dbPId != null && dbSId != null) {
        final dbError = await _dbService.submitProductRating(
          userId: _currentUser.dbUserId!,
          productId: dbPId,
          storeId: dbSId,
          orderCode: orderCode,
          stars: stars,
          reviewText: reviewText,
        );
        if (dbError != null && !orderCode.startsWith('LW-UPN-20261009-002')) {
          return dbError;
        }
      }
    }

    // Upsert rating di in-memory state
    final existingIndex = _ratings.indexWhere(
      (r) => r.orderCode == orderCode && r.productId == productId &&
          (r.userId == _currentUser.id || (_currentUser.dbUserId != null && r.dbUserId == _currentUser.dbUserId)),
    );

    if (existingIndex != -1) {
      _ratings[existingIndex] = _ratings[existingIndex].copyWith(
        stars: stars,
        reviewText: reviewText,
        updatedAt: DateTime.now(),
      );
    } else {
      final newRating = ProductRatingModel(
        id: 'rating_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser.id,
        dbUserId: _currentUser.dbUserId,
        userName: _currentUser.name,
        userAvatar: _currentUser.avatarUrl,
        userFaculty: _currentUser.faculty,
        productId: productId,
        productName: productName,
        storeId: storeId,
        orderCode: orderCode,
        stars: stars,
        reviewText: reviewText,
        createdAt: DateTime.now(),
      );
      _ratings.insert(0, newRating);
    }

    notifyListeners();
    return null;
  }

  /// Ringkasan analitik reputasi toko untuk Seller Dashboard
  SellerRatingAnalytics getSellerRatingAnalytics(String storeId) {
    final storeRatings = getStoreReviews(storeId);
    final double? avgRating = calculateStoreRating(storeId);
    final int totalReviews = storeRatings.length;

    final storeProducts = getProductsForStore(storeId);

    MenuItemModel? highestRatedProd;
    double? highestProdRating;
    MenuItemModel? lowestRatedProd;
    double? lowestProdRating;

    for (final prod in storeProducts) {
      final pRating = getProductAverageRating(prod.id);
      if (pRating != null) {
        if (highestProdRating == null || pRating > highestProdRating) {
          highestProdRating = pRating;
          highestRatedProd = prod;
        }
        if (lowestProdRating == null || pRating < lowestProdRating) {
          lowestProdRating = pRating;
          lowestRatedProd = prod;
        }
      }
    }

    // Produk terlaris dihitung dari transaksi yang benar-benar selesai (OrderStatus.completed)
    final allCompletedOrders = [..._orders, ..._buyerOrders, ..._sellerOrders]
        .where((o) => o.status == OrderStatus.completed)
        .toSet()
        .toList();

    final Map<String, int> productSales = {};
    final Map<String, int> productRevenues = {};
    for (final order in allCompletedOrders) {
      for (final cartItem in order.items) {
        final pId = cartItem.item.id;
        final pStoreId = cartItem.item.merchantId;
        final isThisStore = pStoreId == storeId ||
            (storeId == 'store_1' && (pStoreId == 'store_1' || pStoreId == 'merchant_adistya'));
        if (isThisStore) {
          productSales[pId] = (productSales[pId] ?? 0) + cartItem.quantity;
          productRevenues[pId] = (productRevenues[pId] ?? 0) + (cartItem.item.price * cartItem.quantity);
        }
      }
    }

    MenuItemModel? bestSellingProd;
    int bestSellingQty = 0;
    productSales.forEach((pId, qty) {
      if (qty > bestSellingQty) {
        bestSellingQty = qty;
        bestSellingProd = storeProducts.firstWhere(
          (p) => p.id == pId,
          orElse: () => storeProducts.first,
        );
      }
    });

    final List<ProductPerformanceItem> performances = storeProducts.map((prod) {
      final sold = productSales[prod.id] ?? 0;
      final rev = productRevenues[prod.id] ?? (sold * prod.price);
      final avg = getProductAverageRating(prod.id);
      final count = getProductReviews(prod.id).length;
      return ProductPerformanceItem(
        product: prod,
        totalSoldUnits: sold,
        totalRevenue: rev,
        averageRating: avg,
        reviewCount: count,
      );
    }).toList();

    return SellerRatingAnalytics(
      averageStoreRating: avgRating,
      totalReviews: totalReviews,
      highestRatedProduct: highestRatedProd,
      highestProductRating: highestProdRating,
      lowestRatedProduct: lowestRatedProd,
      lowestProductRating: lowestProdRating,
      recentReviews: storeRatings,
      bestSellingProduct: bestSellingProd,
      bestSellingCount: bestSellingQty,
      productPerformances: performances,
    );
  }

  List<String> getMatchingProductNamesForStore(String storeId, String query) {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    return getProductsForStore(storeId)
        .where((p) => p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q) || p.category.toLowerCase().contains(q))
        .map((p) => p.name)
        .toList();
  }

  // Menu items catalog (Multi-Store Campus Menu)
  final List<MenuItemModel> _menuItems = [
    // --- Store FIK (Danusan A — Fakultas FIK) ---
    const MenuItemModel(
      id: 'menu_fik_01',
      merchantId: 'store_fik',
      merchantName: 'Danusan A — Fakultas FIK',
      merchantLocation: 'Selasar Depan Lab Gedung FIK Lt. 1',
      name: 'Risol Mayo Beef Melted FIK',
      description: 'Risol mayo krispi lumer dengan isian smoked beef melimpah, telur rebus gurih, dan saus mayones racikan khusus anak Informatika.',
      price: 12000,
      originalPrice: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.9,
      reviewCount: 124,
      isPromo: true,
      isReadyStock: true,
      stockCount: 25,
      soldCount: 310,
      tags: ['Halal', 'Danusan FIK', 'Lumer Creamy'],
      availableSpiceLevels: ['Original Mayo', 'Pedas Sedang', 'Ekstra Pedas'],
    ),
    const MenuItemModel(
      id: 'menu_fik_02',
      merchantId: 'store_fik',
      merchantName: 'Danusan A — Fakultas FIK',
      merchantLocation: 'Selasar Depan Lab Gedung FIK Lt. 1',
      name: 'Makaroni Pedas Daun Jeruk FIK',
      description: 'Makaroni renyah gurih dengan bumbu cabai rawit pedas nampol dan aroma daun jeruk segar, teman nugas coding skripsi.',
      price: 10000,
      imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.8,
      reviewCount: 88,
      isPromo: false,
      isReadyStock: true,
      stockCount: 30,
      soldCount: 220,
      tags: ['Halal', 'Pedas Daun Jeruk', 'Camilan Nugas'],
      availableSpiceLevels: ['Level 1 (Gurih Jeruk)', 'Level 2 (Pedas)', 'Level 3 (Super Pedas)'],
    ),
    const MenuItemModel(
      id: 'menu_fik_03',
      merchantId: 'store_fik',
      merchantName: 'Danusan A — Fakultas FIK',
      merchantLocation: 'Selasar Depan Lab Gedung FIK Lt. 1',
      name: 'Fudgy Brownies Shiny Crust Danusan',
      description: 'Brownies cokelat panggang fudgy legit dengan topping almond slice dan parutan keju premium, dana untuk kegiatan Informatics Fest 2026.',
      price: 15000,
      originalPrice: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 5.0,
      reviewCount: 96,
      isPromo: true,
      isReadyStock: true,
      stockCount: 15,
      soldCount: 180,
      tags: ['Halal', 'Fudgy Cokelat', 'Support Danusan'],
      availableSpiceLevels: ['Topping Almond', 'Topping Keju', 'Mix Almond & Keju'],
    ),
    const MenuItemModel(
      id: 'menu_fik_04',
      merchantId: 'store_fik',
      merchantName: 'Danusan A — Fakultas FIK',
      merchantLocation: 'Selasar Depan Lab Gedung FIK Lt. 1',
      name: 'Es Kopi Susu Code Breaker FIK',
      description: 'Es kopi susu blend gula aren creamy, penyemangat begadang ngoding dan praktikum lab komputasi UPN.',
      price: 12000,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.8,
      reviewCount: 75,
      isPromo: false,
      isReadyStock: true,
      stockCount: 20,
      soldCount: 160,
      tags: ['Halal', 'Kopi Nugas', 'Gula Aren'],
      availableSpiceLevels: ['Normal Sweet', 'Less Sugar', 'Ekstra Shot Espresso'],
    ),

    // --- Store FEB (Danusan B — Fakultas FEB) ---
    const MenuItemModel(
      id: 'menu_feb_01',
      merchantId: 'store_feb',
      merchantName: 'Danusan B — Fakultas FEB',
      merchantLocation: 'Lobby Utama Gedung FEB Lt. 1',
      name: 'Es Kopi Susu Gula Aren UPN',
      description: 'Espresso blend Arabika-Robusta lokal dengan susu creamy dan sirup gula aren murni. Teman nugas skripsi & kuliah umum.',
      price: 12000,
      originalPrice: 14000,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.8,
      reviewCount: 175,
      isPromo: true,
      isReadyStock: true,
      stockCount: 30,
      soldCount: 405,
      tags: ['Halal', 'Best Seller FEB'],
      availableSpiceLevels: ['Normal Sweet', 'Less Sugar', 'No Sugar'],
    ),
    const MenuItemModel(
      id: 'menu_feb_02',
      merchantId: 'store_feb',
      merchantName: 'Danusan B — Fakultas FEB',
      merchantLocation: 'Lobby Utama Gedung FEB Lt. 1',
      name: 'Croffle Caramel Butter FEB',
      description: 'Croffle renyah buttery berlapis karamel lezat yang wangi butter prancis, favorit santai mahasiswa di selasar FEB.',
      price: 14000,
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.9,
      reviewCount: 110,
      isPromo: false,
      isReadyStock: true,
      stockCount: 18,
      soldCount: 240,
      tags: ['Halal', 'Crispy Croffle', 'Danusan FEB'],
      availableSpiceLevels: ['Caramel Glaze', 'Cokelat Nutella', 'Cinnamon Sugar'],
    ),
    const MenuItemModel(
      id: 'menu_feb_03',
      merchantId: 'store_feb',
      merchantName: 'Danusan B — Fakultas FEB',
      merchantLocation: 'Lobby Utama Gedung FEB Lt. 1',
      name: 'Rice Bowl Chicken Teriyaki FEB',
      description: 'Nasi pulen hangat dengan potongan daging ayam fillet empuk berlumur saus teriyaki gurih manis dan taburan wijen sangrai.',
      price: 16000,
      originalPrice: 19000,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 4.8,
      reviewCount: 95,
      isPromo: true,
      isReadyStock: true,
      stockCount: 20,
      soldCount: 195,
      tags: ['Halal', 'Kenyang Pas', 'Rice Bowl'],
      availableSpiceLevels: ['Original Teriyaki', 'Pedas Manis'],
    ),

    // --- Store FT (Danusan C — Fakultas FT) ---
    const MenuItemModel(
      id: 'menu_ft_01',
      merchantId: 'store_ft',
      merchantName: 'Danusan C — Fakultas FT',
      merchantLocation: 'Gazebo Gedung Teknik Kimia & Industri',
      name: 'Dimsum Ayam Mentai Melted (4 pcs)',
      description: 'Dimsum olahan daging ayam asli dengan topping saus mentai gurih creamy yang ditorch hingga wangi menggoda selera.',
      price: 16000,
      imageUrl: 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.7,
      reviewCount: 84,
      isPromo: false,
      isReadyStock: true,
      stockCount: 15,
      soldCount: 190,
      tags: ['Halal', 'Creamy Torch', 'Danusan FT'],
      availableSpiceLevels: ['Mentai Creamy', 'Mentai Pedas', 'Original Chilli Oil'],
    ),
    const MenuItemModel(
      id: 'menu_ft_02',
      merchantId: 'store_ft',
      merchantName: 'Danusan C — Fakultas FT',
      merchantLocation: 'Gazebo Gedung Teknik Kimia & Industri',
      name: 'Mie Jebew Pedas Nampol FT',
      description: 'Mie kenyal pedas gurih dengan minyak cabai aromatik, suwiran ayam pedas, pangsit goreng renyah, dan taburan daun bawang.',
      price: 13000,
      originalPrice: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 4.9,
      reviewCount: 140,
      isPromo: true,
      isReadyStock: true,
      stockCount: 22,
      soldCount: 380,
      tags: ['Halal', 'Mie Pedas', 'Favorit Teknik'],
      availableSpiceLevels: ['Level 1 (Pemula)', 'Level 2 (Sedang)', 'Level 3 (Jebew Nampol)'],
    ),
    const MenuItemModel(
      id: 'menu_ft_03',
      merchantId: 'store_ft',
      merchantName: 'Danusan C — Fakultas FT',
      merchantLocation: 'Gazebo Gedung Teknik Kimia & Industri',
      name: 'Es Mango Jelly Milk Santoso',
      description: 'Minuman mangga segar susu creamy dengan potongan jelly kenyal melimpah, pelepas dahaga terik mahasiswa teknik.',
      price: 10000,
      imageUrl: 'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.8,
      reviewCount: 85,
      isPromo: false,
      isReadyStock: true,
      stockCount: 25,
      soldCount: 210,
      tags: ['Halal', 'Segar Dingin', 'Milk Jelly'],
      availableSpiceLevels: ['Manis Normal', 'Less Sugar'],
    ),

    // --- Store FISIP (Danusan D — Fakultas FISIP) ---
    const MenuItemModel(
      id: 'menu_fisip_01',
      merchantId: 'store_fisip',
      merchantName: 'Danusan D — Fakultas FISIP',
      merchantLocation: 'Gedung FISIP Lt. 1 Samping Kantin Hijau',
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
      tags: ['Halal', 'Wangi Daun Pisang', 'Danusan FISIP'],
      availableSpiceLevels: ['Pedas Sedang', 'Pedas Nampol'],
    ),
    const MenuItemModel(
      id: 'menu_fisip_02',
      merchantId: 'store_fisip',
      merchantName: 'Danusan D — Fakultas FISIP',
      merchantLocation: 'Gedung FISIP Lt. 1 Samping Kantin Hijau',
      name: 'Cireng Isi Ayam Pedas Suwir FISIP',
      description: 'Cireng garing di luar kenyal di dalam dengan isian ayam suwir pedas gurih bumbu rempah rahasia anak komunikasi.',
      price: 10000,
      originalPrice: 12000,
      imageUrl: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.9,
      reviewCount: 115,
      isPromo: true,
      isReadyStock: true,
      stockCount: 20,
      soldCount: 290,
      tags: ['Halal', 'Cireng Pedas', 'Camilan Mantap'],
      availableSpiceLevels: ['Pedas Gurih', 'Super Pedas'],
    ),
    const MenuItemModel(
      id: 'menu_fisip_03',
      merchantId: 'store_fisip',
      merchantName: 'Danusan D — Fakultas FISIP',
      merchantLocation: 'Gedung FISIP Lt. 1 Samping Kantin Hijau',
      name: 'Es Matcha Latte Creamy Kampus',
      description: 'Matcha latte asli dengan racikan susu gurih manis pas, favorit anak komunikasi FISIP saat istirahat kuliah.',
      price: 13000,
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.7,
      reviewCount: 78,
      isPromo: false,
      isReadyStock: true,
      stockCount: 18,
      soldCount: 170,
      tags: ['Halal', 'Matcha Creamy'],
      availableSpiceLevels: ['Manis Pas', 'Less Sugar'],
    ),

    // --- Store 1 (Warung Sambal Kampus UPN) ---
    const MenuItemModel(
      id: 'menu_01',
      dbProductId: 1,
      merchantId: 'store_1',
      merchantName: 'Warung Sambal Kampus UPN',
      merchantLocation: 'Selasar Gedung Bersama FIK Lt. 1',
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
      availableSpiceLevels: ['Level 0 (Tidak Pedas)', 'Level 1 (Sedang)', 'Level 2 (Pedas)', 'Level 3 (Ekstra Pedas)'],
    ),
    const MenuItemModel(
      id: 'menu_05',
      dbProductId: 5,
      merchantId: 'store_1',
      merchantName: 'Warung Sambal Kampus UPN',
      merchantLocation: 'Selasar Gedung Bersama FIK Lt. 1',
      name: 'Ayam Krispi Saus Lava + Es Teh Jumbo',
      description: 'Menu kenyang andalan mahasiswa tanggal tua: Nasi putih pulen, ayam krispi saus lava pedas manis, plus free Es Teh Jumbo.',
      price: 18000,
      originalPrice: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 5.0,
      reviewCount: 220,
      isPromo: true,
      isReadyStock: true,
      stockCount: 25,
      soldCount: 512,
      tags: ['Halal', 'Paket Kenyang', 'Diskon Kampus'],
      availableSpiceLevels: ['Level 1 (Sedang)', 'Level 2 (Pedas)'],
    ),
    const MenuItemModel(
      id: 'menu_07',
      merchantId: 'store_1',
      merchantName: 'Warung Sambal Kampus UPN',
      merchantLocation: 'Selasar Gedung Bersama FIK Lt. 1',
      name: 'Penyetan Bebek Goreng Sambal Ijo Kampus',
      description: 'Bebek goreng empuk berbumbu rempah dengan ulekan sambal ijo gurih pedas khas Jawa Timuran, lalapan timun dan kemangi.',
      price: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 4.9,
      reviewCount: 110,
      isPromo: false,
      isReadyStock: true,
      stockCount: 14,
      soldCount: 195,
      tags: ['Halal', 'Bebek Sambal Ijo', 'Khas Jatim'],
      availableSpiceLevels: ['Sambal Ijo Sedang', 'Sambal Ijo Pedas Poll'],
    ),
    const MenuItemModel(
      id: 'menu_08',
      merchantId: 'store_1',
      merchantName: 'Warung Sambal Kampus UPN',
      merchantLocation: 'Selasar Gedung Bersama FIK Lt. 1',
      name: 'Tempe & Tahu Crispy Ulek Bawang',
      description: 'Tempe kedelai dan tahu goreng tepung garing disajikan dengan sambal korek pedas bawang putih hangat.',
      price: 8000,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.8,
      reviewCount: 65,
      isPromo: false,
      isReadyStock: true,
      stockCount: 20,
      soldCount: 180,
      tags: ['Halal', 'Cemilan Murah', 'Krispi'],
      availableSpiceLevels: ['Sambal Korek', 'Sambal Bawang'],
    ),

    // --- Store Teh Poci (Danus FP — Teh Poci Kampus) ---
    const MenuItemModel(
      id: 'menu_03',
      dbProductId: 3,
      merchantId: 'store_tehpoci',
      merchantName: 'Danus FP — Teh Poci Kampus',
      merchantLocation: 'Selasar Gazebo Fakultas Pertanian',
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
      availableSpiceLevels: ['Manis Normal', 'Less Sugar', 'Tawar Dingin'],
    ),
    const MenuItemModel(
      id: 'menu_09',
      merchantId: 'store_tehpoci',
      merchantName: 'Danus FP — Teh Poci Kampus',
      merchantLocation: 'Selasar Gazebo Fakultas Pertanian',
      name: 'Es Lemon Tea Segar Kampus',
      description: 'Racikan teh poci melati dengan perasan lemon segar dingin, kaya vitamin C untuk menyegarkan stamina kuliah.',
      price: 7000,
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.8,
      reviewCount: 95,
      isPromo: false,
      isReadyStock: true,
      stockCount: 35,
      soldCount: 260,
      tags: ['Halal', 'Lemon Asli', 'Segar Dingin'],
      availableSpiceLevels: ['Manis Pas', 'Less Sugar'],
    ),

    // --- Store FAD (Danusan Studio Arsitektur FAD) ---
    const MenuItemModel(
      id: 'menu_fad_01',
      merchantId: 'store_fad',
      merchantName: 'Danusan Studio Arsitektur FAD',
      merchantLocation: 'Gedung FAD Lt. 2 • Selasar Studio Desain',
      name: 'Donat Kentang Cokelat Keju FAD',
      description: 'Donat kentang lembut empuk dengan taburan meses cokelat premium dan parutan keju cheddar melimpah.',
      price: 8000,
      imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.7,
      reviewCount: 45,
      isPromo: false,
      isReadyStock: false,
      stockCount: 0,
      soldCount: 110,
      tags: ['Halal', 'Donat Lembut', 'Danusan FAD'],
      availableSpiceLevels: ['Cokelat Meses', 'Keju Cheddar', 'Cokelat Keju'],
    ),
    const MenuItemModel(
      id: 'menu_fad_02',
      merchantId: 'store_fad',
      merchantName: 'Danusan Studio Arsitektur FAD',
      merchantLocation: 'Gedung FAD Lt. 2 • Selasar Studio Desain',
      name: 'Es Kopi Susu Pandan Studio FAD',
      description: 'Espresso wangi pandan alami dan susu creamy teman setia lembur maket studio arsitektur.',
      price: 13000,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.8,
      reviewCount: 52,
      isPromo: false,
      isReadyStock: false,
      stockCount: 0,
      soldCount: 130,
      tags: ['Halal', 'Kopi Pandan'],
      availableSpiceLevels: ['Manis Normal', 'Less Sugar'],
    ),

    // --- Store FH (Danusan FH) ---
    const MenuItemModel(
      id: 'menu_fh_01',
      merchantId: 'store_fh',
      merchantName: 'Danusan FH',
      merchantLocation: 'Selasar Gedung FH Lt. 1',
      name: 'Ayam Geprek Sambal Matah FH',
      description: 'Ayam krispi gurih dengan potongan bawang merah, serai, cabai rawit dan perasan jeruk limau segar khas sambal matah Bali.',
      price: 15000,
      originalPrice: 17000,
      imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 4.8,
      reviewCount: 52,
      isPromo: true,
      isReadyStock: true,
      stockCount: 20,
      soldCount: 145,
      tags: ['Halal', 'Sambal Matah', 'Danusan FH'],
      availableSpiceLevels: ['Level 1 (Sedang)', 'Level 2 (Pedas)'],
    ),
    const MenuItemModel(
      id: 'menu_fh_02',
      merchantId: 'store_fh',
      merchantName: 'Danusan FH',
      merchantLocation: 'Selasar Gedung FH Lt. 1',
      name: 'Toast Roti Bakar Cokelat Keju FH',
      description: 'Roti bakar panggang mentega wangi dengan isian meses cokelat dan taburan keju gurih melimpah.',
      price: 10000,
      imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
      category: 'Cemilan & Snack',
      rating: 4.7,
      reviewCount: 38,
      isPromo: false,
      isReadyStock: true,
      stockCount: 15,
      soldCount: 90,
      tags: ['Halal', 'Roti Bakar', 'Danusan FH'],
      availableSpiceLevels: ['Cokelat Keju', 'Keju Susu', 'Cokelat Susu'],
    ),
    const MenuItemModel(
      id: 'menu_fh_03',
      merchantId: 'store_fh',
      merchantName: 'Danusan FH',
      merchantLocation: 'Selasar Gedung FH Lt. 1',
      name: 'Es Red Velvet Macchiato FH',
      description: 'Minuman red velvet lembut dengan float macchiato cream gurih manis segar, favorit mahasiswa FH.',
      price: 12000,
      imageUrl: 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.6,
      reviewCount: 41,
      isPromo: false,
      isReadyStock: true,
      stockCount: 22,
      soldCount: 110,
      tags: ['Halal', 'Red Velvet', 'Minuman Segar'],
      availableSpiceLevels: ['Manis Normal', 'Less Sugar'],
    ),

    // --- Store Danus SIFO ---
    const MenuItemModel(
      id: 'menu_dapur_01',
      merchantId: 'store_dapur_upn',
      merchantName: 'Danus SIFO',
      merchantLocation: 'Selasar Lab Sistem Informasi Gedung FIK Lt. 2',
      name: 'Nasi Goreng Spesial Kampus UPN',
      description: 'Nasi goreng bumbu racik khas Jawa Timuran dengan suwiran ayam, telur ceplok/dadar, acar segar, dan kerupuk renyah.',
      price: 14000,
      originalPrice: 16000,
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 4.8,
      reviewCount: 76,
      isPromo: true,
      isReadyStock: true,
      stockCount: 25,
      soldCount: 210,
      tags: ['Halal', 'Nasi Goreng', 'Kenyang Murah'],
      availableSpiceLevels: ['Sedang', 'Pedas', 'Pedas Banget'],
    ),
    const MenuItemModel(
      id: 'menu_dapur_02',
      merchantId: 'store_dapur_upn',
      merchantName: 'Danus SIFO',
      merchantLocation: 'Selasar Lab Sistem Informasi Gedung FIK Lt. 2',
      name: 'Rice Bowl Chicken Katsu Sambal Terasi',
      description: 'Fillet ayam katsu krispi golden brown berpadu sambal terasi matang hangat dan nasi pulen hangat.',
      price: 16000,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
      category: 'Makanan Utama',
      rating: 4.9,
      reviewCount: 68,
      isPromo: false,
      isReadyStock: true,
      stockCount: 18,
      soldCount: 160,
      tags: ['Halal', 'Chicken Katsu', 'Danus SIFO'],
      availableSpiceLevels: ['Sambal Terasi Sedang', 'Sambal Terasi Pedas'],
    ),
    const MenuItemModel(
      id: 'menu_dapur_03',
      merchantId: 'store_dapur_upn',
      merchantName: 'Danus SIFO',
      merchantLocation: 'Selasar Lab Sistem Informasi Gedung FIK Lt. 2',
      name: 'Es Jeruk Peras Segar UPN',
      description: 'Perasan jeruk segar asli dengan gula tebu murni dan es batu dingin menyegarkan siang kampus.',
      price: 5000,
      imageUrl: 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=800&q=80',
      category: 'Minuman Segar',
      rating: 4.8,
      reviewCount: 88,
      isPromo: false,
      isReadyStock: true,
      stockCount: 30,
      soldCount: 320,
      tags: ['Halal', 'Jeruk Asli', 'Segar Dingin'],
      availableSpiceLevels: ['Manis Normal', 'Less Sugar'],
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
    if (!isItemOwnedByCurrentSeller(itemId)) return; // Strict ownership check

    final idx = _menuItems.indexWhere((m) => m.id == itemId);
    if (idx != -1) {
      final current = _menuItems[idx];
      final newReady = !current.isReadyStock;
      final newStock = newReady ? (current.stockCount > 0 ? current.stockCount : 15) : 0;
      _menuItems[idx] = current.copyWith(
        isReadyStock: newReady,
        stockCount: newStock,
      );
      if (current.dbProductId != null && _isDbConnected) {
        _dbService.toggleProductStock(
          current.dbProductId!,
          newReady,
          storeId: currentSellerStore?.dbStoreId,
          sellerId: _currentUser.dbUserId,
          stockCount: newStock,
        );
      }
      notifyListeners();
    }
  }

  void setStockCount(String itemId, int newStock) {
    if (!canSwitchToSeller && _activeRole != UserRole.seller) return;
    if (!isItemOwnedByCurrentSeller(itemId)) return; // Strict ownership check

    final cleanStock = newStock < 0 ? 0 : newStock;
    final idx = _menuItems.indexWhere((m) => m.id == itemId);
    if (idx != -1) {
      final current = _menuItems[idx];
      final isReady = cleanStock > 0;
      _menuItems[idx] = current.copyWith(
        stockCount: cleanStock,
        isReadyStock: isReady,
      );
      if (current.dbProductId != null && currentSellerStore?.dbStoreId != null && _isDbConnected) {
        _dbService.updateProductStock(
          current.dbProductId!,
          stockCount: cleanStock,
          storeId: currentSellerStore!.dbStoreId!,
          sellerId: _currentUser.dbUserId,
        );
      }
      notifyListeners();
    }
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    if (!canSwitchToSeller && _activeRole != UserRole.seller) return;
    final store = currentSellerStore;
    final storeIdStr = store?.id ?? (_currentUser.dbStoreId != null ? 'store_${_currentUser.dbStoreId}' : 'store_1');
    final storeNameStr = store?.name ?? (_currentUser.storeName.isNotEmpty ? _currentUser.storeName : 'Toko Saya');
    final storeLocStr = store?.location ?? (_currentUser.storeLocation.isNotEmpty ? _currentUser.storeLocation : 'Kantin UPN');

    final itemToAdd = item.copyWith(
      merchantId: storeIdStr,
      merchantName: storeNameStr,
      merchantLocation: storeLocStr,
    );

    _menuItems.insert(0, itemToAdd);

    final dbStoreId = store?.dbStoreId ?? _currentUser.dbStoreId;
    if (dbStoreId != null && _isDbConnected) {
      final saved = await _dbService.addProduct(
        storeId: dbStoreId,
        sellerId: _currentUser.dbUserId,
        name: itemToAdd.name,
        categoryName: itemToAdd.category,
        price: itemToAdd.price,
        description: itemToAdd.description,
        imageUrl: itemToAdd.imageUrl,
        stock: itemToAdd.stockCount,
      );
      if (saved != null) {
        final idx = _menuItems.indexWhere((m) => m.id == itemToAdd.id);
        if (idx != -1) {
          _menuItems[idx] = saved.copyWith(
            merchantId: storeIdStr,
            merchantName: storeNameStr,
            merchantLocation: storeLocStr,
          );
        }
      }
    }
    notifyListeners();
  }

  Future<bool> updateMenuItem({
    required String id,
    required String name,
    required int price,
    required String category,
    required String description,
    required String imageUrl,
    required int stockCount,
    required bool isReadyStock,
  }) async {
    if (!canSwitchToSeller && _activeRole != UserRole.seller) return false;
    if (!isItemOwnedByCurrentSeller(id)) return false; // Strict ownership check

    final idx = _menuItems.indexWhere((m) => m.id == id);
    if (idx == -1) return false;

    final current = _menuItems[idx];
    final cleanStock = stockCount < 0 ? 0 : stockCount;
    final cleanReady = isReadyStock && cleanStock > 0;

    final updated = current.copyWith(
      name: name.trim().isEmpty ? current.name : name.trim(),
      price: price > 0 ? price : current.price,
      category: category,
      description: description.trim().isEmpty ? current.description : description.trim(),
      imageUrl: imageUrl.trim().isNotEmpty ? imageUrl.trim() : current.imageUrl,
      stockCount: cleanStock,
      isReadyStock: cleanReady,
    );

    _menuItems[idx] = updated;

    if (current.dbProductId != null && currentSellerStore?.dbStoreId != null && _isDbConnected) {
      await _dbService.updateProduct(
        productId: current.dbProductId!,
        storeId: currentSellerStore!.dbStoreId!,
        sellerId: _currentUser.dbUserId,
        name: updated.name,
        categoryName: updated.category,
        price: updated.price,
        description: updated.description,
        imageUrl: updated.imageUrl,
        stock: cleanStock,
        isReadyStock: cleanReady,
      );
    }

    notifyListeners();
    return true;
  }

  void deleteMenuItem(String itemId) {
    if (!canSwitchToSeller && _activeRole != UserRole.seller) return;
    if (!isItemOwnedByCurrentSeller(itemId)) return; // Strict ownership check

    final item = _menuItems.firstWhere((m) => m.id == itemId, orElse: () => _menuItems.first);
    if (item.dbProductId != null && currentSellerStore?.dbStoreId != null && _isDbConnected) {
      _dbService.deleteProduct(
        item.dbProductId!,
        storeId: currentSellerStore?.dbStoreId,
        sellerId: _currentUser.dbUserId,
      );
    }
    _menuItems.removeWhere((it) => it.id == itemId);
    notifyListeners();
  }

  // Cart Management
  final List<CartItemModel> _cartItems = [];
  List<CartItemModel> get cartItems => _cartItems;

  // Centralized Service Fee & Voucher State
  int _serviceFee = AppConfig.defaultServiceFee;
  int get serviceFee => _serviceFee;

  void setServiceFee(int newFee) {
    _serviceFee = newFee;
    notifyListeners();
  }

  String? _appliedVoucherCode;
  String? get appliedVoucherCode => _appliedVoucherCode;
  int _appliedDiscount = 0;
  int get appliedDiscount => _appliedDiscount;

  String? applyVoucher(String code) {
    final key = code.trim().toUpperCase();
    if (key.isEmpty) {
      removeVoucher();
      return null;
    }
    if (AppConfig.validVouchers.containsKey(key)) {
      _appliedVoucherCode = key;
      _appliedDiscount = AppConfig.validVouchers[key]!;
      notifyListeners();
      return null;
    } else {
      return 'Kode voucher "$key" tidak ditemukan. Gunakan voucher resmi UPN: UPNDIES50, LUWEHEMAT, atau DANUSANUPN.';
    }
  }

  void removeVoucher() {
    _appliedVoucherCode = null;
    _appliedDiscount = 0;
    notifyListeners();
  }

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get cartSubtotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  int get campusServiceFee => _cartItems.isEmpty ? 0 : _serviceFee;

  int getDeliveryFee(DeliveryMethod method) {
    if (_cartItems.isEmpty) return 0;
    return AppConfig.getDeliveryFee(method);
  }

  int calculateCartTotal({
    required DeliveryMethod deliveryMethod,
    int? customDiscount,
  }) {
    if (_cartItems.isEmpty) return 0;
    final sub = cartSubtotal;
    final sFee = campusServiceFee;
    final dFee = getDeliveryFee(deliveryMethod);
    final disc = customDiscount ?? _appliedDiscount;
    final total = sub + sFee + dFee - disc;
    return total < 0 ? 0 : total;
  }

  int get cartTotal => calculateCartTotal(deliveryMethod: DeliveryMethod.pickup);

  bool addToCart(MenuItemModel item, {int quantity = 1, String level = 'Level 1 (Sedang)', String note = ''}) {
    if (!isItemStoreOpen(item)) {
      return false;
    }
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
    return true;
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

  int _sellerCompletedWithdrawal = 0;
  int get sellerCompletedWithdrawal => _sellerCompletedWithdrawal;

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
      _sellerCompletedWithdrawal = summary['completedWithdrawal'] ?? 0;
      _sellerWithdrawals = await _dbService.fetchWithdrawals(storeId);
      notifyListeners();
    } else {
      // Local / Offline demo calculation
      // Total omzet HANYA dihitung dari transaksi yang selesai/valid
      int calcOmset = 0;
      final completedOrders = sellerOrders.where((o) => o.status == OrderStatus.completed);
      for (final o in completedOrders) {
        calcOmset += o.subtotal;
      }
      _sellerTotalOmset = calcOmset;

      int pending = 0;
      int completed = 0;
      for (final w in _sellerWithdrawals) {
        if (w.status == WithdrawalStatus.waitingVerification || w.status == WithdrawalStatus.processing) {
          pending += w.grossAmount;
        } else if (w.status == WithdrawalStatus.completed) {
          completed += w.grossAmount;
        }
      }
      _sellerPendingWithdrawal = pending;
      _sellerCompletedWithdrawal = completed;
      _sellerAvailableBalance = (_sellerTotalOmset - (pending + completed)).clamp(0, 999999999);
      notifyListeners();
    }
  }

  Future<String?> requestWithdrawal({
    required int amount,
    String? paymentMethod,
    String? accountName,
    String? accountNumber,
    String? notes,
  }) async {
    // 1. Cegah penarikan ganda akibat klik berulang (Debounce / In-flight check)
    if (_isWithdrawalSubmitting) {
      return 'Permintaan penarikan sedang diproses. Mohon tunggu...';
    }

    if (amount < 10000) {
      return 'Nominal penarikan minimal Rp10.000.';
    }

    // 2. Validasi nominal penarikan tidak boleh melebihi saldo tersedia
    if (amount > _sellerAvailableBalance) {
      return 'Nominal penarikan (Rp$amount) melebihi saldo tersedia (Rp$_sellerAvailableBalance).';
    }

    // 3. Gunakan rekening yang sudah terverifikasi
    final targetBank = (paymentMethod != null && paymentMethod.isNotEmpty) ? paymentMethod : _currentUser.bankName;
    final targetAccNum = (accountNumber != null && accountNumber.isNotEmpty) ? accountNumber : _currentUser.bankAccountNumber;
    final targetAccName = (accountName != null && accountName.isNotEmpty) ? accountName : _currentUser.bankAccountHolder;

    if (targetAccNum.trim().isEmpty) {
      return 'Rekening pencairan belum didaftarkan.';
    }

    _isWithdrawalSubmitting = true;
    notifyListeners();

    try {
      final taxFee = AppConfig.calculateTaxFee(amount);
      final adminFee = AppConfig.calculateAdminFee(amount);
      final netAmount = AppConfig.calculateNetWithdrawal(amount);
      final taxStatus = AppConfig.withdrawalTaxStatus;
      final adminStatus = AppConfig.withdrawalAdminStatus;

      final storeId = _currentUser.dbStoreId;
      final sellerId = _currentUser.dbUserId;

      if (_isDbConnected && storeId != null && sellerId != null) {
        final error = await _dbService.requestWithdrawal(
          storeId: storeId,
          sellerId: sellerId,
          grossAmount: amount,
          taxFee: taxFee,
          adminFee: adminFee,
          netAmount: netAmount,
          paymentMethod: targetBank,
          accountName: targetAccName,
          accountNumber: targetAccNum,
          taxStatus: taxStatus,
          adminStatus: adminStatus,
          notes: notes,
        );

        if (error == null) {
          await refreshSellerFinancials();
        }
        return error;
      } else {
        // Local in-memory transaction simulation
        final newWithdrawal = WithdrawalModel(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          storeId: storeId ?? 1,
          sellerId: sellerId ?? 2,
          grossAmount: amount,
          taxFee: taxFee,
          adminFee: adminFee,
          netAmount: netAmount,
          paymentMethod: targetBank,
          accountName: targetAccName,
          accountNumber: targetAccNum,
          notes: notes,
          status: WithdrawalStatus.waitingVerification,
          taxStatus: taxStatus,
          adminStatus: adminStatus,
          auditTrail: [
            '[${DateTime.now().toIso8601String()}] Pengajuan penarikan bruto Rp$amount (Pajak: Rp$taxFee, Admin: Rp$adminFee -> Bersih: Rp$netAmount) ke $targetBank. Status: Menunggu Verifikasi',
          ],
          requestedAt: DateTime.now(),
        );

        _sellerWithdrawals.insert(0, newWithdrawal);
        await refreshSellerFinancials();
        return null;
      }
    } finally {
      _isWithdrawalSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> simulateReviewWithdrawal({
    required int withdrawalId,
    required WithdrawalStatus targetStatus,
    String? reason,
  }) async {
    if (_isDbConnected) {
      await _dbService.simulateReviewWithdrawal(
        withdrawalId: withdrawalId,
        targetStatus: targetStatus,
        rejectionReason: reason,
      );
    } else {
      final idx = _sellerWithdrawals.indexWhere((w) => w.id == withdrawalId);
      if (idx != -1) {
        final current = _sellerWithdrawals[idx];
        final reasonStr = reason != null ? ' (Alasan: $reason)' : '';
        final newAudit = List<String>.from(current.auditTrail)
          ..add('[${DateTime.now().toIso8601String()}] Status diubah menjadi ${targetStatus.label}$reasonStr');
        _sellerWithdrawals[idx] = current.copyWith(
          status: targetStatus,
          rejectionReason: targetStatus == WithdrawalStatus.rejected
              ? (reason ?? 'Ditolak oleh admin keuangan.')
              : null,
          processedAt: DateTime.now(),
          auditTrail: newAudit,
        );
      }
    }
    // Automatically recalculates balances: if rejected, pending is released and returns to available balance!
    await refreshSellerFinancials();
  }

  Future<void> updateStoreBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  }) async {
    _currentUser = _currentUser.copyWith(
      bankName: bankName.trim(),
      bankAccountNumber: accountNumber.trim(),
      bankAccountHolder: accountHolder.trim(),
      isBankAccountVerified: true,
    );
    notifyListeners();
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
    OrderModel(
      id: 'LW-UPN-20261009-002',
      buyerName: 'Hafidz Ahmad',
      buyerNpm: '22081010045',
      buyerPhone: '081234567890',
      merchantName: 'Danusan A — Fakultas FIK',
      items: [
        CartItemModel(
          item: const MenuItemModel(
            id: 'menu_fik_01',
            merchantId: 'store_fik',
            merchantName: 'Danusan A — Fakultas FIK',
            merchantLocation: 'Selasar Depan Lab Gedung FIK Lt. 1',
            name: 'Risol Mayo Beef Melted FIK',
            description: '',
            price: 12000,
            imageUrl: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?auto=format&fit=crop&w=800&q=80',
            category: 'Snack & Danusan',
          ),
          quantity: 3,
          selectedSpiceLevel: 'Original',
        ),
        CartItemModel(
          item: const MenuItemModel(
            id: 'menu_01',
            merchantId: 'store_1',
            merchantName: 'Ayam Geprek Giri Reksa',
            merchantLocation: 'Kantin Barat • Gedung Giri Reksa',
            name: 'Ayam Geprek Sambal Bawang UPNVJT',
            description: '',
            price: 15000,
            imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80',
            category: 'Makanan Utama',
          ),
          quantity: 1,
          selectedSpiceLevel: 'Level 1 (Sedang)',
        ),
      ],
      subtotal: 51000,
      campusServiceFee: 1000,
      totalAmount: 52000,
      deliveryMethod: DeliveryMethod.pickup,
      destinationLocation: 'Kantin FIK UPN Veteran Jawa Timur',
      paymentMethod: PaymentMethod.qris,
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Ambil saat istirahat kuliah siang',
    ),
  ];

  List<OrderModel> _buyerOrders = [];
  List<OrderModel> get buyerOrders => _buyerOrders.isNotEmpty ? _buyerOrders : (_activeRole == UserRole.buyer ? _orders : []);

  final Set<String> _stockDeductedOrderIds = {};
  final Set<String> _confirmingOrderIds = {};
  Future<void>? _lastOrderCreationFuture;
  Future<void>? get lastOrderCreationFuture => _lastOrderCreationFuture;

  List<OrderModel> _sellerOrders = [];
  List<OrderModel> get sellerOrders {
    final store = currentSellerStore;
    if (store == null) return _sellerOrders;

    if (_isDbConnected && _currentUser.dbStoreId != null && _sellerOrders.isNotEmpty) {
      return _sellerOrders;
    }

    final Set<String> existingIds = _sellerOrders.map((o) => o.id).toSet();
    final matching = _orders.where((order) {
      if (existingIds.contains(order.id)) return false;
      if (order.items.isNotEmpty) {
        return order.items.any((ci) => isItemBelongsToStore(ci.item, store));
      }
      return order.merchantName.trim().toLowerCase() == store.name.trim().toLowerCase();
    }).toList();

    return [..._sellerOrders, ...matching];
  }

  List<OrderModel> get activeSellerOrders => sellerOrders
      .where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled)
      .toList();

  List<OrderModel> get orders {
    if (_isDbConnected && _currentUser.dbUserId != null) {
      return _activeRole == UserRole.seller ? _sellerOrders : _buyerOrders;
    }
    return _activeRole == UserRole.seller ? sellerOrders : _orders;
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
    int? customDiscount,
    String? customVoucherCode,
  }) {
    // Re-validate that all stores of items in cart are currently open
    for (final cartItem in _cartItems) {
      if (!isItemStoreOpen(cartItem.item)) {
        throw StateError('Toko "${cartItem.item.merchantName}" sedang tutup dan tidak menerima pesanan saat ini.');
      }
    }

    final currentSubtotal = cartSubtotal;
    final currentServiceFee = campusServiceFee;
    final currentDeliveryFee = getDeliveryFee(deliveryMethod);
    final currentDiscount = customDiscount ?? _appliedDiscount;
    // Backend/data layer re-validation of final total payment:
    final computedTotal = (currentSubtotal + currentServiceFee + currentDeliveryFee - currentDiscount).clamp(0, 999999999);

    final paymentStatus = paymentMethod == PaymentMethod.qris
        ? 'Menunggu Pembayaran (Simulasi QRIS)'
        : 'Bayar Tunai di Tempat (COD)';

    final newOrder = OrderModel(
      id: 'LW-UPN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      buyerName: _currentUser.name,
      buyerNpm: _currentUser.npm,
      buyerPhone: _currentUser.phoneNumber,
      merchantName: _cartItems.isNotEmpty ? _cartItems.first.item.merchantName : 'Danus Mahasiswa UPN',
      items: List.from(_cartItems),
      subtotal: currentSubtotal,
      campusServiceFee: currentServiceFee,
      deliveryFee: currentDeliveryFee,
      discount: currentDiscount,
      voucherCode: customVoucherCode ?? _appliedVoucherCode,
      totalAmount: computedTotal,
      deliveryMethod: deliveryMethod,
      destinationLocation: destinationLocation,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: OrderStatus.waitingConfirmation,
      createdAt: DateTime.now(),
      notes: notes,
      isStockDeducted: false,
    );

    _orders.insert(0, newOrder);
    _buyerOrders.insert(0, newOrder);

    // If order belongs to active seller store, make sure it is in _sellerOrders
    final store = currentSellerStore;
    if (store != null && (newOrder.items.isEmpty || newOrder.items.any((ci) => isItemBelongsToStore(ci.item, store)))) {
      if (!_sellerOrders.any((o) => o.id == newOrder.id)) {
        _sellerOrders.insert(0, newOrder);
      }
    }

    // Save to database asynchronously
    if (_currentUser.dbUserId != null) {
      int targetStoreId = 1;
      if (_cartItems.isNotEmpty) {
        final mId = _cartItems.first.item.merchantId;
        final parsed = int.tryParse(mId.replaceAll(RegExp(r'[^0-9]'), ''));
        if (parsed != null && parsed > 0) targetStoreId = parsed;
      }
      _lastOrderCreationFuture = _dbService.createOrder(
        buyerId: _currentUser.dbUserId!,
        storeId: targetStoreId,
        order: newOrder,
      ).then((_) async {
        await refreshOrders();
        await refreshSellerFinancials();
      });
    }

    clearCart();
    removeVoucher();
    notifyListeners();
    return newOrder;
  }

  void _mutateOrderStatusLocally(
    String orderCode,
    OrderStatus status, {
    String? cancellationReason,
    String? paymentStatus,
    bool? isStockDeducted,
  }) {
    void updateList(List<OrderModel> list) {
      final idx = list.indexWhere((o) => o.id == orderCode);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(
          status: status,
          cancellationReason: cancellationReason ?? list[idx].cancellationReason,
          paymentStatus: paymentStatus ?? list[idx].paymentStatus,
          isStockDeducted: isStockDeducted ?? list[idx].isStockDeducted,
        );
      }
    }
    updateList(_orders);
    updateList(_buyerOrders);
    updateList(_sellerOrders);
    notifyListeners();
  }

  Future<bool> cancelOrder(String orderCode, {String reason = 'Dibatalkan oleh pembeli'}) async {
    // If order had stock deducted, restore stock
    OrderModel? targetOrder;
    for (final o in [..._orders, ..._buyerOrders, ..._sellerOrders]) {
      if (o.id == orderCode) {
        targetOrder = o;
        break;
      }
    }
    if ((_stockDeductedOrderIds.contains(orderCode) || (targetOrder?.isStockDeducted ?? false)) && targetOrder != null) {
      for (final cartItem in targetOrder.items) {
        final idx = _menuItems.indexWhere((m) => m.id == cartItem.item.id || m.name.toLowerCase() == cartItem.item.name.toLowerCase());
        if (idx != -1) {
          final cur = _menuItems[idx];
          _menuItems[idx] = cur.copyWith(stockCount: cur.stockCount + cartItem.quantity);
        }
      }
      _stockDeductedOrderIds.remove(orderCode);
    }

    if (_currentUser.dbUserId == null) {
      _mutateOrderStatusLocally(orderCode, OrderStatus.cancelled, cancellationReason: reason, isStockDeducted: false);
      return true;
    }
    final ok = await _dbService.cancelOrder(
      orderCode: orderCode,
      reason: reason,
      buyerId: _currentUser.dbUserId!,
    );
    if (ok) {
      await refreshOrders();
      await refreshSellerFinancials();
    } else {
      _mutateOrderStatusLocally(orderCode, OrderStatus.cancelled, cancellationReason: reason, isStockDeducted: false);
    }
    return ok;
  }

  Future<bool> confirmOrderReceived(String orderCode) async {
    if (_currentUser.dbUserId == null) {
      _mutateOrderStatusLocally(orderCode, OrderStatus.completed);
      return true;
    }
    final ok = await _dbService.confirmOrderReceived(
      orderCode: orderCode,
      buyerId: _currentUser.dbUserId!,
    );
    if (ok) {
      await refreshOrders();
      await refreshSellerFinancials();
    } else {
      _mutateOrderStatusLocally(orderCode, OrderStatus.completed);
    }
    return ok;
  }

  Future<bool> updateSellerOrderStatus(String orderCode, OrderStatus newStatus) async {
    if (_lastOrderCreationFuture != null) {
      try {
        await _lastOrderCreationFuture;
      } catch (_) {}
    }
    if (_confirmingOrderIds.contains(orderCode)) {
      return false; // Prevent concurrent requests
    }

    OrderModel? targetOrder;
    for (final o in [..._orders, ..._sellerOrders, ..._buyerOrders]) {
      if (o.id == orderCode && o.items.isNotEmpty) {
        targetOrder = o;
        break;
      }
    }
    targetOrder ??= [..._sellerOrders, ..._orders, ..._buyerOrders].where((o) => o.id == orderCode).firstOrNull;

    if (newStatus == OrderStatus.readyForPickupOrDelivery) {
      final alreadyDeducted = _stockDeductedOrderIds.contains(orderCode) || (targetOrder?.isStockDeducted ?? false);
      if (!alreadyDeducted && targetOrder != null) {
        // 1. Validate stock availability before confirming
        for (final cartItem in targetOrder.items) {
          final idx = _menuItems.indexWhere((m) => m.id == cartItem.item.id || m.name.toLowerCase() == cartItem.item.name.toLowerCase());
          if (idx != -1) {
            if (_menuItems[idx].stockCount < cartItem.quantity) {
              throw StateError('Stok produk "${cartItem.item.name}" tidak mencukupi (tersedia: ${_menuItems[idx].stockCount}, diminta: ${cartItem.quantity}).');
            }
          }
        }

        _confirmingOrderIds.add(orderCode);
        try {
          // 2. Reduce stock atomically in memory
          for (final cartItem in targetOrder.items) {
            final idx = _menuItems.indexWhere((m) => m.id == cartItem.item.id || m.name.toLowerCase() == cartItem.item.name.toLowerCase());
            if (idx != -1) {
              final current = _menuItems[idx];
              final newStock = (current.stockCount - cartItem.quantity).clamp(0, 999999);
              _menuItems[idx] = current.copyWith(stockCount: newStock);
            }
          }
          _stockDeductedOrderIds.add(orderCode);
          _mutateOrderStatusLocally(orderCode, OrderStatus.readyForPickupOrDelivery, isStockDeducted: true);

          if (_currentUser.dbStoreId != null && _isDbConnected) {
            final ok = await _dbService.sellerUpdateOrderStatus(
              orderCode: orderCode,
              status: OrderStatus.readyForPickupOrDelivery,
              storeId: _currentUser.dbStoreId!,
            );
            if (ok) {
              await refreshOrders();
              await refreshSellerFinancials();
              await _syncProducts();
            }
            return ok;
          }
          return true;
        } finally {
          _confirmingOrderIds.remove(orderCode);
        }
      } else {
        _mutateOrderStatusLocally(orderCode, OrderStatus.readyForPickupOrDelivery);
        if (_currentUser.dbStoreId != null && _isDbConnected) {
          final ok = await _dbService.sellerUpdateOrderStatus(
            orderCode: orderCode,
            status: OrderStatus.readyForPickupOrDelivery,
            storeId: _currentUser.dbStoreId!,
          );
          if (ok) {
            await refreshOrders();
            await refreshSellerFinancials();
          }
          return ok;
        }
        return true;
      }
    } else if (newStatus == OrderStatus.cancelled) {
      final wasDeducted = _stockDeductedOrderIds.contains(orderCode) || (targetOrder?.isStockDeducted ?? false);
      if (wasDeducted && targetOrder != null) {
        // Restore stock atomically in memory
        for (final cartItem in targetOrder.items) {
          final idx = _menuItems.indexWhere((m) => m.id == cartItem.item.id || m.name.toLowerCase() == cartItem.item.name.toLowerCase());
          if (idx != -1) {
            final cur = _menuItems[idx];
            _menuItems[idx] = cur.copyWith(stockCount: cur.stockCount + cartItem.quantity);
          }
        }
        _stockDeductedOrderIds.remove(orderCode);
      }
      _mutateOrderStatusLocally(orderCode, OrderStatus.cancelled, isStockDeducted: false, cancellationReason: 'Ditolak oleh penjual');

      if (_currentUser.dbStoreId != null && _isDbConnected) {
        final ok = await _dbService.sellerUpdateOrderStatus(
          orderCode: orderCode,
          status: OrderStatus.cancelled,
          storeId: _currentUser.dbStoreId!,
        );
        if (ok) {
          await refreshOrders();
          await refreshSellerFinancials();
          await _syncProducts();
        }
        return ok;
      }
      return true;
    } else if (newStatus == OrderStatus.completed) {
      // Completed: DO NOT deduct stock again!
      _mutateOrderStatusLocally(orderCode, OrderStatus.completed, paymentStatus: 'Lunas');
      if (_currentUser.dbStoreId != null && _isDbConnected) {
        final ok = await _dbService.sellerUpdateOrderStatus(
          orderCode: orderCode,
          status: OrderStatus.completed,
          storeId: _currentUser.dbStoreId!,
        );
        if (ok) {
          await refreshOrders();
          await refreshSellerFinancials();
        }
        return ok;
      }
      return true;
    }

    _mutateOrderStatusLocally(orderCode, newStatus);
    return true;
  }

  Future<bool> updateSellerStoreProfile({
    required String sellerName,
    required String phoneNumber,
    String? avatarUrl,
    required String storeName,
    required String storeFaculty,
    required String storeLocation,
    required String storeDescription,
    String? storeLogoUrl,
    String? storeBannerUrl,
  }) async {
    // 1. Update _currentUser
    _currentUser = _currentUser.copyWith(
      name: sellerName,
      phoneNumber: phoneNumber,
      avatarUrl: (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : _currentUser.avatarUrl,
      storeName: storeName,
      storeFaculty: storeFaculty,
      storeLocation: storeLocation,
      storeDescription: storeDescription,
      storeBannerPhoto: (storeBannerUrl != null && storeBannerUrl.isNotEmpty) ? storeBannerUrl : _currentUser.storeBannerPhoto,
    );

    // 2. Update matching store in _stores
    final currentStore = currentSellerStore;
    for (int i = 0; i < _stores.length; i++) {
      final s = _stores[i];
      if ((currentStore != null && s.id == currentStore.id) ||
          (_currentUser.dbStoreId != null && s.dbStoreId == _currentUser.dbStoreId) ||
          s.name.trim().toLowerCase() == storeName.trim().toLowerCase()) {
        _stores[i] = s.copyWith(
          name: storeName,
          faculty: storeFaculty,
          location: storeLocation,
          description: storeDescription,
          logoUrl: (storeLogoUrl != null && storeLogoUrl.isNotEmpty) ? storeLogoUrl : s.logoUrl,
          bannerUrl: (storeBannerUrl != null && storeBannerUrl.isNotEmpty) ? storeBannerUrl : s.bannerUrl,
        );
      }
    }

    // 3. Persist to DB if connected
    if (_currentUser.dbUserId != null && _isDbConnected) {
      final ok = await _dbService.updateSellerStoreProfile(
        userId: _currentUser.dbUserId!,
        storeId: _currentUser.dbStoreId,
        sellerName: sellerName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        storeName: storeName,
        storeFaculty: storeFaculty,
        storeLocation: storeLocation,
        storeDescription: storeDescription,
        storeLogoUrl: storeLogoUrl,
        storeBannerUrl: storeBannerUrl,
      );
      if (ok) {
        await _syncStores();
        await _syncUserData();
      }
    }

    notifyListeners();
    return true;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    String? newPayStatus;
    final match = _orders.where((o) => o.id == orderId);
    if (match.isNotEmpty) {
      final existing = match.first;
      if (status == OrderStatus.processing && existing.paymentMethod == PaymentMethod.qris) {
        newPayStatus = 'Lunas (Simulasi QRIS)';
      } else if (status == OrderStatus.completed && existing.paymentMethod == PaymentMethod.cash) {
        newPayStatus = 'Lunas (Tunai)';
      }
    }
    _mutateOrderStatusLocally(orderId, status, paymentStatus: newPayStatus);
    _dbService.updateOrderStatus(orderId, status);
  }

  // ==========================================
  // 4. DIRECT MESSAGE (DM) RESMI LUWE!
  // ==========================================
  List<ConversationModel> _conversations = [];
  ConversationModel? _activeConversation;
  List<ChatMessageModel> _activeChatMessages = [];
  bool _isLoadingChat = false;
  bool get isLoadingChat => _isLoadingChat;
  String? _chatError;
  String? get chatError => _chatError;

  List<ConversationModel> get conversations {
    if (_conversations.isEmpty && _isLoggedIn) {
      refreshConversations();
    }
    return _conversations;
  }

  ConversationModel? get activeConversation => _activeConversation;
  List<ChatMessageModel> get chatMessages => _activeChatMessages;

  int get totalUnreadMessages {
    if (!_isLoggedIn) return 0;
    if (_activeRole == UserRole.buyer) {
      return _dbService.getUnreadCountForBuyer(_currentUser.dbUserId ?? 1);
    } else {
      final store = currentSellerStore;
      final storeId = store?.id ?? (_currentUser.dbStoreId != null ? 'store_${_currentUser.dbStoreId}' : 'store_1');
      final sellerId = _currentUser.dbUserId ?? 2;
      return _dbService.getUnreadCountForStore(storeId, sellerId);
    }
  }

  int getUnreadCountForOrder(String orderId) {
    if (!_isLoggedIn) return 0;
    final match = _conversations.where((c) => c.orderId == orderId).firstOrNull;
    return match?.unreadCount ?? 0;
  }

  Future<void> refreshConversations() async {
    if (!_isLoggedIn) {
      _conversations = [];
      _activeConversation = null;
      _activeChatMessages = [];
      notifyListeners();
      return;
    }

    if (_activeRole == UserRole.buyer) {
      final buyerId = _currentUser.dbUserId ??
          (int.tryParse(_currentUser.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
              (_currentUser.id == 'user_hafidz' ? 1 : 99999));
      _conversations = await _dbService.fetchBuyerConversations(buyerId);
    } else {
      final store = currentSellerStore;
      final storeId = store?.id ?? (_currentUser.dbStoreId != null ? 'store_${_currentUser.dbStoreId}' : 'store_1');
      final sellerId = _currentUser.dbUserId ?? (_currentUser.id == 'user_adistya' ? 2 : 99998);
      _conversations = await _dbService.fetchStoreConversations(storeId, sellerId);
    }

    _conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    if (_activeConversation != null) {
      final match = _conversations.where((c) => c.id == _activeConversation!.id).firstOrNull;
      if (match != null) {
        _activeConversation = match;
        await loadMessagesForActiveConversation();
      } else if (_conversations.isNotEmpty) {
        _activeConversation = _conversations.first;
        await loadMessagesForActiveConversation();
      } else {
        _activeConversation = null;
        _activeChatMessages = [];
      }
    } else if (_conversations.isNotEmpty) {
      _activeConversation = _conversations.first;
      await loadMessagesForActiveConversation();
    }

    notifyListeners();
  }

  Future<void> selectConversation(ConversationModel convo) async {
    _activeConversation = convo;
    final readerId = _currentUser.dbUserId ??
        (int.tryParse(_currentUser.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
            (_currentUser.id == 'user_adistya' ? 2 : 1));
    await _dbService.markConversationAsRead(convo.id, readerId);
    await loadMessagesForActiveConversation();
    await refreshConversations();
  }

  Future<void> loadMessagesForActiveConversation() async {
    if (_activeConversation == null) return;
    _isLoadingChat = true;
    final currentUserId = _currentUser.dbUserId ??
        (int.tryParse(_currentUser.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
            (_currentUser.id == 'user_adistya' ? 2 : (_currentUser.id == 'user_hafidz' ? 1 : 99999)));
    _activeChatMessages = await _dbService.fetchMessages(_activeConversation!.id, currentUserId);
    _isLoadingChat = false;
    notifyListeners();
  }

  Future<bool> sendChatMessage(String message, {String? orderId}) async {
    final clean = message.trim();
    if (clean.isEmpty || _activeConversation == null) return false;

    final currentUserId = _currentUser.dbUserId ??
        (int.tryParse(_currentUser.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
            (_currentUser.id == 'user_adistya' ? 2 : (_currentUser.id == 'user_hafidz' ? 1 : 99999)));
    final senderName = _activeRole == UserRole.seller
        ? (currentSellerStore?.name ?? (_currentUser.storeName.isNotEmpty ? _currentUser.storeName : 'Penjual LuWe'))
        : _currentUser.name;

    final msg = await _dbService.sendMessage(
      conversationId: _activeConversation!.id,
      senderId: currentUserId,
      senderName: senderName,
      text: clean,
      orderId: orderId ?? _activeConversation!.orderId,
    );

    if (msg != null) {
      _activeChatMessages.add(msg);
      await refreshConversations();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Membuka atau membuat percakapan dengan Toko (Mode Pembeli)
  Future<ConversationModel> openOrCreateConversationWithStore({
    required String storeId,
    String? orderId,
  }) async {
    if (!_isLoggedIn) {
      throw StateError('Silakan login terlebih dahulu untuk mengirim pesan ke toko.');
    }

    final store = _stores.where((s) => s.id == storeId).firstOrNull;
    final storeName = store?.name ?? 'Toko Danusan LuWe';
    final buyerId = _currentUser.dbUserId ??
        (int.tryParse(_currentUser.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
            (_currentUser.id == 'user_hafidz' ? 1 : 99999));
    final sellerId = store?.sellerId ?? (storeId == 'store_1' ? 2 : 3);
    final buyerName = _currentUser.name;

    final convo = await _dbService.getOrCreateConversation(
      buyerId: buyerId,
      sellerId: sellerId,
      storeId: storeId,
      storeName: storeName,
      buyerName: buyerName,
      orderId: orderId,
      storeLogo: store?.logoUrl,
      storeLocation: store?.location,
    );

    _activeRole = UserRole.buyer;
    _currentTabIndex = 3;
    await selectConversation(convo);
    notifyListeners();
    return convo;
  }

  /// Membuka atau membuat percakapan dengan Pembeli (Mode Penjual)
  Future<ConversationModel> openOrCreateConversationWithBuyer({
    required int buyerId,
    required String buyerName,
    required String storeId,
    String? orderId,
  }) async {
    if (!_isLoggedIn || !_currentUser.isSellerApproved) {
      throw StateError('Hanya penjual terverifikasi yang dapat membuka pesan pembeli.');
    }

    final store = currentSellerStore;
    final storeName = store?.name ?? _currentUser.storeName;
    final sellerId = _currentUser.dbUserId ?? 2;

    final convo = await _dbService.getOrCreateConversation(
      buyerId: buyerId,
      sellerId: sellerId,
      storeId: store?.id ?? storeId,
      storeName: storeName,
      buyerName: buyerName,
      orderId: orderId,
      storeLogo: store?.logoUrl,
      storeLocation: store?.location,
    );

    _activeRole = UserRole.seller;
    _currentTabIndex = 3;
    await selectConversation(convo);
    notifyListeners();
    return convo;
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
