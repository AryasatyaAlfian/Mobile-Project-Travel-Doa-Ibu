import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/muthawwif_models.dart';
import '../../services/travel_api.dart';

/// Halaman Detail Anggota Rombongan (Gambar 1, Screen 4).
/// Menampilkan profil jemaah, nomor paspor, tanggal lahir, kontak telepon,
/// serta alokasi nomor kamar di hotel Makkah dan Madinah.
class MuthawwifMemberDetailPage extends StatelessWidget {
  const MuthawwifMemberDetailPage({
    super.key,
    required this.api,
    required this.member,
    required this.group,
  });

  final TravelApi api;
  final MuthawwifMemberInfo member;
  final MuthawwifGroupInfo group;

  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _goldAccent = Color(0xFFC89745);

  @override
  Widget build(BuildContext context) {
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

          // 2. Konten
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar Navigasi (Tinggi 44px, Ikon Back Putih & Judul Emas)
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
                            'Detail Anggota',
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
                const SizedBox(height: 12),

                // Card Profil Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
                    child: Column(
                      children: [
                        // Card Avatar & Nama Jemaah
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar Bulat
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFECC485), Color(0xFFD4A359)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _gold.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    member.initials,
                                    style: GoogleFonts.poppins(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Nama Jemaah
                              Text(
                                member.name,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Badge Role / Status Rombongan
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: member.isLeader
                                      ? const Color(0xFFFBF1DB)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (member.isLeader) ...[
                                      const Icon(
                                        Icons.workspace_premium_rounded,
                                        size: 15,
                                        color: _goldAccent,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      member.roleLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: member.isLeader ? _goldAccent : _muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Card Informasi Data Identitas & Akomodasi
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Nomor Paspor
                              _buildDetailItem(
                                icon: Icons.badge_outlined,
                                label: 'Nomor Paspor',
                                value: member.passportNumber ?? 'A1234567',
                              ),
                              const Divider(height: 24, thickness: 0.6, color: Color(0xFFF1E7D5)),

                              // 2. Tanggal Lahir
                              _buildDetailItem(
                                icon: Icons.calendar_today_outlined,
                                label: 'Tanggal Lahir',
                                value: member.birthDate ?? '12 Januari 2004',
                              ),
                              const Divider(height: 24, thickness: 0.6, color: Color(0xFFF1E7D5)),

                              // 3. Nomor Telepon
                              _buildDetailItem(
                                icon: Icons.phone_outlined,
                                label: 'Nomor Telepon',
                                value: member.phone ?? '+62 812 3456 7890',
                              ),
                              const Divider(height: 24, thickness: 0.6, color: Color(0xFFF1E7D5)),

                              // 4. Kamar
                              _buildDetailItem(
                                icon: Icons.hotel_outlined,
                                label: 'Kamar',
                                value: 'Makkah: ${member.roomMakkah ?? "101 (Double)"}\nMadinah: ${member.roomMadinah ?? "205 (Double)"}',
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF6EE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _goldAccent, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

