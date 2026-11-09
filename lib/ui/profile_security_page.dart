import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/smooth_page_route.dart';
import '../services/travel_api.dart';
import 'profile_change_password_page.dart';

/// Halaman Keamanan Akun (Ubah Sandi, 2FA, Riwayat Aktivitas)
/// Layout 1:1 Presisi Sesuai Figma dengan Header Ka'bah & Curved Top Sheet
class ProfileSecurityPage extends StatefulWidget {
  const ProfileSecurityPage({
    super.key,
    this.api,
    this.initial2FaEnabled = false,
    this.isAdmin = false,
  });

  final TravelApi? api;
  final bool initial2FaEnabled;
  final bool isAdmin;

  @override
  State<ProfileSecurityPage> createState() => _ProfileSecurityPageState();
}

class _ProfileSecurityPageState extends State<ProfileSecurityPage> {
  late bool _twoFactorEnabled;

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF94A3B8);
  static const Color _green = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _twoFactorEnabled = widget.initial2FaEnabled;
  }

  void _openChangePasswordPage() {
    Navigator.push(
      context,
      SmoothPageRoute(
        page: ProfileChangePasswordPage(
          api: widget.api ?? TravelApi(),
        ),
      ),
    );
  }

  void _showActivityHistory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final activities = [
          {
            'device': 'Perangkat Ini (Sesi Aktif)',
            'location': 'Indonesia',
            'time': 'Aktif sekarang',
            'status': 'Online',
          },
          {
            'device': 'Aplikasi Mobile Travel Doa Ibu',
            'location': 'Indonesia',
            'time': 'Sesi Terverifikasi',
            'status': 'Online',
          },
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Riwayat Aktivitas & Perangkat',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Daftar perangkat yang terdaftar mengakses sesi akun Anda.',
                  style: GoogleFonts.poppins(fontSize: 12, color: _muted),
                ),
                const SizedBox(height: 16),
                ...activities.map(
                  (act) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.devices_rounded, size: 20, color: _ink),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                act['device']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _ink,
                                ),
                              ),
                              Text(
                                '${act['location']} · ${act['time']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: act['status'] == 'Online'
                                ? _green.withValues(alpha: 0.15)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            act['status']!,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: act['status'] == 'Online' ? _green : const Color(0xFF64748B),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRoleAdmin = widget.isAdmin || (widget.api?.user?.isAdmin ?? false);
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Background Ka'bah Malam Kompak (Tinggi 135px)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 135,
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

          // 2. Konten Utama
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar Navigasi (Tinggi 44px, Ikon Back Putih & Judul Emas Tengah)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Keamanan Akun',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Penyeimbang IconButton
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Curved Sheet Container (Sudut Melengkung Atas Radius 28px)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card 1: Ubah Kata Sandi -> Menuju Halaman Ubah Kata Sandi
                            _buildSecurityTile(
                              icon: Icons.lock_rounded,
                              title: 'Ubah Kata Sandi',
                              trailing: const Icon(Icons.chevron_right_rounded, color: _ink, size: 21),
                              onTap: _openChangePasswordPage,
                            ),

                            if (!isRoleAdmin) ...[
                              const SizedBox(height: 10),

                              // Card 2: Autentikasi Dua Faktor
                              Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _twoFactorEnabled = !_twoFactorEnabled);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
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
                                        const Icon(Icons.verified_user_rounded, color: _ink, size: 21),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Autentikasi Dua Faktor',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _ink,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                'Tambahkan lapisan keamanan extra untuk akun Anda',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: _muted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Transform.scale(
                                          scale: 0.78,
                                          child: CupertinoSwitch(
                                            value: _twoFactorEnabled,
                                            activeTrackColor: _green,
                                            inactiveTrackColor: const Color(0xFFCBD5E1),
                                            onChanged: (val) {
                                              setState(() => _twoFactorEnabled = val);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Card 3: Riwayat Aktivitas
                              _buildSecurityTile(
                                icon: Icons.access_time_filled_rounded,
                                title: 'Riwayat Aktivitas',
                                subtitle: 'Lihat aktivitas login dan perangkat terkait akun Anda',
                                trailing: const Icon(Icons.chevron_right_rounded, color: _ink, size: 21),
                                onTap: _showActivityHistory,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
