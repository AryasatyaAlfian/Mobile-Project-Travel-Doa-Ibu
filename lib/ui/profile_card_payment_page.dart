import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/smooth_page_route.dart';
import '../services/travel_api.dart';

/// Halaman Pemilihan Metode Pembayaran / Kartu Kredit & Debit
/// Layout 1:1 Presisi Sesuai Figma Prototype
class ProfilePaymentMethodsPage extends StatefulWidget {
  const ProfilePaymentMethodsPage({super.key});

  @override
  State<ProfilePaymentMethodsPage> createState() => _ProfilePaymentMethodsPageState();
}

class _ProfilePaymentMethodsPageState extends State<ProfilePaymentMethodsPage> {
  int _selectedCardIndex = 0;

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF94A3B8);
  static const Color _primaryGold = Color(0xFFDCAE68);

  final List<Map<String, String>> _cards = [
    {
      'type': 'Visa Card',
      'brand': 'Visa',
      'number': '4000 1234 5678 9012',
      'last4': '9012',
      'exp': '12/26',
    },
    {
      'type': 'Mastercard',
      'brand': 'Mastercard',
      'number': '5105 1234 5678 3456',
      'last4': '3456',
      'exp': '08/27',
    },
  ];

  void _showAddCardSheet() {
    final numberController = TextEditingController();
    final expController = TextEditingController();
    final cvvController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text('Tambah Kartu Baru', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 16),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nomor Kartu',
                  hintText: '4000 0000 0000 0000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'Expired (MM/YY)',
                        hintText: '12/28',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final rawNum = numberController.text.trim();
                  if (rawNum.isNotEmpty) {
                    final last4 = rawNum.length >= 4 ? rawNum.substring(rawNum.length - 4) : '0000';
                    setState(() {
                      _cards.add({
                        'type': 'Visa Card',
                        'brand': 'Visa',
                        'number': rawNum,
                        'last4': last4,
                        'exp': expController.text.trim().isNotEmpty ? expController.text.trim() : '12/28',
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kartu •••• $last4 berhasil ditambahkan.', style: GoogleFonts.poppins(fontSize: 13)),
                        backgroundColor: const Color(0xFF22C55E),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Simpan Kartu', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCardDetail() {
    final selectedCard = _cards[_selectedCardIndex];
    Navigator.push(
      context,
      SmoothPageRoute(
        page: ProfileCardDetailPage(
          cardData: selectedCard,
          onCardDeleted: () {
            setState(() {
              if (_cards.length > 1) {
                _cards.removeAt(_selectedCardIndex);
                _selectedCardIndex = 0;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = TravelApi.currentUser;
    final userName = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'Zara Anselma';
    final currentCard = _cards[_selectedCardIndex];

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
                            'Pilih Metode Pembayaran',
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
                          Text(
                            currentCard['type']!,
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _ink),
                          ),
                          const SizedBox(height: 10),

                          // Kartu Kredit Visual Biru (Hero / Banner)
                          InkWell(
                            onTap: _openCardDetail,
                            borderRadius: BorderRadius.circular(22),
                            child: _CreditCardVisual(
                              number: currentCard['number']!,
                              holderName: userName,
                              exp: currentCard['exp']!,
                              brand: currentCard['brand']!,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Dot Pagination Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < 3; i++)
                                Container(
                                  width: i == 0 ? 18 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: i == 0 ? const Color(0xFFC08C4A) : const Color(0xFFCBD5E1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Metode Pembayaran',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _ink),
                          ),
                          const SizedBox(height: 10),

                          // Daftar Opsi Kartu & Tambah Kartu
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1E7D5), width: 0.8),
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < _cards.length; i++) ...[
                                  InkWell(
                                    onTap: () => setState(() => _selectedCardIndex = i),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          _buildCardBrandIcon(_cards[i]['brand']!),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _cards[i]['type']!,
                                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
                                                ),
                                                Text(
                                                  '•••• ${_cards[i]['last4']}',
                                                  style: GoogleFonts.poppins(fontSize: 11, color: _muted),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildCustomRadio(selected: _selectedCardIndex == i),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),
                                ],
                                InkWell(
                                  onTap: _showAddCardSheet,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7E5C8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add, color: _ink, size: 20),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            'Tambah Kartu Baru',
                                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Tombol Primary: Lanjutkan Pembayaran / Lihat Detail
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _openCardDetail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryGold,
                                foregroundColor: _ink,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text('Lanjutkan Pembayaran', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
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

  Widget _buildCustomRadio({required bool selected}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFFB8860B) : const Color(0xFFCBD5E1),
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFB8860B),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCardBrandIcon(String brand) {
    if (brand == 'Mastercard') {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle)),
              Transform.translate(
                offset: const Offset(-4, 0),
                child: Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.85), shape: BoxShape.circle)),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VISA',
        style: TextStyle(
          color: Color(0xFF1D4ED8),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// Halaman Detail Kartu Pembayaran
/// Layout 1:1 Presisi Sesuai Figma Prototype
class ProfileCardDetailPage extends StatefulWidget {
  const ProfileCardDetailPage({
    super.key,
    required this.cardData,
    this.onCardDeleted,
  });

  final Map<String, String> cardData;
  final VoidCallback? onCardDeleted;

  @override
  State<ProfileCardDetailPage> createState() => _ProfileCardDetailPageState();
}

class _ProfileCardDetailPageState extends State<ProfileCardDetailPage> {
  late bool _isDefaultMethod;

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _isDefaultMethod = true;
  }

  void _handleDeleteCard() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus Kartu?', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(
          'Kartu ${widget.cardData['type']} (•••• ${widget.cardData['last4']}) akan dihapus dari akun Anda.',
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onCardDeleted?.call();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kartu berhasil dihapus.', style: GoogleFonts.poppins(fontSize: 13)),
                  backgroundColor: const Color(0xFFE11D48),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _handleEditCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mode edit kartu aktif.', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: _ink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = TravelApi.currentUser;
    final userName = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'Zara Anselma';

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
                            'Detail Kartu',
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
                          // Kartu Visual
                          _CreditCardVisual(
                            number: widget.cardData['number']!,
                            holderName: userName,
                            exp: widget.cardData['exp']!,
                            brand: widget.cardData['brand']!,
                          ),
                          const SizedBox(height: 20),

                          // Tabel Informasi Detail Kartu
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFF1E7D5), width: 0.8),
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow('Nama Pemilik', userName),
                                const SizedBox(height: 14),
                                _buildDetailRow('Jenis Kartu', widget.cardData['brand']!),
                                const SizedBox(height: 14),
                                _buildDetailRow('Nomor Kartu', '•••• ${widget.cardData['last4']}'),
                                const SizedBox(height: 14),
                                _buildDetailRow('Tanggal Expired', widget.cardData['exp']!),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Status', style: GoogleFonts.poppins(fontSize: 12, color: _muted)),
                                    Row(
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 6),
                                        Text('Aktif', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _ink)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Metode Utama', style: GoogleFonts.poppins(fontSize: 12, color: _muted)),
                                    Switch(
                                      value: _isDefaultMethod,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: const Color(0xFFB8860B),
                                      onChanged: (val) => setState(() => _isDefaultMethod = val),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Tombol Aksi Bawah: Hapus Kartu & Edit Kartu
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _handleDeleteCard,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                  label: Text(
                                    'Hapus Kartu',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _handleEditCard,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  icon: const Icon(Icons.edit_outlined, color: _ink, size: 18),
                                  label: Text(
                                    'Edit Kartu',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: _muted)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _ink)),
      ],
    );
  }
}

/// Widget Kartu Kredit Visual Biru Presisi Figma (Wave, Chip, Visa, Nomor, Nama, Exp)
class _CreditCardVisual extends StatelessWidget {
  const _CreditCardVisual({
    required this.number,
    required this.holderName,
    required this.exp,
    required this.brand,
  });

  final String number;
  final String holderName;
  final String exp;
  final String brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 185,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Baris Atas: Ikon Contactless Wave & Logo VISA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
              ),
              Text(
                brand.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          // Chip Kartu Emas Logam
          Container(
            width: 38,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD97706), width: 0.8),
            ),
            child: GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                4,
                (_) => Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.6), width: 0.5),
                  ),
                ),
              ),
            ),
          ),

          // Nomor Kartu
          Text(
            number,
            style: GoogleFonts.sourceCodePro(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2.2,
            ),
          ),

          // Baris Bawah: Nama & Exp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                holderName,
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.9)),
              ),
              Text(
                exp,
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
