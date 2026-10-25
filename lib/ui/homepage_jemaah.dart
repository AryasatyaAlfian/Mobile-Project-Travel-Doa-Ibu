import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/travel_api.dart';
import 'package_detail_page.dart';

/// Home page sesuai Figma "homepage" (lebar 402).
/// Konten memakai koordinat Figma lalu di-scale mengikuti lebar layar
/// dan bisa di-scroll. Navbar disediakan oleh MainScreen.
class HomepageJemaah extends StatefulWidget {
  const HomepageJemaah({
    super.key,
    required this.api,
    this.onExplorePackages,
    this.onConsultation,
    this.onLogout,
  });

  final TravelApi api;
  final VoidCallback? onExplorePackages;
  final VoidCallback? onConsultation;
  final VoidCallback? onLogout;

  @override
  State<HomepageJemaah> createState() => _HomepageJemaahState();
}

class _HomepageJemaahState extends State<HomepageJemaah> {
  // Ukuran & posisi dari Figma
  static const double _frameW = 402;
  static const double _cardLeft = 20;
  static const double _cardTop = 211; // Frame 711
  static const double _cardSpacing = 272; // 211 -> 483 -> 754
  static const double _cardHeight = 255; // foto 167 + garis 3 + info 85

  // Warna dari Figma
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _dark = Color(0xFF121413);
  static const Color _chipBorder = Color(0xFFE7E7E7);

  static const List<String> _categoryLabels = [
    'Semua',
    'Umrah',
    'Domestik',
    'Internasional',
  ];
  static const List<double> _chipWidths = [64, 98, 98, 104];

