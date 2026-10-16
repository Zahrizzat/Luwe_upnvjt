import 'package:flutter/material.dart';

/// Centralized Design Tokens for LuWe! Campus Marketplace
/// Based on the official brand color palette (Warm reds, energetic oranges, and soft golden/cream neutrals)
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. Core Color Palette Tokens (Design System Specification)
  // ===========================================================================
  /// Primary Red: `#BE1E2D` - Tombol penting, elemen aktif, identitas visual aplikasi
  static const Color primaryRed = Color(0xFFBE1E2D);

  /// Secondary Red: `#D52F1E` - Variasi aksen, badge, elemen interaktif
  static const Color secondaryRed = Color(0xFFD52F1E);

  /// Accent Red-Orange: `#EE3D23` - Aksen dinamis, badge menonjol, tag
  static const Color accentRedOrange = Color(0xFFEE3D23);

  /// Primary Orange: `#FF6900` - Tombol aksi sekunder, penanda penting, elemen promosi
  static const Color primaryOrange = Color(0xFFFF6900);

  /// Accent Orange: `#CC501D` - Aksen hangat, penekanan teks/border oranye pekat
  static const Color accentOrange = Color(0xFFCC501D);

  /// Golden Yellow: `#F6D77D` - Banner promosi, highlight, bintang rating
  static const Color goldenYellow = Color(0xFFF6D77D);

  /// Amber Yellow: `#FBB936` - Highlight cerah, badge promo, rating aktif
  static const Color amberYellow = Color(0xFFFBB936);

  /// Pastel Yellow: `#F8EBAF` - Latar lembut pada kartu dan area informasi
  static const Color pastelYellow = Color(0xFFF8EBAF);

  /// Warm Yellow: `#F5CF72` - Aksen kartu, border highlight, container lembut
  static const Color warmYellow = Color(0xFFF5CF72);

  /// Cream: `#FFDEA0` - Latar lembut pada kartu, voucher, dan area info
  static const Color cream = Color(0xFFFFDEA0);

  /// Light Background: `#FFFFFF` - Latar putih bersih
  static const Color lightBackground = Color(0xFFFFFFFF);

  /// Soft Neutral Background: `#FAF9F6` - Latar netral hangat aplikasi
  static const Color softNeutral = Color(0xFFFAF9F6);

  // ===========================================================================
  // 2. Semantic Design Tokens & Theme Aliases
  // ===========================================================================
  /// Brand Primary (Primary Red #BE1E2D)
  static const Color primary = primaryRed;
  static const Color primaryHover = Color(0xFFA61523);
  static const Color primaryLight = Color(0xFFFDE8EA);
  static const Color primaryContainer = Color(0xFFFFF1F2);

  /// Brand Secondary (Secondary Red #D52F1E)
  static const Color secondary = secondaryRed;
  static const Color secondaryLight = Color(0xFFFEE8E6);
  static const Color secondaryDark = Color(0xFF8F150A);

  /// Secondary Action & Accent (Primary Orange #FF6900)
  static const Color secondaryAction = primaryOrange;
  static const Color secondaryActionHover = Color(0xFFE05C00);
  static const Color secondaryActionLight = Color(0xFFFFF0E6);

  /// Highlight & Promotions (Amber Yellow #FBB936 & Golden Yellow #F6D77D)
  static const Color tertiary = amberYellow;
  static const Color tertiaryLight = pastelYellow;

  /// Surfaces & Canvas
  static const Color canvas = softNeutral; // #FAF9F6
  static const Color surface = lightBackground; // #FFFFFF
  static const Color surfaceMuted = Color(0xFFF5F4F0);
  static const Color surfaceBorder = Color(0xFFE9E5DC);

  /// Text Hierarchy (Warm, high contrast readable dark stones)
  static const Color textPrimary = Color(0xFF1E1715);
  static const Color textSecondary = Color(0xFF5E544F);
  static const Color textMuted = Color(0xFF887D77);
  static const Color textLight = Color(0xFFAFA6A0);

  /// Functional Status Colors (Preserved for status integrity)
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = amberYellow;
  static const Color warningLight = pastelYellow;
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);
}
