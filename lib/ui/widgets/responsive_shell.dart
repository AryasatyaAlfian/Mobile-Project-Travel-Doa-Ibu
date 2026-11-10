import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/breakpoints.dart';

/// Pembungkus global seluruh halaman (dipasang di `MaterialApp.builder`).
///
/// Tata letak menyesuaikan kelas perangkat:
/// - **HP (compact)**: kolom penuh, konten dibatasi 560 px agar tidak melar.
/// - **HP lipat terbuka / tablet portrait (medium)**: kolom konten 840 px.
/// - **Tablet landscape / desktop (expanded)**: kolom konten 1280 px.
///
/// Di layar lebar, kolom konten dipusatkan dan sisanya diisi warna latar aplikasi.
/// [DeviceClass] dibagikan lewat [DeviceScope] supaya halaman bisa memilih
/// nav samping, grid 3–4 kolom, atau panel ganda.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.child});

  static const double maxContentWidth = 560;
  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.3;

  static Widget builder(BuildContext context, Widget? child) =>
      ResponsiveShell(child: child ?? const SizedBox.shrink());

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScaler = media.textScaler.clamp(minScaleFactor: minTextScale, maxScaleFactor: maxTextScale);
    final deviceClass = Breakpoints.classify(media.size.width);
    final contentWidth = Breakpoints.contentMaxWidth(deviceClass);

    if (media.size.width <= contentWidth) {
      return DeviceScope(
        deviceClass: deviceClass,
        child: MediaQuery(data: media.copyWith(textScaler: textScaler), child: child),
      );
    }

    // Layar lebih lebar dari kolom konten: pusatkan kolom, sisanya latar aplikasi.
    final sideInset = (media.size.width - contentWidth) / 2;
    return DeviceScope(
      deviceClass: deviceClass,
      child: ColoredBox(
        color: AppColors.pageBg,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: MediaQuery(
              data: media.copyWith(
                size: Size(contentWidth, media.size.height),
                textScaler: textScaler,
                // Area aman kiri/kanan (mis. engsel/notch saat landscape) sudah berada di luar kolom.
                padding: media.padding.copyWith(
                  left: (media.padding.left - sideInset).clamp(0, double.infinity),
                  right: (media.padding.right - sideInset).clamp(0, double.infinity),
                ),
                viewPadding: media.viewPadding.copyWith(
                  left: (media.viewPadding.left - sideInset).clamp(0, double.infinity),
                  right: (media.viewPadding.right - sideInset).clamp(0, double.infinity),
                ),
              ),
              child: ClipRect(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
