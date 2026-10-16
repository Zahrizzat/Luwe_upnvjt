import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'store_verification_screen.dart';
import '../../models/delivery_location_model.dart';

class ProfileScreen extends StatelessWidget {
  final AppState state;

  const ProfileScreen({super.key, required this.state});

  void _openLoginModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LoginScreen(state: state),
          ),
        ),
      ),
    );
  }

  void _openRegisterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: RegisterScreen(state: state),
          ),
        ),
      ),
    );
  }

  void _openStoreVerification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => StoreVerificationScreen(state: state)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!state.isLoggedIn) {
      return _buildGuestProfile(context);
    }

    final user = state.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Profil Akun Civitas UPNVJT',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kelola identitas civitas akademika, preferensi pemesanan, dan mode akun.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 10),
                            CampusBadge.verified(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.npm.isNotEmpty
                              ? 'NPM: ${user.npm} • ${user.studyProgram} (${user.faculty})'
                              : '${user.studyProgram} (${user.faculty})',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user.email} • ${user.phoneNumber}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seller Verification / Store Status Section
            _buildStoreStatusCard(context, user),
            const SizedBox(height: 24),

            // Delivery favorites card
            _buildDeliveryLocationsSection(context, state),
            const SizedBox(height: 24),

            // Settings & Security
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PENGATURAN AKUN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textLight)),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    title: const Text('Notifikasi Pesanan Masuk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: Switch(value: true, onChanged: (v) {}, activeThumbColor: AppColors.primary),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: const Text('Keluar dari Akun (Logout)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => state.logout(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Store Management Card inside Profile
  Widget _buildStoreStatusCard(BuildContext context, UserModel user) {
    if (user.isSellerApproved) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldenYellow),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cream),
              ),
              child: const Icon(Icons.storefront_rounded, color: AppColors.primaryRed, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.storeName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryRed),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Terverifikasi', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lokasi: ${user.storeLocation} • Toko Aktif',
                    style: const TextStyle(fontSize: 12, color: AppColors.accentOrange, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                state.toggleUserRole();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: Text(
                state.activeRole == UserRole.buyer ? 'Masuk ke Mode Penjual' : 'Kembali ke Pembeli',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
    }

    if (user.verificationStatus == StoreVerificationStatus.pending) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.pastelYellow.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldenYellow),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hourglass_top_rounded, color: AppColors.amberYellow, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengajuan Toko: ${user.storeName}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sedang ditinjau oleh tim verifikasi kantin UPNVJT (Menunggu Verifikasi).',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _openStoreVerification(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentOrange,
                side: const BorderSide(color: AppColors.amberYellow),
              ),
              child: const Text('Cek Status Toko', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    if (user.verificationStatus == StoreVerificationStatus.rejected) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengajuan Toko Belum Disetujui',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFB71C1C)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.rejectionReason ?? 'Ketuk untuk melihat alasan penolakan dan perbaiki formulir.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFC62828)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _openStoreVerification(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Perbaiki Data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    // Belum mengajukan (None)
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingin Berjualan di Kampus?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Ajukan stan kuliner kantin Anda dan mulai terima pesanan dari ribuan mahasiswa.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _openStoreVerification(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Mulai Berjualan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // Guest Profile View
  Widget _buildGuestProfile(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil Pengguna LuWe!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Akses akun civitas akademika UPN "Veteran" Jawa Timur.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Guest Welcome Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.person_outline_rounded, size: 36, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Halo, Tamu Civitas UPNVJT!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Anda sedang menjelajahi katalog kuliner LuWe! sebagai Tamu. Masuk atau daftarkan akun Anda untuk memesan makanan, menyimpan menu favorit, melihat riwayat pesanan, serta mendaftar sebagai mitra stan penjual.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openLoginModal(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Masuk ke Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 14),
                      OutlinedButton.icon(
                        onPressed: () => _openRegisterModal(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.person_add_rounded, size: 18),
                        label: const Text('Daftar Akun Baru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryLocationsSection(BuildContext context, AppState state) {
    final locations = state.deliveryLocations;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.place_rounded, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Titik Pengantaran Favorit di Kampus',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showLocationFormModal(context, state),
                icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                label: const Text('Tambah Titik', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (locations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  const Icon(Icons.location_off_outlined, size: 36, color: AppColors.textLight),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum ada titik pengantaran favorit tersimpan',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Simpan lokasi fakultas, gedung kuliah, atau lab agar lebih cepat saat memesan makanan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => _showLocationFormModal(context, state),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Tambah Titik Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            )
          else
            ...locations.map((loc) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: loc.isPrimary ? const Color(0xFFF0FDF4) : AppColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: loc.isPrimary ? const Color(0xFF86EFAC) : AppColors.surfaceBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: loc.isPrimary ? AppColors.secondaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.place_rounded,
                        size: 20,
                        color: loc.isPrimary ? AppColors.secondaryDark : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                loc.title,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              if (loc.isPrimary) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Utama',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondaryDark),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${loc.areaName} • ${loc.detailAddress}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          if (loc.deliveryNote != null && loc.deliveryNote!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Catatan kurir: "${loc.deliveryNote}"',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
                      onSelected: (val) async {
                        if (val == 'primary' && loc.id != null) {
                          await state.setPrimaryDeliveryLocation(loc.id!);
                        } else if (val == 'edit') {
                          _showLocationFormModal(context, state, location: loc);
                        } else if (val == 'delete' && loc.id != null) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Titik Pengantaran?'),
                              content: Text('Yakin ingin menghapus titik "${loc.title}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await state.deleteDeliveryLocation(loc.id!);
                          }
                        }
                      },
                      itemBuilder: (ctx) => [
                        if (!loc.isPrimary && loc.id != null)
                          const PopupMenuItem(
                            value: 'primary',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, size: 16, color: AppColors.secondary),
                                SizedBox(width: 8),
                                Text('Jadikan Titik Utama', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                              SizedBox(width: 8),
                              Text('Edit Titik', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Hapus', style: TextStyle(fontSize: 12, color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showLocationFormModal(BuildContext context, AppState state, {DeliveryLocationModel? location}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: location?.title ?? '');
    final detailController = TextEditingController(text: location?.detailAddress ?? '');
    final noteController = TextEditingController(text: location?.deliveryNote ?? '');
    String selectedArea = location?.areaName ?? 'Gedung Giri Santoso';
    bool isPrimary = location?.isPrimary ?? (state.deliveryLocations.isEmpty);

    final areaList = [
      'Gedung Giri Santoso',
      'Gedung Giri Reksa',
      'FIK - Fakultas Ilmu Komputer',
      'FEB - Fakultas Ekonomi & Bisnis',
      'FT - Fakultas Teknik',
      'FP - Fakultas Pertanian',
      'FISIP - Fak. Ilmu Sosial & Ilmu Politik',
      'FAD - Arsitektur & Desain',
      'FH - Fakultas Hukum',
      'Gedung Rektorat UPNVJT',
      'Kantin Barat & Gazebo',
      'Pos Satpam Pintu Utama',
      'Lainnya',
    ];

    if (!areaList.contains(selectedArea)) {
      areaList.insert(0, selectedArea);
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              location == null ? 'Tambah Titik Favorit' : 'Edit Titik Pengantaran',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        const Text('Nama Titik / Label', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Lab RPL FIK, Pos Satpam, Ruang Kelas 302',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nama titik wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        // Area
                        const Text('Area / Gedung Kampus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedArea,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: areaList.map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) setStateModal(() => selectedArea = val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Detail address
                        const Text('Detail Lokasi & Lantai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: detailController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Lantai 2, Depan Pintu Lab Riset RPL',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Detail lokasi wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        // Notes
                        const Text('Catatan untuk Kurir (Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: noteController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Titip di lobi satpam jika saya sedang ada ujian',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Is Primary checkbox
                        SwitchListTile(
                          value: isPrimary,
                          onChanged: (val) => setStateModal(() => isPrimary = val),
                          title: const Text('Jadikan Titik Utama', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          subtitle: const Text('Dipilih otomatis ketika checkout', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.primary,
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              Navigator.pop(ctx);

                              if (location == null) {
                                await state.addDeliveryLocation(
                                  title: titleController.text.trim(),
                                  areaName: selectedArea,
                                  detailAddress: detailController.text.trim(),
                                  deliveryNote: noteController.text.trim(),
                                  isPrimary: isPrimary,
                                );
                              } else {
                                await state.updateDeliveryLocation(
                                  locationId: location.id!,
                                  title: titleController.text.trim(),
                                  areaName: selectedArea,
                                  detailAddress: detailController.text.trim(),
                                  deliveryNote: noteController.text.trim(),
                                  isPrimary: isPrimary,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(location == null ? 'Simpan Titik Pengantaran' : 'Perbarui Titik', style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

