import 'package:flutter/material.dart';

void main() {
  runApp(const LuweApp());
}

class LuweApp extends StatelessWidget {
  const LuweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LUWE',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFFFF8F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA33900),
        ),
      ),
      home: const HomePage(),
routes: {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/tambah-menu': (context) => const TambahMenuPage(),
},
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
         children: [
  _buildNavbar(context),
  _buildDeliveryBar(),
  _buildHero(),
  _buildCategories(),
  _buildPromoBanner(),
  _buildPopularFood(),
  _buildCampusTrust(),
  _buildFooter(),
],
        ),
      ),
    );
  }

  // ============================================================
  // NAVBAR
  // ============================================================

 Widget _buildNavbar(BuildContext context) {
  return Container(
    height: 80,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Row(
      children: [
        // =====================================================
        // LOGO LUWE
        // =====================================================
        GestureDetector(
          onTap: () {
            Navigator.popUntil(
              context,
              (route) => route.isFirst,
            );
          },
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFA33900),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LUWE',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B19),
                    ),
                  ),
                  Text(
                    'UPN Jatim Campus Food Hub',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6E5A53),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // =====================================================
        // NAVIGATION
        // =====================================================
        Row(
          children: [
            // HOME
            GestureDetector(
              onTap: () {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              },
              child: _navItem(
                'Home',
                true,
              ),
            ),

            const SizedBox(width: 32),

            // TAMBAH MENU
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/tambah-menu',
                );
              },
              child: _navItem(
                'Tambah Menu',
                false,
              ),
            ),

            const SizedBox(width: 32),

            // MENU LAINNYA
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MenuLainnyaPage(),
                  ),
                );
              },
              child: _navItem(
                'Menu Lainnya',
                false,
              ),
            ),
          ],
        ),

        const Spacer(),

        // =====================================================
        // SEARCH
        // =====================================================
        Container(
          width: 220,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFAF2EE),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              SizedBox(width: 14),

              Icon(
                Icons.search,
                size: 18,
                color: Color(0xFF5A4138),
              ),

              SizedBox(width: 8),

              Text(
                'Cari makanan atau kantin...',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8C7770),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // =====================================================
        // PROFILE
        // =====================================================
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/login',
            );
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF2EE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: Color(0xFF5A4138),
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _navItem(String title, bool active) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        color: active
            ? const Color(0xFFA33900)
            : const Color(0xFF5A4138),
      ),
    );
  }

  // ============================================================
  // DELIVERY BAR
  // ============================================================

  Widget _buildDeliveryBar() {
    return Container(
      height: 52,
      color: const Color(0xFFFAF2EE),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            size: 17,
            color: Color(0xFF006D30),
          ),

          const SizedBox(width: 10),

          const Text(
            'Kampus UPN "Veteran" Jatim Hub',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1B19),
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            '•',
            style: TextStyle(
              color: Color(0xFFE2BFB2),
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.place_outlined,
            size: 15,
            color: Color(0xFF5A4138),
          ),

          const SizedBox(width: 5),

          const Text(
            'Lokasi: Rungkut Madya No. 1, Gunung Anyar',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF5A4138),
            ),
          ),

          const Spacer(),

          // PICKUP / DELIVERY
          Container(
            height: 36,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF4ECE8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 15,
                        color: Color(0xFFA33900),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Ambil Sendiri di Kantin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA33900),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 15,
                        color: Color(0xFF5A4138),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Antar ke Gedung Kuliah',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5A4138),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // STATUS
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0x6692F5A4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFF006D30),
                ),
                SizedBox(width: 8),
                Text(
                  'Semua 8 Kantin Fakultas Buka',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF006D30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      height: 600,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 48,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LABEL
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEE7E3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF006D30),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'CAMPUS FOOD DELIVERY & PICK-UP • UPN VETERAN JATIM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFF5A4138),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // TITLE
                const Text(
                  'Temukan Makanan Favoritmu di',
                  style: TextStyle(
                    fontSize: 40,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B19),
                  ),
                ),

                const Text(
                  'Luwe',
                  style: TextStyle(
                    fontSize: 40,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFA33900),
                  ),
                ),

                const SizedBox(height: 16),

                // DESCRIPTION
                const SizedBox(
                  width: 576,
                  child: Text(
                    "Marketplace makanan khusus civitas UPN 'Veteran' Jawa Timur. "
                    "Pesan santapan lezat dari kantin fakultas & UMKM kampus "
                    "langsung dari sela-sela jam kuliah, cepat tanpa antre.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF5A4138),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // BUTTON
                Row(
                  children: [
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA33900),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Mulai Pesan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4ECE8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 16,
                            color: Color(0xFFA33900),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Lihat Promo Hari Ini',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E1B19),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // STATS
                Row(
                  children: [
                    _statCard('50+', 'Mitra Kantin'),
                    const SizedBox(width: 16),
                    _statCard('10.000+', 'Pesanan Civitas'),
                    const SizedBox(width: 16),
                    _statCard('15 Mnt', 'Rata-rata Siap'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // RIGHT IMAGE AREA
          Expanded(
            flex: 5,
            child: Container(
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF6D8C9),
                    Color(0xFFEFC2AC),
                    Color(0xFFDDA78C),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 100,
                      color: Color(0xFFA33900),
                    ),
                  ),

                  Positioned(
                    left: 16,
                    bottom: -1,
                    child: Container(
                      width: 320,
                      height: 74,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFFFE5D8),
                            child: Icon(
                              Icons.local_offer,
                              color: Color(0xFFA33900),
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Diskon 20% Khusus Mhs Fasilkom',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1B19),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tunjukkan KTM / Akun UPN Jatim',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF5A4138),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label) {
    return Container(
      width: 160,
      height: 84,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFFA33900),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5A4138),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    final categories = [
      {
        'icon': Icons.rice_bowl,
        'title': 'Makanan Berat',
        'subtitle': 'Nasi, mie & lauk',
      },
      {
        'icon': Icons.fastfood,
        'title': 'Snack & Kudapan',
        'subtitle': 'Cemilan & jajanan',
      },
      {
        'icon': Icons.local_cafe,
        'title': 'Minuman',
        'subtitle': 'Kopi, teh & lainnya',
      },
      {
        'icon': Icons.icecream,
        'title': 'Dessert',
        'subtitle': 'Manis & segar',
      },
      {
        'icon': Icons.local_pizza,
        'title': 'Makanan Cepat',
        'subtitle': 'Praktis & lezat',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(80, 48, 80, 64),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Jelajahi Pilihan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA33900),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kategori Makanan',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B19),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Temukan makanan sesuai selera kamu.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5A4138),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              const Text(
                'Lihat Semua Kategori  →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA33900),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: 235,
            child: Row(
              children: categories.map((category) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: _categoryCard(
                      icon: category['icon'] as IconData,
                      title: category['title'] as String,
                      subtitle: category['subtitle'] as String,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF0E2DB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1D4C6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 52,
                color: const Color(0xFFA33900),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1B19),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A4138),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Color(0xFFA33900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Promo Banner
  // ============================================================

Widget _buildPromoBanner() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 32,
    ),
    color: const Color(0xFFFFF8F5),
    child: Container(
      height: 352,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFA33900),
            Color(0xFFCC4900),
            Color(0xFFA36700),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                32,
                48,
                20,
                48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'VOUCHER KHUSUS CIVITAS UPN JATIM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Judul
                  const Text(
                    'Lapar di kampus? Temukan makanan favoritmu di\nLuwe.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Deskripsi
                  const Text(
                    'Ambil langsung di kantin favoritmu atau pesan antar ke '
                    'gedung kuliah dengan mudah tanpa perlu terburu-buru '
                    'antar mata kuliah.',
                    style: TextStyle(
                      color: Color(0xFFFFFBFF),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      // Voucher
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'KODE VOUCHER:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'UPNKENYANG',
                              style: TextStyle(
                                color: Color(0xFFFFF8F5),
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.copy_outlined,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Tombol
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Center(
                          child: Text(
                            'Klaim Voucher Sekarang',
                            style: TextStyle(
                              color: Color(0xFFA33900),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Visual voucher
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 48,
              ),
              child: Transform.rotate(
                angle: 0.05,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.30),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.white,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'LUWE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'CAMPUS FOOD HUB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

 // ============================================================
  // POPULAR FOODS
  // ============================================================

  Widget _buildPopularFood() {
  final foods = [
    {
      'name': 'Nasi Ayam Geprek',
      'shop': 'Kantin Giri Reka',
      'price': 'Rp15.000',
      'rating': '4.8',
      'icon': Icons.rice_bowl,
    },
    {
      'name': 'Rice Bowl Chicken',
      'shop': 'Kantin Giri Loka',
      'price': 'Rp18.000',
      'rating': '4.9',
      'icon': Icons.restaurant,
    },
    {
      'name': 'Es Kopi Susu',
      'shop': 'Kantin FIK',
      'price': 'Rp10.000',
      'rating': '4.7',
      'icon': Icons.local_cafe,
    },
    {
      'name': 'Dimsum Ayam',
      'shop': 'Kantin FT',
      'price': 'Rp12.000',
      'rating': '4.8',
      'icon': Icons.lunch_dining,
    },
    {
      'name': 'Donat Coklat',
      'shop': 'Kantin Giri Reka',
      'price': 'Rp8.000',
      'rating': '4.9',
      'icon': Icons.donut_large,
    },
    {
      'name': 'Mie Ayam',
      'shop': 'Kantin Pusat',
      'price': 'Rp13.000',
      'rating': '4.8',
      'icon': Icons.ramen_dining,
    },
  ];

  return Container(
    width: double.infinity,
    color: const Color(0xFFFFF8F5),
    padding: const EdgeInsets.fromLTRB(
      80,
      56,
      80,
      64,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PALING BANYAK DIPESAN',
                  style: TextStyle(
                    color: Color(0xFFA33900),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Pilihan Favorit',
                  style: TextStyle(
                    color: Color(0xFF1E1B19),
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Menu favorit civitas UPN Veteran Jawa Timur.',
                  style: TextStyle(
                    color: Color(0xFF5A4138),
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Color(0xFFEBDDD6),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 15,
                    color: Color(0xFFA33900),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Filter Menu',
                    style: TextStyle(
                      color: Color(0xFF5A4138),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        
        const SizedBox(height: 28),

        // Filter chips
        Row(
          children: [
            _foodFilterChip('Semua', true),
            const SizedBox(width: 10),
            _foodFilterChip('Makanan Berat', false),
            const SizedBox(width: 10),
            _foodFilterChip('Snack', false),
            const SizedBox(width: 10),
            _foodFilterChip('Minuman', false),
            const SizedBox(width: 10),
            _foodFilterChip('Dessert', false),
          ],
        ),

        const SizedBox(height: 28),

        // Food grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: foods.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 24,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            final food = foods[index];

            return _foodCard(
              name: food['name'] as String,
              shop: food['shop'] as String,
              price: food['price'] as String,
              rating: food['rating'] as String,
              icon: food['icon'] as IconData,
            );
          },
        ),
      ],
    ),
  );
}
Widget _foodCard({
  required String name,
  required String shop,
  required String price,
  required String rating,
  required IconData icon,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFEBDDD6),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF1D4C6),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 58,
                    color: const Color(0xFFA33900),
                  ),
                ),

                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 13,
                          color: Color(0xFFE59B00),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Information
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B19),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  shop,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A665F),
                  ),
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA33900),
                      ),
                    ),

                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE7DC),
                        borderRadius:
                            BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Color(0xFFA33900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _foodFilterChip(
  String title,
  bool active,
) {
  return Container(
    height: 36,
    padding: const EdgeInsets.symmetric(
      horizontal: 18,
    ),
    decoration: BoxDecoration(
      color: active
          ? const Color(0xFFA33900)
          : Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: active
            ? const Color(0xFFA33900)
            : const Color(0xFFEBDDD6),
      ),
    ),
    child: Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active
              ? Colors.white
              : const Color(0xFF5A4138),
        ),
      ),
    ),
  );
}

  // ============================================================
  // Campus Trust
  // ============================================================

  Widget _buildCampusTrust() {
  return Container(
    width: double.infinity,
    color: const Color(0xFFFAF2EE),
    padding: const EdgeInsets.fromLTRB(
      40,
      48,
      40,
      48,
    ),
    child: Column(
      children: [
        // =========================
        // HEADER
        // =========================
        const Text(
          'LAYANAN TANPA RIBET',
          style: TextStyle(
            color: Color(0xFFA33900),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.55,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Kuliah Tenang, Makan Terjamin',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1E1B19),
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Dirancang khusus menjawab rutinitas padat civitas akademika UPN Veteran Jawa Timur',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF5A4138),
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 32),

        // =========================
        // 3 CARDS
        // =========================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _howItWorksCard(
                number: '1',
                title: 'Pilih Menu Favorit',
                description:
                    'Pesan dari berbagai stan kantin fakultas maupun UMKM '
                    'binaan kampus melalui satu platform.',
                icon: Icons.restaurant_menu,
                iconBackground: const Color(0xFFFFDBCE),
                iconColor: const Color(0xFFA33900),
              ),
            ),

            const SizedBox(width: 24),

            Expanded(
              child: _howItWorksCard(
                number: '2',
                title: 'Notifikasi Pesanan Siap',
                description:
                    'Kantin menyiapkan pesananmu saat kamu masih di kelas. '
                    'Dapatkan alert saat makanan siap dinikmati.',
                icon: Icons.notifications_active_outlined,
                iconBackground: const Color(0xFF95F8A7),
                iconColor: const Color(0xFF006D30),
              ),
            ),

            const SizedBox(width: 24),

            Expanded(
              child: _howItWorksCard(
                number: '3',
                title: 'Ambil / Antar Cepat',
                description:
                    'Tunjukkan QR tanpa perlu antre di gerai, atau minta '
                    'diantar langsung ke lobi fakultasmu.',
                icon: Icons.delivery_dining,
                iconBackground: const Color(0xFFFFDDB8),
                iconColor: const Color(0xFFA85C00),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
Widget _howItWorksCard({
  required String number,
  required String title,
  required String description,
  required IconData icon,
  required Color iconBackground,
  required Color iconColor,
}) {
  return Container(
    height: 202,
    padding: const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 24,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      children: [
        // ICON
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 25,
            color: iconColor,
          ),
        ),

        const SizedBox(height: 12),

        // TITLE
        Text(
          '$number. $title',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1E1B19),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        // DESCRIPTION
        Expanded(
          child: Center(
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5A4138),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E1B19),
      padding: const EdgeInsets.symmetric(
        horizontal: 80,
        vertical: 48,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _footerColumn(
                  'LUWE',
                  [
                    'Marketplace makanan civitas UPN Veteran Jawa Timur.',
                    'Akses cepat santapan kantin kampus langsung dari gedung kuliah.',
                  ],
                ),
              ),

              Expanded(
                child: _footerColumn(
                  'Jelajah',
                  [
                    'Home',
                    'Kategori & Kantin',
                    'Kelola Menu Mitra',
                  ],
                ),
              ),

              Expanded(
                child: _footerColumn(
                  'Civitas UPN',
                  [
                    'Kantin Giri Reka',
                    'Kantin Giri Loka',
                    'Kantin Barat FIK & FT',
                  ],
                ),
              ),

              Expanded(
                child: _footerColumn(
                  'Pusat Bantuan & Kontak',
                  [
                    'Kantin Pusat UPN Veteran Jatim',
                    'Gedung Giri Loka Lt. 1',
                    'Rungkut Madya, Surabaya',
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          const Divider(
            color: Color(0xFF514945),
          ),

          const SizedBox(height: 20),

          const Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 LUWE — UPN Veteran Jawa Timur',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFB9AAA4),
                ),
              ),
              Text(
                'Campus Food Hub',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFB9AAA4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(
    String title,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFFB9AAA4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 1050,
            height: 620,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                // =========================
                // LEFT SIDE
                // =========================
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFA33900),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Color(0xFFA33900),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'LUWE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          const Text(
                            'Selamat Datang\nKembali di Luwe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Pesan makanan favoritmu dari kantin '
                            'kampus tanpa perlu antre.',
                            style: TextStyle(
                              color: Color(0xFFFFEDE5),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              _loginBenefit(
                                Icons.restaurant_menu,
                                '50+ Menu',
                              ),
                              const SizedBox(width: 20),
                              _loginBenefit(
                                Icons.flash_on,
                                'Cepat',
                              ),
                            ],
                          ),

                          const Spacer(),

                          const Text(
                            'UPN Veteran Jawa Timur',
                            style: TextStyle(
                              color: Color(0xFFFFDCD0),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================
                // RIGHT SIDE
                // =========================
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 55,
                      vertical: 45,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Masuk ke Akun',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1B19),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Masukkan akun civitas UPN kamu untuk melanjutkan.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7A665F),
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _authTextField(
                          hint: 'Masukkan email UPN',
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _authTextField(
                          hint: 'Masukkan password',
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),

                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Lupa password?',
                            style: TextStyle(
                              color: Color(0xFFA33900),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFA33900),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum punya akun?',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7A665F),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/register',
                                );
                              },
                              child: const Text(
                                'Daftar sekarang',
                                style: TextStyle(
                                  color: Color(0xFFA33900),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginBenefit(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _authTextField({
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return SizedBox(
      height: 46,
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9B8982),
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: Color(0xFF8C7770),
          ),
          filled: true,
          fillColor: const Color(0xFFFAF2EE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 1050,
            height: 680,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                // LEFT
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFA33900),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Color(0xFFA33900),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'LUWE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          const Text(
                            'Bergabung dengan\nLuwe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Nikmati kemudahan memesan makanan '
                            'dari berbagai kantin dan UMKM di '
                            'lingkungan UPN Veteran Jawa Timur.',
                            style: TextStyle(
                              color: Color(0xFFFFEDE5),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),

                          const Spacer(),

                          const Text(
                            'Khusus Civitas UPN Veteran Jawa Timur',
                            style: TextStyle(
                              color: Color(0xFFFFDCD0),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // RIGHT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 55,
                      vertical: 35,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buat Akun',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1B19),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Daftarkan dirimu sebagai civitas UPN.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7A665F),
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Nama Lengkap',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        _registerField(
                          'Masukkan nama lengkap',
                          Icons.person_outline,
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        _registerField(
                          'Masukkan email',
                          Icons.email_outlined,
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Jenis Civitas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF2EE),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text(
                                'Pilih jenis civitas',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9B8982),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Mahasiswa',
                                  child: Text('Mahasiswa'),
                                ),
                                DropdownMenuItem(
                                  value: 'Karyawan',
                                  child: Text('Karyawan'),
                                ),
                                DropdownMenuItem(
                                  value: 'Dosen',
                                  child: Text('Dosen'),
                                ),
                              ],
                              onChanged: (value) {},
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        _registerField(
                          'Buat password',
                          Icons.lock_outline,
                          obscure: true,
                        ),

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFA33900),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun?',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7A665F),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  color: Color(0xFFA33900),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerField(
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return SizedBox(
      height: 46,
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9B8982),
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: Color(0xFF8C7770),
          ),
          filled: true,
          fillColor: const Color(0xFFFAF2EE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
class TambahMenuPage extends StatefulWidget {
  const TambahMenuPage({super.key});

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  String? selectedCategory;

  final List<String> categories = [
    'Makanan Berat',
    'Snack & Kudapan',
    'Minuman',
    'Dessert',
    'Makanan Cepat',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF5A4138),
          ),
        ),

        title: const Row(
          children: [
            Icon(
              Icons.restaurant,
              color: Color(0xFFA33900),
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Tambah Menu',
              style: TextStyle(
                color: Color(0xFF1E1B19),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          80,
          40,
          80,
          60,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =========================
                // HEADER
                // =========================
                const Text(
                  'Kelola Menu',
                  style: TextStyle(
                    color: Color(0xFFA33900),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Tambah Menu Baru',
                  style: TextStyle(
                    color: Color(0xFF1E1B19),
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Tambahkan makanan atau minuman yang tersedia '
                  'di kantin kamu ke dalam Luwe.',
                  style: TextStyle(
                    color: Color(0xFF5A4138),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 32),

                // =========================
                // MAIN FORM
                // =========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEBDDD6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =========================
                      // LEFT : IMAGE
                      // =========================
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Foto Menu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1B19),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Container(
                              width: double.infinity,
                              height: 320,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF2EE),
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(
                                    0xFFEBDDD6,
                                  ),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration:
                                        BoxDecoration(
                                      color: const Color(
                                        0xFFFFE0D2,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(
                                        16,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .add_photo_alternate_outlined,
                                      size: 30,
                                      color: Color(
                                        0xFFA33900,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  const Text(
                                    'Upload Foto Menu',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: Color(
                                        0xFF1E1B19,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  const Text(
                                    'PNG, JPG atau JPEG',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                        0xFF8C7770,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons
                                          .cloud_upload_outlined,
                                      size: 17,
                                    ),
                                    label: const Text(
                                      'Pilih Foto',
                                    ),
                                    style: OutlinedButton
                                        .styleFrom(
                                      foregroundColor:
                                          const Color(
                                        0xFFA33900,
                                      ),
                                      side:
                                          const BorderSide(
                                        color: Color(
                                          0xFFA33900,
                                        ),
                                      ),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'Gunakan foto makanan yang jelas dan menarik.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8C7770),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 40),

                      // =========================
                      // RIGHT : FORM
                      // =========================
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Menu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w800,
                                color: Color(0xFF1E1B19),
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              'Nama Menu',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            _menuField(
                              'Contoh: Nasi Ayam Geprek',
                              Icons.restaurant_menu,
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFAF2EE,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child:
                                  DropdownButtonHideUnderline(
                                child:
                                    DropdownButton<String>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  hint: const Text(
                                    'Pilih kategori menu',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(
                                        0xFF9B8982,
                                      ),
                                    ),
                                  ),
                                  items: categories
                                      .map(
                                        (category) =>
                                            DropdownMenuItem<
                                                String>(
                                          value: category,
                                          child: Text(
                                            category,
                                            style:
                                                const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory =
                                          value;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      const Text(
                                        'Harga',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      _menuField(
                                        'Rp15.000',
                                        Icons
                                            .payments_outlined,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 18),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      const Text(
                                        'Stok',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      _menuField(
                                        'Contoh: 20',
                                        Icons
                                            .inventory_2_outlined,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Deskripsi Menu',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextField(
                              maxLines: 4,
                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Jelaskan menu, bahan, rasa, atau informasi lainnya...',
                                hintStyle:
                                    const TextStyle(
                                  fontSize: 13,
                                  color: Color(
                                    0xFF9B8982,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                  0xFFFAF2EE,
                                ),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                  borderSide:
                                      BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },
                                  style: OutlinedButton
                                      .styleFrom(
                                    foregroundColor:
                                        const Color(
                                      0xFF5A4138,
                                    ),
                                    side:
                                        const BorderSide(
                                      color: Color(
                                        0xFFE0D1CA,
                                      ),
                                    ),
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        999,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Batal',
                                  ),
                                ),

                                const SizedBox(width: 12),

                                ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Menu berhasil disimpan (simulasi)',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                    size: 17,
                                  ),
                                  label: const Text(
                                    'Simpan Menu',
                                  ),
                                  style: ElevatedButton
                                      .styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xFFA33900,
                                    ),
                                    foregroundColor:
                                        Colors.white,
                                    elevation: 0,
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        999,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuField(
    String hint,
    IconData icon,
  ) {
    return SizedBox(
      height: 48,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9B8982),
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: Color(0xFF8C7770),
          ),
          filled: true,
          fillColor: const Color(0xFFFAF2EE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
class FoodItem {
  final String name;
  final String category;
  final String price;
  final String description;
  final IconData icon;

  const FoodItem({
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.icon,
  });
}
class MenuLainnyaPage extends StatefulWidget {
  const MenuLainnyaPage({super.key});

  @override
  State<MenuLainnyaPage> createState() => _MenuLainnyaPageState();
}

class _MenuLainnyaPageState extends State<MenuLainnyaPage> {
  String selectedCategory = 'Semua';
  String searchQuery = '';

  final List<String> categories = [
    'Semua',
    'Makanan Berat',
    'Snack',
    'Minuman',
    'Dessert',
  ];

  final List<FoodItem> foods = const [
    FoodItem(
      name: 'Ayam Geprek',
      category: 'Makanan Berat',
      price: 'Rp15.000',
      description: 'Nasi putih, ayam goreng crispy, dan sambal geprek.',
      icon: Icons.rice_bowl,
    ),
    FoodItem(
      name: 'Nasi Goreng',
      category: 'Makanan Berat',
      price: 'Rp13.000',
      description: 'Nasi goreng dengan bumbu khas dan telur.',
      icon: Icons.dinner_dining,
    ),
    FoodItem(
      name: 'Mie Ayam',
      category: 'Makanan Berat',
      price: 'Rp12.000',
      description: 'Mie ayam dengan topping ayam berbumbu.',
      icon: Icons.ramen_dining,
    ),
    FoodItem(
      name: 'Kentang Goreng',
      category: 'Snack',
      price: 'Rp10.000',
      description: 'Kentang goreng renyah untuk camilan.',
      icon: Icons.fastfood,
    ),
    FoodItem(
      name: 'Es Teh',
      category: 'Minuman',
      price: 'Rp5.000',
      description: 'Minuman teh segar dengan es.',
      icon: Icons.local_cafe,
    ),
    FoodItem(
      name: 'Es Cokelat',
      category: 'Minuman',
      price: 'Rp8.000',
      description: 'Minuman cokelat dingin yang manis.',
      icon: Icons.local_drink,
    ),
    FoodItem(
      name: 'Puding Cokelat',
      category: 'Dessert',
      price: 'Rp7.000',
      description: 'Puding cokelat lembut sebagai hidangan penutup.',
      icon: Icons.icecream,
    ),
    FoodItem(
      name: 'Roti Bakar',
      category: 'Snack',
      price: 'Rp10.000',
      description: 'Roti panggang dengan isian cokelat.',
      icon: Icons.bakery_dining,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFoods = foods.where((food) {
      final matchesCategory = selectedCategory == 'Semua' ||
          food.category == selectedCategory;

      final matchesSearch = food.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1B19),
        elevation: 0,
        title: const Text(
          'Menu Lainnya',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jelajahi Menu',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1B19),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Temukan makanan favorit dari kantin dan UMKM kampus.',
              style: TextStyle(
                color: Color(0xFF5A4138),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // PENCARIAN
            SizedBox(
              width: 420,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama makanan...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFEBDDD6),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFEBDDD6),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // FILTER KATEGORI
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final active = selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: active,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      selectedColor: const Color(0xFFA33900),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: active
                            ? Colors.white
                            : const Color(0xFF5A4138),
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: active
                            ? const Color(0xFFA33900)
                            : const Color(0xFFEBDDD6),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              '${filteredFoods.length} menu ditemukan',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A4138),
              ),
            ),

            const SizedBox(height: 16),

            // DAFTAR MAKANAN
            Expanded(
              child: filteredFoods.isEmpty
                  ? const Center(
                      child: Text(
                        'Menu tidak ditemukan.',
                        style: TextStyle(
                          color: Color(0xFF5A4138),
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth >= 1000
                                ? 4
                                : constraints.maxWidth >= 650
                                    ? 3
                                    : 2;

                        return GridView.builder(
                          itemCount: filteredFoods.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.88,
                          ),
                          itemBuilder: (context, index) {
                            final food = filteredFoods[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailMenuPage(food: food),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEBDDD6),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1D4C6),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          food.icon,
                                          size: 54,
                                          color: const Color(0xFFA33900),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      food.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFA33900),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      food.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E1B19),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            food.price,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFA33900),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward,
                                          color: Color(0xFFA33900),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
class DetailMenuPage extends StatefulWidget {
  final FoodItem food;

  const DetailMenuPage({
    super.key,
    required this.food,
  });

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text(
          'Detail Menu',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1B19),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEBDDD6),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final image = Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1D4C6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    food.icon,
                    size: 100,
                    color: const Color(0xFFA33900),
                  ),
                );

                final information = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA33900),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1B19),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      food.price,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA33900),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Deskripsi Menu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF5A4138),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Jumlah Pesanan',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: quantity > 1
                              ? () {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFFA33900),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFFA33900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${food.name} sebanyak $quantity porsi '
                                'ditambahkan (simulasi).',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text(
                          'Tambah ke Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA33900),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                if (constraints.maxWidth >= 700) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: image),
                      const SizedBox(width: 32),
                      Expanded(child: information),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image,
                    const SizedBox(height: 28),
                    information,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}