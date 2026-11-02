import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Halaman Transfer Bank / QRIS
/// Layout 1:1 Presisi Sesuai Figma Prototype
class ProfileBankTransferQrisPage extends StatefulWidget {
  const ProfileBankTransferQrisPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<ProfileBankTransferQrisPage> createState() => _ProfileBankTransferQrisPageState();
}

class _ProfileBankTransferQrisPageState extends State<ProfileBankTransferQrisPage> {
  late int _selectedTab;
  String _selectedBank = 'BCA';

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF94A3B8);
  static const Color _primaryGold = Color(0xFFDCAE68);

  final Map<String, Map<String, String>> _bankData = {
    'BCA': {
      'name': 'Bank Central Asia (BCA)',
      'account': '1234 5678 9012',
      'holder': "PT Travel Do'a Ibu",
      'code': '014',
    },
    'Mandiri': {
      'name': 'Bank Mandiri',
      'account': '1370 0123 4567 8',
      'holder': "PT Travel Do'a Ibu",
      'code': '008',
    },
    'BSI': {
      'name': 'Bank Syariah Indonesia (BSI)',
      'account': '7123 4567 89',
      'holder': "PT Travel Do'a Ibu",
      'code': '451',
    },
    'BNI': {
      'name': 'Bank Negara Indonesia (BNI)',
      'account': '0234 5678 90',
      'holder': "PT Travel Do'a Ibu",
      'code': '009',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text.replaceAll(' ', '')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke papan klip.', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: const Color(0xFF22C55E),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleConfirmTransfer() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Konfirmasi Pembayaran', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(
          'Bukti pembayaran Anda akan diverifikasi secara otomatis oleh sistem dalam 1x24 jam kerja.',
          style: GoogleFonts.poppins(fontSize: 13, height: 1.5, color: const Color(0xFF64748B)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terima kasih, pembayaran Anda sedang diproses.', style: GoogleFonts.poppins(fontSize: 13)),
                  backgroundColor: const Color(0xFF22C55E),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Tutup', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showBankPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 18),
                Text('Pilih Rekening Tujuan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
                const SizedBox(height: 14),
                for (final key in _bankData.keys)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text(key, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF003087))),
                    ),
                    title: Text(_bankData[key]!['name']!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                    trailing: _selectedBank == key ? const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E)) : null,
                    onTap: () {
                      setState(() => _selectedBank = key);
                      Navigator.pop(ctx);
                    },
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
    final currentBank = _bankData[_selectedBank]!;

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

          // 2. Konten Utama
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar Navigasi
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
                            _selectedTab == 0 ? 'Transfer Bank / QRIS' : 'QRIS',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
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
                const SizedBox(height: 6),

                // 3. Curved Sheet Container
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
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Segmented Capsule Toggle: Transfer Bank | QRIS
                          Container(
                            height: 46,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1E9DB),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedTab = 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedTab == 0 ? const Color(0xFFECC485) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Transfer Bank',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                          color: _selectedTab == 0 ? _ink : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedTab = 1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedTab == 1 ? const Color(0xFFECC485) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'QRIS',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                          color: _selectedTab == 1 ? _ink : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          if (_selectedTab == 0) ...[
                            // TAB 1: TRANSFER BANK
                            Text(
                              'Pilih Bank',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
                            ),
                            const SizedBox(height: 8),

                            // Dropdown Bank Selector
                            InkWell(
                              onTap: _showBankPicker,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Text('▲', style: TextStyle(color: Color(0xFF003087), fontSize: 13)),
                                    const SizedBox(width: 8),
                                    Text(_selectedBank, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF003087))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        currentBank['name']!,
                                        style: GoogleFonts.poppins(fontSize: 13, color: _ink),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: _ink, size: 22),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Detail Rekening Card (Light Blue Tint)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF5FF),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Nomor Rekening',
                                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF2563EB), fontWeight: FontWeight.w500),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF2563EB)),
                                        onPressed: () => _copyToClipboard(currentBank['account']!, 'Nomor rekening'),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    currentBank['account']!,
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: _ink),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Nama Penerima',
                                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                                  ),
                                  Text(
                                    currentBank['holder']!,
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Kode Bank',
                                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                                  ),
                                  Text(
                                    currentBank['code']!,
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Catatan Penting Card (Soft Amber Tint)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle),
                                        child: const Icon(Icons.info_outline, color: Colors.white, size: 13),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Catatan Penting',
                                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildBulletPoint('Pastikan nama dan nomor rekening sesuai.'),
                                  _buildBulletPoint('Transfer sesuai nominal yang ditampilkan.'),
                                  _buildBulletPoint('Simpan bukti pembayaran.'),
                                  _buildBulletPoint('Konfirmasi pembayaran setelah transfer selesai.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Tombol Primary: Saya Sudah Transfer
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _handleConfirmTransfer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryGold,
                                  foregroundColor: _ink,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('Saya Sudah Transfer', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ] else ...[
                            // TAB 2: QRIS
                            Center(
                              child: Text(
                                'QRIS',
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: _ink),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // QRIS Code Box
                            Center(
                              child: Container(
                                width: 220,
                                height: 220,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFF1E7D5), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const _ProceduralQrisPainterWidget(),
                              ),
                            ),
                            const SizedBox(height: 14),

                            Text(
                              'Scan QR Code ini dengan aplikasi pembayaran Anda (GoPay, OVO, Dana, ShopeePay, Mobile Banking, dll).',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 11, color: _muted, height: 1.4),
                            ),
                            const SizedBox(height: 18),

                            // Detail Nominal & Merchant
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFF1E7D5), width: 0.8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Nominal Pembayaran', style: GoogleFonts.poppins(fontSize: 11, color: _muted)),
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded, size: 16, color: _muted),
                                        onPressed: () => _copyToClipboard('10500000', 'Nominal pembayaran'),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  Text('Rp 10.500.000', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
                                  const SizedBox(height: 10),
                                  Text('Nama Merchant', style: GoogleFonts.poppins(fontSize: 11, color: _muted)),
                                  Text("Travel Do'a Ibu", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _ink)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Tombol Primary: Saya Sudah Transfer
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _handleConfirmTransfer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryGold,
                                  foregroundColor: _ink,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('Saya Sudah Transfer', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget CustomPainter untuk rendering kode QRIS tajam, presisi, dan ringan tanpa dependensi luar
class _ProceduralQrisPainterWidget extends StatelessWidget {
  const _ProceduralQrisPainterWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(190, 190),
      painter: _QrisPainter(),
    );
  }
}

