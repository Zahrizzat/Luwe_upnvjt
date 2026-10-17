import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'store_verification_screen.dart';
import '../seller/edit_store_profile_dialog.dart';

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

            // Titik pengantaran favorit dihapus sesuai revisi LuWe!
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
                    'Fakultas: ${(user.storeFaculty?.isNotEmpty ?? false) ? user.storeFaculty : user.faculty} • Lokasi: ${user.storeLocation}',
                    style: const TextStyle(fontSize: 12, color: AppColors.accentOrange, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => EditStoreProfileDialog(state: state),
                    );
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Edit Toko & Profil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: const BorderSide(color: AppColors.primaryRed),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
}