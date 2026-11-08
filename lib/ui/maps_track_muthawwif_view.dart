import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/travel_api.dart';
import 'widgets/maps_canvas_view.dart';

/// Halaman Lacak Mutawwif & Jarak Rombongan
/// Desain 1:1 Sesuai Figma Prototype media_1793605768563_e0eacd9a.png
class MapsTrackMuthawwifView extends StatefulWidget {
  final TravelApi? api;
  final Muthawwif? muthawwif;
  final VoidCallback? onClose;
  final String groupId;
  final double userLat;
  final double userLng;

  const MapsTrackMuthawwifView({
    super.key,
    this.api,
    this.muthawwif,
    this.onClose,
    this.groupId = 'AGR8598',
    this.userLat = 21.4189,
    this.userLng = 39.8246,
  });

  @override
  State<MapsTrackMuthawwifView> createState() => _MapsTrackMuthawwifViewState();
}

class _MapsTrackMuthawwifViewState extends State<MapsTrackMuthawwifView> {
  static const Color _ink = Color(0xFF1E293B);
  static const Color _muted = Color(0xFF64748B);
  static const Color _green = Color(0xFF10B981);
  static const Color _bgCream = Color(0xFFFFFBEB);

  late String _muthawwifName;
  late String _muthawwifPhone;
  late String _groupId;

  // Koordinat Muthawwif & Lokasi Terakhir (Sekitar Masjidil Haram Gate 1)
  double _muthawwifLat = 21.4266;
  double _muthawwifLng = 39.8328;
  String _muthawwifGate = 'Gerbang King Abdul Aziz (Gate 1)';
  String _muthawwifSubLocation = 'Masjidil Haram, Makkah · 1 mnt lalu';

  // Metrik Dinamis yang Dihitung Otomatis
  double _distanceKm = 1.2;
  int _walkMinutes = 15;
  double _routeKm = 1.5;
  String _bearing = 'Timur Laut';
  bool _isSafeRadius = true;

  @override
  void initState() {
    super.initState();
    _muthawwifName = widget.muthawwif?.name ?? 'Ust. Ahmad Fauzi';
    _muthawwifPhone = widget.muthawwif?.phone ?? '081234567890';
    _groupId = widget.groupId;
    _computeMetrics();
    _loadMuthawwifData();
  }

  void _computeMetrics() {
    final dist = _haversine(widget.userLat, widget.userLng, _muthawwifLat, _muthawwifLng);
    final walkTime = (dist * 12.5).round().clamp(1, 180);
    final routeDist = dist * 1.25;
    final brng = _calculateBearing(widget.userLat, widget.userLng, _muthawwifLat, _muthawwifLng);

    setState(() {
      _distanceKm = dist > 0 ? dist : 1.2;
      _walkMinutes = walkTime;
      _routeKm = routeDist > 0 ? routeDist : 1.5;
      _bearing = brng;
      _isSafeRadius = _distanceKm <= 2.0;
    });
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // pi / 180
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // R = 6371 km
  }

  String _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final y = math.sin(dLon) * math.cos(lat2 * math.pi / 180.0);
    final x = math.cos(lat1 * math.pi / 180.0) * math.sin(lat2 * math.pi / 180.0) -
        math.sin(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) * math.cos(dLon);
    var brng = math.atan2(y, x) * 180.0 / math.pi;
    brng = (brng + 360.0) % 360.0;

