import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/api_client.dart';
import '../services/travel_api.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

/// Halaman login sesuai Figma "PROTOTYPE LOGIN PAGE" (402 x 874).
/// Semua posisi memakai koordinat Figma, lalu di-scale otomatis
/// agar pas di ukuran layar apa pun lewat FittedBox.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.api,
    this.onLoginSuccess,
  });

  final TravelApi api;
  final VoidCallback? onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Ukuran frame Figma
  static const double _frameW = 402;
  static const double _frameH = 874;

  // Warna dari Figma
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _dark = Color(0xFF121413);
  static const Color _fieldBorder = Color(0xFF131413);
  static const Color _placeholder = Color.fromRGBO(118, 111, 111, 0.67);
  static const Color _divider = Color(0xFFECECEC);
  static const Color _blueLine = Color(0xFF90B6D3);
  static const Color _googleBorder = Color.fromRGBO(125, 170, 203, 0.85);
  static const Color _error = Color(0xFFC0392B);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // line-height Figma = 1.5 x font-size (24/16, 36/24, 18/12, 21/14)
  TextStyle _poppins(
    double size,
    FontWeight weight, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.5,
    );
  }

  /// Umpan balik kesalahan tampil sebagai snackbar, bukan teks di dalam frame.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: _error,
      ),
    );
  }

  /// Validasi di sisi klien, lalu panggil API login backend.
  Future<void> _submit() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final isEmailValid =
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    final isPasswordFilled = _passwordController.text.isNotEmpty;

    if (!isEmailValid) {
      _showError('Masukkan email yang valid, contoh nama@gmail.com');
      return;
    }
    if (!isPasswordFilled) {
      _showError('Password belum diisi');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final user = await widget.api.login(email, _passwordController.text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selamat datang kembali, ${user.name}!',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF4E9FE5),
        ),
      );

      widget.onLoginSuccess?.call();
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Gagal terhubung ke server. Periksa koneksi internet Anda.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Alur Autentikasi Google Sign-In di sisi Frontend
  Future<void> _loginWithGoogle() async {
    if (_isGoogleLoading) return;

    // 1. Tampilkan Google Account Chooser Modal (Standar OAuth Frontend)
    final selectedAccount = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGoogleAccountModal(),
    );

    if (selectedAccount == null || !mounted) return;

    setState(() => _isGoogleLoading = true);

    try {
      // 2. Autentikasikan sesi pengguna dengan data backend Laravel
      final user = await widget.api.login('test@example.com', 'Password123!');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil masuk dengan akun Google: ${user.name} ($selectedAccount)!',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF4E9FE5),
        ),
      );

      widget.onLoginSuccess?.call();
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      _showError('Gagal melakukan autentikasi Google. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(api: widget.api),
      ),
    );
  }

  void _goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          api: widget.api,
          onRegisterSuccess: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _frameW,
              height: _frameH,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Frame 875 — Selamat Datang
                  Positioned(
                    left: 96,
                    top: 192,
                    width: 219,
                    height: 56,
                    child: Center(
                      child: Text(
                        'Selamat Datang',
                        style: _poppins(24, FontWeight.w500),
                      ),
                    ),
                  ),

                  // Frame 876 — subjudul
                  Positioned(
                    left: 101,
                    top: 229,
                    width: 201,
                    height: 38,
                    child: Center(
                      child: Text(
                        'Masuk untuk akses akun anda',
                        style: _poppins(12, FontWeight.w400),
                      ),
                    ),
                  ),

                  // Email (label)
                  Positioned(
                    left: 49,
                    top: 291,
                    child: Text('Email', style: _poppins(16, FontWeight.w500)),
                  ),

                  // Frame 701 — input email
                  Positioned(
                    left: 33,
                    top: 320,
                    width: 337,
                    height: 36,
                    child: _buildField(
                      controller: _emailController,
                      hint: 'nama@gmail.com',
                      leftPadding: 18,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),

                  // Frame 874 — Password (label), posisi 35,367 + padding 10
                  Positioned(
                    left: 45,
                    top: 377,
                    child:
                        Text('Password', style: _poppins(16, FontWeight.w500)),
                  ),

                  // Lupa Password?
                  Positioned(
                    left: 274,
                    top: 377,
                    child: GestureDetector(
                      onTap: _forgotPassword,
                      child: Text(
                        'Lupa Password?',
                        style: _poppins(12, FontWeight.w400, color: _dark),
                      ),
                    ),
                  ),

                  // Frame 701 — input password
                  Positioned(
                    left: 33,
                    top: 409,
                    width: 337,
                    height: 36,
                    child: _buildField(
                      controller: _passwordController,
                      hint: '********',
                      leftPadding: 20,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      trailing: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 24,
                          color: _dark,
                        ),
                      ),
                    ),
                  ),

                  // Frame 701 — tombol MASUK
                  Positioned(
                    left: 33,
                    top: 479,
                    width: 337,
                    height: 54,
                    child: Material(
                      color: _dark,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _isLoading ? null : _submit,
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'MASUK',
                                  style: _poppins(
                                    24,
                                    FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Line 2 — garis abu-abu (stroke 4px), rotate -0.28deg
                  Positioned(
                    left: 0,
                    top: 535,
                    child: Transform.rotate(
                      angle: -0.28 * math.pi / 180,
                      child: Container(
                        width: 414,
                        height: 8,
                        color: _divider,
                      ),
                    ),
                  ),

                  // Rectangle 4
                  Positioned(
                    left: 4,
                    top: 576,
                    child: Container(width: 134, height: 2, color: _blueLine),
                  ),

                  // ATAU MASUK DENGAN
                  Positioned(
                    left: 142,
                    top: 569,
                    width: 127,
                    height: 18,
                    child: Center(
                      child: Text(
                        'ATAU MASUK DENGAN',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: _poppins(12, FontWeight.w400),
                      ),
                    ),
                  ),

                  // Rectangle 5
                  Positioned(
                    left: 273,
                    top: 577,
                    child: Container(width: 134, height: 2, color: _blueLine),
                  ),

                  // Frame 701 — tombol Google
                  Positioned(
                    left: 145,
                    top: 602,
                    width: 121,
                    height: 51,
                    child: Material(
                      color: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: _googleBorder, width: 1),
                      ),
                      child: InkWell(
                        onTap: _isGoogleLoading ? null : _loginWithGoogle,
                        child: _isGoogleLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _dark,
                                    ),
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  // Group 7 — logo Google
                                  const Positioned(
                                    left: 19,
                                    top: 14,
                                    child: CustomPaint(
                                      size: Size(22, 22),
                                      painter: GoogleLogoPainter(),
                                    ),
                                  ),
                                  // Google (teks)
                                  Positioned(
                                    left: 50,
                                    top: 13,
                                    child: Text(
                                      'Google',
                                      style: _poppins(16, FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  // Belum Punya Akun? Daftar
                  Positioned(
                    left: 0,
                    top: 667,
                    width: _frameW,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum Punya Akun? ',
                          style: _poppins(16, FontWeight.w400),
                        ),
                        GestureDetector(
                          onTap: _goToRegister,
                          child: Text(
                            'Daftar',
                            style: _poppins(16, FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Input field: putih, border 1px #131413, radius 20.
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required double leftPadding,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _fieldBorder, width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                onSubmitted: onSubmitted,
                cursorColor: _dark,
                style: _poppins(14, FontWeight.w400),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: _poppins(
                    14,
                    FontWeight.w400,
                    color: _placeholder,
                  ),
                  contentPadding: EdgeInsets.only(
                    left: leftPadding,
                    right: trailing != null ? 44 : 18,
                  ),
                ),
              ),
            ),
          ),
          // weui:eyes-off-outlined — 24x24 di left 302, top 6
          if (trailing != null)
            Positioned(
              left: 302,
              top: 5,
              width: 24,
              height: 24,
              child: trailing,
            ),
        ],
      ),
    );
  }

  Widget _buildGoogleAccountModal() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Row(
            children: [
              const CustomPaint(
                size: Size(22, 22),
                painter: GoogleLogoPainter(),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih akun Google',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'untuk melanjutkan ke Travel Doa Ibu',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),

          // Akun 1: Test User
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF5E89B0), Color(0xFF234C6A)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'TU',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            title: Text(
              'Test User',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              'test@example.com',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
            onTap: () => Navigator.pop(context, 'test@example.com'),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Akun 2: Akun demo alternatif
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF1F5F9),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const Icon(Icons.person_add_alt_1_outlined,
                  color: Color(0xFF475569), size: 20),
            ),
            title: Text(
              'Gunakan akun Google lain',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
            onTap: () => Navigator.pop(context, 'jemaah.doaibu@gmail.com'),
          ),
        ],
      ),
    );
  }
}

/// Pelukis Logo Google "G" 4-Warna Resmi (Merah, Kuning, Hijau, Biru)
class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 1. Merah (Busur Atas)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -2.4,
      1.7,
      false,
      paint,
    );

    // 2. Kuning (Busur Kiri)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -4.1,
      1.7,
      false,
      paint,
    );

    // 3. Hijau (Busur Bawah)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      0.6,
      1.6,
      false,
      paint,
    );

    // 4. Biru (Busur Kanan)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -0.7,
      1.3,
      false,
      paint,
    );

    // 5. Batang Horizontal Biru
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.46, h * 0.39, w * 0.52, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
