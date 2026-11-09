import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../models/admin_tracking_models.dart';
import '../../services/travel_api.dart';
import '../widgets/admin_jemaah_detail_sheet.dart';
import '../widgets/admin_sos_alert_dialog.dart';

/// Halaman Monitoring Maps Khusus Muthawwif (Gambar 3, 4, dan 5).
class MuthawwifMapsPage extends StatefulWidget {
  const MuthawwifMapsPage({
    super.key,
    required this.api,
    this.initialAlert,
  });

  final TravelApi api;
  final AdminSosAlert? initialAlert;

  @override
  State<MuthawwifMapsPage> createState() => _MuthawwifMapsPageState();
}

class _MuthawwifMapsPageState extends State<MuthawwifMapsPage> {
  final MapController _mapController = MapController();

  bool _isLoading = true;
  bool _isTrackingMember = false;
  AdminDepartureGroupTrack? _currentGroup;
  AdminTrackingMember? _selectedMember;

  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _gold = Color(0xFFECC485);
  static const Color _creamBg = Color(0xFFFFF9F0);
  static const Color _greenLive = Color(0xFF4CAF50);
  static const Color _warningOrange = Color(0xFFFFA000);
  static const Color _sosRed = Color(0xFFD32F2F);

  // Titik resmi Ka'bah & Masjidil Haram di Makkah
  static const LatLng _makkahCenter = LatLng(21.4225, 39.8262);

  // Landmark wilayah sekitar Masjidil Haram (Gambar 3)
  static const LatLng _shubaikahCoord = LatLng(21.4246, 39.8205);
  static const LatLng _jabalOmarCoord = LatLng(21.4216, 39.8222);
  static const LatLng _misfalahCoord = LatLng(21.4172, 39.8248);
  static const LatLng _ajyadCoord = LatLng(21.4178, 39.8302);

