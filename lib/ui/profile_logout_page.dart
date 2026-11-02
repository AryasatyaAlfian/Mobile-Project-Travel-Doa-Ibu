import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';

/// Halaman Konfirmasi Keluar dari Akun
/// Desain 1:1 Sesuai Figma Prototype media_1793603598983_2a52939a.png
class ProfileLogoutPage extends StatefulWidget {
  final VoidCallback? onLogout;
  final TravelApi? api;

  const ProfileLogoutPage({
    super.key,
    this.onLogout,
    this.api,
  });

  @override
  State<ProfileLogoutPage> createState() => _ProfileLogoutPageState();
}

class _ProfileLogoutPageState extends State<ProfileLogoutPage> {
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _red = Color(0xFFDC2626);
  static const Color _borderRed = Color(0xFFFCA5A5);

  bool _isProcessing = false;

  Future<void> _handleLogout() async {
    setState(() => _isProcessing = true);
    try {
      final api = widget.api ?? TravelApi();
      await api.logout();
    } catch (_) {
      // Abaikan error jaringan saat logout agar user tetap bisa logout secara lokal
    }

    if (!mounted) return;

    if (widget.onLogout != null) {
      widget.onLogout!();
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, true);
    }
  }

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
                // Top Bar Navigasi (Tinggi 44px, Hanya Tombol Back Sesuai Figma)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        const Spacer(),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),

                          // Lingkaran Peach Ikon Keluar
                          Container(
                            width: 104,
                            height: 104,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBE8CD),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.logout_rounded,
                              size: 40,
                              color: _ink,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Judul
                          Text(
                            'Keluar dari Akun?',
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
                              'Anda akan keluar dari akun ini. Untuk masuk kembali, Anda perlu login lagi.',
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

                          // Tombol Merah Keluar
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Keluar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Tombol Putih Border Merah Batal
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _ink,
                                side: const BorderSide(color: _borderRed, width: 1.2),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Batal',
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

