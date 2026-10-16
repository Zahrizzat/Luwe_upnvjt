import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import 'auth_guard_dialog.dart';

class AppTopBar extends StatelessWidget {
  final AppState state;
  final VoidCallback onOpenCart;

  const AppTopBar({
    super.key,
    required this.state,
    required this.onOpenCart,
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

  @override
  Widget build(BuildContext context) {
    final isBuyer = state.activeRole == UserRole.buyer;
    final isLoggedIn = state.isLoggedIn;
    final user = state.currentUser;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 3,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: TextField(
                onChanged: (val) => state.setSearchQuery(val),
                decoration: const InputDecoration(
                  hintText: 'Cari nama toko, danusan, menu makanan, atau kategori...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                  suffixIcon: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Ctrl+K',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Campus Faculty / Building Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.selectedFaculty,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Semua Lokasi', child: Text('Semua Fakultas & Kantin')),
                      DropdownMenuItem(value: 'FIK', child: Text('Fakultas Ilmu Komputer (FIK)')),
                      DropdownMenuItem(value: 'FEB', child: Text('Fakultas Ekonomi & Bisnis (FEB)')),
                      DropdownMenuItem(value: 'FT', child: Text('Fakultas Teknik (FT)')),
                      DropdownMenuItem(value: 'FISIP', child: Text('Fakultas Ilmu Sosial & Politik (FISIP)')),
                      DropdownMenuItem(value: 'FAD', child: Text('Fakultas Arsitektur & Desain (FAD)')),
                      DropdownMenuItem(value: 'Giri Reksa', child: Text('Kantin Giri Reksa')),
                      DropdownMenuItem(value: 'Santoso', child: Text('Kantin Giri Santoso')),
                    ],
                    onChanged: (val) {
                      if (val != null) state.setSelectedFaculty(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Store Open Toggle for Seller
          if (!isBuyer) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.isStoreOpen ? AppColors.secondaryLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: user.isStoreOpen ? AppColors.secondary : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.isStoreOpen ? 'Toko Buka' : 'Toko Tutup',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: user.isStoreOpen ? AppColors.secondaryDark : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Switch(
                    value: user.isStoreOpen,
                    onChanged: (v) => state.toggleStoreStatus(),
                    activeThumbColor: AppColors.secondary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          // If Guest: Show "Masuk" and "Daftar" buttons
          if (!isLoggedIn) ...[
            OutlinedButton.icon(
              onPressed: () => _openLoginModal(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text('Masuk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _openRegisterModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.person_add_rounded, size: 16),
              label: const Text('Daftar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
          ],

          // Cart Button (Buyer Mode or Guest)
          if (isBuyer)
            ElevatedButton.icon(
              onPressed: () {
                if (!isLoggedIn) {
                  AuthGuardDialog.requireAuth(
                    context,
                    state,
                    message: 'Masuk ke akun Luwe kamu untuk melihat keranjang dan menyelesaikan pesanan.',
                    onAuthenticated: onOpenCart,
                  );
                } else {
                  onOpenCart();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn ? AppColors.primary : AppColors.surfaceMuted,
                foregroundColor: isLoggedIn ? Colors.white : AppColors.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isLoggedIn ? BorderSide.none : const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 18, color: isLoggedIn ? Colors.white : AppColors.textSecondary),
                  if (state.cartCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isLoggedIn ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${state.cartCount}',
                          style: TextStyle(
                            color: isLoggedIn ? AppColors.primary : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: Text(
                state.cartCount > 0
                    ? 'Keranjang (Rp ${state.cartTotal})'
                    : 'Keranjang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLoggedIn ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
