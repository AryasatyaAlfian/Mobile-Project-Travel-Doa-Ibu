import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';

/// Elysian Horizon — Forgot Password Flow (Lupa Password)
/// 100% Presisi sesuai prototipe Figma Gambar 1 - 5:
/// - Step 1: Input Email terdaftar -> Tombol "Kirim Email" (PROTOTYPE FORGOT PASS USER 5)
/// - Step 2: Cek Email Anda -> Ilustrasi amplop biru ber-centang + Tombol "Lanjutkan" (PROTOTYPE FEEDBACK FORGOT PAS...)
/// - Step 3: Verifikasi Kode 5 Digit -> 5 Kotak OTP interaktif + Timer hitung mundur 30 detik (PROTOTYPE FORGOT PASS USER 5)
/// - Step 4: Reset Password -> Kata Sandi Baru & Konfirmasi Kata Sandi (PROTOTYPE FORGOT PASS USER 6)
/// - Step 5: Berhasil Reset Password -> Feedback sukses kata sandi berhasil diubah + tombol "Masuk Sekarang"
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    required this.api,
  });

  final TravelApi api;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Step saat ini: 1 sampai 5
  int _currentStep = 1;

  // Controllers Step 1
  final _emailController = TextEditingController();
  final _step1FormKey = GlobalKey<FormState>();

  // Controllers Step 3 (5 Digit OTP)
  final List<TextEditingController> _otpControllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(5, (_) => FocusNode());
  int _countdownSeconds = 30;
  Timer? _countdownTimer;

  // Controllers Step 4 (New Password)
  final _step4FormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;
  String _targetEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdownSeconds = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        if (mounted) setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  // Action Step 1: Kirim Email
  Future<void> _submitStep1() async {
    if (!_step1FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await widget.api.requestPasswordReset(_emailController.text.trim());

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _targetEmail = _emailController.text.trim();
      _currentStep = 2; // Pindah ke Step 2 (Cek Email Anda)
    });
  }

  // Action Step 2: Lanjutkan ke Input OTP
  void _submitStep2() {
    setState(() {
      _currentStep = 3; // Pindah ke Step 3 (5-Digit OTP)
    });
    _startCountdown();
  }

  // Action Step 3: Verifikasi Kode OTP
  Future<void> _submitStep3() async {
    final otpCode = _otpControllers.map((c) => c.text).join();
    if (otpCode.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan masukkan 5 digit kode verifikasi',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await widget.api.verifyPasswordResetOtp(email: _targetEmail, otp: otpCode);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentStep = 4; // Pindah ke Step 4 (Reset Password)
    });
  }

  // Action Step 4: Simpan Kata Sandi Baru
  Future<void> _submitStep4() async {
    if (!_step4FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final otpCode = _otpControllers.map((c) => c.text).join();
    await widget.api.resetPassword(
      email: _targetEmail,
      password: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      otp: otpCode,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentStep = 5; // Pindah ke Step 5 (Berhasil Reset Password)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EEF5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;

            Widget body;
            switch (_currentStep) {
              case 1:
                body = _buildStep1EmailInput();
                break;
              case 2:
                body = _buildStep2CheckEmailFeedback();
                break;
              case 3:
                body = _buildStep3OtpVerification();
                break;
              case 4:
                body = _buildStep4NewPasswordInput();
                break;
              case 5:
              default:
                body = _buildStep5SuccessFeedback();
                break;
            }

            if (!isWide) {
              return body;
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEF5),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: body,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // STEP 1: Input Email (Gambar 1 Figma)
  // ==========================================
  Widget _buildStep1EmailInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const ClampingScrollPhysics(),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: Tombol < Kembali
            Align(
              alignment: Alignment.centerLeft,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF1E293B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kembali',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70),

            // Judul: Reset Password
            Text(
              'Reset Password',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan alamat email yang terdaftar\npada akun anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 36),

            // Field: Email
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6),
              child: Text(
                'Email',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                return null;
              },
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'nama@gmail.com',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF64748B), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF5AAAE7), width: 1.6),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Tombol Kirim Email
            _buildPrimaryPillButton(
              title: 'Kirim Email',
              isLoading: _isLoading,
              onTap: _submitStep1,
            ),
            const SizedBox(height: 24),

            // Footer: Kembali ke halaman Masuk
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      text: 'Kembali ke halaman ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B),
                      ),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3B82F6),
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
    );
  }

  // ==========================================
  // STEP 2: Cek Email Anda (Gambar 2 Figma)
  // ==========================================
  Widget _buildStep2CheckEmailFeedback() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 80),

          // Judul: Cek Email Anda
          Text(
            'Cek Email Anda',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 36),

          // Ilustrasi Amplop Biru dengan Centang Putih
          Center(
            child: SizedBox(
              width: 150,
              height: 120,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Amplop Bergaris Biru Cerah
                  Container(
                    width: 130,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0091FF),
                        width: 5.5,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _EnvelopeFlapPainter(),
                    ),
                  ),

                  // Lingkaran Centang di Sudut Kanan Bawah Amplop
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0091FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5EEF5),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0091FF).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Subjudul: Kode Verifikasi 5 digit telah dikirimkan
          Text(
            'Kode Verifikasi 5 digit telah dikirimkan\nke akun email anda',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          if (_targetEmail.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _targetEmail,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],

          const Spacer(),

          // Tombol Lanjutkan
          _buildPrimaryPillButton(
            title: 'Lanjutkan',
            isLoading: false,
            onTap: _submitStep2,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 3: 5-Digit Verifikasi Kode (Gambar 3 Figma)
  // ==========================================
  Widget _buildStep3OtpVerification() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top: Tombol < Kembali
          Align(
            alignment: Alignment.centerLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () => setState(() => _currentStep = 1),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF1E293B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kembali',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 70),

          // Judul: Reset Password
          Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukan 5 digit kode verifikasi yang sudah dikirimkan\nke email anda',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 36),

          // Label: 5- Digit Verifikasi Kode (Persis sesuai teks Figma)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '5- Digit Verifikasi Kode',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),

          // 5 Kotak Input OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return SizedBox(
                width: 52,
                height: 52,
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF64748B), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF5AAAE7), width: 1.8),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 4) {
                      _otpFocusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Tombol Verifikasi Kode
          _buildPrimaryPillButton(
            title: 'Verifikasi Kode',
            isLoading: _isLoading,
            onTap: _submitStep3,
          ),
          const SizedBox(height: 16),

          // Countdown / Kirim Ulang
          Center(
            child: _countdownSeconds > 0
                ? Text(
                    'Kirim Ulang Kode Verifikasi dalam $_countdownSeconds detik',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  )
                : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _startCountdown();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kode verifikasi baru telah dikirimkan ke email Anda',
                              style: GoogleFonts.poppins(fontSize: 12.5),
                            ),
                            backgroundColor: const Color(0xFF5AAAE7),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'Kirim Ulang Kode Verifikasi',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 4: Reset Kata Sandi Baru (Gambar 4 Figma)
  // ==========================================
  Widget _buildStep4NewPasswordInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const ClampingScrollPhysics(),
      child: Form(
        key: _step4FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 90),

            // Judul: Reset Password
            Text(
              'Reset Password',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kata Sandi Baru anda Harus Berbeda\ndari Kata Sandi anda Sebelumnya',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 36),

            // Field 1: Kata Sandi Baru
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6),
              child: Text(
                'Kata Sandi Baru',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Kata sandi baru wajib diisi';
                if (v.length < 6) return 'Kata sandi minimal 6 karakter';
                return null;
              },
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF475569),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF64748B), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF5AAAE7), width: 1.6),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Field 2: Konfirmasi Kata Sandi
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6),
              child: Text(
                'Konfirmasi Kata Sandi',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                if (v != _newPasswordController.text) return 'Kata sandi tidak cocok';
                return null;
              },
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF475569),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF64748B), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF5AAAE7), width: 1.6),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Reset Password
            _buildPrimaryPillButton(
              title: 'Reset Password',
              isLoading: _isLoading,
              onTap: _submitStep4,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 5: Feedback Sukses (Gambar 5)
  // ==========================================
  Widget _buildStep5SuccessFeedback() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 100),

          // Icon Sukses Centang Biru Besar
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF5AAAE7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5AAAE7).withValues(alpha: 0.38),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Judul
          Text(
            'Kata Sandi Berhasil Diubah!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Kata sandi akun Anda telah berhasil diperbarui.\nSilakan masuk kembali dengan kata sandi baru Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),

          const Spacer(),

          // Tombol Masuk Sekarang
          _buildPrimaryPillButton(
            title: 'Masuk Sekarang',
            isLoading: false,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Reusable Pill Button sesuai Figma
  Widget _buildPrimaryPillButton({
    required String title,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF55A6E3), Color(0xFF75B7E8), Color(0xFF55A6E3)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5AAAE7).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Custom Painter untuk Flap Amplop Biru Cerah (Step 2)
class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0091FF)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(4, 4);
    path.lineTo(size.width * 0.5, size.height * 0.55);
    path.lineTo(size.width - 4, 4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
