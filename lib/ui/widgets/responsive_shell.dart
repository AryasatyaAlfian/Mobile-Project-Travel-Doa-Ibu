import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// Pembungkus global seluruh halaman (dipasang di `MaterialApp.builder`).
///
/// Desain aplikasi dibuat untuk lebar HP (±402 px). Di layar lebar — tablet, HP lipat yang dibuka,
/// atau HP landscape — konten dipusatkan dengan lebar maksimal [maxContentWidth] supaya kartu, tombol,
/// dan halaman berbingkai desain tidak melar atau membesar tak terkendali. `MediaQuery` di dalamnya
/// ikut disesuaikan, jadi dialog, bottom sheet, dan snackbar juga pas di kolom konten.
///
/// Ukuran teks sistem dibatasi [minTextScale]–[maxTextScale] agar teks besar dari pengaturan HP tetap
/// terbaca tanpa memecah layout.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.child});

  static const double maxContentWidth = 560;
  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.3;

  static Widget builder(BuildContext context, Widget? child) => ResponsiveShell(child: child ?? const SizedBox.shrink());

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScaler = media.textScaler.clamp(minScaleFactor: minTextScale, maxScaleFactor: maxTextScale);

    if (media.size.width <= maxContentWidth) {
      return MediaQuery(data: media.copyWith(textScaler: textScaler), child: child);
    }

    // Layar lebar: kolom konten di tengah; sisi kiri/kanan diisi warna latar aplikasi.
    final sideInset = (media.size.width - maxContentWidth) / 2;
    return ColoredBox(
      color: AppColors.pageBg,
      child: Center(
        child: SizedBox(
          width: maxContentWidth,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(maxContentWidth, media.size.height),
              textScaler: textScaler,
              // Area aman kiri/kanan (mis. engsel/notch saat landscape) sudah berada di luar kolom.
              padding: media.padding.copyWith(left: (media.padding.left - sideInset).clamp(0, double.infinity), right: (media.padding.right - sideInset).clamp(0, double.infinity)),
              viewPadding: media.viewPadding.copyWith(left: (media.viewPadding.left - sideInset).clamp(0, double.infinity), right: (media.viewPadding.right - sideInset).clamp(0, double.infinity)),
            ),
            child: ClipRect(child: child),
          ),
        ),
      ),
    );
  }
}
