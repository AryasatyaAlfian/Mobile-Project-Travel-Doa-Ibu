import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';

/// Halaman Landing Page untuk pengguna dengan role Muthawwif (Pembimbing).
/// Menyediakan panel kerja muthawwif untuk koordinasi jemaah, radar lokasi, dan manasik.
class MuthawwifLandingPage extends StatelessWidget {
  const MuthawwifLandingPage({
    super.key,
    required this.api,
    this.onLogout,
  });

  final TravelApi api;
  final VoidCallback? onLogout;

  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _muthawwifTeal = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    final user = api.user;
    final muthawwifName = user?.name ?? 'Pembimbing Muthawwif';

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background Header Gradient (Islamic Luxury)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF132220),
                    const Color(0xFF1D3531),
                    _bg,
                  ],
                  stops: const [0.0, 0.75, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Top Bar: Title & Logout Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _muthawwifTeal,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ROLE: ${(user?.roleLabel ?? 'Muthawwif').toUpperCase()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Travel Doa Ibu',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _gold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Portal Pembimbing',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: 'Keluar / Logout',
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                        ),
                        onPressed: onLogout,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 2. Konten Menu Muthawwif
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    children: [
                      // Kartu Profil & Penugasan Muthawwif
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: _muthawwifTeal.withValues(alpha: 0.15),
                              child: const Icon(Icons.support_agent_rounded, color: _muthawwifTeal, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ahlan wa Sahlan,',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  Text(
                                    muthawwifName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                  Text(
                                    user?.email ?? '-',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Kartu Status Rombongan Bimbingan Aktif
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rombongan Bimbingan: Aktif',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF14532D),
                                    ),
                                  ),
                                  Text(
                                    'Bimbingan Ibadah & Rombongan Jemaah',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: const Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section Title
                      Text(
                        'Modul Operasional Muthawwif',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3 Kartu Menu Operasional Muthawwif
                      _buildMuthawwifMenuCard(
                        context,
                        title: 'Jemaah Bimbingan',
                        subtitle: 'Daftar jemaah dalam rombongan, no. kamar hotel & paspor',
                        icon: Icons.groups_rounded,
                        color: const Color(0xFF0F766E),
                      ),
                      _buildMuthawwifMenuCard(
                        context,
                        title: 'Radar & Pemantauan Lokasi',
                        subtitle: 'Pantau posisi jemaah secara real-time dan notifikasi sinyal SOS',
                        icon: Icons.map_rounded,
                        color: const Color(0xFF2563EB),
                      ),
                      _buildMuthawwifMenuCard(
                        context,
                        title: 'Agenda Manasik & Ibadah',
                        subtitle: 'Jadwal tawaf, sai, ziarah, dan panduan doa harian jemaah',
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFFD97706),
                      ),

                      const SizedBox(height: 16),

                      // Tombol Logout Utama
                      OutlinedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: Text(
                          'Keluar dari Akun Muthawwif',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC0392B),
                          side: BorderSide(color: const Color(0xFFC0392B).withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuthawwifMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Modul "$title" siap dikembangkan pada tahapan fitur Muthawwif berikutnya.',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                backgroundColor: color,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade600, height: 1.3),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
