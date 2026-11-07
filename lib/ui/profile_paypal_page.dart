import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/smooth_page_route.dart';

/// Halaman Hubungkan Akun PayPal
/// Desain 1:1 Sesuai Figma Prototype media_1793603558605_e599ac3d.png
class ProfilePaypalPage extends StatelessWidget {
  const ProfilePaypalPage({super.key});

  static const Color _gold = Color(0xFFECC485);
  static const Color _btnGold = Color(0xFFDCAE68);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Ka'bah Malam
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

          // 2. Konten Halaman
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar Navigasi (Tinggi 44px)
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
                            'PayPal',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Seimbang dengan tombol back
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Card Putih/Krem Melengkung
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    // Bisa di-scroll supaya tombol tetap terjangkau di HP landscape.
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),

                          // Lingkaran Biru Logo PayPal
                          Container(
                            width: 104,
                            height: 104,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE1F0FF),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const _PaypalMonogram(),
                          ),

                          const SizedBox(height: 32),

                          // Judul
                          Text(
                            'Hubungkan Akun PayPal',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Deskripsi
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Text(
                              'Anda akan diarahkan ke halaman resmi PayPal untuk menghubungkan akun Anda.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _muted,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Tombol Hubungkan Akun PayPal
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  SmoothPageRoute(
                                    page: const ProfilePaypalSuccessPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _btnGold,
                                foregroundColor: _ink,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Hubungkan Akun PayPal',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
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
        ],
      ),
    );
  }
}

/// Halaman PayPal Terhubung (Berhasil)
/// Desain 1:1 Sesuai Figma Prototype media_1793603577471_ab02bd5c.png
class ProfilePaypalSuccessPage extends StatelessWidget {
  const ProfilePaypalSuccessPage({super.key});

  static const Color _gold = Color(0xFFECC485);
  static const Color _btnGold = Color(0xFFDCAE68);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Ka'bah Malam
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

          // 2. Konten Halaman
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar Navigasi (Tinggi 44px)
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
                            'PayPal Terhubung',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Card Putih/Krem Melengkung
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    // Bisa di-scroll supaya tombol tetap terjangkau di HP landscape.
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),

                          // Ilustrasi Centang Hijau dengan Sparkle Emas
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 18,
                                  left: 14,
                                  child: Icon(Icons.star_rounded, size: 16, color: _gold.withValues(alpha: 0.9)),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 28,
                                  child: Icon(Icons.star_rounded, size: 14, color: _gold.withValues(alpha: 0.9)),
                                ),
                                Positioned(
                                  bottom: 24,
                                  left: 20,
                                  child: Icon(Icons.star_rounded, size: 12, color: _gold.withValues(alpha: 0.8)),
                                ),
                                Positioned(
                                  bottom: 30,
                                  right: 16,
                                  child: Icon(Icons.star_rounded, size: 16, color: _gold.withValues(alpha: 0.9)),
                                ),
                                // Lingkaran hijau lembut luar
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD1F2DE),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2EAA5B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Judul
                          Text(
                            'Akun PayPal Berhasil\nTerhubung',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Deskripsi
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Text(
                              'Akun PayPal Anda telah berhasil ditambahkan sebagai metode pembayaran.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _muted,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Tombol Kembali ke Digital Payment
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _btnGold,
                                foregroundColor: _ink,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Kembali ke Digital Payment',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
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
        ],
      ),
    );
  }
}

/// Monogram Ikon PayPal (Dua huruf P bertumpuk khas PayPal)
class _PaypalMonogram extends StatelessWidget {
  const _PaypalMonogram();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        children: [
          // P pertama (Biru Tua)
          Positioned(
            left: 6,
            top: 2,
            child: Text(
              'P',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 42,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF003087),
                height: 1.0,
              ),
            ),
          ),
          // P kedua (Biru Terang Bergeser ke Kanan Bawah)
          Positioned(
            left: 17,
            top: 8,
            child: Text(
              'P',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 42,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF0079C1),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