class _QrisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF1E293B);
    final paintBg = Paint()..color = Colors.white;

    final cell = size.width / 25;

    // Helper untuk menggambar kotak modul finder QR
    void drawFinder(double startX, double startY) {
      canvas.drawRect(Rect.fromLTWH(startX, startY, cell * 7, cell * 7), paintDark);
      canvas.drawRect(Rect.fromLTWH(startX + cell, startY + cell, cell * 5, cell * 5), paintBg);
      canvas.drawRect(Rect.fromLTWH(startX + cell * 2, startY + cell * 2, cell * 3, cell * 3), paintDark);
    }

    // 3 Finder patterns di tiga sudut
    drawFinder(0, 0);
    drawFinder(size.width - cell * 7, 0);
    drawFinder(0, size.height - cell * 7);

    // Timing patterns
    for (int i = 8; i < 17; i += 2) {
      canvas.drawRect(Rect.fromLTWH(i * cell, 6 * cell, cell, cell), paintDark);
      canvas.drawRect(Rect.fromLTWH(6 * cell, i * cell, cell, cell), paintDark);
    }

    // Data matrix pseudo-random berulang deterministik
    final pattern = [
      0x5A, 0x3C, 0xF0, 0x96, 0x69, 0x0F, 0xAA, 0x55,
      0xC3, 0xA5, 0x5A, 0x33, 0xCC, 0xF0, 0x0F, 0x87,
      0x4B, 0x2D, 0x1E, 0x8F, 0xC6, 0x78, 0x3C, 0x55,
    ];

    int byteIdx = 0;
    for (int r = 0; r < 25; r++) {
      for (int c = 0; c < 25; c++) {
        // Lewati area finder
        if ((r < 8 && c < 8) || (r < 8 && c > 16) || (r > 16 && c < 8)) continue;
        // Lewati area logo tengah
        if (r >= 10 && r <= 14 && c >= 9 && c <= 15) continue;

        final byte = pattern[byteIdx % pattern.length];
        final bit = (byte >> ((r + c) % 8)) & 1;
        if (bit == 1) {
          canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell * 0.92, cell * 0.92), paintDark);
        }
        byteIdx++;
      }
    }

    // Logo QRIS di tengah
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cell * 6.5,
      height: cell * 3.2,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(4)), paintBg);
    final borderPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(4)), borderPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'QRIS',
        style: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