    if (brng >= 337.5 || brng < 22.5) return 'Utara';
    if (brng >= 22.5 && brng < 67.5) return 'Timur Laut';
    if (brng >= 67.5 && brng < 112.5) return 'Timur';
    if (brng >= 112.5 && brng < 157.5) return 'Tenggara';
    if (brng >= 157.5 && brng < 202.5) return 'Selatan';
    if (brng >= 202.5 && brng < 247.5) return 'Barat Daya';
    if (brng >= 247.5 && brng < 292.5) return 'Barat';
    return 'Barat Laut';
  }

  Future<void> _loadMuthawwifData() async {
    if (widget.api == null) return;
    try {
      final muth = await widget.api!.myMuthawwif();
      if (!mounted) return;
      if (muth != null && muth.name.isNotEmpty) {
        setState(() {
          _muthawwifName = muth.name;
          if (muth.phone != null && muth.phone!.isNotEmpty) {
            _muthawwifPhone = muth.phone!;
          }
        });
      }
    } catch (_) {}

    try {
      final contact = await widget.api!.myMuthawwifContact();
      if (!mounted) return;
      if (contact['whatsapp'] != null) {
        final wa = contact['whatsapp'] as Map<String, dynamic>;
        if (wa['number'] != null) {
          setState(() {
            _muthawwifPhone = wa['number'].toString();
          });
        }
      }
      if (contact['muthawwif'] != null) {
        final mw = contact['muthawwif'] as Map<String, dynamic>;
        if (mw['name'] != null && _muthawwifName.isEmpty) {
          setState(() {
            _muthawwifName = mw['name'].toString();
          });
        }
      }
      if (contact['location_name'] != null) {
        setState(() {
          _muthawwifGate = contact['location_name'].toString();
        });
      }
      if (contact['sub_location'] != null) {
        setState(() {
          _muthawwifSubLocation = contact['sub_location'].toString();
        });
      }
      if (contact['latitude'] != null && contact['longitude'] != null) {
        setState(() {
          _muthawwifLat = (contact['latitude'] as num).toDouble();
          _muthawwifLng = (contact['longitude'] as num).toDouble();
        });
      }
    } catch (_) {}

    try {
      final tracker = await widget.api!.getTracker();
      if (!mounted) return;
      if (tracker['group'] != null) {
        final grp = tracker['group'] as Map<String, dynamic>;
        setState(() {
          if (grp['code'] != null) {
            _groupId = grp['code'].toString();
          } else if (grp['name'] != null) {
            _groupId = grp['name'].toString();
          }
        });
      }
    } catch (_) {}

    _computeMetrics();
  }

  void _callMuthawwif() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Menghubungi $_muthawwifName ($_muthawwifPhone)...',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  void _openDirections() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rute navigasi ke $_muthawwifName: ${_routeKm.toStringAsFixed(1).replaceAll('.', ',')} km via Ibrahim Al Khalil St (estimasi $_walkMinutes menit jalan kaki).',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final sheetPaddingBottom = 16.0 + bottomInset + 16.0;
    // Tinggi estimasi sheet sekitar 370px, posisikan pill aman di atasnya
    final pillBottom = 385.0 + bottomInset;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Peta Interaktif dengan Multi-Marker (Jemaah & Mutawwif)
            Positioned.fill(
              child: MapsCanvasView(
                showMuthawwif: true,
                userLat: widget.userLat,
                userLng: widget.userLng,
                muthawwifLat: _muthawwifLat,
                muthawwifLng: _muthawwifLng,
              ),
            ),

            // 2. Top Bar Navigasi (Tinggi 44px)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Tombol Kembali Lingkaran
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                        shadowColor: Colors.black.withValues(alpha: 0.12),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            if (widget.onClose != null) {
                              widget.onClose!();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(Icons.arrow_back_ios_new_rounded, color: _ink, size: 18),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Pill "• Lacak Mutawwif"
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: _green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lacak Mutawwif',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2b. Floating Controls Kanan Atas (Map Layer, Direction, Compass N) Sesuai Figma
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleTool(
                    icon: Icons.map_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildCircleTool(
                    icon: Icons.near_me_outlined,
                    onTap: _openDirections,
                  ),
                  const SizedBox(height: 8),
                  _buildNorthDial(),
                ],
              ),
            ),

            // 3. Floating Pill "Masih dalam radius aman rombongan (< 2 km)"
            Positioned(
              left: 20,
              right: 20,
              bottom: pillBottom,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _isSafeRadius ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isSafeRadius ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSafeRadius ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
                        color: _isSafeRadius ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _isSafeRadius
                              ? 'Masih dalam radius aman rombongan (< 2 km)'
                              : 'Di luar radius aman rombongan (> 2 km)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isSafeRadius ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Sliding Bottom Sheet Detail Mutawwif
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, sheetPaddingBottom),
                decoration: const BoxDecoration(
                  color: _bgCream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle Bar
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Header Profil Mutawwif & Tombol Tutup X
                      Row(
                        children: [
                          // Avatar Mutawwif
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _green, width: 2),
                              color: const Color(0xFFE2E8F0),
                            ),
                            child: const Icon(Icons.person, color: _ink, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _muthawwifName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Mutawwif',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F766E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Rombongan $_groupId',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: _muted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: const Color(0xFFF1F5F9),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                if (widget.onClose != null) {
                                  widget.onClose!();
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.close_rounded, color: _ink, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Lokasi Terakhir Gate 1
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: _ink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _muthawwifGate,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                                Text(
                                  _muthawwifSubLocation,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: _green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Live',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Card Metrik Jarak Putih (Dihitung Dinamis)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF1E7D5)),
                        ),
                        child: Column(
                          children: [
                            // Baris Indikator Titik Jemaah -> Mutawwif
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF3B82F6),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Jemaah',
                                        style: GoogleFonts.poppins(fontSize: 10, color: _muted)),
                                    Text('Anda',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12, fontWeight: FontWeight.w700, color: _ink)),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            _distanceKm.toStringAsFixed(1).replaceAll('.', ','),
                                            style: GoogleFonts.poppins(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: _ink,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'km',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Jarak lurus ke mutawaf',
                                        style: GoogleFonts.poppins(fontSize: 10, color: _muted),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: _green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Mutawaf',
                                        style: GoogleFonts.poppins(fontSize: 10, color: _muted)),
                                    Text(
                                      _muthawwifName.split(' ').first,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, fontWeight: FontWeight.w700, color: _ink),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 12),

                            // 3 Sub-Metrik (Dihitung Matematis)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSubMetric('$_walkMinutes mnt', 'Jalan kaki'),
                                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                                _buildSubMetric(
                                    '${_routeKm.toStringAsFixed(1).replaceAll('.', ',')} km',
                                    'Lewat rute'),
                                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                                _buildSubMetric(_bearing, 'Arah mutawaf'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dua Tombol Aksi Bawah: Hubungi & Petunjuk Arah
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _callMuthawwif,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.phone_rounded,
                                          color: Colors.white, size: 15),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Hubungi',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: _ink),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _openDirections,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.near_me_rounded,
                                          color: Colors.white, size: 15),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Petunjuk Arah',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: _ink),
                                          ),
                                          Text(
                                            '$_walkMinutes mnt',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                fontSize: 9.5, color: _muted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleTool({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: _ink, size: 20),
        ),
      ),
    );
  }

  Widget _buildNorthDial() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_drop_up, size: 16, color: Colors.red),
            Text(
              'N',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _ink,
                height: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
