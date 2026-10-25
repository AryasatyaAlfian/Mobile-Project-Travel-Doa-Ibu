import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/travel_api.dart';

/// Elysian Horizon — Route Guard Bimbingan Muthawwif
/// Memproteksi halaman: jika jemaah belum memiliki muthawwif pembimbing (contoh: persona Nadia),
/// sistem secara otomatis me-redirect ke halaman terbatas yang informatif.
class MuthawwifGuardPage extends StatefulWidget {
  const MuthawwifGuardPage({
    super.key,
    required this.api,
    this.onBackToHome,
  });

  final TravelApi api;
  final VoidCallback? onBackToHome;

  @override
  State<MuthawwifGuardPage> createState() => _MuthawwifGuardPageState();
}

class _MuthawwifGuardPageState extends State<MuthawwifGuardPage> {
  late Future<Muthawwif?> _muthawwifFuture;
  bool _isSwitchingPersona = false;

  @override
  void initState() {
    super.initState();
    _loadMuthawwif();
  }

  void _loadMuthawwif() {
    _muthawwifFuture = widget.api.myMuthawwif();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadMuthawwif();
    });
    await _muthawwifFuture;
  }

  /// Simulasi Persona Testing: Menguji langsung akun Zara (dengan muthawwif) vs Nadia (tanpa muthawwif)
  Future<void> _testLoginPersona({required String email, required String password}) async {
    setState(() => _isSwitchingPersona = true);
    try {
      final user = await widget.api.login(email, password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Beralih ke persona uji API: ${user.name}',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF4E9FE5),
        ),
      );
      _refresh();
    } catch (_) {
      // Fallback simulasi jika seeder backend belum di-run oleh tim Backend
      if (!mounted) return;
      final isNadia = email.contains('nadia');
      final name = isNadia ? 'Nadia Putri' : 'Zara Anselma';
      TravelApi.currentUser = AppUser(
        id: isNadia ? 99 : 98,
        name: name,
        email: email,
        isAdmin: false,
        role: 'jemaah',
      );

      setState(() {
        if (isNadia) {
          _muthawwifFuture = Future.value(null); // Nadia: tanpa muthawwif (404)
        } else {
          _muthawwifFuture = Future.value(Muthawwif(
            id: 1,
            name: 'Ustadz Felix Siauw',
            phone: '081234567890',
            specialization: 'Pembimbing Ibadah Umrah & Sirah Nabawiyah',
            yearsExperience: 8,
            languages: ['Indonesia', 'Arab', 'Inggris'],
            bio: 'Muthawwif bersertifikasi Kemenag RI dengan pengalaman membimbing lebih dari 50 rombongan jemaah Umrah dan Haji Khusus.',
          )); // Zara: ada muthawwif (200)
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mode Uji Aktif: $name (${isNadia ? "Tanpa Muthawwif -> Restricted" : "Dengan Muthawwif -> Unlocked"})',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: isNadia ? const Color(0xFFD97706) : const Color(0xFF4E9FE5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSwitchingPersona = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF2F7),
      appBar: AppBar(
        title: Text(
          'Muthawwif Pembimbing',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E293B)),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<Muthawwif?>(
        future: _muthawwifFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isSwitchingPersona) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4E9FE5)),
            );
          }

          final muthawwif = snapshot.data;

          // 1. KONDISI GUARD: Jemaah belum memiliki muthawwif (Contoh: Nadia) -> Tampilkan Halaman Terbatas
          if (muthawwif == null) {
            return _buildUnassignedRestrictedView();
          }

          // 2. KONDISI LOLOS GUARD: Jemaah memiliki pembimbing (Contoh: Zara) -> Tampilkan Profil Lengkap
          return _buildAssignedMuthawwifView(muthawwif);
        },
      ),
    );
  }

  /// 1. Tampilan Halaman Terbatas (Jemaah Tanpa Muthawwif / Nadia)
  Widget _buildUnassignedRestrictedView() {
    final user = TravelApi.currentUser;
    final jemaahName = user?.name ?? 'Jemaah';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          // Card Peringatan Akses Terbatas (Elysian Card)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFB0C5D7), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon Halo Peringatan
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFEF3C7),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                  ),
                  child: const Icon(
                    Icons.lock_clock_rounded,
                    size: 36,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 18),

                // Judul
                Text(
                  'Akses Layanan Terbatas',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    'Status: Menunggu Penugasan Muthawwif',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Penjelasan
                Text(
                  'Assalamu\'alaikum, $jemaahName. Akun Anda saat ini belum memiliki muthawwif pembimbing ibadah yang ditugaskan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.5,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Penugasan muthawwif akan dilakukan oleh tim Admin Travel Doa Ibu setelah verifikasi paket, manifes rombongan, dan penerbitan tiket perjalanan Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Bantuan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Menghubungi layanan pelanggan Travel Doa Ibu...',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          backgroundColor: const Color(0xFF4E9FE5),
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent_rounded, size: 20),
                    label: Text(
                      'Hubungi Admin / CS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E9FE5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Persona Test Bench (Khusus Pengujian Pengembang / Sprint 1)
          _buildTestingPersonaSection(),
        ],
      ),
    );
  }

  /// 2. Tampilan Lolos Guard (Jemaah Memiliki Muthawwif / Zara)
  Widget _buildAssignedMuthawwifView(Muthawwif muthawwif) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Profil Pembimbing
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFB0C5D7), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF5E89B0), Color(0xFF234C6A)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    muthawwif.name.isNotEmpty ? muthawwif.name[0].toUpperCase() : 'M',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  muthawwif.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  muthawwif.specialization ?? 'Muthawwif Pembimbing Umrah & Haji',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),

                // Info Pengalaman & Bahasa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn('Pengalaman', '${muthawwif.yearsExperience ?? 5}+ Tahun'),
                    Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                    _buildInfoColumn(
                      'Bahasa',
                      muthawwif.languages.isNotEmpty ? muthawwif.languages.join(', ') : 'ID, AR',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bio
                if (muthawwif.bio != null && muthawwif.bio!.isNotEmpty) ...[
                  Text(
                    muthawwif.bio!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.5,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Tombol Hubungi Pembimbing
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Menghubungi ${muthawwif.name} (${muthawwif.phone ?? 'WhatsApp'})...',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          backgroundColor: const Color(0xFF4E9FE5),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                    label: Text(
                      'Konsultasi dengan Muthawwif',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E9FE5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Persona Test Bench
          _buildTestingPersonaSection(),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  /// Bagian Simulasi Testing Khusus Sprint 1 (Persona Nadia vs Zara)
  Widget _buildTestingPersonaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 18, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              Text(
                'Panel Uji Route Guard (Sprint 1)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Uji perpindahan kondisi jemaah memiliki muthawwif (Zara) vs tanpa muthawwif (Nadia):',
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _testLoginPersona(
                    email: 'nadia@traveldoaibu.test',
                    password: 'DoaIbu123!',
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD97706)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Uji Nadia\n(Tanpa Muthawwif)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFD97706)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _testLoginPersona(
                    email: 'zara@traveldoaibu.test',
                    password: 'DoaIbu123!',
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4E9FE5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Uji Zara\n(Ada Muthawwif)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF4E9FE5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
