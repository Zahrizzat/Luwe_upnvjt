# LuWe! — Platform Promosi & Marketplace F&B Mahasiswa UPN "Veteran" Jawa Timur


Aplikasi Flutter Desktop & Web modern untuk memfasilitasi wirausaha kuliner mahasiswa dan mempermudah civitas akademika UPN "Veteran" Jawa Timur (UPNVJT) dalam mencari, memesan, serta mengantarkan makanan/minuman langsung ke gedung kuliah atau kantin kampus.

---

## 👨‍💻 Tim Pengembang

Aplikasi **LuWe!** dikembangkan oleh mahasiswa sebagai proyek pengembangan aplikasi yang berfokus pada promosi dan marketplace makanan dan minuman di lingkungan Universitas Pembangunan Nasional “Veteran” Jawa Timur (UPNVJT).

Tim pengembang menggunakan pembagian peran berdasarkan pendekatan **Startup Team Roles**, yaitu Captain, Hustler, Hacker, dan Hipster.

| Nama | NPM | Peran |
|---|---|---|
| Abygail Evageline Warokka | 25082010198 | **Captain** — Memimpin tim, mengoordinasikan pekerjaan, dan memastikan tujuan proyek tercapai. |
| Annisa Salsabila | 25082010194 | **Hustler** — Berfokus pada strategi bisnis, kebutuhan pengguna, dan pengembangan nilai produk. |
| M. Asrul Mujahiddin | 25082010208 | **Hacker** — Berfokus pada pengembangan teknis, pemrograman, dan implementasi fungsionalitas aplikasi. |
| Zahrizzat Rahimi | 25082010212 | **Hipster** — Berfokus pada desain UI/UX, konsistensi visual, dan pengalaman pengguna. |

### 🤝 Kolaborasi Tim

Setiap anggota berkontribusi sesuai perannya untuk mengembangkan LuWe! menjadi platform digital yang dapat membantu mahasiswa memasarkan usaha kuliner sekaligus memudahkan civitas akademika UPNVJT dalam mencari dan memesan makanan serta minuman.

**Dikembangkan oleh mahasiswa Sistem Informasi — UPN “Veteran” Jawa Timur.**

---

## 🚀 Fitur Utama Sesuai Dokumen Kebutuhan Produk (PRD)

### 1. Dual Role System (Pembeli & Penjual)
* **Mahasiswa / Pembeli (Hafidz)**:
  * **Beranda Discovery**: Banner promo kampus, filter cepat kategori kuliner, rekomendasi menu terlaris.
  * **Jelajah Katalog**: Pencarian instan (*Ctrl+K*), filter lokasi kantin/fakultas (Kantin Giri Reksa, Giri Santoso, Gedung FIK, FEB, FT, FAD, FISIP, FH).
  * **Detail Menu & Kustomisasi**: Pilihan level kepedasan (Level 0 s/d Level 3), catatan pesanan khusus (*sambal dipisah, kuah banyak*), counter porsi.
  * **Keranjang & Checkout Kampus**:
    * Pilihan metode: **Ambil di Kantin** atau **Kirim ke Gedung Kuliah** (misal: *Gedung Giri Santoso Lt. 2 - Depan Lab RPL*).
    * Biaya layanan kampus otomatis: **Rp 1.000**.
    * Pilihan pembayaran: **Generative QRIS** (dengan QR code dialog & simulasi verifikasi instan) atau **Tunai/Cash saat Terima**.
  * **Lacak Status Pesanan (Realtime Stepper)**: Menunggu Konfirmasi ➔ Sedang Dimasak ➔ Siap Diantar / Diambil ➔ Selesai.
  * **Direct Chat & Diskusi**: Komunikasi langsung antara pembeli dan penjual disertai template pesan kilat.
  * **Profil Mahasiswa**: Identitas NPM, Fakultas, Program Studi, dan alamat favorit pengantaran.

* **Wirausaha Mahasiswa / Penjual (Adistya - Warung Sambal Kampus UPN)**:
  * **Dashboard Toko**: Statistik omzet, jumlah pesanan aktif, total menu, rating toko, toggle switch **Toko Buka / Tutup**.
  * **Kelola Menu & Stok**: Ubah status ketersediaan (*Ready Stock* / *Habis*) secara instan dengan satu kali klik.
  * **Tambah Menu Baru**: Modal penambahan menu dengan input nama, kategori, harga Rp, deskripsi, dan foto.
  * **Pesanan Masuk**: Konfirmasi pesanan masuk (Terima & Mulai Masak / Tolak), pembaruan status pengantaran hingga selesai.
  * **Kelola Promosi**: Banner potongan harga mahasiswa dan voucher diskon.

