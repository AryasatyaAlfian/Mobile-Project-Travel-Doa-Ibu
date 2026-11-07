import 'package:flutter/material.dart';

/// Menampilkan halaman yang disusun dengan posisi tetap dari desain Figma ([designSize], mis. 402×874).
///
/// Bingkai diskalakan mengikuti LEBAR layar (di HP portrait hasilnya sama seperti desain), lalu:
/// - bila layar lebih tinggi dari bingkai → bingkai di tengah;
/// - bila layar lebih pendek (HP landscape, keyboard terbuka) → halaman bisa di-scroll,
///   bukan mengecil sampai tidak terbaca seperti `FittedBox(BoxFit.contain)`.
///
/// Struktur widget sengaja tidak berganti antar kondisi: berganti struktur saat keyboard muncul akan
/// membuat ulang kolom isian dan menutup keyboard lagi.
class DesignFrame extends StatelessWidget {
  const DesignFrame({super.key, required this.designSize, required this.child});

  final Size designSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / designSize.width;
        final scaledHeight = designSize.height * scale;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: SizedBox(
                width: constraints.maxWidth,
                height: scaledHeight,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox.fromSize(size: designSize, child: child),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
