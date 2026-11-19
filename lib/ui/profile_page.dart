import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/smooth_page_route.dart';
import '../core/storage/app_storage.dart';
import '../models/models.dart';
import '../services/travel_api.dart';
import 'profile_account_info_page.dart';
import 'profile_digital_payment_page.dart';
import 'profile_logout_page.dart';
import 'profile_security_page.dart';
import 'profile_settings_page.dart';
import 'widgets/skeleton_view.dart';

/// Halaman Profil Utama Pengguna (Profile)
/// Layout 1:1 Presisi Sesuai Figma Prototype Profile:
/// Header Ka'bah malam, Kartu Profil Melayang di atas Header, dan Menu Akun
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.api,
    required this.onLogout,
    this.onNavigateToMuthawwif,
    this.isAdmin = false,
    this.isMuthawwif = false,
  });

  final TravelApi api;
  final VoidCallback onLogout;
  final VoidCallback? onNavigateToMuthawwif;
  final bool isAdmin;
  final bool isMuthawwif;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _handleRefresh(silent: true);
  }

  Future<void> _handleRefresh({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      await widget.api.me();
      final data = await widget.api.getProfile();
      if (mounted) {
        setState(() {
          _profileData = data;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  DepartureGroupItem? get _departureGroup {
    final dg = _profileData?['departure_group'];
    if (dg is Map<String, dynamic>) {
      try {
        return DepartureGroupItem.fromJson(dg);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  bool get _isAccommodationUpdated {
    final group = _departureGroup;
    if (group == null || group.accommodationUpdatedAt == null) return false;
    final seen = AppStorage.instance.get('profile_seen_acc_${group.id}');
    if (seen == null || seen.isEmpty) return true;
    try {
      final updatedDt = DateTime.parse(group.accommodationUpdatedAt!);
      final seenDt = DateTime.parse(seen);
      return updatedDt.isAfter(seenDt);
    } catch (_) {
      return false;
    }
  }

  void _markAccommodationSeen() {
    final group = _departureGroup;
    if (group != null && group.accommodationUpdatedAt != null) {
      AppStorage.instance.set('profile_seen_acc_${group.id}', DateTime.now().toIso8601String());
      if (mounted) setState(() {});
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await Navigator.push<bool>(
      context,
      SmoothPageRoute(
        page: ProfileLogoutPage(
          api: widget.api,
        ),
      ),
    );

    if (shouldLogout != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Anda telah berhasil keluar dari akun Travel Doa Ibu.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: _ink,
      ),
    );

    widget.onLogout();
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isRoleAdmin = widget.isAdmin || (TravelApi.currentUser?.isAdmin ?? false);
    final isRoleMuthawwif = widget.isMuthawwif || (TravelApi.currentUser?.isMuthawwif ?? false);
    final isStaff = isRoleAdmin || isRoleMuthawwif;
    final user = TravelApi.currentUser ?? widget.api.user;
    final userName = (user?.name != null && user!.name.isNotEmpty)
        ? user.name
        : (isRoleAdmin ? 'Raina' : (isRoleMuthawwif ? 'Ust. Felix Siauw' : 'Jemaah'));
    final userEmail = (user?.email != null && user!.email.isNotEmpty)
        ? user.email
        : (isRoleAdmin ? 'raina@gmail.com' : (isRoleMuthawwif ? 'felix@traveldoaibu.test' : 'jemaah@traveldoaibu.com'));
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + 115.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Ka'bah Malam di Latar Belakang (Berhenti di separuh atas kartu profil)
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
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: _ink,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar: Judul Halaman "Profile" (Tinggi 44px, Emas Tengah)
                    SizedBox(
                      height: 44,
                      child: Center(
                        child: Text(
                          'Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _gold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildSkeletonProfileView(),
                      )
                    else ...[
                      // 1. Kartu Profil Jemaah Melayang di Atas Header Ka'bah (Warna: #FFF8EC)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar Inisial Dinamis dengan Lencana Verifikasi Emas (Hero Smooth Animation)
                            Hero(
                              tag: 'profile_avatar_hero',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFECC485), Color(0xFFD4A359)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _gold.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _getInitials(userName),
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: _ink,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: _gold,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 11,
                                          color: _ink,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Nama & Email Asli
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userEmail,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Tombol Edit Pill
                            Material(
                              color: const Color(0xFFF7E5C8),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothPageRoute(
                                      page: ProfileAccountInfoPage(
                                        api: widget.api,
                                        isAdmin: isRoleAdmin,
                                      ),
                                    ),
                                  ).then((_) => _handleRefresh(silent: true));
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit_rounded, size: 13, color: _ink),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Edit',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Seksi Akomodasi Rombongan (Khusus Jemaah bila memiliki data grup)
                      if (!isStaff && _departureGroup != null) ...[
                        _buildGroupAccommodationCard(_departureGroup!),
                        const SizedBox(height: 16),
                      ],

                      // 2. Seksi Akun (Jelas Berada di Bawah Header Ka'bah & Kartu Profil)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'Akun',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Menu 1: Informasi Akun (Smooth Transition)
                      _buildMenuCard(
                        icon: Icons.person_rounded,
                        title: 'Informasi Akun',
                        subtitle: 'Nama, email, dan informasi pribadi',
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(
                              page: ProfileAccountInfoPage(
                                api: widget.api,
                                isAdmin: isStaff,
                              ),
                            ),
                          ).then((_) => _handleRefresh(silent: true));
                        },
                      ),

                      // Menu 2: Pengaturan (Smooth Transition)
                      _buildMenuCard(
                        icon: Icons.settings_rounded,
                        title: 'Pengaturan',
                        subtitle: 'Preferensi aplikasi',
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(
                              page: ProfileSettingsPage(
                                api: widget.api,
                                isAdmin: isStaff,
                              ),
                            ),
                          );
                        },
                      ),

                      // Menu 3: Keamanan Akun (Smooth Transition)
                      _buildMenuCard(
                        icon: Icons.lock_rounded,
                        title: 'Keamanan Akun',
                        subtitle: 'Ubah kata sandi dan pengaturan keamanan',
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(
                              page: ProfileSecurityPage(
                                api: widget.api,
                                isAdmin: isStaff,
                              ),
                            ),
                          );
                        },
                      ),

                      // Menu 4: Digital Payment (Khusus Jemaah)
                      if (!isStaff)
                        _buildMenuCard(
                          icon: Icons.credit_card_rounded,
                          title: 'Digital Payment',
                          subtitle: 'Kelola kartu dan metode pembayaran',
                          onTap: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                page: const ProfileDigitalPaymentPage(),
                              ),
                            );
                          },
                        ),

                      // Menu 5: Keluar
                      _buildMenuCard(
                        icon: Icons.logout_rounded,
                        title: 'Keluar',
                        subtitle: 'Keluar dari akun Anda',
                        onTap: _handleLogout,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
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
                Icon(icon, color: _ink, size: 21),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _ink),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: _ink, size: 21),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              SkeletonCircle(size: 60),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140, height: 16, borderRadius: 6),
                    SizedBox(height: 6),
                    SkeletonBox(width: 180, height: 11, borderRadius: 4),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SkeletonBox(width: 56, height: 30, borderRadius: 14),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SkeletonBox(width: 80, height: 16, borderRadius: 6),
        const SizedBox(height: 12),
        const SkeletonBox(height: 56, borderRadius: 18),
        const SizedBox(height: 10),
        const SkeletonBox(height: 56, borderRadius: 18),
        const SizedBox(height: 10),
        const SkeletonBox(height: 56, borderRadius: 18),
        const SizedBox(height: 10),
        const SkeletonBox(height: 56, borderRadius: 18),
        const SizedBox(height: 10),
        const SkeletonBox(height: 56, borderRadius: 18),
      ],
    );
  }

  Widget _buildGroupAccommodationCard(DepartureGroupItem group) {
    final hasAirlines = group.airlines.isNotEmpty;
    final hasHotels = group.hotels.isNotEmpty;
    if (!hasAirlines && !hasHotels) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D6C3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flight_takeoff_rounded, size: 18, color: _ink),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akomodasi Rombongan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    if (group.name.isNotEmpty)
                      Text(
                        group.name,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _muted,
                        ),
                      ),
                  ],
                ),
              ),
              if (_isAccommodationUpdated)
                GestureDetector(
                  onTap: _markAccommodationSeen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync_rounded, size: 12, color: Color(0xFF166534)),
                        const SizedBox(width: 4),
                        Text(
                          'Diperbarui',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasAirlines) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.airlines_rounded, size: 14, color: _muted),
                    const SizedBox(width: 6),
                    Text(
                      'Maskapai',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _ink),
                    ),
                  ],
                ),
                _buildStatusChip(group.airlinesConfirmed),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              group.airlines.join(', '),
              style: GoogleFonts.poppins(fontSize: 12, color: _ink),
            ),
            const SizedBox(height: 12),
          ],
          if (hasHotels) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hotel_rounded, size: 14, color: _muted),
                    const SizedBox(width: 6),
                    Text(
                      'Hotel',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _ink),
                    ),
                  ],
                ),
                _buildStatusChip(group.hotelsConfirmed),
              ],
            ),
            const SizedBox(height: 4),
            ...group.hotels.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  h.items.isNotEmpty ? '${h.text}: ${h.items.join(", ")}' : h.text,
                  style: GoogleFonts.poppins(fontSize: 12, color: _ink),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isConfirmed) {
    final bg = isConfirmed ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final border = isConfirmed ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A);
    final text = isConfirmed ? const Color(0xFF166534) : const Color(0xFF92400E);
    final label = isConfirmed ? 'Sudah pasti' : 'Rencana (atau setaraf)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
