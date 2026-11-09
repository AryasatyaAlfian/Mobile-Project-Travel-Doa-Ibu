import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/smooth_page_route.dart';
import '../../models/muthawwif_models.dart';
import '../../services/travel_api.dart';
import 'muthawwif_group_detail_page.dart';
import 'muthawwif_itinerary_page.dart';

/// Halaman Home / Layanan Mutawwif (Gambar 1, Screen 1).
/// Menyediakan akses ke Detail Rombongan dan Jadwal Kegiatan Manasik/Ibadah.
class MuthawwifHomePage extends StatefulWidget {
  const MuthawwifHomePage({
    super.key,
    required this.api,
    this.onOpenMaps,
  });

  final TravelApi api;
  final VoidCallback? onOpenMaps;

  @override
  State<MuthawwifHomePage> createState() => _MuthawwifHomePageState();
}

class _MuthawwifHomePageState extends State<MuthawwifHomePage> {
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _goldAccent = Color(0xFFE5B56E);

  MuthawwifGroupInfo? _groupInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    setState(() => _isLoading = true);
    try {
      final groups = await widget.api.getDepartures();
      if (groups.isNotEmpty) {
        _groupInfo = MuthawwifGroupInfo.fromBackend(
          groupData: groups.first,
          fallbackMuthawwifName: widget.api.user?.name,
          fallbackMuthawwifPhone: widget.api.user?.phone,
        );
      }
    } catch (_) {}

    _groupInfo ??= MuthawwifGroupInfo.defaultPreset(
      muthawwifName: widget.api.user?.name,
      muthawwifPhone: widget.api.user?.phone,
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _groupInfo == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(color: _gold),
        ),
      );
    }

    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + 115.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Ka'bah Malam
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Image.asset(
              'assets/images/Header Bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/images/Background.webp',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // 2. Konten Scrollable
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar Title "Mutawwif" (Emas Tengah)
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        'Mutawwif',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _gold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Floating Card Utama (Ilustrasi Jamaah & Ka'bah + Title Layanan Mutawwif)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Ilustrasi Ka'bah & Rombongan
                        Container(
                          width: double.infinity,
                          height: 130,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF6EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ikon Ka'bah Stylized di tengah
                              Positioned(
                                top: 16,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1B18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _gold, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gold.withValues(alpha: 0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 46,
                                      height: 6,
                                      margin: const EdgeInsets.only(bottom: 22),
                                      color: _gold,
                                    ),
                                  ),
                                ),
                              ),
                              // Baris Avatar Rombongan di Depan Ka'bah
                              Positioned(
                                bottom: 12,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildPilgrimAvatar(Icons.face_3_rounded, 28, const Color(0xFF2C3E50)),
                                    const SizedBox(width: 6),
                                    _buildPilgrimAvatar(Icons.face_rounded, 34, _goldAccent),
                                    const SizedBox(width: 6),
                                    _buildPilgrimAvatar(Icons.person_rounded, 40, _ink),
                                    const SizedBox(width: 6),
                                    _buildPilgrimAvatar(Icons.face_rounded, 34, _goldAccent),
                                    const SizedBox(width: 6),
                                    _buildPilgrimAvatar(Icons.face_3_rounded, 28, const Color(0xFF2C3E50)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Headline
                        Text(
                          'Layanan Mutawwif',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'Pendamping perjalanan ibadah\nAnda di Tanah Suci.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Menu Card 1: Detail Rombongan
                  _buildServiceCard(
                    icon: Icons.groups_rounded,
                    title: 'Detail Rombongan',
                    subtitle: 'Lihat informasi dan anggota\nrombongan Anda',
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(
                          page: MuthawwifGroupDetailPage(
                            api: widget.api,
                            group: _groupInfo ?? MuthawwifGroupInfo.defaultPreset(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Menu Card 2: Jadwal Kegiatan
                  _buildServiceCard(
                    icon: Icons.calendar_today_rounded,
                    title: 'Jadwal Kegiatan',
                    subtitle: 'Lihat dan kelola jadwal kegiatan\nperjalanan (checklist)',
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(
                          page: MuthawwifItineraryPage(
                            api: widget.api,
                            group: _groupInfo ?? MuthawwifGroupInfo.defaultPreset(),
                          ),
                        ),
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

  Widget _buildPilgrimAvatar(IconData icon, double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.6, color: color),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1E7D5), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon Bulat Krem Keemasan
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EEDF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFFC89745), size: 24),
                ),
                const SizedBox(width: 16),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _muted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _ink,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

