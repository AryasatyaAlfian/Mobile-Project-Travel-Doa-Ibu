import 'package:flutter/widgets.dart';

/// Kelas perangkat untuk tata letak adaptif.
///
/// - [compact]  : HP biasa (lebar < 600) — nav bawah, satu kolom.
/// - [medium]   : HP lipat saat dibuka / tablet portrait (600–899) — nav samping ringkas, grid 2–3 kolom.
/// - [expanded] : tablet landscape / desktop (>= 900) — nav samping berlabel, grid 3–4 kolom, panel ganda.
enum DeviceClass { compact, medium, expanded }

class Breakpoints {
  Breakpoints._();

  /// Batas bawah HP lipat (Fold: 673–717 dp saat terbuka) dan tablet portrait.
  static const double mediumMin = 600;

  /// Batas tablet landscape / desktop.
  static const double expandedMin = 900;

  static DeviceClass classify(double width) {
    if (width >= expandedMin) return DeviceClass.expanded;
    if (width >= mediumMin) return DeviceClass.medium;
    return DeviceClass.compact;
  }

  static DeviceClass of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DeviceScope>();
    if (scope != null) return scope.deviceClass;
    return classify(MediaQuery.sizeOf(context).width);
  }

  /// Lebar maksimum kolom konten supaya teks tidak melebar berlebihan di layar besar.
  static double contentMaxWidth(DeviceClass deviceClass) {
    switch (deviceClass) {
      case DeviceClass.compact:
        return 560;
      case DeviceClass.medium:
        return 840;
      case DeviceClass.expanded:
        return 1280;
    }
  }

  /// Jumlah kolom grid untuk daftar kartu.
  static int gridColumns(DeviceClass deviceClass) {
    switch (deviceClass) {
      case DeviceClass.compact:
        return 2;
      case DeviceClass.medium:
        return 3;
      case DeviceClass.expanded:
        return 4;
    }
  }

  /// Padding tepi halaman.
  static double pagePadding(DeviceClass deviceClass) {
    switch (deviceClass) {
      case DeviceClass.compact:
        return 20;
      case DeviceClass.medium:
        return 28;
      case DeviceClass.expanded:
        return 36;
    }
  }

  static bool isWide(DeviceClass deviceClass) => deviceClass != DeviceClass.compact;
}

/// Menyediakan [DeviceClass] ke seluruh subtree, sehingga halaman tidak perlu
/// menghitung ulang lebar layar setelah [ResponsiveShell] membatasi kolom konten.
class DeviceScope extends InheritedWidget {
  const DeviceScope({super.key, required this.deviceClass, required super.child});

  final DeviceClass deviceClass;

  static DeviceClass of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DeviceScope>()?.deviceClass ??
      Breakpoints.classify(MediaQuery.sizeOf(context).width);

  @override
  bool updateShouldNotify(DeviceScope oldWidget) => oldWidget.deviceClass != deviceClass;
}
