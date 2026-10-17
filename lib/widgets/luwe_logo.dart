import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Official LuWe! Brand Logo Component
/// Displays "LuWe!" with the brand color palette (Primary Red, Secondary Red gradient,
/// crisp white typography, and vibrant Amber/Golden Yellow exclamation mark).
/// Never uses abbreviations like "LW" or "ULW".
class LuweLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  final bool compact;

  const LuweLogo({
    super.key,
    this.size = 40,
    this.showSubtitle = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeWidth = compact ? (size * 1.8) : (size * 2.2);
    final badgeHeight = size;
    final fontSize = size * 0.46;

    final logoBadge = Container(
      width: badgeWidth,
      height: badgeHeight,
      padding: EdgeInsets.symmetric(horizontal: size * 0.18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryRed,
            AppColors.secondaryRed,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColors.goldenYellow.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'LuWe',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: fontSize,
                  letterSpacing: -0.5,
                  fontFamily: 'Inter',
                ),
              ),
              TextSpan(
                text: '!',
                style: TextStyle(
                  color: AppColors.amberYellow,
                  fontWeight: FontWeight.w900,
                  fontSize: fontSize * 1.15,
                  letterSpacing: -0.5,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!showSubtitle) {
      return logoBadge;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoBadge,
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'LuWe',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: '!',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'UPN "Veteran" Jawa Timur',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
