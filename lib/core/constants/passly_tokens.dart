import 'package:flutter/material.dart';

// Figma "Passly" ファイルの Variables (DTCG フォーマット) から機械的に反映。
// 既存の AppColors とは並列に存在させ、置換は段階的に行う。

// ─── Color ─────────────────────────────────────────────

/// Active / Primary Action / Presence
abstract final class PasslyBrand {
  static const Color primary = Color(0xFF3AAA3A);
  static const Color primaryLight = Color(0xFF6BD168);
  static const Color primaryDark = Color(0xFF1E7F1E);
  static const Color primarySurface = Color(0xFFE8F7E8);
  static const Color primaryMuted = Color(0xFFC7E9C7);
}

abstract final class PasslyBg {
  /// App background
  static const Color defaultBg = Color(0xFFF6F7F9);

  /// Card / sheet surface
  static const Color surface = Color(0xFFFFFFFF);

  /// Inset / search field
  static const Color elevated = Color(0xFFF2F4F6);

  /// Passly moment background
  static const Color soft = Color(0xFFF0FFF2);
}

abstract final class PasslyText {
  static const Color primary = Color(0xFF111827);
  static const Color secondary = Color(0xFF6B7280);
  static const Color tertiary = Color(0xFF9CA3AF);
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color onBrand = Color(0xFFFFFFFF);
}

abstract final class PasslyBorder {
  static const Color defaultBorder = Color(0xFFE5E7EB);
  static const Color strong = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFEEF0F2);
}

abstract final class PasslyState {
  static const Color success = Color(0xFF3AAA3A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color focus = Color(0xFFC7E9C7);
}

abstract final class PasslyPresence {
  static const Color online = Color(0xFF3AAA3A);
  static const Color offline = Color(0xFF9CA3AF);
  static const Color busy = Color(0xFFEF4444);
  static const Color away = Color(0xFFF59E0B);
  static const Color invisible = Color(0xFFFFFFFF);
}

abstract final class PasslyAchievement {
  static const Color common = Color(0xFFB7E5B4);
  static const Color rare = Color(0xFF7CC4FF);
  static const Color special = Color(0xFFF6C453);
  static const Color epic = Color(0xFFC9A6FF);
}

// ─── Dimension ─────────────────────────────────────────

abstract final class PasslySpace {
  static const double s0 = 0;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;

  /// Default screen margin / card padding
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;
}

abstract final class PasslyRadius {
  /// Tag inner / small inset
  static const double sm = 4;

  /// Swatch / small control
  static const double md = 6;

  /// Card / input
  static const double lg = 12;

  /// Nav bar / modal
  static const double xl = 16;

  /// Bottom sheet top
  static const double xxl = 24;

  /// Button / chip
  static const double pill = 999;

  /// Avatar / node only
  static const double circle = 9999;
}

abstract final class PasslyBorderWidth {
  static const double hairline = 1;

  /// Icon stroke
  static const double icon = 1.5;
  static const double emphasis = 2;
  static const double avatar = 2.5;
}

abstract final class PasslyAvatarSize {
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;
  static const double s72 = 72;
}

abstract final class PasslyIconSize {
  static const double s20 = 20;

  /// Default
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
}

abstract final class PasslyGrid {
  static const double margin = 16;
  static const double gutter = 16;
}

// ─── Typography ────────────────────────────────────────

abstract final class PasslyFont {
  static const String family = 'Noto Sans JP';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
