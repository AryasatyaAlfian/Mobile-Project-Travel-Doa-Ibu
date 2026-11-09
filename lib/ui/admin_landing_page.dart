import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';

/// Halaman Landing Page untuk pengguna dengan role Admin.
/// Menyediakan panel kontrol awal dan navigasi modul administratif.
class AdminLandingPage extends StatelessWidget {
  const AdminLandingPage({
    super.key,
    required this.api,
    this.onLogout,
  });

  final TravelApi api;
  final VoidCallback? onLogout;

  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _adminRed = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final user = api.user;
    final adminName = user?.name ?? 'Administrator';

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
                    const Color(0xFF1E1B18),
                    const Color(0xFF2C2720),
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
                                    color: _adminRed,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ROLE: ${(user?.roleLabel ?? 'Admin').toUpperCase()}',
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
                              'Panel Administrator',
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

                // 2. Konten Menu Admin
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    children: [
                      // Kartu Sambutan Profil Admin
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
                              backgroundColor: _gold.withValues(alpha: 0.2),
                              child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF8B6B23), size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat datang,',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  Text(
                                    adminName,
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

                      const SizedBox(height: 20),

                      // Section Title
                      Text(
                        'Modul Manajemen Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4 Kartu Modul Admin
                      _buildAdminMenuCard(
                        context,
                        title: 'Data Jemaah',
                        subtitle: 'Pantau manifest, paspor, dan kontak darurat rombongan jemaah',
                        icon: Icons.groups_rounded,
                        color: const Color(0xFF2E7D32),
                      ),
                      _buildAdminMenuCard(
                        context,
                        title: 'Data Muthawwif',
                        subtitle: 'Kelola penugasan pembimbing ibadah umrah & nomor sertifikasi',
                        icon: Icons.support_agent_rounded,
                        color: const Color(0xFF1565C0),
                      ),
                      _buildAdminMenuCard(
                        context,
                        title: 'Pemesanan & Tiket',
                        subtitle: 'Verifikasi konfirmasi booking, pembayaran Midtrans, dan kuota kursi',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFFE65100),
                      ),
                      _buildAdminMenuCard(
                        context,
                        title: 'Kelola Pengguna',
                        subtitle: 'Pengaturan otorisasi hak akses RBAC (Admin, Muthawwif, Jemaah)',
                        icon: Icons.manage_accounts_rounded,
                        color: const Color(0xFF6A1B9A),
                      ),

                      const SizedBox(height: 16),

                      // Tombol Logout Utama
                      OutlinedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: Text(
                          'Keluar dari Akun Admin',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _adminRed,
                          side: BorderSide(color: _adminRed.withValues(alpha: 0.5)),
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

  Widget _buildAdminMenuCard(
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
                  'Modul "$title" siap dikembangkan pada tahapan fitur Admin berikutnya.',
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
