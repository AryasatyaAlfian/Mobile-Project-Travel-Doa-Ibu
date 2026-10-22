import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/app_colors.dart';
import '../models/models.dart';
import '../services/travel_api.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({
    super.key,
    required this.package,
    required this.api,
  });

  final TravelPackage package;
  final TravelApi api;

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  int _participants = 1;
  DateTime? _preferredDate;
  String _contactPreference = 'whatsapp';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _preferredDate = widget.package.departureDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.tealPrimary,
              onPrimary: AppColors.white,
              surface: AppColors.surfaceWhite,
              onSurface: AppColors.textDark,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surfaceWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _preferredDate = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final request = BookingRequest(
        packageCategoryId: widget.package.category?.id ?? 1,
        packageId: widget.package.id,
        customerName: _nameController.text.trim(),
        customerWhatsapp: _whatsappController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerCity: _cityController.text.trim(),
        participants: _participants,
        preferredDate: _preferredDate,
        specialRequests: _specialRequestsController.text.trim().isEmpty
            ? null
            : _specialRequestsController.text.trim(),
        contactPreference: _contactPreference,
      );

      final message = await widget.api.submitBooking(request);

      if (!mounted) return;
      _showSuccessDialog(message);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.redNegative,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan koneksi. Silakan periksa jaringan Anda.'),
          backgroundColor: AppColors.redNegative,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.tealPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: AppColors.tealButtonGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 36, color: AppColors.white),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pemesanan Berhasil!',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textBody, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Pop dialog
                  Navigator.pop(context); // Pop booking form
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealPrimary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Formulir Reservasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPackageSummaryCard(),
              const SizedBox(height: 24),
              const Text(
                'Data Calon Jamaah / Pemesan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap (sesuai KTP/Paspor)',
                icon: Icons.person_outline,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama lengkap wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _whatsappController,
                label: 'Nomor WhatsApp (contoh: 081234567890)',
                icon: Icons.phone_iphone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nomor WhatsApp wajib diisi';
                  if (!val.startsWith('08') && !val.startsWith('+62') && !val.startsWith('62')) {
                    return 'Format nomor tidak valid (gunakan awalan 08)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _emailController,
                label: 'Alamat Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                  if (!val.contains('@') || !val.contains('.')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _cityController,
                label: 'Kota / Domisili Asal',
                icon: Icons.location_city_outlined,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Kota asal wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              _buildParticipantSelector(),
              const SizedBox(height: 16),
              _buildDateSelector(),
              const SizedBox(height: 20),
              _buildContactPreferenceSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _specialRequestsController,
                label: 'Catatan Khusus (Opsional)',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tealPrimary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealPrimary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tealSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.luggage_outlined, color: AppColors.tealPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.package.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.package.formattedPrice,
                  style: const TextStyle(color: AppColors.tealPrimary, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textBody, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.tealPrimary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tealPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.redNegative),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.redNegative, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildParticipantSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.group_outlined, color: AppColors.tealPrimary, size: 20),
              SizedBox(width: 12),
              Text(
                'Jumlah Peserta',
                style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _participants > 1 ? () => setState(() => _participants--) : null,
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.tealPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$_participants',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _participants++),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.tealPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: AppColors.tealPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rencana Tanggal Keberangkatan', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    _preferredDate != null
                        ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
                        : 'Pilih Tanggal',
                    style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.tealPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildContactPreferenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferensi Dihubungi',
          style: TextStyle(color: AppColors.textBody, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPreferenceChip('WhatsApp', 'whatsapp', Icons.chat_outlined),
            const SizedBox(width: 8),
            _buildPreferenceChip('Email', 'email', Icons.email_outlined),
            const SizedBox(width: 8),
            _buildPreferenceChip('Telepon', 'phone', Icons.phone_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferenceChip(String label, String value, IconData icon) {
    final isSelected = _contactPreference == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _contactPreference = value),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tealPrimary : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.tealDark : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.white : AppColors.textBody,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textBody,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: _isSubmitting ? null : _submitBooking,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: _isSubmitting ? null : AppColors.tealButtonGradient,
            color: _isSubmitting ? AppColors.textMuted : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!_isSubmitting)
                BoxShadow(
                  color: AppColors.tealPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded, color: AppColors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Kirim Permintaan Reservasi',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
