# 🍊 LuWe! — Platform Promosi & Marketplace F&B Mahasiswa UPN "Veteran" Jawa Timur

**LuWe!** adalah platform marketplace makanan dan minuman berbasis Flutter untuk civitas akademika Universitas Pembangunan Nasional "Veteran" Jawa Timur. Platform ini dirancang untuk memudahkan mahasiswa, dosen, dan karyawan dalam menemukan serta memesan makanan dan minuman dari berbagai usaha mahasiswa maupun penjual di lingkungan kampus.

LuWe! juga membantu mahasiswa yang memiliki usaha makanan, minuman, atau danusan untuk mempromosikan produk dan mengelola penjualan secara digital.

---

## 👥 Tim Pengembang

| Nama | NPM | Peran |
|---|---|---|
| Abygail Evageline Warokka | 25082010198 | Captain |
| Annisa Salsabila | 25082010194 | Hustler |
| M. Asrul Mujahiddin | 25082010208 | Hacker |
| Zahrizzat Rahimi | 25082010212 | Hipster |

## 🎯 Tujuan Proyek

- Mempermudah civitas akademika dalam mencari makanan dan minuman di lingkungan kampus.
- Membantu mahasiswa mempromosikan usaha dan kegiatan danusan.
- Menyediakan sistem pemesanan makanan yang praktis dan terintegrasi.
- Membantu penjual mengelola produk, stok, pesanan, dan pendapatan.
- Mendorong digitalisasi kegiatan usaha mahasiswa di lingkungan UPN "Veteran" Jawa Timur.

## ✨ Fitur Utama

### 1. Beranda dan Katalog Pembeli
- Menampilkan berbagai toko makanan dan minuman yang tersedia.
- Menampilkan informasi toko, rating, dan produk.
- Banner utama menampilkan toko dengan rating tertinggi berdasarkan penilaian yang valid.
- Menyediakan pencarian toko dan produk serta filter kategori.
- Menampilkan produk berdasarkan toko yang dipilih.
- Mendukung penjelajahan katalog tanpa harus login terlebih dahulu.

### 2. Detail Toko dan Produk
- Menampilkan informasi toko dan daftar produk yang dijual.
- Menampilkan foto, nama, harga, stok, dan status ketersediaan produk.
- Menampilkan rating dan ulasan produk yang tersedia.
- Memastikan produk yang ditampilkan pada halaman detail toko sesuai dengan toko tersebut.

### 3. Autentikasi dan Profil Pengguna
- Registrasi dan login pengguna.
- Mendukung pengguna dengan peran pembeli dan penjual.
- Pengguna yang belum login tetap dapat menjelajahi katalog.
- Aksi yang membutuhkan akun akan mengarahkan pengguna untuk login.
- Profil pengguna mencakup informasi akun dan titik pengantaran favorit.

### 4. Keranjang dan Pemesanan
- Menambahkan produk ke keranjang.
- Melakukan checkout dan melihat rincian pesanan.
- Mendukung pilihan pengantaran atau pengambilan pesanan sesuai opsi yang tersedia.
- Mendukung pilihan pembayaran yang disediakan aplikasi, termasuk simulasi QRIS atau pembayaran tunai.
- Menampilkan status dan riwayat pesanan pembeli.

### 5. Dashboard Penjual
- Menampilkan ringkasan penjualan dan total omzet.
- Menampilkan informasi pesanan dan produk.
- Menyediakan pengelolaan menu dan stok.
- Menyediakan informasi saldo dan fitur penarikan saldo sesuai mekanisme aplikasi.

### 6. Menu dan Stok Berdasarkan Toko
Pengelolaan menu dan stok dirancang agar setiap penjual hanya dapat mengakses produk dari toko yang dikelolanya.

- **Pemisahan produk per toko:** produk dari berbagai toko tidak digabung dalam halaman pengelolaan milik satu penjual.
- **Tambah menu:** menambahkan produk baru ke toko yang dikelola.
- **Edit menu:** memperbarui nama, harga, foto, dan informasi produk.
- **Hapus menu:** menghapus produk sesuai kewenangan penjual.
- **Kelola stok:** memperbarui jumlah stok dan status ketersediaan produk.
- **Validasi kepemilikan:** memastikan penjual hanya dapat mengelola produk dari tokonya sendiri.
- **Empty state:** menampilkan informasi dan tombol tambah menu ketika toko belum memiliki produk.

Pemisahan data ini berlaku pada halaman pengelolaan penjual. Katalog pembeli tetap dapat menampilkan produk dari seluruh toko yang tersedia.

### 7. Verifikasi Toko
- Pengguna dapat mengajukan perubahan dari mode pembeli ke mode penjual.
- Pengguna perlu melalui proses verifikasi toko sebelum memperoleh akses pengelolaan penjual.
- Data toko dan kepemilikan produk digunakan untuk membatasi akses pengelolaan.

### 8. Rating dan Ulasan
- Pembeli dapat memberikan penilaian terhadap produk sesuai mekanisme aplikasi.
- Rating toko dihitung berdasarkan penilaian valid yang tersedia.
- Rating digunakan sebagai salah satu dasar penentuan toko pada banner utama.
- Apabila belum ada penilaian, aplikasi tidak menampilkan rating palsu.

