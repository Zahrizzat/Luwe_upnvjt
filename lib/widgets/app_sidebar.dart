import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/buyer/store_verification_screen.dart';
import 'auth_guard_dialog.dart';
import 'luwe_logo.dart';

class AppSidebar extends StatelessWidget {
  final AppState state;
  final Function(int) onTabSelected;

  const AppSidebar({
    super.key,
    required this.state,
    required this.onTabSelected,
  });

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
    if (!state.isLoggedIn) {
      AuthGuardDialog.requireAuth(
        context,
        state,
        message: 'Masuk ke akun Luwe kamu untuk mendaftarkan dan mengajukan verifikasi stan kuliner.',
        onAuthenticated: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => StoreVerificationScreen(state: state)),
          );
        },
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => StoreVerificationScreen(state: state)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuyer = state.activeRole == UserRole.buyer;
    final isLoggedIn = state.isLoggedIn;
    final user = state.currentUser;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const LuweLogo(size: 40, compact: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'LuWe!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'UPNVJT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Kuliner Kampus Terpadu',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Role & Mode Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        isLoggedIn ? 'MODE APLIKASI' : 'STATUS PENGGUNA',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isLoggedIn) ...[
                      if (user.isSellerApproved)
                        InkWell(
                          onTap: () => state.toggleUserRole(),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isBuyer ? AppColors.cream : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isBuyer ? 'Ganti ke Toko' : 'Ganti ke Pembeli',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isBuyer ? AppColors.accentOrange : AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: () => _openStoreVerification(context),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: user.verificationStatus == StoreVerificationStatus.pending
                                  ? const Color(0xFFFFF8E1)
                                  : user.verificationStatus == StoreVerificationStatus.rejected
                                      ? const Color(0xFFFFEBEE)
                                      : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.verificationStatus == StoreVerificationStatus.pending
                                  ? 'Menunggu Verifikasi'
                                  : user.verificationStatus == StoreVerificationStatus.rejected
                                      ? 'Ditolak (Cek)'
                                      : 'Mulai Berjualan',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: user.verificationStatus == StoreVerificationStatus.pending
                                    ? const Color(0xFFFFA000)
                                    : user.verificationStatus == StoreVerificationStatus.rejected
                                        ? AppColors.error
                                        : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                    ] else ...[
                      InkWell(
                        onTap: () => _openLoginModal(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Masuk Akun',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      !isLoggedIn
                          ? Icons.person_outline_rounded
                          : (isBuyer ? Icons.school_rounded : Icons.storefront_rounded),
                      size: 16,
                      color: !isLoggedIn
                          ? AppColors.textMuted
                          : (isBuyer ? AppColors.primary : AppColors.secondaryRed),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      !isLoggedIn
                          ? 'Tamu (Guest)'
                          : (isBuyer ? 'Mahasiswa / Pembeli' : 'Penjual / Merchant F&B'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'MENU UTAMA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Navigation Links (Chat & Promosi temporarily disabled from UI)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: isBuyer
                  ? [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.storefront_outlined,
                        activeIcon: Icons.storefront_rounded,
                        label: 'Toko & Danusan',
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.restaurant_menu_rounded,
                        activeIcon: Icons.restaurant_rounded,
                        label: 'Katalog Semua Menu',
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long_rounded,
                        label: 'Pesanan Saya',
                        badge: isLoggedIn && state.orders.isNotEmpty ? '${state.orders.length}' : null,
                        requiresAuth: true,
                        authMessage: 'Masuk ke akun Luwe kamu untuk melihat daftar dan status pesanan kuliner.',
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.chat_bubble_outline_rounded,
                        activeIcon: Icons.chat_bubble_rounded,
                        label: 'Direct Message',
                        badge: isLoggedIn && state.totalUnreadMessages > 0 ? '${state.totalUnreadMessages}' : null,
                        badgeColor: AppColors.primaryRed,
                        requiresAuth: true,
                        authMessage: 'Masuk ke akun LuWe! kamu untuk membuka Direct Message.',
                      ),
                      _buildNavItem(
                        index: 4,
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profil Akun',
                      ),
                    ]
                  : [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.store_mall_directory_outlined,
                        activeIcon: Icons.store_mall_directory_rounded,
                        label: 'Dashboard Toko',
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.restaurant_menu_outlined,
                        activeIcon: Icons.restaurant_menu_rounded,
                        label: 'Kelola Menu & Stok',
                        badge: '${state.sellerMenuItems.length}',
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.shopping_bag_outlined,
                        activeIcon: Icons.shopping_bag_rounded,
                        label: 'Pesanan Masuk',
                        badge: state.activeSellerOrders.isNotEmpty ? '${state.activeSellerOrders.length} Baru' : '0',
                        badgeColor: state.activeSellerOrders.isNotEmpty ? AppColors.primary : const Color(0xFF94A3B8),
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.chat_bubble_outline_rounded,
                        activeIcon: Icons.chat_bubble_rounded,
                        label: 'Direct Message',
                        badge: state.totalUnreadMessages > 0 ? '${state.totalUnreadMessages}' : null,
                        badgeColor: AppColors.primaryRed,
                      ),
                    ],
            ),
          ),

          // User Profile Card at Bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
            ),
            child: isLoggedIn
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: NetworkImage(user.avatarUrl),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user.npm.isNotEmpty ? 'NPM: ${user.npm}' : user.email,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                        tooltip: 'Keluar dari Akun',
                        onPressed: () => state.logout(),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.surfaceMuted,
                        child: const Icon(Icons.person_rounded, size: 20, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tamu LuWe',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Belum masuk akun',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_add_rounded, size: 18, color: AppColors.primaryOrange),
                        tooltip: 'Daftar Akun Baru',
                        onPressed: () => _openRegisterModal(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.login_rounded, size: 18, color: AppColors.primary),
                        tooltip: 'Masuk ke Akun',
                        onPressed: () => _openLoginModal(context),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    String? badge,
    Color? badgeColor,
    bool requiresAuth = false,
    String? authMessage,
  }) {
    final isSelected = state.currentTabIndex == index;

    return Builder(
      builder: (context) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            selected: isSelected,
            selectedTileColor: AppColors.primaryLight.withValues(alpha: 0.5),
            leading: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            title: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            trailing: badge != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeColor != null ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              if (requiresAuth && !state.isLoggedIn) {
                AuthGuardDialog.requireAuth(
                  context,
                  state,
                  message: authMessage ?? 'Masuk ke akun Luwe kamu untuk melanjutkan.',
                  onAuthenticated: () => onTabSelected(index),
                );
              } else {
                onTabSelected(index);
              }
            },
          ),
        );
      },
    );
  }
}
