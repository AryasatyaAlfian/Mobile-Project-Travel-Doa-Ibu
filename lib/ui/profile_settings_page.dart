import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/smooth_page_route.dart';
import '../services/travel_api.dart';
import 'profile_language_page.dart';

/// Halaman Pengaturan & Preferensi Aplikasi
/// Layout 1:1 Presisi Sesuai Figma dengan Header Ka'bah & Curved Top Sheet
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({
    super.key,
    this.api,
    this.initialLanguage = 'Bahasa Indonesia',
    this.initialTheme = 'Terang',
    this.initialNotification = true,
    this.initialCurrency = 'Rupiah (IDR)',
  });

  final TravelApi? api;
  final String initialLanguage;
  final String initialTheme;
  final bool initialNotification;
  final String initialCurrency;

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late String _language;
  late String _theme;
  late bool _notificationsEnabled;
  late String _currency;

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF94A3B8);
  static const Color _green = Color(0xFF22C55E);

  Map<String, dynamic> _serverSettings = {};

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _theme = widget.initialTheme;
    _notificationsEnabled = widget.initialNotification;
    _currency = widget.initialCurrency;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (widget.api == null) return;
    try {
      final res = await widget.api!.settings();
      if (mounted) setState(() => _serverSettings = res);
    } catch (_) {}
  }

  Future<void> _openLanguageSelection() async {
    final selected = await Navigator.push<String>(
      context,
      SmoothPageRoute<String>(
        page: ProfileLanguagePage(
          currentLanguage: _language,
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() => _language = selected);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bahasa aplikasi diubah ke $selected.'),
          backgroundColor: _green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openThemeSelection() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Tema Tampilan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  title: Text(
                    'Terang',
                    style: GoogleFonts.poppins(
                      fontWeight: _theme == 'Terang' ? FontWeight.w700 : FontWeight.w500,
                      color: _ink,
                    ),
                  ),
                  trailing: _theme == 'Terang'
                      ? const Icon(Icons.check_circle_rounded, color: _ink)
                      : null,
                  onTap: () {
                    setState(() => _theme = 'Terang');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: Text(
                    'Gelap (Dark Mode)',
                    style: GoogleFonts.poppins(
                      fontWeight: _theme == 'Gelap' ? FontWeight.w700 : FontWeight.w500,
                      color: _ink,
                    ),
                  ),
                  trailing: _theme == 'Gelap'
                      ? const Icon(Icons.check_circle_rounded, color: _ink)
                      : null,
                  onTap: () {
                    setState(() => _theme = 'Gelap');
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

  void _openCurrencySelection() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final currencies = ['Rupiah (IDR)', 'Saudi Riyal (SAR)', 'US Dollar (USD)'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Mata Uang Acuan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 14),
                ...currencies.map(
                  (cur) => ListTile(
                    title: Text(
                      cur,
                      style: GoogleFonts.poppins(
                        fontWeight: _currency == cur ? FontWeight.w700 : FontWeight.w500,
                        color: _ink,
                      ),
                    ),
                    trailing: _currency == cur
                        ? const Icon(Icons.check_circle_rounded, color: _ink)
                        : null,
                    onTap: () {
                      setState(() => _currency = cur);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.6,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Background Ka'bah Malam Kompak (Tinggi 135px)
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
                            'Pengaturan',
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
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Seksi: Preferensi Aplikasi
                            Text(
                              'Preferensi Aplikasi',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Item 1: Bahasa Aplikasi
                            _buildSettingTile(
                              icon: Icons.language_rounded,
                              title: 'Bahasa Aplikasi',
                              subtitle: _language,
                              onTap: _openLanguageSelection,
                            ),
                            const SizedBox(height: 10),

                            // Item 2: Tema Tampilan
                            _buildSettingTile(
                              icon: Icons.wb_sunny_outlined,
                              title: 'Tema Tampilan',
                              subtitle: _theme,
                              onTap: _openThemeSelection,
                            ),
                            const SizedBox(height: 10),

                            // Item 3: Notifikasi (dengan Switch toggle)
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _notificationsEnabled = !_notificationsEnabled);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
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
                                      const Icon(Icons.notifications_none_rounded, color: _ink, size: 21),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          'Notifikasi',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _ink,
                                          ),
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: 0.78,
                                        child: CupertinoSwitch(
                                          value: _notificationsEnabled,
                                          activeTrackColor: _green,
                                          onChanged: (val) {
                                            setState(() => _notificationsEnabled = val);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.chevron_right_rounded, color: _ink, size: 21),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Item 4: Mata Uang
                            _buildSettingTile(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Mata Uang',
                              subtitle: _currency,
                              onTap: _openCurrencySelection,
                            ),
                            const SizedBox(height: 20),

                            // Seksi: Lainnya
                            Text(
                              'Lainnya',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Item 5: Tentang Aplikasi
                            _buildSettingTile(
                              icon: Icons.brightness_medium_outlined,
                              title: 'Tentang Aplikasi',
                              onTap: () {
                                final company = _serverSettings['company_name'] as String? ?? 'Travel Doa Ibu';
                                final email = _serverSettings['email'] as String? ?? 'info@traveldoaibu.com';
                                final phone = _serverSettings['phone'] as String? ?? (_serverSettings['whatsapp_number'] as String? ?? '6281234567890');
                                final address = _serverSettings['address'] as String?;

                                final text = '$company Mobile v1.0.0\n\n'
                                    'Aplikasi pendamping perjalanan ibadah Umrah dan Haji terpadu, memudahkan pendaftaran, pemantauan jadwal manasik, bimbingan Muthawwif secara langsung, dan pengelolaan pembayaran secara aman dan transparan.\n\n'
                                    'Kontak Resmi:\n'
                                    '• Email: $email\n'
                                    '• Telepon / WA: $phone'
                                    '${address != null && address.isNotEmpty ? '\n• Alamat: $address' : ''}';

                                _showInfoDialog('Tentang Aplikasi', text);
                              },
                            ),
                            const SizedBox(height: 10),

                            // Item 6: Syarat dan Ketentuan
                            _buildSettingTile(
                              icon: Icons.description_outlined,
                              title: 'Syarat dan Ketentuan',
                              onTap: () => _showInfoDialog(
                                'Syarat dan Ketentuan',
                                '1. Ketentuan Pendaftaran\nCalon jemaah wajib mengisi data diri dengan benar sesuai identitas paspor/KTP.\n\n2. Pembayaran & Pembatalan\nPembayaran dapat dilakukan bertahap sesuai skema paket yang dipilih. Pembatalan tiket mengikuti regulasi maskapai dan akomodasi hotel di Arab Saudi.\n\n3. Kebijakan Kesehatan\nJemaah wajib memenuhi persyaratan vaksinasi dan tes kesehatan yang diwajibkan oleh Kementerian Haji dan Umrah Kerajaan Arab Saudi.',
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Item 7: Kebijakan Privasi
                            _buildSettingTile(
                              icon: Icons.shield_outlined,
                              title: 'Kebijakan Privasi',
                              onTap: () => _showInfoDialog(
                                'Kebijakan Privasi',
                                'Kami menghargai privasi Anda dan berkomitmen melindungi seluruh data pribadi serta dokumen perjalanan Anda. Data nomor paspor, foto KTP, dan bukti pembayaran hanya digunakan untuk keperluan pengurusan visa, reservasi tiket, dan administrasi resmi ibadah.',
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
              Icon(icon, color: _ink, size: 21),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _ink, size: 21),
            ],
          ),
        ),
      ),
    );
  }
}
