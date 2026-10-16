import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CampusBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const CampusBadge({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor = AppColors.cream,
    this.textColor = AppColors.primaryRed,
    this.borderColor,
  });

  factory CampusBadge.verified() {
    return const CampusBadge(
      text: 'UPNVJT Terverifikasi',
      icon: Icons.verified_rounded,
      backgroundColor: AppColors.cream,
      textColor: AppColors.primaryRed,
      borderColor: AppColors.goldenYellow,
    );
  }

  factory CampusBadge.halal() {
    return const CampusBadge(
      text: 'Halal',
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppColors.surfaceMuted,
      textColor: AppColors.textSecondary,
      borderColor: AppColors.surfaceBorder,
    );
  }

  factory CampusBadge.readyStock() {
    return const CampusBadge(
      text: 'Ready Stock',
      icon: Icons.radio_button_checked_rounded,
      backgroundColor: AppColors.successLight,
      textColor: AppColors.success,
      borderColor: Color(0xFF86EFAC),
    );
  }

  factory CampusBadge.outOfStock() {
    return const CampusBadge(
      text: 'Habis Hari Ini',
      icon: Icons.cancel_outlined,
      backgroundColor: AppColors.errorLight,
      textColor: AppColors.error,
      borderColor: Color(0xFFFCA5A5),
    );
  }

  factory CampusBadge.promo(String text) {
    return CampusBadge(
      text: text,
      icon: Icons.local_fire_department_rounded,
      backgroundColor: AppColors.pastelYellow,
      textColor: AppColors.accentOrange,
      borderColor: AppColors.goldenYellow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor ?? backgroundColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
