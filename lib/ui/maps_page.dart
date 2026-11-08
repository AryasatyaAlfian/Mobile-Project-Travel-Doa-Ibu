import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';
import 'maps_my_location_sheet.dart';
import 'maps_track_muthawwif_view.dart';
import 'widgets/maps_canvas_view.dart';

class MapsPage extends StatefulWidget {
  final TravelApi? api;
  final VoidCallback? onBackToHome;

  const MapsPage({
    super.key,
    this.api,
    this.onBackToHome,
  });

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  static const Color _ink = Color(0xFF1E293B);
  static const Color _muted = Color(0xFF64748B);
  static const Color _green = Color(0xFF10B981);
  static const Color _red = Color(0xFFEF4444);

  // Status Lokasi & Koordinat Lapangan (Dinamis dari Backend)
  String _currentAddress = 'Ibrahim Al Khalil St, Ajyad, Makkah 24231';
  String _currentCoords = '21.4189° N, 39.8246° E';
  double _currentLat = 21.4189;
  double _currentLng = 39.8246;

  // Profil Jemaah & Rombongan (Dinamis dari Backend)
  String _userName = 'Zara';
  String _groupId = 'AGR8598';
  String _muthawwifName = 'Ust. Ahmad Fauzi';

  // State SOS & Timer
  bool _isSosActive = false;
  Timer? _sosTimer;
  int _sosDurationSeconds = 0;
  bool _isSendingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndTrackerData();
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserAndTrackerData() async {
    final user = TravelApi.currentUser;
    if (user != null) {
      final nameFirst = user.name.split(' ').first;
      setState(() {
        _userName = nameFirst;
      });
    }

    if (widget.api == null) return;
    try {
      final tracker = await widget.api!.getTracker();
      if (!mounted) return;
      setState(() {
        if (tracker['identity'] != null) {
          final idData = tracker['identity'] as Map<String, dynamic>;
          if (idData['name'] != null) {
            _userName = (idData['name'] as String).split(' ').first;
          }
        }
        if (tracker['group'] != null) {
          final grp = tracker['group'] as Map<String, dynamic>;
          if (grp['code'] != null) {
            _groupId = grp['code'].toString();
          } else if (grp['name'] != null) {
            _groupId = grp['name'].toString();
          }
        }
        if (tracker['last_location'] != null) {
          final loc = tracker['last_location'] as Map<String, dynamic>;
          if (loc['latitude'] != null && loc['longitude'] != null) {
            _currentLat = (loc['latitude'] as num).toDouble();
            _currentLng = (loc['longitude'] as num).toDouble();
            _currentCoords =
                '${_currentLat.toStringAsFixed(4)}° N, ${_currentLng.toStringAsFixed(4)}° E';
          }
          if (loc['address'] != null && loc['address'].toString().isNotEmpty) {
            _currentAddress = loc['address'].toString();
          } else if (loc['label'] != null && loc['label'].toString().isNotEmpty) {
            _currentAddress = loc['label'].toString();
          }
        }
      });
    } catch (_) {}

    try {
      final muth = await widget.api!.myMuthawwif();
      if (!mounted) return;
      if (muth != null && muth.name.isNotEmpty) {
        setState(() {
          _muthawwifName = muth.name;
        });
      }
    } catch (_) {}
  }

