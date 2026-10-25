import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../models/models.dart';
import '../services/travel_api.dart';
import 'package_detail_page.dart';

/// Elysian Horizon — Homepage Jemaah (Beranda User Setelah Login)
/// Desain presisi sesuai prototipe Figma "PROTOTYPE HOMEPAGE USER" & spesifikasi DESIGN.md
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
  late Future<Paginated<TravelPackage>> _packagesFuture;
  String _selectedCategory = 'ALL';

  // Filter Keberangkatan State
  String _departureCity = 'CGK(Soekarno Hatta) - JAKARTA';
  String _duration = '10 Hari';
  String _peopleCount = '2 Orang';

  final List<String> _categories = const [
    'ALL',
    'Haji & Umrah',
    'Domestik',
    'Internasional',
    'Open Trip',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPackages();
    _initUser();
  }

  void _initUser() {
    if (TravelApi.currentUser != null) return;

    if (widget.api.client.token != null) {
      widget.api.me().then((u) {
        if (mounted && u != null) setState(() {});
      }).catchError((_) {});
    } else {
      widget.api.login('test@example.com', 'Password123!').then((u) {
        if (mounted) setState(() {});
      }).catchError((_) {});
    }
  }

  void _fetchPackages() {
    String? categoryParam;
    if (_selectedCategory == 'Haji & Umrah') {
      categoryParam = 'umrah';
    } else if (_selectedCategory == 'Domestik') {
      categoryParam = 'wisata-domestik';
    } else if (_selectedCategory == 'Internasional') {
      categoryParam = 'wisata-internasional';
    } else if (_selectedCategory == 'Open Trip') {
      categoryParam = 'open-trip';
    }

    _packagesFuture = widget.api.packages(
      category: categoryParam,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _fetchPackages();
    });
    await _packagesFuture.catchError((_) => Paginated<TravelPackage>(
          items: [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
        ));
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _fetchPackages();
    });
  }

  void _selectDepartureCity() {
    final cities = [
      'CGK(Soekarno Hatta) - JAKARTA',
      'SUB(Juanda) - SURABAYA',
      'KNO(Kualanamu) - MEDAN',
      'DPS(Ngurah Rai) - BALI',
      'BDO(Husein Sastranegara) - BANDUNG',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Pilih Kota Keberangkatan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.elysianSecondary,
                    ),
                  ),
                ),
                const Divider(),
                ...cities.map((city) {
                  return ListTile(
                    leading: const Icon(Icons.flight_takeoff_rounded, color: AppColors.elysianAccentBlue),
                    title: Text(city, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                    trailing: _departureCity == city
                        ? const Icon(Icons.check_circle, color: AppColors.elysianAccentBlue)
                        : null,
                    onTap: () {
                      setState(() => _departureCity = city);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectDuration() {
    final durations = ['3 Hari', '5 Hari', '7 Hari', '10 Hari', '12 Hari', '15 Hari'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Pilih Durasi Perjalanan',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              ...durations.map((d) => ListTile(
                    leading: const Icon(Icons.calendar_today_outlined, color: AppColors.elysianAccentBlue),
                    title: Text(d, style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: _duration == d ? const Icon(Icons.check_circle, color: AppColors.elysianAccentBlue) : null,
                    onTap: () {
                      setState(() => _duration = d);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _selectPeople() {
    final counts = ['1 Orang', '2 Orang', '3 Orang', '4 Orang', '5+ Orang (Rombongan)'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Pilih Jumlah Orang',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              ...counts.map((c) => ListTile(
                    leading: const Icon(Icons.people_outline_rounded, color: AppColors.elysianAccentBlue),
                    title: Text(c, style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: _peopleCount == c ? const Icon(Icons.check_circle, color: AppColors.elysianAccentBlue) : null,
                    onTap: () {
                      setState(() => _peopleCount = c);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        color: AppColors.elysianAccentBlue,
        backgroundColor: Colors.white,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90), // Space for floating bottom nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Curved Blue Canopy / Header (Figma)
              _buildCurvedHeader(),

              // 2. Booking Filter Box (Floating Card)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildBookingFilterBox(),
              ),

              // 2.5 Akses Bimbingan Muthawwif (Elysian Horizon)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildMuthawwifBanner(),
              ),

              // 3. Category Filter Chips (Pill Geometri)
              _buildCategoryChips(),
              const SizedBox(height: 8),

              // 4. Destination Cards List (Feed)
              _buildDestinationCardsList(),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Curved Blue Canopy Header
  Widget _buildCurvedHeader() {
    final user = TravelApi.currentUser;
    final userName = user?.name ?? 'User';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.elysianPrimary, // #9DBED8
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Row(
        children: [
          // User Avatar with White Halo (dapat diklik untuk melihat detail akun & logout)
          GestureDetector(
            onTap: _showUserProfileModal,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.elysianSecondary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildInitialsAvatar(userName),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Greeting & Name (Diambil dari kolom name user yang login dari backend)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.elysianSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Hi, '),
                      TextSpan(
                        text: userName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'selamat pagi!',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.elysianSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          // Header Action Buttons (Search & Notifications)
          _buildHeaderCircleButton(
            icon: Icons.search,
            onTap: () {
              if (widget.onExplorePackages != null) {
                widget.onExplorePackages!();
              }
            },
          ),
          const SizedBox(width: 8),
          _buildHeaderCircleButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tidak ada pemberitahuan baru saat ini.',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  backgroundColor: AppColors.elysianAccentBlue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.elysianSecondary, size: 20),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final cleanName = name.trim();
    final parts = cleanName.split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (cleanName.isNotEmpty ? cleanName[0].toUpperCase() : 'TU');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5E89B0),
            Color(0xFF234C6A),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 2.5 Banner Akses Bimbingan Muthawwif
  Widget _buildMuthawwifBanner() {
    return InkWell(
      onTap: () {
        if (widget.onConsultation != null) {
          widget.onConsultation!();
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF234C6A), Color(0xFF3B6E94)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF234C6A).withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.supervisor_account_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bimbingan Muthawwif',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Konsultasi ibadah & cek status pembimbing Anda',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfileModal() {
    final user = TravelApi.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9DBED8), width: 2.5),
                ),
                child: ClipOval(child: _buildInitialsAvatar(user?.name ?? 'User')),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Tamu',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'Belum login',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0FD),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  user?.roleLabel ?? 'Jemaah',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF234C6A),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.supervisor_account_outlined, color: Color(0xFF234C6A)),
                title: Text(
                  'Bimbingan Muthawwif',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Cek muthawwif pembimbing ibadah Anda',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onConsultation?.call();
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: [
                            const Icon(Icons.logout_rounded, color: Color(0xFFE11D48), size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Konfirmasi Keluar',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        content: Text(
                          'Apakah Anda yakin ingin keluar dari akun Travel Doa Ibu?',
                          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('Batal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Keluar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                    if (shouldLogout == true && widget.onLogout != null) {
                      widget.onLogout!();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE11D48)),
                  label: Text(
                    'Keluar dari Akun',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                    backgroundColor: const Color(0xFFFFF1F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 2. Booking Filter Box (Floating Card dengan border geometris)
  Widget _buildBookingFilterBox() {
    return Container(
      transform: Matrix4.translationValues(0, -14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.elysianSecondary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Kota Keberangkatan
          InkWell(
            onTap: _selectDepartureCity,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.elysianSecondary.withValues(alpha: 0.8), width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: AppColors.elysianSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kota Keberangkatan',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppColors.elysianTextMuted,
                          ),
                        ),
                        Text(
                          _departureCity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.elysianSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.elysianSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Row 2: Durasi Perjalanan & Jumlah Orang
          Row(
            children: [
              // Durasi
              Expanded(
                child: InkWell(
                  onTap: _selectDuration,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.elysianSecondary.withValues(alpha: 0.8), width: 1.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.elysianSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Durasi Perjalanan',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.elysianTextMuted,
                                ),
                              ),
                              Text(
                                _duration,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.elysianSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.elysianSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Jumlah Orang
              Expanded(
                child: InkWell(
                  onTap: _selectPeople,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.elysianSecondary.withValues(alpha: 0.8), width: 1.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people_outline_rounded, size: 18, color: AppColors.elysianSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jumlah Orang',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.elysianTextMuted,
                                ),
                              ),
                              Text(
                                _peopleCount,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.elysianSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.elysianSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Action Button "CARI JADWAL & KEBERANGKATAN"
          InkWell(
            onTap: _refresh,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.elysianSecondary, width: 1.4),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.elysianSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'CARI JADWAL & KEBERANGKATAN',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.elysianSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Category Filter Chips (Horizontal)
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _onCategorySelected(category),
              borderRadius: BorderRadius.circular(9999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.elysianPrimary
                      : AppColors.elysianPrimary.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.elysianPrimary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 4. Destination Cards Feed
  Widget _buildDestinationCardsList() {
    return FutureBuilder<Paginated<TravelPackage>>(
      future: _packagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.elysianAccentBlue),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.cloud_off, size: 40, color: AppColors.elysianAccentBlue),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal memuat paket wisata.',
                    style: GoogleFonts.poppins(color: AppColors.elysianSecondary),
                  ),
                  TextButton(
                    onPressed: _refresh,
                    child: Text('Coba Lagi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }

        final packages = snapshot.data?.items ?? [];

        if (packages.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Tidak ada paket wisata pada kategori ini.',
                style: GoogleFonts.poppins(color: AppColors.elysianTextMuted),
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: packages.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            final pkg = packages[index];
            return _buildPackageCard(pkg);
          },
        );
      },
    );
  }

  /// Kartu Destinasi Sesuai Figma Prototype
  Widget _buildPackageCard(TravelPackage pkg) {
    final categoryName = pkg.category?.name ?? 'Paket Pilihan';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackageDetailPage(package: pkg, api: widget.api),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gambar Destinasi dengan Badge Kategori
              Stack(
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: pkg.image != null
                        ? Image.network(
                            pkg.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  // Frosted Category Pill Badge (Top-Left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      child: Text(
                        categoryName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.elysianTextMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Banner Informasi Biru Horizon (#9DBED8) di Bagian Bawah
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: AppColors.elysianPrimary, // #9DBED8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.elysianSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pkg.excerpt ??
                          [pkg.category?.name, pkg.duration, pkg.formattedPrice]
                              .whereType<String>()
                              .join(' • '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        height: 1.35,
                        color: AppColors.elysianSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Baris Aksi Lihat Detail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.elysianSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: AppColors.elysianSecondary,
                        ),
                      ],
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

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      color: AppColors.elysianTertiary,
      child: const Center(
        child: Icon(Icons.landscape_rounded, size: 48, color: AppColors.elysianPrimary),
      ),
    );
  }
}
