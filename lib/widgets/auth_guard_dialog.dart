import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../providers/app_state.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

class AuthGuardDialog extends StatelessWidget {
  final AppState state;
  final String message;
  final VoidCallback? onAuthenticated;

  const AuthGuardDialog({
    super.key,
    required this.state,
    this.message = 'Masuk ke akun Luwe kamu untuk melanjutkan aktivitas ini.',
    this.onAuthenticated,
  });

  static Future<bool> requireAuth(
    BuildContext context,
    AppState state, {
    String message = 'Masuk ke akun Luwe kamu untuk melanjutkan pesanan.',
    VoidCallback? onAuthenticated,
  }) async {
    if (state.isLoggedIn) {
      onAuthenticated?.call();
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AuthGuardDialog(
        state: state,
        message: message,
        onAuthenticated: onAuthenticated,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_person_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Perlu Masuk Akun',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Description Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              // 1. Masuk
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    await showDialog(
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
                    if (state.isLoggedIn) {
                      onAuthenticated?.call();
                    }
                  },
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text(
                    'Masuk Sekarang',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Daftar Akun
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    await showDialog(
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
                    if (state.isLoggedIn) {
                      onAuthenticated?.call();
                    }
                  },
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 3. Nanti Saja
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Nanti Saja',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
