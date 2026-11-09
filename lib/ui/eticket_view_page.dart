import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ticket_order.dart';

/// Halaman E-Tiket Digital (Boarding Pass) sesuai Gambar 1
/// Menggunakan custom clipper untuk lekukan tiket fisik dan procedural QR painter.
class ETicketViewPage extends StatelessWidget {
  const ETicketViewPage({
    super.key,
    required this.ticket,
  });

  final TicketOrder ticket;

  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _bg = Color(0xFFFFF8EC);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background Header Menara/Kubah Masjid
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/Background.webp',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/Background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1F1B16)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        _bg.withValues(alpha: 0.1),
                        _bg,
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Konten Utama
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header Navigasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back, color: _ink, size: 20),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'E-Tiket',
                            style: GoogleFonts.poppins(
                              color: _gold,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // spacer penyeimbang
                    ],
                  ),
                ),

                // Card Tiket Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 100),
                    child: Column(
                      children: [
                        _buildTicketCard(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Action Buttons di Bawah
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomInset > 0 ? bottomInset + 8 : 20,
            child: Row(
              children: [
                // Tombol Bagikan
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: 'E-Tiket Doa Ibu: ${ticket.packageName} (${ticket.bookingCode}) - Kursi ${ticket.seatNumber}',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tautan E-Tiket berhasil disalin!', style: GoogleFonts.poppins(fontSize: 13)),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share_outlined, color: _ink, size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Bagikan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Tombol Unduh E-Tiket
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('E-Tiket ${ticket.bookingCode} berhasil diunduh.', style: GoogleFonts.poppins(fontSize: 13)),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.file_download_outlined, color: _ink, size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Unduh E-Tiket',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _ink,
                                ),
                              ),
                            ),
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

  Widget _buildTicketCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // BAGIAN ATAS TIKET
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Maskapai & Badge Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ticket.airline,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD32F2F),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 4),
                          Text(
                            'Dikonfirmasi',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'E-Tiket Perjalanan · Order ID ${ticket.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 22),

                // Visual Rute Penerbangan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Asal
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.originCode,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          Text(
                            ticket.originCity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '15:45',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          Text(
                            'Kam, 15 Jan 2026',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),

                    // Garis & Ikon Pesawat di Tengah
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Divider(color: Colors.grey.shade300, thickness: 1.2),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF4DE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.flight_takeoff_rounded,
                                    size: 15,
                                    color: Color(0xFF9E651E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                ticket.transitInfo,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tujuan
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ticket.destinationCode,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          Text(
                            ticket.destinationCity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '07:30',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          Text(
                            'Jum, 16 Jan 2026',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Grid Rincian Penumpang (2 Kolom)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldItem('Penumpang', ticket.passengerName),
                          const SizedBox(height: 14),
                          _buildFieldItem('Penerbangan', ticket.flightCodePair),
                          const SizedBox(height: 14),
                          _buildFieldItem('Kursi', ticket.seatNumber),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Kolom Kanan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldItem('Kode Booking', ticket.bookingCode),
                          const SizedBox(height: 14),
                          _buildFieldItem('Kelas', ticket.cabinClass),
                          const SizedBox(height: 14),
                          _buildFieldItem('Bagasi', ticket.baggageWeight),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PEMISAH DENGAN NOTCH BULAT DI KIRI & KANAN
          _buildNotchDivider(),

          // BAGIAN BAWAH TIKET (QR Code)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(
              children: [
                // QR Code Prosedural (Presisi, zero dependency)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: SizedBox(
                    width: 190,
                    height: 190,
                    child: CustomPaint(
                      painter: _ProceduralQRPainter(seed: ticket.id),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tunjukkan QR ini saat check-in di bandara',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No. Tiket ${ticket.ticketNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _buildNotchDivider() {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Garis Putus-putus
          LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 6.0;
              const dashSpace = 4.0;
              final width = constraints.maxWidth - 40; // menyisakan jarak notch
              final count = (width / (dashWidth + dashSpace)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  count,
                  (_) => Container(
                    width: dashWidth,
                    height: 1.5,
                    margin: const EdgeInsets.symmetric(horizontal: dashSpace / 2),
                    color: Colors.grey.shade300,
                  ),
                ),
              );
            },
          ),
          // Notch Kiri (lingkaran yang memotong kartu menyatu dengan background)
          Positioned(
            left: -14,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: _bg,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Notch Kanan
          Positioned(
            right: -14,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: _bg,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter untuk menggambar QR Code prosedural tajam tanpa third-party library
class _ProceduralQRPainter extends CustomPainter {
  _ProceduralQRPainter({required this.seed});
  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..style = PaintingStyle.fill;

    const int modules = 21; // Standar QR Version 1 (21 x 21)
    final double moduleSize = size.width / modules;

    void drawSquare(int col, int row) {
      canvas.drawRect(
        Rect.fromLTWH(col * moduleSize, row * moduleSize, moduleSize, moduleSize),
        paint,
      );
    }

    void drawFinderPattern(int startX, int startY) {
      // Kotak luar 7x7
      for (int x = 0; x < 7; x++) {
        for (int y = 0; y < 7; y++) {
          if (x == 0 || x == 6 || y == 0 || y == 6 || (x >= 2 && x <= 4 && y >= 2 && y <= 4)) {
            drawSquare(startX + x, startY + y);
          }
        }
      }
    }

    // Tiga Finder Pattern di sudut
    drawFinderPattern(0, 0); // Kiri atas
    drawFinderPattern(modules - 7, 0); // Kanan atas
    drawFinderPattern(0, modules - 7); // Kiri bawah

    // Timing patterns
    for (int i = 8; i < modules - 8; i += 2) {
      drawSquare(i, 6);
      drawSquare(6, i);
    }

    // Data matrix pseudo-random stabil berdasarkan seed id tiket
    final int baseSeed = seed.hashCode.abs();
    for (int x = 0; x < modules; x++) {
      for (int y = 0; y < modules; y++) {
        // Lewati area finder patterns
        final inTopLeft = x < 8 && y < 8;
        final inTopRight = x >= modules - 8 && y < 8;
        final inBottomLeft = x < 8 && y >= modules - 8;
        if (inTopLeft || inTopRight || inBottomLeft) continue;

        // Formula hash stabil
        final val = (x * 37 + y * 17 + baseSeed) % 100;
        if (val < 45) {
          drawSquare(x, y);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ProceduralQRPainter oldDelegate) => oldDelegate.seed != seed;
}