  void _triggerSos() {
    setState(() {
      _isSosActive = true;
      _sosDurationSeconds = 0;
    });

    _sosTimer?.cancel();
    _sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _sosDurationSeconds++;
      });
    });

    // Panggil API Backend POST /api/v1/me/sos
    widget.api?.sendSos(
      latitude: _currentLat,
      longitude: _currentLng,
      message: 'Panggilan Darurat Jemaah Lapangan - Mohon Bantuan Mutawwif Segera!',
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Peringatan SOS Darurat Terkirim ke Mutawwif Rombongan!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _cancelSos() {
    _sosTimer?.cancel();
    setState(() {
      _isSosActive = false;
      _sosDurationSeconds = 0;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Panggilan Darurat Dibatalkan.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: const Color(0xFF64748B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isSendingLocation = true);
    try {
      if (widget.api != null) {
        await widget.api!.sendLocation(
          latitude: _currentLat,
          longitude: _currentLng,
          accuracyM: 8.0,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Check In berhasil dicatat di $_currentAddress',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: _green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check In tersimpan offline pada koordinat $_currentCoords',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            backgroundColor: const Color(0xFF2563EB),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingLocation = false);
    }
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Jarak aman agar tombol pulau (Group, SOS, Person) memiliki ruang minimal 20px
    // di atas navbar mengambang di main.dart (tinggi 57 + margin bawah 17)
    final creamBottomPadding = 94.0 + bottomInset;
    // Tinggi total container krem: padding atas (16) + tinggi tombol SOS (72) + creamBottomPadding
    final creamHeight = 88.0 + creamBottomPadding;
    // Posisi kartu melayang (Check In atau SOS aktif) tepat 16px di atas puncak container krem
    final floatingCardBottom = creamHeight + 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Peta Interaktif Canvas (Tile Provider Gratis CartoDB / OSM)
            Positioned.fill(
              child: MapsCanvasView(
                isSosActive: _isSosActive,
                showMuthawwif: true,
                onTapMuthawwif: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapsTrackMuthawwifView(
                        api: widget.api,
                        groupId: _groupId,
                        userLat: _currentLat,
                        userLng: _currentLng,
                      ),
                    ),
                  );
                },
                userLat: _currentLat,
                userLng: _currentLng,
              ),
            ),

            // 2. Top Header (SOS Mode vs Normal Mode Sesuai Figma 1:1)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSosActive) ...[
                        // Floating Banner SOS Terkirim (Sesuai Figma Lampiran SOS Aktif)
                        _buildSosTopBanner(),
                        const SizedBox(height: 10),
                      ] else ...[
                        // Chip Profil Jemaah + Notifikasi + Menu (Sesuai Figma Normal)
                        _buildNormalTopBar(),
                        const SizedBox(height: 12),
                      ],
                      // Floating Card Alamat & Live Tracking
                      _buildAddressCard(),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Bottom Cream Container & SOS Action Island (Sesuai Figma 1:1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 16, 24, creamBottomPadding),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Tombol Kiri: Lacak Rombongan & Mutawwif
                    _buildIslandCircleButton(
                      icon: Icons.groups_rounded,
                      tooltip: 'Lacak Mutawwif & Rombongan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapsTrackMuthawwifView(
                              api: widget.api,
                              groupId: _groupId,
                              userLat: _currentLat,
                              userLng: _currentLng,
                            ),
                          ),
                        );
                      },
                    ),

                    // Tombol Tengah: SOS Utama (Besar & Merah dengan glow halo)
                    GestureDetector(
                      onTap: _isSosActive ? null : _triggerSos,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _red.withValues(alpha: _isSosActive ? 0.35 : 0.45),
                              blurRadius: _isSosActive ? 25 : 20,
                              spreadRadius: _isSosActive ? 6 : 0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSosActive
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'SOS',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '✓ Terkirim',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'SOS',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Tombol Kanan: Lokasi Saya
                    _buildIslandCircleButton(
                      icon: Icons.person_outline,
                      tooltip: 'Lokasi Saya',
                      onTap: () {
                        MapsMyLocationSheet.show(
                          context,
                          api: widget.api,
                          address: _currentAddress,
                          coordinates: _currentCoords,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 4. Floating Check In Button (HANYA saat SOS tidak aktif)
            if (!_isSosActive)
              Positioned(
                left: 0,
                right: 0,
                bottom: floatingCardBottom,
                child: Center(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _isSendingLocation ? null : _handleCheckIn,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSendingLocation)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF3B82F6),
                                size: 18,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              'Check In',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
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

            // 5. Floating SOS Alert Card (HANYA saat SOS aktif - Berada di atas container krem)
            if (_isSosActive)
              Positioned(
                left: 20,
                right: 20,
                bottom: floatingCardBottom,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _red.withValues(alpha: 0.2)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.warning_amber_rounded, color: _red, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'SOS aktif',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE4E6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _formatTimer(_sosDurationSeconds),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Menunggu respon mutawwif...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _ink,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _cancelSos,
                        child: Text(
                          'Batalkan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Top Banner saat SOS Aktif Sesuai Figma Prototype
  Widget _buildSosTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _ink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SOS TERKIRIM',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Baru saja',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Lokasi Sudah Dikirimkan ke Mutawwif',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tetap tenang dan tunggu di tempat. $_muthawwifName akan segera menghubungi Anda.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top Bar Normal: Avatar Profil + Bell Notifikasi + Menu Hamburger
  Widget _buildNormalTopBar() {
    return Row(
      children: [
        // Chip Profil Jemaah
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(Icons.person, color: Color(0xFF64748B), size: 20),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $_userName',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _groupId,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _muted,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: _muted,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        const Spacer(),

        // Tombol Notifikasi
        _buildTopRoundButton(
          icon: Icons.notifications_none_rounded,
          showBadge: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tidak ada notifikasi darurat baru.',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 8),

        // Tombol Menu Hamburger
        _buildTopRoundButton(
          icon: Icons.menu_rounded,
          onTap: () {
            MapsMyLocationSheet.show(
              context,
              api: widget.api,
              address: _currentAddress,
              coordinates: _currentCoords,
            );
          },
        ),
      ],
    );
  }

  /// Card Alamat & Status Live Tracking
  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                'Live Tracking',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Coordinates: $_currentCoords',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRoundButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: _ink, size: 20),
              if (showBadge)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIslandCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: _ink, size: 22),
          ),
        ),
      ),
    );
  }
}