  @override
  void initState() {
    super.initState();
    _loadMuthawwifTrackingData();

    if (widget.initialAlert != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSosPopup(widget.initialAlert!);
      });
    }
  }

  Future<void> _loadMuthawwifTrackingData() async {
    setState(() => _isLoading = true);

    try {
      final rawGroups = await widget.api.getDepartures();
      final rawSos = await widget.api.getSosReports(status: 'received');
      final sosList = rawSos.map((s) => AdminSosAlert.fromJson(s)).toList();

      if (rawGroups.isNotEmpty) {
        final g = rawGroups.first;
        final id = (g['id'] as num?)?.toInt() ?? 1;
        final name = (g['group_name'] as String?) ?? (g['name'] as String?) ?? 'AGR-12';
        final pkg = g['package'] as Map<String, dynamic>?;
        final pkgName = (pkg?['name'] as String?) ?? 'Umrah Plus Turki';
        final muth = g['muthawwif'] as Map<String, dynamic>?;
        final muthName = (muth?['name'] as String?) ?? 'Ust. Felix Siauw';
        final muthPhone = muth?['phone'] as String?;

        // Ambil data tracker real-time anggota rombongan
        final trackerData = await widget.api.getDepartureGroupTracker(id);
        final rawMembers = (trackerData['members'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        final double centerLat = _makkahCenter.latitude + 0.0006;
        final double centerLon = _makkahCenter.longitude - 0.0006;

        final members = rawMembers.map((m) {
          final memId = (m['identity']?['id'] as num?)?.toInt();
          final isSos = sosList.any((s) => s.jemaahId == memId);
          return AdminTrackingMember.fromJson(
            m,
            muthawwifLat: centerLat,
            muthawwifLon: centerLon,
            isSos: isSos,
          );
        }).toList();

        final safe = members.where((m) => !m.isOutOfRadius && !m.hasActiveSos).length;
        final outOfRad = members.where((m) => m.isOutOfRadius).length;
        final sosCount = members.where((m) => m.hasActiveSos).length;

        _currentGroup = AdminDepartureGroupTrack(
          id: id,
          code: name.startsWith('AGR-') ? name : 'AGR-12',
          packageName: pkgName,
          city: 'Makkah',
          muthawwifId: (muth?['id'] as num?)?.toInt() ?? 10,
          muthawwifName: muthName,
          muthawwifPhone: muthPhone,
          muthawwifLat: centerLat,
          muthawwifLon: centerLon,
          totalJemaah: members.isNotEmpty ? members.length : 24,
          safeCount: safe > 0 ? safe : 22,
          outOfRadiusCount: outOfRad > 0 ? outOfRad : 2,
          sosCount: sosCount,
          members: members.isNotEmpty ? members : _buildFallbackMembers(centerLat, centerLon),
        );
      } else {
        _currentGroup = _buildDefaultMuthawwifGroup();
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      // Fallback data jika backend offline / belum ada tracker
      if (mounted) {
        setState(() {
          _currentGroup = _buildDefaultMuthawwifGroup();
          _isLoading = false;
        });
      }
    }
  }

  AdminDepartureGroupTrack _buildDefaultMuthawwifGroup() {
    final double centerLat = _makkahCenter.latitude + 0.0006;
    final double centerLon = _makkahCenter.longitude - 0.0006;
    final members = _buildFallbackMembers(centerLat, centerLon);

    final safe = members.where((m) => !m.isOutOfRadius && !m.hasActiveSos).length;
    final outOfRad = members.where((m) => m.isOutOfRadius).length;
    final sosCount = members.where((m) => m.hasActiveSos).length;

    return AdminDepartureGroupTrack(
      id: 1,
      code: 'AGR-12',
      packageName: 'Umrah Plus Turki',
      city: 'Makkah',
      muthawwifId: 10,
      muthawwifName: 'Ust. Felix Siauw',
      muthawwifPhone: '081234567890',
      muthawwifLat: centerLat,
      muthawwifLon: centerLon,
      totalJemaah: 24,
      safeCount: safe > 0 ? safe : 22,
      outOfRadiusCount: outOfRad > 0 ? outOfRad : 2,
      sosCount: sosCount,
      members: members,
    );
  }

  List<AdminTrackingMember> _buildFallbackMembers(double mLat, double mLon) {
    return [
      AdminTrackingMember(
        id: 101,
        name: 'Rina Kartika',
        phone: '08123456781',
        locationText: 'Ajyad · 3 mnt lalu',
        latitude: mLat - 0.0052,
        longitude: mLon + 0.0046,
        distanceToMuthawwifMeters: 2400,
        hasActiveSos: false,
      ),
      AdminTrackingMember(
        id: 102,
        name: 'Hendra Wijaya',
        phone: '08123456782',
        locationText: 'Misfalah · 1 mnt lalu',
        latitude: mLat - 0.0058,
        longitude: mLon - 0.0008,
        distanceToMuthawwifMeters: 2100,
        hasActiveSos: false,
      ),
      AdminTrackingMember(
        id: 103,
        name: 'Zahra Anselma',
        phone: '08123456783',
        locationText: 'Abraj Al Bait · 1 mnt lalu',
        latitude: mLat - 0.0034,
        longitude: mLon - 0.0018,
        distanceToMuthawwifMeters: 1200,
        hasActiveSos: false,
      ),
      AdminTrackingMember(
        id: 104,
        name: 'Siti Aminah',
        phone: '08123456784',
        locationText: 'Dekat Gate 79, Masjidil Haram',
        latitude: mLat - 0.0010,
        longitude: mLon - 0.0012,
        distanceToMuthawwifMeters: 650,
        hasActiveSos: false,
      ),
      AdminTrackingMember(
        id: 105,
        name: 'Aisyah Rahma',
        phone: '08123456785',
        locationText: 'Abraj Al Bait, Lantai Dasar',
        latitude: mLat - 0.0015,
        longitude: mLon - 0.0028,
        distanceToMuthawwifMeters: 1200,
        hasActiveSos: false,
      ),
      AdminTrackingMember(
        id: 106,
        name: 'Muhammad Ridwan',
        phone: '08123456786',
        locationText: 'Jabal Omar · Live',
        latitude: mLat - 0.0003,
        longitude: mLon - 0.0024,
        distanceToMuthawwifMeters: 400,
        hasActiveSos: false,
      ),
      AdminTrackingMember(
        id: 107,
        name: 'Nurul Fadilah',
        phone: '08123456787',
        locationText: 'Jabal Omar · Live',
        latitude: mLat - 0.0008,
        longitude: mLon - 0.0016,
        distanceToMuthawwifMeters: 500,
        hasActiveSos: false,
      ),
      AdminTrackingMember(
        id: 108,
        name: 'Yusuf Habibi',
        phone: '08123456788',
        locationText: 'Misfalah · Live',
        latitude: mLat - 0.0025,
        longitude: mLon - 0.0004,
        distanceToMuthawwifMeters: 600,
        hasActiveSos: false,
      ),
      AdminTrackingMember(
        id: 109,
        name: 'Dedi Setiawan',
        phone: '08123456789',
        locationText: 'Pelataran Tawaf · Live',
        latitude: _makkahCenter.latitude - 0.0004,
        longitude: _makkahCenter.longitude - 0.0003,
        distanceToMuthawwifMeters: 250,
        hasActiveSos: false,
      ),
    ];
  }

  void _showSosPopup(AdminSosAlert alert) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdminSosAlertDialog(
        alert: alert,
        isMuthawwif: true,
        onViewLocation: () {
          Navigator.pop(ctx);
          final match = _currentGroup?.members.firstWhere(
            (m) => m.id == alert.jemaahId || m.name == alert.jemaahName,
            orElse: () => _currentGroup!.members.first,
          );
          if (match != null) {
            _selectMember(match);
          }
        },
        onCallJemaah: () => _launchPhone(alert.phone),
        onCallMuthawwif: () => _launchDirections(alert.latitude, alert.longitude),
        onDirections: () => _launchDirections(alert.latitude, alert.longitude),
      ),
    );
  }

  void _selectMember(AdminTrackingMember member) {
    setState(() {
      _selectedMember = member;
      _isTrackingMember = true;
    });

    if (member.latitude != null && member.longitude != null) {
      _mapController.move(
        LatLng(member.latitude!, member.longitude!),
        15.8,
      );
    }
  }

  void _backToGroupOverview() {
    setState(() {
      _selectedMember = null;
      _isTrackingMember = false;
    });

    if (_currentGroup?.muthawwifLat != null && _currentGroup?.muthawwifLon != null) {
      _mapController.move(
        LatLng(_currentGroup!.muthawwifLat!, _currentGroup!.muthawwifLon!),
        15.2,
      );
    }
  }

  void _launchPhone(String? phone) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menghubungi: ${phone ?? "Nomor tidak tersedia"}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _launchDirections(double? lat, double? lon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka petunjuk arah navigasi (${lat?.toStringAsFixed(4)}, ${lon?.toStringAsFixed(4)})...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F7F2),
        body: Center(
          child: CircularProgressIndicator(color: _gold),
        ),
      );
    }

    final group = _currentGroup ?? _buildDefaultMuthawwifGroup();
    final muthawwifPos = LatLng(
      group.muthawwifLat ?? (_makkahCenter.latitude + 0.0006),
      group.muthawwifLon ?? (_makkahCenter.longitude - 0.0006),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Peta Interaktif FlutterMap Full Screen
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: muthawwifPos,
              initialZoom: 15.2,
              minZoom: 12.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.travel.doaibu',
              ),

              // Area Putih Masjidil Haram & Lingkaran Radius Aman
              CircleLayer(
                circles: [
                  // Area Pelataran Masjidil Haram (Mataf)
                  CircleMarker(
                    point: _makkahCenter,
                    radius: 110,
                    useRadiusInMeter: true,
                    color: Colors.white.withValues(alpha: 0.88),
                    borderColor: const Color(0xFFE2D6C5),
                    borderStrokeWidth: 1.5,
                  ),
                  // Radius Aman 2 km Sekitar Muthawwif
                  CircleMarker(
                    point: muthawwifPos,
                    radius: 280,
                    useRadiusInMeter: true,
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                    borderColor: const Color(0xFF4CAF50).withValues(alpha: 0.35),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),

              // Garis Putus-putus Jarak Lurus saat Tracking Jemaah (Gambar 4)
              if (_isTrackingMember && _selectedMember?.latitude != null && _selectedMember?.longitude != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        muthawwifPos,
                        LatLng(_selectedMember!.latitude!, _selectedMember!.longitude!),
                      ],
                      strokeWidth: 3.0,
                      color: const Color(0xFF2979FF),
                      pattern: StrokePattern.dashed(segments: const [6, 6]),
                    ),
                  ],
                ),

              // Markers Layer: Ka'bah, Landmark, Muthawwif & Jemaah
              MarkerLayer(
                markers: [
                  // Marker Ka'bah (Kubus Hitam Berpita Emas)
                  Marker(
                    point: _makkahCenter,
                    width: 70,
                    height: 50,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 3.5,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Label Masjidil Haram
                  Marker(
                    point: LatLng(_makkahCenter.latitude - 0.0009, _makkahCenter.longitude + 0.0004),
                    width: 100,
                    height: 20,
                    child: Center(
                      child: Text(
                        'Masjidil Haram',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B655B),
                        ),
                      ),
                    ),
                  ),

                  // Landmark Wilayah Makkah (Gambar 3)
                  Marker(
                    point: _shubaikahCoord,
                    width: 90,
                    height: 20,
                    child: Center(
                      child: Text(
                        'AL SHUBAIKAH',
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: _jabalOmarCoord,
                    width: 80,
                    height: 20,
                    child: Center(
                      child: Text(
                        'JABAL OMAR',
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: _misfalahCoord,
                    width: 70,
                    height: 20,
                    child: Center(
                      child: Text(
                        'MISFALAH',
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: _ajyadCoord,
                    width: 60,
                    height: 20,
                    child: Center(
                      child: Text(
                        'AJYAD',
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),

                  // Badge Jarak Mengambang di Tengah Rute Dotted Line (Gambar 4)
                  if (_isTrackingMember && _selectedMember?.latitude != null && _selectedMember?.longitude != null)
                    Marker(
                      point: LatLng(
                        (muthawwifPos.latitude + _selectedMember!.latitude!) / 2,
                        (muthawwifPos.longitude + _selectedMember!.longitude!) / 2,
                      ),
                      width: 100,
                      height: 32,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_walk_rounded, color: Color(0xFF2979FF), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              GeodesicHelper.formatDistance(_selectedMember!.distanceToMuthawwifMeters ?? 1200),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Marker Muthawwif ("Anda • Mutawwif")
                  Marker(
                    point: muthawwifPos,
                    width: 170,
                    height: 85,
                    child: _buildMuthawwifMarker(),
                  ),

                  // Marker Ringkasan Anggota Dalam Haram "+16" (Gambar 3)
                  if (!_isTrackingMember)
                    Marker(
                      point: LatLng(_makkahCenter.latitude - 0.0006, _makkahCenter.longitude - 0.0001),
                      width: 32,
                      height: 32,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1F1F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '+16',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Marker Anggota Jemaah
                  ...group.members.map((m) {
                    if (m.latitude == null || m.longitude == null) {
                      return const Marker(point: _makkahCenter, child: SizedBox());
                    }
                    return Marker(
                      point: LatLng(m.latitude!, m.longitude!),
                      width: _isTrackingMember && _selectedMember?.id == m.id ? 150 : 80,
                      height: 80,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (m.hasActiveSos) {
                            _showSosPopup(
                              AdminSosAlert(
                                id: m.id,
                                jemaahId: m.id,
                                jemaahName: m.name,
                                phone: m.phone,
                                groupName: group.code,
                                muthawwifName: group.muthawwifName,
                                locationText: m.locationText,
                                latitude: m.latitude,
                                longitude: m.longitude,
                                distanceToMuthawwifMeters: m.distanceToMuthawwifMeters,
                                createdAt: DateTime.now(),
                                status: 'received',
                              ),
                            );
                          } else {
                            _selectMember(m);
                          }
                        },
                        child: _buildMemberMarker(m),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // 2. Header Pill Mengambang di Atas (Gambar 3 vs Gambar 4)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isTrackingMember)
                      // Tombol Back & Title "Lacak Jemaah" (Gambar 4)
                      InkWell(
                        onTap: _backToGroupOverview,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back_rounded, size: 18, color: _ink),
                              const SizedBox(width: 8),
                              Text(
                                'Lacak Jemaah',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // Pill Nama Rombongan: "• Rombongan AGR-12" (Gambar 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
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
                                color: _greenLive,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rombongan ${group.code}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Map Control Floating Buttons (Kanan Atas)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFloatingMapBtn(
                          icon: Icons.layers_outlined,
                          onTap: () {},
                        ),
                        const SizedBox(height: 8),
                        _buildFloatingMapBtn(
                          icon: Icons.navigation_outlined,
                          onTap: () {
                            _mapController.move(muthawwifPos, 15.2);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildCompassBtn(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Banner Peringatan Mengambang Tepat di Atas Bottom Sheet
          if (!_isTrackingMember && group.outOfRadiusCount > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 395,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFE65100)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${group.outOfRadiusCount} jemaah di luar radius aman (> 2 km)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Banner Status Radius saat Mode Tracking Jemaah (Gambar 4)
          if (_isTrackingMember && _selectedMember != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 395,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedMember!.isOutOfRadius
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedMember!.isOutOfRadius
                        ? const Color(0xFFFFCC80)
                        : const Color(0xFFA5D6A7),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedMember!.isOutOfRadius
                          ? Icons.warning_amber_rounded
                          : Icons.shield_outlined,
                      size: 18,
                      color: _selectedMember!.isOutOfRadius
                          ? const Color(0xFFE65100)
                          : const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedMember!.isOutOfRadius
                            ? 'Di luar radius aman rombongan (> 2 km)'
                            : 'Masih dalam radius aman rombongan (< 2 km)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedMember!.isOutOfRadius
                              ? const Color(0xFFE65100)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Bottom Sheet (Gambar 3 Overview vs Gambar 4 Tracking Detail)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _isTrackingMember && _selectedMember != null
                ? AdminJemaahDetailSheet(
                    member: _selectedMember!,
                    group: group,
                    isMuthawwif: true,
                    onClose: _backToGroupOverview,
                    onCallJemaah: () => _launchPhone(_selectedMember?.phone),
                    onCallMuthawwif: () => _launchDirections(
                      _selectedMember?.latitude,
                      _selectedMember?.longitude,
                    ),
                    onDirections: () => _launchDirections(
                      _selectedMember?.latitude,
                      _selectedMember?.longitude,
                    ),
                  )
                : _buildMuthawwifGroupOverviewSheet(group),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMapBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: _ink),
      ),
    );
  }

  Widget _buildCompassBtn() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.navigation_rounded, size: 18, color: Colors.red),
          Positioned(
            bottom: 6,
            child: Text(
              'N',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuthawwifMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pill "Anda • Mutawwif" (Gambar 3)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF66BB6A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 11, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Anda · Mutawwif',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 3),
        // Avatar Muthawwif
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF66BB6A), width: 2.5),
            color: const Color(0xFFFFF3E0),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: const Center(
            child: Icon(Icons.person, color: Color(0xFF66BB6A), size: 24),
          ),
        ),
        const SizedBox(height: 2),
        // Titik Pin Hijau
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF66BB6A),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberMarker(AdminTrackingMember member) {
    // Jika sedang dalam tracking jemaah yang dipilih (Gambar 4)
    if (_isTrackingMember && _selectedMember?.id == member.id) {
      final firstName = member.name.trim().split(' ').first;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFECC485),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 10, color: Color(0xFF5D4037)),
                  const SizedBox(width: 3),
                  Text(
                    '$firstName · Jemaah',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 2.5),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Center(
              child: Text(
                member.initials,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5D4037),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (member.hasActiveSos) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _sosRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'SOS',
              style: GoogleFonts.poppins(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _sosRed,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _sosRed.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                member.initials,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (member.isOutOfRadius) {
      final distStr = member.distanceToMuthawwifMeters != null
          ? GeodesicHelper.formatDistance(member.distanceToMuthawwifMeters!)
          : '2,4 km';
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _warningOrange, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Center(
              child: Text(
                member.initials,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE65100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _warningOrange, width: 0.8),
            ),
            child: Text(
              distStr,
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      );
    }

    // Anggota Aman (Bulatan Krem / Avatar)
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF5EBE1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          member.initials,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF795548),
          ),
        ),
      ),
    );
  }

  Widget _buildMuthawwifGroupOverviewSheet(AdminDepartureGroupTrack group) {
    return Container(
      height: 380,
      decoration: const BoxDecoration(
        color: _creamBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header Bottom Sheet
          Text(
            'Jemaah Rombongan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${group.packageName} · ${group.totalJemaah} jemaah',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),

          // 3 Kolom Metrik Ringkasan (Gambar 3)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  count: group.safeCount,
                  label: 'Dalam radius',
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  count: group.outOfRadiusCount,
                  label: 'Di luar radius',
                  color: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  count: group.sosCount,
                  label: 'SOS aktif',
                  color: group.sosCount > 0 ? _sosRed : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daftar Anggota Jemaah
          // Memberikan padding bottom 95 agar tidak tertutup floating capsule navbar
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 95),
              itemCount: group.members.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: 12,
              ),
              itemBuilder: (context, index) {
                final m = group.members[index];
                return _buildMemberListItem(m, group);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberListItem(AdminTrackingMember member, AdminDepartureGroupTrack group) {
    return InkWell(
      onTap: () {
        if (member.hasActiveSos) {
          _showSosPopup(
            AdminSosAlert(
              id: member.id,
              jemaahId: member.id,
              jemaahName: member.name,
              phone: member.phone,
              groupName: group.code,
              muthawwifName: group.muthawwifName,
              locationText: member.locationText,
              latitude: member.latitude,
              longitude: member.longitude,
              distanceToMuthawwifMeters: member.distanceToMuthawwifMeters,
              createdAt: DateTime.now(),
              status: 'received',
            ),
          );
        } else {
          _selectMember(member);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: member.hasActiveSos
                    ? const Color(0xFFFFEBEE)
                    : member.isOutOfRadius
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFF5EBE1),
                border: Border.all(
                  color: member.hasActiveSos
                      ? _sosRed
                      : member.isOutOfRadius
                          ? _warningOrange
                          : _gold,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  member.initials,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: member.hasActiveSos
                        ? _sosRed
                        : member.isOutOfRadius
                            ? const Color(0xFFE65100)
                            : const Color(0xFF795548),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nama & Lokasi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.locationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Status Pill (SOS / Di luar · 2,4 km / Aman · 1,2 km)
            if (member.hasActiveSos)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _sosRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'SOS',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              )
            else if (member.isOutOfRadius)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: Text(
                  'Di luar · ${GeodesicHelper.formatDistance(member.distanceToMuthawwifMeters ?? 2400)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Text(
                  'Aman · ${GeodesicHelper.formatDistance(member.distanceToMuthawwifMeters ?? 1200)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
