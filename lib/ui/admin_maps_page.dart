import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../models/admin_tracking_models.dart';
import '../services/travel_api.dart';
import 'widgets/admin_group_list_sheet.dart';
import 'widgets/admin_jemaah_detail_sheet.dart';
import 'widgets/admin_muthawwif_sheet.dart';
import 'widgets/admin_sos_alert_dialog.dart';

enum AdminMapsMode {
  overview,
  muthawwif,
  jemaah,
}

/// Halaman Peta Administrasi & Monitoring Lapangan (Gambar 1, 2, 3, 4).
class AdminMapsPage extends StatefulWidget {
  const AdminMapsPage({
    super.key,
    required this.api,
    this.initialAlert,
  });

  final TravelApi api;
  final AdminSosAlert? initialAlert;

  @override
  State<AdminMapsPage> createState() => _AdminMapsPageState();
}

class _AdminMapsPageState extends State<AdminMapsPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  AdminMapsMode _mode = AdminMapsMode.overview;
  String _selectedCity = 'Semua';
  String _searchQuery = '';

  bool _isLoading = true;
  List<AdminDepartureGroupTrack> _allGroups = [];
  List<AdminSosAlert> _sosAlerts = [];
  AdminDepartureGroupTrack? _selectedGroup;
  AdminTrackingMember? _selectedMember;

  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _gold = Color(0xFFECC485);
  static const Color _sosRed = Color(0xFFD32F2F);

  // Titik default Makkah (Masjidil Haram)
  static const LatLng _makkahCenter = LatLng(21.4225, 39.8262);

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.initialAlert != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSosPopup(widget.initialAlert!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final rawGroups = await widget.api.getAdminDepartureGroups();
      final rawSos = await widget.api.getSosReports(status: 'received');

      final sosList = rawSos.map((s) => AdminSosAlert.fromJson(s)).toList();

      final List<AdminDepartureGroupTrack> tracks = [];
      for (final g in rawGroups) {
        final id = (g['id'] as num?)?.toInt() ?? 0;
        final name = (g['name'] as String?) ?? 'AGR-01';
        final pkg = g['package'] as Map<String, dynamic>?;
        final pkgName = (pkg?['name'] as String?) ?? 'Paket Umrah';
        final muth = g['muthawwif'] as Map<String, dynamic>?;
        final muthName = (muth?['name'] as String?) ?? 'Ust. Ahmad Fauzi';
        final muthPhone = muth?['phone'] as String?;
        final memberCount = (g['members_count'] as num?)?.toInt() ?? 0;

        // Ambil data tracker anggota untuk grup ini
        final trackerData = await widget.api.getDepartureGroupTracker(id);
        final rawMembers = (trackerData['members'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        // Deteksi kota dari nama paket
        String city = 'Makkah';
        final lowerPkg = pkgName.toLowerCase();
        if (lowerPkg.contains('madinah')) {
          city = 'Madinah';
        } else if (lowerPkg.contains('turki') || lowerPkg.contains('istanbul')) {
          city = 'Istanbul';
        }

        // Koordinat acuan pusat grup
        double centerLat = _makkahCenter.latitude + (id % 3) * 0.003;
        double centerLon = _makkahCenter.longitude + (id % 2) * 0.003;

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
        final sosInGroup = sosList.where((s) => s.groupName == name || s.groupName == pkgName).length;

        tracks.add(AdminDepartureGroupTrack(
          id: id,
          code: name,
          packageName: pkgName,
          city: city,
          muthawwifId: (muth?['id'] as num?)?.toInt() ?? 0,
          muthawwifName: muthName,
          muthawwifPhone: muthPhone,
          muthawwifLat: centerLat,
          muthawwifLon: centerLon,
          totalJemaah: members.isNotEmpty ? members.length : memberCount,
          safeCount: safe,
          outOfRadiusCount: outOfRad,
          sosCount: sosInGroup,
          members: members,
        ));
      }

      setState(() {
        _allGroups = tracks;
        _sosAlerts = sosList;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<AdminDepartureGroupTrack> get _filteredGroups {
    return _allGroups.where((g) {
      if (_selectedCity != 'Semua' && g.city != _selectedCity) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchGroup = g.code.toLowerCase().contains(query) ||
            g.packageName.toLowerCase().contains(query) ||
            g.muthawwifName.toLowerCase().contains(query);
        final matchMember = g.members.any((m) => m.name.toLowerCase().contains(query));
        return matchGroup || matchMember;
      }
      return true;
    }).toList();
  }

  AdminMapsOverview get _currentOverview {
    final groups = _filteredGroups;
    int totalJemaah = 0;
    int safeCount = 0;
    int outOfRad = 0;
    int sosCount = 0;

    for (final g in groups) {
      totalJemaah += g.totalJemaah;
      safeCount += g.safeCount;
      outOfRad += g.outOfRadiusCount;
      sosCount += g.sosCount;
    }

    return AdminMapsOverview(
      totalGroups: groups.length,
      totalJemaah: totalJemaah,
      safeCount: safeCount,
      outOfRadiusCount: outOfRad,
      sosActiveCount: sosCount,
      groups: groups,
      activeAlerts: _sosAlerts,
    );
  }

  void _showSosPopup(AdminSosAlert alert) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdminSosAlertDialog(
        alert: alert,
        onViewLocation: () {
          Navigator.of(ctx).pop();
          _focusOnSosAlert(alert);
        },
        onCallJemaah: () {
          _contactPerson(alert.jemaahName, alert.phone ?? 'Nomor tidak tersedia');
        },
        onCallMuthawwif: () {
          _contactPerson(alert.muthawwifName, alert.muthawwifPhone ?? 'Nomor muthawwif');
        },
      ),
    );
  }

  void _focusOnSosAlert(AdminSosAlert alert) {
    AdminDepartureGroupTrack? targetGroup;
    AdminTrackingMember? targetMember;

    for (final g in _allGroups) {
      for (final m in g.members) {
        if (m.id == alert.jemaahId || m.name.toLowerCase() == alert.jemaahName.toLowerCase()) {
          targetGroup = g;
          targetMember = m;
          break;
        }
      }
      if (targetGroup != null) break;
    }

    targetGroup ??= _allGroups.isNotEmpty ? _allGroups.first : null;
    if (targetGroup != null) {
      targetMember ??= targetGroup.members.isNotEmpty
          ? targetGroup.members.first
          : AdminTrackingMember(
              id: alert.jemaahId,
              name: alert.jemaahName,
              phone: alert.phone,
              latitude: alert.latitude ?? targetGroup.centerLatitude + 0.002,
              longitude: alert.longitude ?? targetGroup.centerLongitude + 0.002,
              locationText: alert.locationText,
              hasActiveSos: true,
              distanceToMuthawwifMeters: alert.distanceToMuthawwifMeters,
            );

      setState(() {
        _selectedGroup = targetGroup;
        _selectedMember = targetMember;
        _mode = AdminMapsMode.jemaah;
      });

      if (targetMember.latitude != null && targetMember.longitude != null) {
        _mapController.move(
          LatLng(targetMember.latitude!, targetMember.longitude!),
          16.5,
        );
      }
    }
  }

  void _selectGroup(AdminDepartureGroupTrack group) {
    setState(() {
      _selectedGroup = group;
      _mode = AdminMapsMode.muthawwif;
    });
    _mapController.move(
      LatLng(group.centerLatitude, group.centerLongitude),
      16.0,
    );
  }

  void _selectMember(AdminTrackingMember member) {
    setState(() {
      _selectedMember = member;
      _mode = AdminMapsMode.jemaah;
    });
    if (member.latitude != null && member.longitude != null) {
      _mapController.move(
        LatLng(member.latitude!, member.longitude!),
        16.8,
      );
    }
  }

  void _contactPerson(String name, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menghubungi $name ($phone)...'),
        backgroundColor: const Color(0xFF191614),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overview = _currentOverview;
    final activeSos = _sosAlerts.isNotEmpty ? _sosAlerts.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Interactive Map Canvas (flutter_map)
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _makkahCenter,
              initialZoom: 15.2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.traveldoaibu.mobile',
              ),

              // Garis Rute Jemaah <-> Muthawwif (jika di mode Jemaah)
              if (_mode == AdminMapsMode.jemaah &&
                  _selectedMember?.latitude != null &&
                  _selectedMember?.longitude != null &&
                  _selectedGroup != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        LatLng(_selectedMember!.latitude!, _selectedMember!.longitude!),
                        LatLng(_selectedGroup!.centerLatitude, _selectedGroup!.centerLongitude),
                      ],
                      strokeWidth: 3.5,
                      color: const Color(0xFF2979FF),
                    ),
                  ],
                ),

              // Radius Aman 2km Sekitar Muthawwif
              if (_selectedGroup != null && _mode != AdminMapsMode.overview)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(_selectedGroup!.centerLatitude, _selectedGroup!.centerLongitude),
                      radius: 120,
                      useRadiusInMeter: true,
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),

              // Marker Layers
              MarkerLayer(
                markers: _buildMapMarkers(),
              ),
            ],
          ),

          // 2. Top Header & Floating Search Area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_mode == AdminMapsMode.overview) ...[
                    // Search Bar Melayang (Gambar 1)
                    _buildFloatingSearchBar(),
                    const SizedBox(height: 10),

                    // Filter Kota Chips (Gambar 1)
                    _buildCityFilterChips(),
                    const SizedBox(height: 10),

                    // SOS Top Banner (Merah Melayang, Gambar 1)
                    if (activeSos != null) _buildTopSosBanner(activeSos),
                  ] else ...[
                    // Header Bar Kembali (Gambar 3 & 4)
                    _buildDetailTopBar(),
                  ],
                ],
              ),
            ),
          ),

          // 3. Floating Map Controls (Layer, Locate Me, Compass di Kanan Atas)
          if (_mode != AdminMapsMode.overview)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              right: 16,
              child: _buildFloatingMapControls(),
            ),

          // 4. Floating Safe Radius Pill (Gambar 4 di Bawah Map)
          if (_mode == AdminMapsMode.jemaah && _selectedMember != null)
            Positioned(
              bottom: 380,
              left: 20,
              right: 20,
              child: _buildRadiusSafetyPill(_selectedMember!),
            ),

          // 5. Bottom Sheets Interaktif
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildActiveBottomSheet(overview),
          ),

          // Loading Indicator
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: _gold,
              ),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMapMarkers() {
    final List<Marker> markers = [];

    if (_mode == AdminMapsMode.overview) {
      // Cluster Bubbles (Gambar 1)
      for (final g in _filteredGroups) {
        Color bubbleColor = const Color(0xFF7E57C2); // default ungu
        bool showExclamation = false;
        String badgeText = '';

        if (g.sosCount > 0) {
          bubbleColor = _sosRed;
          showExclamation = true;
        } else if (g.outOfRadiusCount > 0) {
          bubbleColor = const Color(0xFFE5B869);
          badgeText = '${g.outOfRadiusCount}';
        }

        markers.add(
          Marker(
            point: LatLng(g.centerLatitude, g.centerLongitude),
            width: 70,
            height: 75,
            child: GestureDetector(
              onTap: () => _selectGroup(g),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: bubbleColor.withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${g.totalJemaah}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (showExclamation)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: _sosRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '!',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (badgeText.isNotEmpty)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE65100),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                badgeText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Text(
                      g.code,
                      style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w700, color: _ink),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      // Muthawwif & Jemaah Marker (Gambar 3 & 4)
      final group = _selectedGroup;
      if (group != null) {
        // Marker Muthawwif
        markers.add(
          Marker(
            point: LatLng(group.centerLatitude, group.centerLongitude),
            width: 90,
            height: 70,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, size: 10, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        group.muthawwifName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      group.muthawwifInitials,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF2E7D32)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        // Marker Tiap Jemaah
        for (final m in group.members) {
          if (m.latitude == null || m.longitude == null) continue;

          Color badgeColor = Colors.grey.shade400;
          if (m.hasActiveSos) {
            badgeColor = _sosRed;
          } else if (m.isOutOfRadius) {
            badgeColor = const Color(0xFFE65100);
          }

          final bool isSelected = _selectedMember?.id == m.id;

          markers.add(
            Marker(
              point: LatLng(m.latitude!, m.longitude!),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => _selectMember(m),
                child: Column(
                  children: [
                    Container(
                      width: isSelected ? 34 : 28,
                      height: isSelected ? 34 : 28,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 1.5),
                        boxShadow: isSelected
                            ? [BoxShadow(color: badgeColor.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          m.initials,
                          style: TextStyle(
                            fontSize: isSelected ? 11 : 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (m.hasActiveSos)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: _sosRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('SOS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  Widget _buildFloatingSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.poppins(fontSize: 13, color: _ink),
        decoration: InputDecoration(
          hintText: 'Cari grup atau nama jemaah',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF8D6E63)),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCityFilterChips() {
    final cities = ['Semua', 'Makkah', 'Madinah', 'Istanbul'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cities.map((city) {
          final isSelected = _selectedCity == city;
          int count = _allGroups.length;
          if (city != 'Semua') {
            count = _allGroups.where((g) => g.city == city).length;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedCity = city),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? _gold : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Text(
                  '$city · $count',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: _ink,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopSosBanner(AdminSosAlert alert) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _sosRed,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SOS · ${alert.jemaahName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${alert.groupName} · ${alert.locationText} · ${alert.timeAgo}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _focusOnSosAlert(alert),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _sosRed,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Lihat',
              style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTopBar() {
    final title = _mode == AdminMapsMode.jemaah
        ? 'Lacak Jemaah'
        : '${_selectedGroup?.code ?? ''} · ${_selectedGroup?.packageName ?? ''}';

    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (_mode == AdminMapsMode.jemaah && _selectedGroup != null) {
                _mode = AdminMapsMode.muthawwif;
              } else {
                _mode = AdminMapsMode.overview;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded, size: 18, color: _ink),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingMapControls() {
    return Column(
      children: [
        _buildCircleControlButton(
          icon: Icons.layers_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lapisan peta: Standar OSM aktif.')),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildCircleControlButton(
          icon: Icons.near_me_outlined,
          onTap: () {
            if (_selectedGroup != null) {
              _mapController.move(
                LatLng(_selectedGroup!.centerLatitude, _selectedGroup!.centerLongitude),
                16.0,
              );
            } else {
              _mapController.move(_makkahCenter, 15.2);
            }
          },
        ),
        const SizedBox(height: 8),
        _buildCircleControlButton(
          icon: Icons.explore_outlined,
          color: _sosRed,
          onTap: () {
            _mapController.rotate(0.0);
          },
        ),
      ],
    );
  }

  Widget _buildCircleControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color ?? _ink, size: 20),
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildRadiusSafetyPill(AdminTrackingMember member) {
    final bool isSafe = !member.isOutOfRadius;
    final color = isSafe ? const Color(0xFF4CAF50) : const Color(0xFFE65100);
    final text = isSafe
        ? 'Masih dalam radius aman rombongan (< 2 km)'
        : 'Di luar radius aman rombongan (> 2 km)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSafe ? Icons.verified_user_rounded : Icons.warning_amber_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBottomSheet(AdminMapsOverview overview) {
    switch (_mode) {
      case AdminMapsMode.overview:
        return AdminGroupListSheet(
          overview: overview,
          onSelectGroup: _selectGroup,
        );
      case AdminMapsMode.muthawwif:
        if (_selectedGroup == null) return const SizedBox.shrink();
        return AdminMuthawwifSheet(
          group: _selectedGroup!,
          onSelectMember: _selectMember,
          onCallMuthawwif: () {
            _contactPerson(
              _selectedGroup!.muthawwifName,
              _selectedGroup!.muthawwifPhone ?? 'Nomor muthawwif',
            );
          },
        );
      case AdminMapsMode.jemaah:
        if (_selectedMember == null || _selectedGroup == null) return const SizedBox.shrink();
        return AdminJemaahDetailSheet(
          member: _selectedMember!,
          group: _selectedGroup!,
          onClose: () {
            setState(() => _mode = AdminMapsMode.muthawwif);
          },
          onCallJemaah: () {
            _contactPerson(
              _selectedMember!.name,
              _selectedMember!.phone ?? 'Nomor jemaah',
            );
          },
          onCallMuthawwif: () {
            _contactPerson(
              _selectedGroup!.muthawwifName,
              _selectedGroup!.muthawwifPhone ?? 'Nomor muthawwif',
            );
          },
        );
    }
  }
}