---

## 🎨 Design System & Estetika (Desktop-First)
* **Warna Brand**:
  * **Primary**: `#EA580C` *(Sambal Orange)* — Hangat, menggugah selera, energetic.
  * **Secondary**: `#15803D` *(Daun Pandan Green)* — Identitas kampus, verifikasi mahasiswa UPNVJT.
  * **Tertiary**: `#D97706` *(Kunyit Gold)* — Promo & rating bintang.
  * **Canvas & Surface**: `#FAF9F6` *(Warm Rice White)* & `#FFFFFF` dengan shadow lembut.
* **Layout Desktop**:
  * Sidebar navigasi permanen di sisi kiri (`260px`) dengan badge notifikasi & quick role switcher.
  * Top navigation bar (`72px`) dengan pencarian global, filter lokasi gedung fakultas, dan drawer keranjang.
  * Grid responsif untuk card makanan beresolusi tinggi dengan indikator stok & badge verifikasi.

---

## 📂 Struktur File Projek

```
luwe_app/
├── lib/
│   ├── constants/
│   │   ├── app_colors.dart          # Palet warna brand LuWe & UPNVJT
│   │   └── app_theme.dart           # Konfigurasi ThemeData Material 3
│   ├── models/
│   │   ├── user_model.dart          # Model Mahasiswa & Merchant
│   │   ├── menu_item_model.dart     # Model Menu Kuliner & Stok
│   │   ├── cart_item_model.dart     # Model Item Keranjang
│   │   ├── order_model.dart         # Model Pesanan & Metode Antar
│   │   ├── chat_message_model.dart  # Model Pesan Direct Message
│   │   └── promotion_model.dart     # Model Promosi & Voucher
│   ├── providers/
│   │   └── app_state.dart           # State Management reaktif (ChangeNotifier)
│   ├── widgets/
│   │   ├── app_sidebar.dart         # Sidebar navigasi desktop
│   │   ├── app_top_bar.dart         # Header bar pencarian & lokasi
│   │   ├── food_card.dart           # Komponen kartu makanan & tombol pesan
│   │   ├── product_detail_dialog.dart # Modal kustomisasi menu & level pedas
│   │   ├── cart_drawer.dart         # Drawer keranjang & pemilihan metode antar
│   │   ├── qris_dialog.dart         # Modal QRIS generatif & simulasi pembayaran
│   │   └── status_badge.dart        # Badge verifikasi, halal & stok
│   ├── screens/
│   │   ├── main_shell.dart          # Shell utama desktop (Sidebar + TopBar + Body)
│   │   ├── buyer/
│   │   │   ├── discovery_screen.dart # Beranda Discovery & Rekomendasi
│   │   │   ├── explore_screen.dart   # Jelajah Katalog & Multi-Filter
│   │   │   ├── orders_screen.dart    # Riwayat & Pelacakan Pesanan
│   │   │   ├── chat_screen.dart      # Chat Pembeli ke Penjual
│   │   │   └── profile_screen.dart   # Profil Mahasiswa & Pengaturan
│   │   └── seller/
│   │       ├── seller_dashboard_screen.dart # Dashboard Penjual & Omzet
│   │       ├── seller_menu_screen.dart      # Kelola Menu & Stok Instan
│   │       ├── seller_orders_screen.dart    # Pesanan Masuk & Proses Memasak
│   │       └── seller_promos_screen.dart    # Banner Promosi & Diskon
│   └── main.dart                    # Entry point aplikasi
└── test/
    └── widget_test.dart             # Unit & State test suite
```

---

## 💻 Cara Menjalankan Aplikasi

Pastikan berada di folder projek:
```bash
cd "C:\Users\moklet 1\.gemini\antigravity-ide\scratch\luwe-campus-marketplace\luwe_app"
```

### 1. Jalankan di Desktop Windows:
```bash
flutter run -d windows
```

### 2. Jalankan di Browser (Chrome / Edge):
```bash
flutter run -d chrome
```

### 3. Menjalankan Pengujian Otomatis (Unit & State Tests):
```bash
flutter test
```
