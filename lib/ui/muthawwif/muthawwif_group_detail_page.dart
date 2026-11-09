import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/smooth_page_route.dart';
import '../../models/muthawwif_models.dart';
import '../../services/travel_api.dart';
import 'muthawwif_member_list_page.dart';

/// Halaman Detail Rombongan (Gambar 1, Screen 2).
/// Menampilkan informasi jadwal keberangkatan, maskapai, akomodasi hotel,
/// kontak muthawwif pendamping, serta tombol navigasi ke daftar anggota rombongan.
class MuthawwifGroupDetailPage extends StatelessWidget {
  const MuthawwifGroupDetailPage({
    super.key,
    required this.api,
    required this.group,
  });

  final TravelApi api;
  final MuthawwifGroupInfo group;

  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _greenWa = Color(0xFF25D366);

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

          // 2. Konten Scrollable
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
                            'Detail Rombongan',
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

                // Konten Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card 1: Informasi Paket Rombongan
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Kartu: Ikon & Nama Rombongan
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBF6EE),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7EEDF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.groups_rounded,
                                        color: Color(0xFFC89745),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        group.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _ink,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Item 1: Keberangkatan
                              _buildInfoRow(
                                icon: Icons.calendar_today_rounded,
                                label: 'Keberangkatan',
                                value: group.departureDate,
                              ),
                              const Divider(height: 24, thickness: 0.6, color: Color(0xFFF1E7D5)),

                              // Item 2: Maskapai
                              _buildInfoRow(
                                icon: Icons.flight_takeoff_rounded,
                                label: 'Maskapai',
                                value: group.airline,
                              ),
                              const Divider(height: 24, thickness: 0.6, color: Color(0xFFF1E7D5)),

                              // Item 3: Hotel
                              _buildInfoRow(
                                icon: Icons.hotel_rounded,
                                label: 'Hotel',
                                value: '${group.hotelMakkah}\n${group.hotelMadinah}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Card 2: Mutawwif Pendamping
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
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
                              Text(
                                'Mutawwif Pendamping',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFECC485), Color(0xFFD4A359)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _gold.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'AF',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Nama & Role
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.muthawwifName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Mutawwif',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Tombol Call
                                  IconButton(
                                    icon: const Icon(Icons.phone_rounded, color: Color(0xFFC89745), size: 22),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Menghubungi ${group.muthawwifName}...')),
                                      );
                                    },
                                    tooltip: 'Telepon',
                                  ),

                                  // Tombol WhatsApp
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_rounded, color: _greenWa, size: 22),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Membuka chat WhatsApp ${group.muthawwifName}...')),
                                      );
                                    },
                                    tooltip: 'WhatsApp',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol Aksi: Lihat Anggota Rombongan (Emas Penuh)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                page: MuthawwifMemberListPage(
                                  api: api,
                                  group: group,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.groups_rounded, size: 20),
                          label: Text(
                            'Lihat Anggota Rombongan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8BD7C),
                            foregroundColor: _ink,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFC89745), size: 20),
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

