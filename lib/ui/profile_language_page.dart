import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Halaman Pilihan Bahasa Aplikasi (Bahasa Indonesia, English, العربية)
/// Layout 1:1 Presisi Sesuai Figma dengan Header Ka'bah & Curved Top Sheet
class ProfileLanguagePage extends StatefulWidget {
  const ProfileLanguagePage({
    super.key,
    this.currentLanguage = 'Bahasa Indonesia',
    this.onLanguageSelected,
  });

  final String currentLanguage;
  final ValueChanged<String>? onLanguageSelected;

  @override
  State<ProfileLanguagePage> createState() => _ProfileLanguagePageState();
}

class _ProfileLanguagePageState extends State<ProfileLanguagePage> {
  late String _selectedLanguage;

  static const Color _gold = Color(0xFFECC485);
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF1F1F1F);

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  void _select(String lang) {
    setState(() => _selectedLanguage = lang);
    widget.onLanguageSelected?.call(lang);
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) Navigator.pop(context, lang);
    });
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
                            'Bahasa Aplikasi',
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF1E7D5), width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildLanguageItem(
                                name: 'Bahasa Indonesia',
                                isSelected: _selectedLanguage == 'Bahasa Indonesia',
                                flagWidget: _buildIndonesianFlag(),
                                onTap: () => _select('Bahasa Indonesia'),
                              ),
                              const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56, endIndent: 16),
                              _buildLanguageItem(
                                name: 'English',
                                isSelected: _selectedLanguage == 'English',
                                flagWidget: _buildUKFlag(),
                                onTap: () => _select('English'),
                              ),
                              const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56, endIndent: 16),
                              _buildLanguageItem(
                                name: 'العربية',
                                isSelected: _selectedLanguage == 'العربية',
                                flagWidget: _buildSaudiFlag(),
                                isArabic: true,
                                onTap: () => _select('العربية'),
                              ),
                            ],
                          ),
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

  Widget _buildLanguageItem({
    required String name,
    required bool isSelected,
    required Widget flagWidget,
    required VoidCallback onTap,
    bool isArabic = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            flagWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: isArabic ? 16 : 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: _ink,
                ),
              ),
            ),
            _buildRadioButton(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(bool selected) {
    if (selected) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _ink, width: 2),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: _ink,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
      ),
    );
  }

  Widget _buildIndonesianFlag() {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Column(
          children: [
            Expanded(child: Container(color: const Color(0xFFEF4444))),
            Expanded(child: Container(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildUKFlag() {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF012169),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: 0.55,
              child: Container(width: 32, height: 4, color: Colors.white),
            ),
            Transform.rotate(
              angle: -0.55,
              child: Container(width: 32, height: 4, color: Colors.white),
            ),
            Transform.rotate(
              angle: 0.55,
              child: Container(width: 32, height: 1.5, color: const Color(0xFFC8102E)),
            ),
            Transform.rotate(
              angle: -0.55,
              child: Container(width: 32, height: 1.5, color: const Color(0xFFC8102E)),
            ),
            Container(width: 26, height: 6, color: Colors.white),
            Container(width: 6, height: 18, color: Colors.white),
            Container(width: 26, height: 3, color: const Color(0xFFC8102E)),
            Container(width: 3, height: 18, color: const Color(0xFFC8102E)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaudiFlag() {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF006C35),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: const Center(
        child: Text(
          '🇸🇦',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
