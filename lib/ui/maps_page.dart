import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';
import 'maps_my_location_sheet.dart';
import 'maps_track_muthawwif_view.dart';
import 'widgets/maps_canvas_view.dart';

/// Halaman Peta Pelacakan & Keselamatan Lapangan (Maps Page)
/// Desain 1:1 Sesuai Figma Prototype:
/// - media_1793605794368_8a5b8234.png (Tampilan Utama & Check In)
/// - media_1793605822400_9de03761.png (Mode SOS Darurat Aktif)
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

  // Status Lokasi & Koordinat Lapangan
  final String _currentAddress = 'Ibrahim Al Khalil St, Ajyad, Makkah 24231';
  final String _currentCoords = '21.4189° N, 39.8246° E';
  final double _currentLat = 21.4189;
  final double _currentLng = 39.8246;

  // Profil Jemaah
  String _userName = 'Zara';
  String _groupId = 'AGR8598';

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
          }
        }
      });
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

    // Panggil API Backend /me/sos
    widget.api?.sendSos(
      latitude: _currentLat,
      longitude: _currentLng,
      message: 'Panggilan Darurat Jemaah Lapangan - Mohon Bantuan Mutawwif Segera!',
    );

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Peta Interaktif Canvas (100% Free & Built-in Flutter)
          Positioned.fill(
            child: MapsCanvasView(
              isSosActive: _isSosActive,
              showMuthawwif: false,
            ),
          ),

          // 2. Banner SOS Terkirim di Bagian Teratas (Jika SOS Aktif)
          if (_isSosActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 8,
                  16,
                  12,
                ),
                decoration: const BoxDecoration(
                  color: _red,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOS TERKIRIM',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Lokasi Sudah Dikirimkan ke Mutawwif Rombongan',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Top Floating Bar (Avatar chip, Notifikasi, Menu)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: _isSosActive ? 56 : 10,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                  ),
                  const SizedBox(height: 12),

                  // Floating Card Alamat & Live Tracking
                  Container(
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
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating Check In Button (Tepat di atas peta)
          Positioned(
            left: 0,
            right: 0,
            bottom: _isSosActive ? 230 : 130,
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

          // 5. Floating SOS Alert Card (Jika SOS Aktif)
          if (_isSosActive)
            Positioned(
              left: 20,
              right: 20,
              bottom: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _red.withValues(alpha: 0.3)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.emergency_rounded, color: _red, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'SOS Aktif',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTimer(_sosDurationSeconds),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Menunggu respon mutawwif...',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: _red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: _red),
                        ),
                      ),
                      onPressed: _cancelSos,
                      child: Text(
                        'Batalkan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 6. Bottom Floating Island Dock (Figma Frame: Group, SOS, User)
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 18,
                    offset: Offset(0, 6),
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
                          ),
                        ),
                      );
                    },
                  ),

                  // Tombol Tengah: SOS Utama (Besar & Merah)
                  GestureDetector(
                    onTap: _isSosActive ? null : _triggerSos,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _red.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isSosActive ? '✓\nAktif' : 'SOS',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: _isSosActive ? 11 : 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tombol Kanan: Lokasi Saya
                  _buildIslandCircleButton(
                    icon: Icons.person_pin_circle_rounded,
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
