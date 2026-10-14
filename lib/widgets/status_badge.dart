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
    this.backgroundColor = AppColors.secondaryLight,
    this.textColor = AppColors.secondary,
    this.borderColor,
  });

  factory CampusBadge.verified() {
    return const CampusBadge(
      text: 'UPNVJT Terverifikasi',
      icon: Icons.verified_rounded,
      backgroundColor: AppColors.secondaryLight,
      textColor: AppColors.secondary,
      borderColor: Color(0xFFBBF7D0),
    );
  }

  factory CampusBadge.halal() {
    return const CampusBadge(
      text: 'Halal',
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: Color(0xFFF0FDF4),
      textColor: AppColors.secondaryDark,
      borderColor: Color(0xFFBBF7D0),
    );
  }

  factory CampusBadge.readyStock() {
    return const CampusBadge(
      text: 'Ready Stock',
      icon: Icons.radio_button_checked_rounded,
      backgroundColor: Color(0xFFDCFCE7),
      textColor: AppColors.secondary,
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
      backgroundColor: AppColors.primaryLight,
      textColor: AppColors.primary,
      borderColor: const Color(0xFFFED7AA),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