  late Future<Paginated<TravelPackage>> _packagesFuture;
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _packagesFuture = widget.api.packages();
    _initUser();
  }

  void _initUser() {
    if (TravelApi.currentUser != null) return;
    if (widget.api.client.token == null) return;

    widget.api.me().then((u) {
      if (mounted && u != null) setState(() {});
    }).catchError((_) => null);
  }

  /// Saring berdasarkan nama kategori dari backend.
  List<TravelPackage> _filter(List<TravelPackage> all) {
    if (_selectedCategory == 0) return all;

    final keyword = _categoryLabels[_selectedCategory].toLowerCase();
    return all.where((p) {
      final name = p.category?.name.toLowerCase() ?? '';
      if (keyword == 'umrah') return name.contains('umrah') || name.contains('haji');
      return name.contains(keyword);
    }).toList();
  }

  void _openPackage(TravelPackage package) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageDetailPage(
          package: package,
          api: widget.api,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = TravelApi.currentUser?.name ?? 'Jemaah';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bg,
        body: FutureBuilder<Paginated<TravelPackage>>(
          future: _packagesFuture,
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final packages =
                isLoading ? const <TravelPackage>[] : _filter(snapshot.data?.items ?? const []);

            return LayoutBuilder(
              builder: (context, constraints) {
                final double scale = constraints.maxWidth / _frameW;

                // Tinggi konten dalam koordinat Figma + ruang untuk navbar
                final double listBottom = packages.isEmpty
                    ? _cardTop + 120
                    : _cardTop +
                        (packages.length - 1) * _cardSpacing +
                        _cardHeight;
                final double designHeight = listBottom + 98;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: designHeight * scale,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _frameW,
                        height: designHeight,
                        child: _buildContent(
                          userName: userName,
                          packages: packages,
                          isLoading: isLoading,
                          hasError: snapshot.hasError,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent({
    required String userName,
    required List<TravelPackage> packages,
    required bool isLoading,
    required bool hasError,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Frame 865 — Hi, <nama> (posisi 14,70 + padding 10)
        Positioned(
          left: 24,
          top: 80,
          right: 24,
          height: 35,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hi, $userName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: 21 * 0.05,
                height: 35 / 21,
                color: Colors.black,
              ),
            ),
          ),
        ),

        // Rectangle 8-11 — filter kategori
        Positioned(
          left: 18,
          top: 140,
          child: Row(
            children: [
              for (int i = 0; i < _categoryLabels.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                _buildChip(i),
              ],
            ],
          ),
        ),

        // Kartu paket
        for (int i = 0; i < packages.length; i++)
          Positioned(
            left: _cardLeft,
            top: _cardTop + i * _cardSpacing,
            child: _PackageCard(
              package: packages[i],
              onTap: () => _openPackage(packages[i]),
            ),
          ),

        // Status kosong / memuat / gagal
        if (packages.isEmpty)
          Positioned(
            left: _cardLeft,
            top: _cardTop,
            width: 362,
            height: 120,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _chipBorder, width: 1),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(_dark),
                      ),
                    )
                  : Text(
                      hasError
                          ? 'Gagal memuat paket. Periksa koneksi Anda.'
                          : 'Belum ada paket ${_categoryLabels[_selectedCategory]}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromRGBO(18, 20, 19, 0.5),
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  /// Chip kategori: tinggi 42, radius 50, border 1px #E7E7E7.
  /// Chip yang aktif diberi border gelap.
  Widget _buildChip(int index) {
    final bool selected = index == _selectedCategory;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedCategory = index),
      child: Container(
        width: _chipWidths[index],
        height: 42,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: index == 0 ? _bg : const Color.fromRGBO(255, 255, 255, 0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? _dark : _chipBorder,
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _categoryLabels[index],
            maxLines: 1,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 12 * 0.06,
              height: 1.5,
              color: index == 0 ? _dark : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu paket: foto 362 x 167 + info #ECC485 85px (garis putih 3px di atas).
class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.onTap});

  final TravelPackage package;
  final VoidCallback onTap;

  static const Color _gold = Color(0xFFECC485);

  @override
  Widget build(BuildContext context) {
    final label = package.category?.name ?? 'Paket';
    final description = package.excerpt ?? package.description ?? '';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 362,
          height: 255,
          child: Column(
            children: [
              // Foto (Frame 711 / 870 / 872)
              SizedBox(
                width: 362,
                height: 167,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(package.image),
                    // Frame 739 — badge kategori
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        height: 26,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(240, 245, 249, 0.85),
                          borderRadius: BorderRadius.circular(9.5),
                          border: Border.all(
                            color: const Color.fromRGBO(239, 246, 255, 0.1),
                            width: 3,
                          ),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 12.7,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 12.7 * 0.005,
                            height: 1.2,
                            color: const Color.fromRGBO(18, 20, 19, 0.71),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // border-top 3px #FFFFFF
              Container(width: 362, height: 3, color: Colors.white),

              // Info (Frame 739 / 871 / 873)
              Container(
                width: 362,
                height: 85,
                color: _gold,
                child: Stack(
                  children: [
                    // Judul paket
                    Positioned(
                      left: 12,
                      right: 12,
                      top: 8,
                      height: 25,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          package.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.7,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 12.7 * 0.005,
                            height: 1.2,
                            color: const Color.fromRGBO(18, 20, 19, 0.7585),
                          ),
                        ),
                      ),
                    ),
                    // Deskripsi
                    Positioned(
                      left: 12,
                      top: 29,
                      width: 337,
                      height: 36,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 10 * 0.005,
                            height: 1.5,
                            color: const Color.fromRGBO(18, 20, 19, 0.5),
                          ),
                        ),
                      ),
                    ),
                    // Frame 854 — Lihat Detail→
                    Positioned(
                      right: 16,
                      top: 47,
                      height: 35,
                      child: Center(
                        child: Text(
                          'Lihat Detail →',
                          maxLines: 1,
                          softWrap: false,
                          style: GoogleFonts.poppins(
                            fontSize: 12.7,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 12.7 * 0.005,
                            height: 1.2,
                            color: const Color(0xFF313B42),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Foto paket dari backend; jatuh ke placeholder bila kosong / gagal.
  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) return _placeholder();

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD8C5A4), Color(0xFFB08E5E)],
        ),
      ),
      child: Center(
        child: Icon(Icons.photo_outlined, size: 44, color: Colors.white70),
      ),
    );
  }
}
