import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// Peta Interaktif Makkah & Lapangan
/// Menggunakan provider tile peta asli gratis (CartoDB Voyager / OpenStreetMap)
/// Dilengkapi dengan layer marker real-time, polyline rute putus-putus, dan animasi radar SOS
class MapsCanvasView extends StatefulWidget {
  final bool showMuthawwif;
  final bool isSosActive;
  final VoidCallback? onCheckIn;
  final VoidCallback? onRecenter;
  final double userLat;
  final double userLng;
  final double muthawwifLat;
  final double muthawwifLng;

  const MapsCanvasView({
    super.key,
    this.showMuthawwif = false,
    this.isSosActive = false,
    this.onCheckIn,
    this.onRecenter,
    this.userLat = 21.4189,
    this.userLng = 39.8246,
    this.muthawwifLat = 21.4208,
    this.muthawwifLng = 39.8258,
  });

  @override
  State<MapsCanvasView> createState() => _MapsCanvasViewState();
}

class _MapsCanvasViewState extends State<MapsCanvasView> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;

  // Mode Tile Provider (0: OpenStreetMap Standard, 1: OSM Humanitarian)
  int _tileProviderIndex = 0;

  static const _osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _osmHotUrl = 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

  // Ka'bah Koordinat Resmi Masjidil Haram
  static const _kabahCoord = LatLng(21.4225, 39.8262);

  LatLng get _userCoord => LatLng(widget.userLat, widget.userLng);
  LatLng get _muthawwifCoord => LatLng(widget.muthawwifLat, widget.muthawwifLng);

  LatLng get _midpointCoord => LatLng(
        (widget.userLat + widget.muthawwifLat) / 2,
        (widget.userLng + widget.muthawwifLng) / 2,
      );

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final curZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (curZoom + 0.8).clamp(3.0, 19.0));
  }

  void _zoomOut() {
    final curZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (curZoom - 0.8).clamp(3.0, 19.0));
  }

  void _recenter() {
    _mapController.move(_userCoord, 16.5);
    widget.onRecenter?.call();
  }

  void _toggleTileProvider() {
    setState(() {
      _tileProviderIndex = (_tileProviderIndex + 1) % 2;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tileProviderIndex == 0
              ? 'Peta: OpenStreetMap Standard (Gratis Tanpa API Key)'
              : 'Peta: OpenStreetMap Humanitarian (Mode Kontras & Halus)',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Engine Peta Asli Gratis (FlutterMap)
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.showMuthawwif ? _midpointCoord : _userCoord,
            initialZoom: widget.showMuthawwif ? 16.0 : 16.5,
            minZoom: 4.0,
            maxZoom: 19.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // Tile Layer Peta Dunia Nyata (100% Bebas API Key)
            TileLayer(
              urlTemplate: _tileProviderIndex == 0 ? _osmUrl : _osmHotUrl,
              subdomains: _tileProviderIndex == 0 ? const [] : const ['a', 'b'],
              userAgentPackageName: 'com.traveldoaibu.app',
              maxZoom: 19,
              errorTileCallback: (tile, error, stackTrace) {
                // Penanganan graceful jika sedang offline
              },
            ),

            // Polyline Rute Lacak Mutawwif (Putus-putus Biru)
            if (widget.showMuthawwif)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_userCoord, _muthawwifCoord],
                    strokeWidth: 3.5,
                    color: const Color(0xFF3B82F6),
                    pattern: StrokePattern.dashed(segments: const [8, 5]),
                  ),
                ],
              ),

            // Marker Layer (Ka'bah, Mutawwif, Jemaah, Radius, SOS)
            MarkerLayer(
              markers: [
                // Marker Ka'bah di Masjidil Haram
                Marker(
                  point: _kabahCoord,
                  width: 90,
                  height: 60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFEAB308), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 22,
                            height: 4,
                            color: const Color(0xFFEAB308),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: Color(0x1A000000), blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          'Ka\'bah',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Marker Mutawwif (Ust. Ahmad Fauzi)
                if (widget.showMuthawwif)
                  Marker(
                    point: _muthawwifCoord,
                    width: 120,
                    height: 95,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tag Pill "Mutawaf"
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Color(0x1F000000), blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield, color: Colors.white, size: 10),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Mutawaf',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Avatar Lingkaran Hijau
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF10B981), width: 3),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Color(0xFFE2E8F0),
                            child: Icon(Icons.person, color: Color(0xFF10B981), size: 26),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Badge Jarak Mengambang di Titik Tengah Rute (1,2 km)
                if (widget.showMuthawwif)
                  Marker(
                    point: _midpointCoord,
                    width: 110,
                    height: 36,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_walk_rounded, color: Color(0xFF3B82F6), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '1,2 km',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Marker Posisi User (Jemaah)
                Marker(
                  point: _userCoord,
                  width: 150,
                  height: 150,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final val = _pulseController.value;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Gelombang Sinyal Merah Darurat jika SOS Aktif
                          if (widget.isSosActive)
                            Container(
                              width: 60 + (val * 85),
                              height: 60 + (val * 85),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFEF4444).withValues(alpha: 0.35 * (1.0 - val)),
                                border: Border.all(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.6 * (1.0 - val)),
                                  width: 2,
                                ),
                              ),
                            ),

                          // Sight Cone Radar Arah Pandang (Sudut ke arah Ka'bah)
                          Transform.rotate(
                            angle: -math.pi / 4,
                            child: CustomPaint(
                              size: const Size(90, 90),
                              painter: _SightConePainter(),
                            ),
                          ),

                          // Lingkaran Denyut Biru Radar Normal
                          if (!widget.isSosActive)
                            Container(
                              width: 38 + (val * 32),
                              height: 38 + (val * 32),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.25 * (1.0 - val)),
                                border: Border.all(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.45 * (1.0 - val)),
                                  width: 1.5,
                                ),
                              ),
                            ),

                          // Avatar Utama Jemaah
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: widget.isSosActive ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x26000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Color(0xFF0F172A),
                                      child: Icon(Icons.person, color: Colors.white, size: 22),
                                    ),
                                    // Dot Pin Posisi
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget.isSosActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 3),
                              // Label "Anda • Jemaah"
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x14000000), blurRadius: 4),
                                  ],
                                ),
                                child: Text(
                                  'Anda • Jemaah',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        // 2. Tombol Navigasi Mengambang di Kanan (Ganti Layer, Zoom +, Zoom -, Kompas)
        Positioned(
          right: 16,
          top: 130,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ganti Provider Tile (CartoDB / OSM)
              _buildControlButton(
                icon: Icons.layers_rounded,
                tooltip: 'Ganti Provider Peta',
                onTap: _toggleTileProvider,
              ),
              const SizedBox(height: 12),

              // Zoom In (+)
              _buildControlButton(
                icon: Icons.add_rounded,
                tooltip: 'Perbesar',
                onTap: _zoomIn,
              ),
              const SizedBox(height: 6),

              // Zoom Out (-)
              _buildControlButton(
                icon: Icons.remove_rounded,
                tooltip: 'Perkecil',
                onTap: _zoomOut,
              ),
              const SizedBox(height: 12),

              // Recenter Kompas / Lokasi Jemaah
              _buildControlButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Pusatkan ke Lokasi Saya',
                onTap: _recenter,
              ),
            ],
          ),
        ),

        // 3. Tombol Check In Mengambang (Opsional dari parameter)
        if (widget.onCheckIn != null && !widget.showMuthawwif && !widget.isSosActive)
          Positioned(
            left: 0,
            right: 0,
            bottom: 230,
            child: Center(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 3,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                child: InkWell(
                  onTap: widget.onCheckIn,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Check In',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
          ),
        ),
      ),
    );
  }
}

/// Painter Radar Sight Cone (Arah Pandang Jemaah)
class _SightConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.35),
          const Color(0xFF3B82F6).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 45));

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: 45),
        -math.pi / 4,
        math.pi / 2,
        false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
