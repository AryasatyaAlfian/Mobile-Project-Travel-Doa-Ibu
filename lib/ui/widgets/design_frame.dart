import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Menampilkan halaman yang disusun dengan posisi tetap dari desain Figma ([designSize], mis. 402×874).
///
/// Skala bingkai = sebesar mungkin, asalkan:
/// - tidak lebih lebar dari layar, dan
/// - seluruh bingkai muat setinggi layar (tablet landscape, HP lipat: tampil utuh tanpa terpotong),
///   kecuali itu membuatnya lebih kecil dari [minScale]. Di layar yang sangat pendek (HP landscape)
///   bingkai berhenti mengecil di [minScale] dan halaman bisa di-scroll, supaya tetap terbaca.
///
/// Tinggi keyboard tidak ikut dihitung, jadi halaman tidak mengecil saat keyboard muncul. Body yang
/// memendek cukup di-scroll ke kolom yang sedang diisi.
///
/// Struktur widget sengaja tidak berganti antar kondisi: berganti struktur saat keyboard muncul akan
/// membuat ulang kolom isian dan menutup keyboard lagi.
class DesignFrame extends StatelessWidget {
  const DesignFrame({super.key, required this.designSize, required this.child, this.background});

  /// Skala terkecil yang masih nyaman dibaca (teks desain 12 px → ±10 px, tombol 16 px → ±14 px).
  /// Cukup untuk menampilkan bingkai utuh di tablet landscape (tinggi ±800).
  static const double minScale = 0.85;

  final Size designSize;
  final Widget child;

  /// Latar selebar & setinggi layar di belakang bingkai (mis. gradient) agar sisi kiri/kanan atau
  /// atas/bawah bingkai menyatu dengan desain.
  final Widget? background;

  /// Skala bingkai untuk area [width]×[height] (tanpa keyboard).
  static double scaleFor(Size designSize, double width, double height) {
    final widthScale = width / designSize.width;
    final heightScale = height / designSize.height;
    return math.min(widthScale, math.max(heightScale, minScale));
  }

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Scaffold membuang inset keyboard dari MediaQuery body-nya, jadi baca langsung dari View.
        // Dibaca di sini (bukan di build) karena builder ini dijalankan ulang saat body memendek.
        final keyboard = view.viewInsets.bottom / view.devicePixelRatio;
        final scale = scaleFor(designSize, constraints.maxWidth, constraints.maxHeight + keyboard);
        final frameSize = designSize * scale;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (background != null) Positioned.fill(child: background!),
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth, minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox.fromSize(
                    size: frameSize,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox.fromSize(size: designSize, child: child),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
