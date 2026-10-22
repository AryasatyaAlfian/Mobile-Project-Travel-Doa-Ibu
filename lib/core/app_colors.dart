import 'package:flutter/material.dart';

/// Palet warna resmi StockVision / Modern Teal
/// Diekstrak dari `doa-ibu-color-palette.md`
class AppColors {
  AppColors._();

  // 🟢 Teal / Hijau — Aksen Utama
  static const Color tealPrimary = Color(0xFF1A9E8F);
  static const Color tealDark = Color(0xFF157A6E);
  static const Color tealLight = Color(0xFF5CC8BB);
  static const Color tealSubtle = Color(0xFFE0F5F3);

  // ⚪ Netral — Background & Surface
  static const Color pageBg = Color(0xFFEEF4F3);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color footerBg = Color(0xFFD6E8E6);
  static const Color border = Color(0xFFD0E5E3);

  // 🔤 Teks
  static const Color textDark = Color(0xFF1A2E2C);
  static const Color textBody = Color(0xFF4A6663);
  static const Color textMuted = Color(0xFF8AADAA);
  static const Color white = Color(0xFFFFFFFF);

  // 🔴 Status
  static const Color redNegative = Color(0xFFE8504A);

  // 🏷️ Badge
  static const Color badgeBg = Color(0xFFE0F0EE);
  static const Color badgeText = Color(0xFF2A8C80);

  // 🌌 Elysian Horizon Design Tokens (DESIGN.md)
  static const Color elysianPrimary = Color(0xFF9DBED8);
  static const Color elysianSecondary = Color(0xFF111827);
  static const Color elysianTertiary = Color(0xFFEBF2F7);
  static const Color elysianNeutral = Color(0xFFFFFFFF);
  static const Color skyGradientStart = Color(0xFFF4F8FB);
  static const Color skyGradientEnd = Color(0xFF9DBED8);
  static const Color elysianTextMuted = Color(0xFF4B5563);
  static const Color elysianAccentBlue = Color(0xFF426279);
  static const Color surfaceBorder = Color(0xFFC2C7CD);

  static const LinearGradient elysianCanvasGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyGradientStart, skyGradientEnd],
  );

  // 🖼️ Gradients & Effects
  static const LinearGradient tealButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealPrimary, tealDark],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [tealSubtle, pageBg],
  );

  static const LinearGradient statsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceWhite, tealSubtle],
  );

  // Aliases for seamless semantic mapping across components
  static const Color gold = tealPrimary;
  static const Color goldDark = tealDark;
  static const Color goldLight = tealPrimary;
  static const Color goldBorder = border;
  static const Color goldSurface = badgeBg;

  static const Color deepNavy = pageBg;
  static const Color navyDark = surfaceWhite;
  static const Color navyMid = tealSubtle;
  static const Color steelBlue = footerBg;

  static const Color lightGray = textMuted;
  static const Color white65 = textBody;
  static const Color white40 = textMuted;
  static const Color white15 = border;
  static const Color white08 = border;

  static const LinearGradient goldButtonGradient = tealButtonGradient;
  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceWhite, surfaceWhite],
  );
}
