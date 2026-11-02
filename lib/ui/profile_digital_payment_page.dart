import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/smooth_page_route.dart';
import 'profile_bank_transfer_qris_page.dart';
import 'profile_card_payment_page.dart';
import 'profile_paypal_page.dart';

/// Halaman Utama Digital Payment (Kelola Metode Pembayaran)
/// Layout 1:1 Presisi Sesuai Figma Prototype
class ProfileDigitalPaymentPage extends StatelessWidget {
  const ProfileDigitalPaymentPage({super.key});

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Ka'bah Malam di Latar Belakang
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
                            'Digital Payment',
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),

                          // Ilustrasi Dua Kartu Tumpuk (Figma Style)
                          Center(
                            child: SizedBox(
                              width: 170,
                              height: 110,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Sparkle kiri atas
                                  const Positioned(
                                    top: 12,
                                    left: 10,
                                    child: Icon(Icons.auto_awesome, color: Color(0xFFECC485), size: 16),
                                  ),
                                  // Sparkle kanan bawah
                                  const Positioned(
                                    bottom: 12,
                                    right: 8,
                                    child: Icon(Icons.auto_awesome, color: Color(0xFFECC485), size: 14),
                                  ),
                                  // Kartu Hitam Belakang (Miring)
                                  Transform.rotate(
                                    angle: 0.22,
                                    child: Container(
                                      width: 125,
                                      height: 78,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF262626),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 10,
                                            offset: const Offset(2, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Kartu Emas Depan
                                  Container(
                                    width: 135,
                                    height: 84,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFEBC78C), Color(0xFFD4A359)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD4A359).withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Dua garis dekoratif kartu
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: 24, height: 3, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
                                            const SizedBox(height: 3),
                                            Container(width: 16, height: 3, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1F1F1F),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Judul & Subtitle
                          Text(
                            'Kelola Metode Pembayaran Anda',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tambah dan kelola metode pembayaran\nuntuk mempermudah transaksi Anda.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _muted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Opsi 1: Transfer Bank / QRIS
                          _buildOptionCard(
                            context: context,
                            iconWidget: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1F1F1F),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 22),
                            ),
                            title: 'Transfer Bank / QRIS',
                            subtitle: 'Transfer bank atau scan QRIS',
                            onTap: () {
                              Navigator.push(
                                context,
                                SmoothPageRoute(page: const ProfileBankTransferQrisPage()),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Opsi 2: Kartu Kredit/Debit
                          _buildOptionCard(
                            context: context,
                            iconWidget: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3C47D),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(-5, 0),
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.85), shape: BoxShape.circle),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            title: 'Kartu Kredit/Debit',
                            subtitle: 'Tambah kartu Visa, Mastercard, dll',
                            onTap: () {
                              Navigator.push(
                                context,
                                SmoothPageRoute(page: const ProfilePaymentMethodsPage()),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Opsi 3: Paypal
                          _buildOptionCard(
                            context: context,
                            iconWidget: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE0F2FE),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'P',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF003087),
                                ),
                              ),
                            ),
                            title: 'Paypal',
                            subtitle: 'Hubungkan akun Paypal Anda',
                            onTap: () {
                              Navigator.push(
                                context,
                                SmoothPageRoute(page: const ProfilePaypalPage()),
                              );
                            },
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

  Widget _buildOptionCard({
    required BuildContext context,
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
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
              iconWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              const Icon(Icons.chevron_right_rounded, color: _ink, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
