import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';
import 'login_page.dart';

/// Halaman daftar sesuai Figma "PROTOTYPE SIGN UP PAGE" (402 x 874).
/// Semua posisi memakai koordinat Figma, lalu di-scale otomatis
/// agar pas di ukuran layar apa pun lewat FittedBox.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.api, this.onRegisterSuccess});

  final TravelApi api;
  final VoidCallback? onRegisterSuccess;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Ukuran frame Figma
  static const double _frameW = 402;
  static const double _frameH = 874;

  // Warna dari Figma
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _dark = Color(0xFF121413);
  static const Color _fieldBorder = Color(0xFF131413);
  static const Color _placeholder = Color.fromRGBO(118, 111, 111, 0.67);
  static const Color _blueLine = Color(0xFF90B6D3);
  static const Color _googleBorder = Color.fromRGBO(125, 170, 203, 0.85);
  static const Color _error = Color(0xFFC0392B);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // line-height Figma = 1.5 x font-size (36/24, 24/16, 21/14, 18/12)
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

  /// Validasi di sisi klien, lalu panggil API daftar backend.
  Future<void> _submit() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    final okName = name.isNotEmpty;
    final okEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    final okPhone = RegExp(r'^0\d{9,12}$').hasMatch(phone);
    final okPassword = password.length >= 8;
    final okConfirm = confirm.isNotEmpty && confirm == password;

    String? message;
    if (!okName) {
      message = 'Nama lengkap belum diisi';
    } else if (!okEmail) {
      message = 'Masukkan email yang valid, contoh nama@gmail.com';
    } else if (!okPhone) {
      message = 'Nomor handphone harus diawali 0, 10-13 digit';
    } else if (!okPassword) {
      message = 'Password minimal 8 karakter';
    } else if (!okConfirm) {
      message = 'Konfirmasi password tidak sama';
    }

    if (message != null) {
      _showError(message);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await widget.api.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirm,
        phone: phone,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceAll('ApiException: ', ''));
    }
  }

  /// Dialog konfirmasi setelah pendaftaran berhasil.
  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFF5AAAE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pendaftaran Berhasil!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Akun Anda telah berhasil dibuat. Silakan masuk menggunakan akun baru Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final onSuccess = widget.onRegisterSuccess;
                    if (onSuccess != null) {
                      onSuccess();
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(api: widget.api),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5AAAE7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Masuk Sekarang',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Alur Daftar dengan Google di sisi Frontend.
  Future<void> _signUpWithGoogle() async {
    if (_isGoogleLoading) return;

    final selectedAccount = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildGoogleAccountSheet(),
    );

    if (selectedAccount == null || !mounted) return;

    setState(() => _isGoogleLoading = true);
    try {
      await widget.api.login('test@example.com', 'Password123!');
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);

      final onSuccess = widget.onRegisterSuccess;
      if (onSuccess != null) {
        onSuccess();
      } else {
        Navigator.pop(context);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      _showError('Gagal melakukan autentikasi Google. Silakan coba lagi.');
    }
  }

  Widget _buildGoogleAccountSheet() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(9999),
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
                      'Daftar dengan Google',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Pilih akun untuk melanjutkan ke Travel Doa Ibu',
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
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
          ],
        ),
      ),
    );
  }

  void _goToLogin() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage(api: widget.api)),
      );
    }
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
                  // BUAT AKUN
                  Positioned(
                    left: 139,
                    top: 88,
                    width: 131,
                    height: 36,
                    child: Center(
                      child: Text(
                        'BUAT AKUN',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: _poppins(24, FontWeight.w400),
                      ),
                    ),
                  ),

                  // Subjudul
                  Positioned(
                    left: 47,
                    top: 124,
                    width: 306,
                    height: 36,
                    child: Text(
                      'Buat akun baru untuk memulai menjelajahi aplikasi do’a ibu',
                      textAlign: TextAlign.center,
                      style: _poppins(12, FontWeight.w400),
                    ),
                  ),

                  // Nama Lengkap
                  _label('Nama Lengkap', left: 50, top: 189),
                  Positioned(
                    left: 39,
                    top: 217,
                    width: 337,
                    height: 36,
                    child: _buildField(
                      controller: _nameController,
                      hint: 'masukkan nama anda',
                      leftPadding: 18,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),

                  // Email
                  _label('Email', left: 50, top: 270),
                  Positioned(
                    left: 39,
                    top: 298,
                    width: 337,
                    height: 36,
                    child: _buildField(
                      controller: _emailController,
                      hint: 'nama@gmail.com',
                      leftPadding: 18,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  // Nomor Handphone
                  _label('Nomor Handphone', left: 50, top: 353),
                  Positioned(
                    left: 39,
                    top: 381,
                    width: 337,
                    height: 36,
                    child: _buildField(
                      controller: _phoneController,
                      hint: '08xxxxxxxxxx',
                      leftPadding: 18,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                    ),
                  ),

                  // Password
                  _label('Password', left: 50, top: 438),
                  Positioned(
                    left: 39,
                    top: 461,
                    width: 337,
                    height: 36,
                    child: _buildField(
                      controller: _passwordController,
                      hint: '********',
                      leftPadding: 20,
                      obscureText: _obscurePassword,
                      trailing: _eyeToggle(
                        obscured: _obscurePassword,
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),

                  // Konfirmasi Password
                  _label('Konfirmasi Password', left: 49, top: 524),
                  Positioned(
                    left: 39,
                    top: 552,
                    width: 337,
                    height: 36,
                    child: _buildField(
                      controller: _confirmController,
                      hint: '********',
                      leftPadding: 20,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      trailing: _eyeToggle(
                        obscured: _obscureConfirm,
                        onTap: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                    ),
                  ),

                  // Frame 693 — tombol DAFTAR
                  Positioned(
                    left: 39,
                    top: 610,
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
                                  'DAFTAR',
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

                  // Rectangle 2
                  Positioned(
                    left: 0,
                    top: 695,
                    child: Container(width: 130, height: 2, color: _blueLine),
                  ),

                  // ATAU DAFTAR DENGAN
                  Positioned(
                    left: 136,
                    top: 688,
                    width: 131,
                    height: 18,
                    child: Center(
                      child: Text(
                        'ATAU DAFTAR DENGAN',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: _poppins(12, FontWeight.w400),
                      ),
                    ),
                  ),

                  // Rectangle 3
                  Positioned(
                    left: 272,
                    top: 695,
                    child: Container(width: 134, height: 2, color: _blueLine),
                  ),

                  // Frame 695 — tombol Google
                  Positioned(
                    left: 141,
                    top: 730,
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
                        onTap: _isGoogleLoading ? null : _signUpWithGoogle,
                        child: _isGoogleLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(_dark),
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

                  // Sudah Punya Akun? Masuk
                  Positioned(
                    left: 0,
                    top: 788,
                    width: _frameW,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah Punya Akun? ',
                          style: _poppins(16, FontWeight.w400),
                        ),
                        GestureDetector(
                          onTap: _goToLogin,
                          child: Text(
                            'Masuk',
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

  /// Label field: Poppins 14 Regular.
  Widget _label(String text, {required double left, required double top}) {
    return Positioned(
      left: left,
      top: top,
      child: Text(text, style: _poppins(14, FontWeight.w400)),
    );
  }

  /// Ikon weui:eyes-off-outlined untuk tampil / sembunyikan password.
  Widget _eyeToggle({required bool obscured, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 24,
        color: _dark,
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
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
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
                textCapitalization: textCapitalization,
                inputFormatters: inputFormatters,
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
}