### 9. Penarikan Saldo
- Penjual dapat mengajukan penarikan saldo melalui dashboard.
- Proses penarikan menggunakan data rekening yang telah diverifikasi sesuai implementasi aplikasi.
- Status penarikan ditampilkan sesuai proses yang tercatat.
- Estimasi proses penarikan mengikuti ketentuan yang ditampilkan aplikasi; estimasi 2–3 hari kerja bukan jaminan transfer selesai.
- Transaksi saldo harus divalidasi agar tidak terjadi pengurangan saldo ganda atau transaksi yang tidak konsisten.

## 🏪 Alur Penggunaan

### Pembeli
1. Membuka aplikasi LuWe!.
2. Menjelajahi toko dan produk yang tersedia.
3. Memilih toko untuk melihat menu yang dijual.
4. Memilih produk dan memasukkannya ke keranjang.
5. Login apabila diperlukan untuk melanjutkan pemesanan.
6. Melakukan checkout dan memilih metode pengantaran atau pengambilan.
7. Memilih metode pembayaran yang tersedia.
8. Memantau status dan riwayat pesanan.

### Penjual
1. Mendaftar atau login ke aplikasi.
2. Mengajukan verifikasi toko.
3. Mengakses dashboard setelah memperoleh akses penjual.
4. Menambahkan serta mengelola menu dan stok milik tokonya sendiri.
5. Memantau pesanan, penjualan, dan total omzet.
6. Mengajukan penarikan saldo sesuai ketentuan aplikasi.

## 🛠️ Teknologi yang Digunakan

- **Flutter** — pengembangan antarmuka aplikasi.
- **Dart** — bahasa pemrograman utama.
- **Database SQL** — penyimpanan data sesuai konfigurasi proyek.
- **State Management** — pengelolaan state aplikasi sesuai implementasi proyek.

> Catatan: Detail database, backend, dan library yang digunakan mengikuti konfigurasi aktual dalam repository.

## 📂 Struktur Proyek

Struktur berikut merupakan gambaran pengelompokan kode yang digunakan atau dituju dalam pengembangan LuWe!. Nama folder dan file perlu disesuaikan dengan struktur aktual repository.

```text
luwe_app/
├── lib/
│   ├── constants/
│   ├── models/
│   ├── providers/
│   ├── widgets/
│   ├── screens/
│   │   ├── buyer/
│   │   └── seller/
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

## 🚀 Cara Menjalankan Proyek

Pastikan Flutter SDK telah terpasang dan konfigurasi database/backend yang diperlukan sudah tersedia.

1. Clone repository:

```bash
git clone <URL_REPOSITORY>
```

2. Masuk ke direktori proyek:

```bash
cd luwe_app
```

3. Unduh dependensi:

```bash
flutter pub get
```

4. Periksa konfigurasi aplikasi dan koneksi database sesuai lingkungan pengembangan.

5. Jalankan aplikasi pada perangkat atau target yang didukung:

```bash
flutter run
```

Untuk menjalankan aplikasi pada browser atau desktop, pastikan target Flutter yang sesuai telah diaktifkan dan dikonfigurasi.

## 🧪 Pengujian

Pengujian dilakukan untuk memastikan fitur utama berjalan sesuai kebutuhan, antara lain:

- Registrasi, login, dan akses pengguna.
- Penjelajahan katalog dan detail toko.
- Pemesanan dan riwayat pesanan.
- Pengelolaan produk serta stok.
- Pemisahan produk berdasarkan toko dan akun penjual.
- Validasi akses saat menambah, mengedit, atau menghapus produk.
- Penghitungan omzet dan proses penarikan saldo.
- Penentuan banner berdasarkan rating toko.
- Tampilan loading, empty state, dan penanganan kesalahan.

Perintah pemeriksaan Flutter:

```bash
flutter analyze
flutter test
```

Hasil pengujian perlu dicatat berdasarkan eksekusi aktual pada repository.

## 🔒 Keamanan dan Konsistensi Data

- Penjual hanya dapat mengelola produk dari toko yang menjadi kewenangannya.
- Validasi kepemilikan produk dilakukan sesuai mekanisme backend atau database yang digunakan.
- Operasi stok dan saldo harus menjaga konsistensi data.
- Data toko dan produk yang sudah ada tidak boleh terhapus hanya karena penambahan data contoh.
- Data demonstrasi perlu dibedakan dari data pengguna sebenarnya.

## 📌 Status Proyek

LuWe! dikembangkan sebagai proyek marketplace F&B untuk lingkungan kampus UPN "Veteran" Jawa Timur. Pengembangan mencakup katalog pembeli, pemesanan, pengelolaan toko, produk dan stok, serta dashboard penjual.

Fitur dan status implementasi akhir mengikuti kode yang tersedia pada repository.

---

**LuWe! — Temukan, Pesan, dan Dukung Usaha Mahasiswa di Kampus.** 🍊