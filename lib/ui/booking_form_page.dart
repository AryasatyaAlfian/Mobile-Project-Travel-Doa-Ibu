import 'dart:async';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../services/ticket_service.dart';
import '../services/travel_api.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({
    super.key,
    required this.package,
    required this.api,
    this.initialSelectedGroup,
    this.initialRoomType,
    this.initialRoomPrice,
  });

  final TravelPackage package;
  final TravelApi api;
  final DepartureGroupItem? initialSelectedGroup;
  final String? initialRoomType;
  final double? initialRoomPrice;

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  int _currentStep = 1; // 1: Data Diri, 2: Detail Pesanan, 3: Pembayaran (Step 4 di UI)

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _passportController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController(text: 'Jakarta');
  DateTime? _birthDate;

  // Step 2 State
  DepartureGroupItem? _selectedGroup;
  DateTime? _preferredDate;
  String _selectedRoom = 'Quad';
  double _roomPrice = 35000000.0;
  int _adultCount = 2;
  int _childCount = 0;

  late final List<Map<String, dynamic>> _roomOptions;

  // Step 3 (Pembayaran) State
  bool _isDpSelected = false; // false = Bayar Lunas, true = Bayar DP
  int _selectedPaymentMethod = 0; // 0: VA, 1: QRIS, 2: Card
  Timer? _countdownTimer;
  int _remainingSeconds = 1800; // 30 Menit
  late final DateTime _expireTime;

  bool _isSubmitting = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _expireTime = DateTime.now().add(const Duration(minutes: 30));

    // Dynamic Room Options sesuai starting_price / pricing paket
    final basePrice = widget.package.startingPrice ?? 35000000.0;
    double quadPrice = basePrice;
    double triplePrice = basePrice >= 15000000 ? basePrice + 2500000 : (basePrice * 1.1).roundToDouble();
    double doublePrice = basePrice >= 15000000 ? basePrice + 5500000 : (basePrice * 1.25).roundToDouble();

    final pricing = widget.package.pricing;
    if (pricing != null) {
      if (pricing['quad'] is num) quadPrice = (pricing['quad'] as num).toDouble();
      if (pricing['triple'] is num) triplePrice = (pricing['triple'] as num).toDouble();
      if (pricing['double'] is num) doublePrice = (pricing['double'] as num).toDouble();
    }

    _roomOptions = [
      {
        'name': 'Quad',
        'label': 'Quad',
        'capacity': '4 org / kamar',
        'price': quadPrice,
        'formatted': 'Rp ${_formatPriceCompact(quadPrice)}',
      },
      {
        'name': 'Triple',
        'label': 'Triple',
        'capacity': '3 org / kamar',
        'price': triplePrice,
        'formatted': 'Rp ${_formatPriceCompact(triplePrice)}',
      },
      {
        'name': 'Double',
        'label': 'Double',
        'capacity': '2 org / kamar',
        'price': doublePrice,
        'formatted': 'Rp ${_formatPriceCompact(doublePrice)}',
      },
    ];

    // Auto-fill dari user login jika tersedia
    final user = TravelApi.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      if (user.phone != null && user.phone!.isNotEmpty) {
        _whatsappController.text = user.phone!;
      }
    }

    // Inisialisasi room & group
    if (widget.initialRoomType != null) {
      _selectedRoom = widget.initialRoomType!;
    }
    if (widget.initialRoomPrice != null) {
      _roomPrice = widget.initialRoomPrice!;
    } else {
      final match = _roomOptions.firstWhere(
        (o) => o['name'] == _selectedRoom,
        orElse: () => _roomOptions.first,
      );
      _roomPrice = (match['price'] as num).toDouble();
    }

    if (widget.initialSelectedGroup != null) {
      _selectedGroup = widget.initialSelectedGroup;
    } else if (widget.package.departureGroups.isNotEmpty) {
      final firstOpen = widget.package.departureGroups.indexWhere((g) => !g.isFull);
      _selectedGroup = firstOpen != -1
          ? widget.package.departureGroups[firstOpen]
          : widget.package.departureGroups.first;
    } else {
      _preferredDate = widget.package.departureDate ?? DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameController.dispose();
    _nikController.dispose();
    _passportController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        _showExpiredDialog();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Waktu Pembayaran Habis', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Batas waktu 30 menit telah berakhir. Silakan lakukan pemesanan ulang.',
            style: TextStyle(fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Dialog
                Navigator.pop(context); // Booking Page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFECC485),
                foregroundColor: const Color(0xFF1F1F1F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Kembali ke Detail'),
            ),
          ],
        );
      },
    );
  }

  int get _totalParticipants => _adultCount + _childCount;
  double get _totalPrice => _roomPrice * _totalParticipants;
  double get _dpPerPerson =>
      (widget.package.startingPrice != null && widget.package.startingPrice! < 20000000)
          ? (widget.package.startingPrice! * 0.3).roundToDouble()
          : 10000000.0;
  double get _payableAmount => _isDpSelected ? (_dpPerPerson * _totalParticipants) : _totalPrice;

  // Navigasi Step
  void _goToStep(int step) {
    setState(() {
      _inlineError = null;
      _currentStep = step;
    });
    if (step == 3 && _countdownTimer == null) {
      _startTimer();
    }
  }

  void _onStep1Next() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _inlineError = 'Nama Lengkap wajib diisi.');
      return;
    }
    if (_nikController.text.trim().length < 16) {
      setState(() => _inlineError = 'NIK harus 16 digit.');
      return;
    }
    if (_whatsappController.text.trim().isEmpty) {
      setState(() => _inlineError = 'Nomor WhatsApp wajib diisi.');
      return;
    }
    // Normalisasi WhatsApp jika diawali 62 atau +62
    var wa = _whatsappController.text.trim();
    if (wa.startsWith('+62')) {
      wa = '08${wa.substring(3)}';
    } else if (wa.startsWith('62')) {
      wa = '08${wa.substring(2)}';
    }
    _whatsappController.text = wa;

    if (!RegExp(r'^08[0-9]{8,11}$').hasMatch(wa)) {
      setState(() => _inlineError = 'Format WhatsApp tidak valid (contoh: 08123456789).');
      return;
    }

    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      setState(() => _inlineError = 'Email tidak valid.');
      return;
    }

    _goToStep(2);
  }

  void _onStep2Next() {
    if (widget.package.departureGroups.isNotEmpty && _selectedGroup == null) {
      setState(() => _inlineError = 'Pilih jadwal keberangkatan.');
      return;
    }
    if (_selectedGroup != null && _selectedGroup!.isFull) {
      setState(() => _inlineError = 'Jadwal rombongan yang dipilih sudah penuh.');
      return;
    }
    if (_selectedGroup != null &&
        _selectedGroup!.remainingQuota != null &&
        _totalParticipants > _selectedGroup!.remainingQuota!) {
      setState(() => _inlineError = 'Sisa kuota hanya ${_selectedGroup!.remainingQuota} peserta.');
      return;
    }
    if (_totalParticipants < 1) {
      setState(() => _inlineError = 'Jumlah jemaah minimal 1 orang.');
      return;
    }

    _goToStep(3);
  }

  Future<void> _processPayment() async {
    setState(() {
      _isSubmitting = true;
      _inlineError = null;
    });

    try {
      final specialNotes = 'Tipe Kamar: $_selectedRoom. NIK: ${_nikController.text.trim()}, '
          'Paspor: ${_passportController.text.trim()}, '
          'Tgl Lahir: ${_birthDate != null ? "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}" : "-"}, '
          'Opsi Bayar: ${_isDpSelected ? "Bayar DP" : "Lunas"}.';

      final request = BookingRequest(
        packageCategoryId: widget.package.category?.id ?? 1,
        packageId: widget.package.id,
        departureGroupId: _selectedGroup?.id,
        customerName: _nameController.text.trim(),
        customerWhatsapp: _whatsappController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerCity: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'Jakarta',
        participants: _totalParticipants,
        preferredDate: _selectedGroup == null ? _preferredDate : null,
        specialRequests: specialNotes,
        contactPreference: 'whatsapp',
      );

      final message = await widget.api.submitBooking(request);

      // Tambahkan tiket ke TicketService persisten
      await TicketService.instance.addBookingTicket(
        packageName: widget.package.name,
        customerName: _nameController.text.trim(),
        imageUrl: widget.package.image,
      );

      if (!mounted) return;
      _countdownTimer?.cancel();
      _showSuccessDialog(message);
    } on ApiException catch (e) {
      if (!mounted) return;
      var err = e.message;
      if (e.errors.isNotEmpty) {
        final firstList = e.errors.values.first;
        if (firstList.isNotEmpty) err = firstList.first;
      }
      setState(() => _inlineError = err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red.shade700),
      );
    } catch (_) {
      if (!mounted) return;
      const err = 'Terjadi kesalahan jaringan saat memproses pesanan.';
      setState(() => _inlineError = err);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(err), backgroundColor: Colors.red),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFECC485),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 36, color: Color(0xFF1F1F1F)),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pemesanan Berhasil!',
                style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF555B60), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Pop dialog
                  Navigator.pop(context); // Pop booking form to detail
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFECC485),
                  foregroundColor: const Color(0xFF1F1F1F),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali ke Paket', style: TextStyle(fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F1F1F)),
          onPressed: () {
            if (_currentStep > 1) {
              _goToStep(_currentStep - 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Selesaikan Pesananmu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildStepperHeader(),
            if (_inlineError != null)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF8B4B4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _inlineError!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentStep),
                  child: _buildStepBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stepper Header (1. Data Diri, 2. Detail Pesanan, 3. Konfirmasi, 4. Pembayaran)
  Widget _buildStepperHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 500,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepCircle(
                stepNumber: 1,
                label: 'Data Diri',
                isCompleted: _currentStep > 1,
                isActive: _currentStep == 1,
              ),
              _buildStepDivider(isCompleted: _currentStep > 1),
              _buildStepCircle(
                stepNumber: 2,
                label: 'Detail Pesanan',
                isCompleted: _currentStep > 2,
                isActive: _currentStep == 2,
              ),
              _buildStepDivider(isCompleted: _currentStep > 2),
              _buildStepCircle(
                stepNumber: 3,
                label: 'Konfirmasi',
                isCompleted: _currentStep == 3,
                isActive: false,
              ),
              _buildStepDivider(isCompleted: _currentStep == 3),
              _buildStepCircle(
                stepNumber: 4,
                label: 'Pembayaran',
                isCompleted: false,
                isActive: _currentStep == 3, // Step 3 logic adalah Layar Pembayaran
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle({
    required int stepNumber,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isCompleted || isActive) ? const Color(0xFFECC485) : Colors.white,
            border: Border.all(
              color: (isCompleted || isActive) ? const Color(0xFFECC485) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Color(0xFF1F1F1F))
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF1F1F1F) : const Color(0xFF94A3B8),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: (isActive || isCompleted) ? FontWeight.bold : FontWeight.w500,
            color: (isActive || isCompleted) ? const Color(0xFF1F1F1F) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 18),
        color: isCompleted ? const Color(0xFFECC485) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildStepBody() {
    if (_currentStep == 1) {
      return _buildStep1DataDiri();
    } else if (_currentStep == 2) {
      return _buildStep2DetailPesanan();
    } else {
      return _buildStep3Pembayaran();
    }
  }

  // ---- STEP 1: DATA DIRI ----
  Widget _buildStep1DataDiri() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _buildInputField(
          label: 'Nama Lengkap (sesuai paspor) *',
          hint: 'nama sesuai KTP',
          icon: Icons.person_outline,
          controller: _nameController,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: 'NIK *',
          hint: 'masukkan 16 digit NIK',
          icon: Icons.badge_outlined,
          controller: _nikController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        // Tanggal Lahir Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanggal Lahir *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate ?? DateTime(1995, 1, 1),
                  firstDate: DateTime(1920),
                  lastDate: now,
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFFECC485),
                          onPrimary: Color(0xFF1F1F1F),
                          surface: Colors.white,
                          onSurface: Color(0xFF1F1F1F),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _birthDate = picked);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF72787D)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _birthDate != null
                            ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                            : 'DD/MM/YYYY',
                        style: TextStyle(
                          fontSize: 14,
                          color: _birthDate != null ? const Color(0xFF1F1F1F) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF72787D)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: 'Nomor Paspor *',
          hint: 'Contoh: C1234567',
          icon: Icons.contact_mail_outlined,
          controller: _passportController,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: 'Nomor WhatsApp *',
          hint: '+62 8XXX XXXX XXX',
          icon: Icons.phone_outlined,
          controller: _whatsappController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: 'Email *',
          hint: 'nama@gmail.com',
          icon: Icons.mail_outline,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: 'Kota Domisili *',
          hint: 'Jakarta',
          icon: Icons.location_city_outlined,
          controller: _cityController,
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _onStep1Next,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFECC485),
            foregroundColor: const Color(0xFF1F1F1F),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          child: const Text(
            'Lanjut ke Detail Pesanan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  // ---- STEP 2: DETAIL PESANAN ----
  Widget _buildStep2DetailPesanan() {
    final subtotal = _roomPrice * _totalParticipants;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Package Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.package.image != null && widget.package.image!.isNotEmpty
                    ? Image.network(
                        widget.package.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFEFE8DE),
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        'assets/images/mecca.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.package.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.package.duration ?? "15 Hari"} · ${widget.package.airline ?? "Saudia Airlines"}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF72787D)),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _goToStep(1),
                child: const Text(
                  'Ubah',
                  style: TextStyle(
                    color: Color(0xFFB57F26),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Jadwal Keberangkatan Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jadwal Keberangkatan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Lihat Kalender',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFB57F26)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildStep2ScheduleOptions(),
        const SizedBox(height: 20),

        // Tipe Kamar
        const Text(
          'Tipe Kamar',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
        ),
        const SizedBox(height: 10),
        Row(
          children: _roomOptions.map((opt) {
            final isSelected = _selectedRoom == opt['name'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRoom = opt['name'] as String;
                      _roomPrice = (opt['price'] as num).toDouble();
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF7EB) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE8B972) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          opt['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF1F1F1F) : const Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opt['formatted'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB57F26),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          opt['capacity'] as String,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF72787D)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Jumlah Jemaah
        const Text(
          'Jumlah Jemaah',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Dewasa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dewasa',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                      ),
                      Text(
                        'Usia 12 tahun ke atas',
                        style: TextStyle(fontSize: 11, color: Color(0xFF72787D)),
                      ),
                    ],
                  ),
                  _buildCounter(
                    value: _adultCount,
                    minValue: 1,
                    onChanged: (val) => setState(() => _adultCount = val),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Color(0xFFF1F5F9), height: 1),
              ),
              // Anak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anak',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                      ),
                      Text(
                        'Usia 2 – 11 tahun',
                        style: TextStyle(fontSize: 11, color: Color(0xFF72787D)),
                      ),
                    ],
                  ),
                  _buildCounter(
                    value: _childCount,
                    minValue: 0,
                    onChanged: (val) => setState(() => _childCount = val),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Rincian Harga Card
        const Text(
          'Rincian Harga',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paket $_selectedRoom × $_totalParticipants jemaah',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF555B60)),
                  ),
                  Text(
                    'Rp ${_formatRupiah(subtotal)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F1F1F)),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Color(0xFFF1F5F9), height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                  ),
                  Text(
                    'Rp ${_formatRupiah(subtotal)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F1F1F)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _onStep2Next,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFECC485),
            foregroundColor: const Color(0xFF1F1F1F),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          child: const Text(
            'Lanjut ke Konfirmasi Pesanan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2ScheduleOptions() {
    final groups = widget.package.departureGroups;
    if (groups.isNotEmpty) {
      return Row(
        children: groups.take(3).map((grp) {
          final isSelected = _selectedGroup?.id == grp.id;
          final isFull = grp.isFull;

          final dateStr = grp.departureDate != null
              ? '${grp.departureDate!.day} ${_monthName(grp.departureDate!.month)} ${grp.departureDate!.year}'
              : grp.name;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: isFull ? null : () => setState(() => _selectedGroup = grp),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isFull
                        ? const Color(0xFFF1F1F1)
                        : (isSelected ? const Color(0xFFFFF7EB) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFull
                          ? const Color(0xFFE0E0E0)
                          : (isSelected ? const Color(0xFFE8B972) : const Color(0xFFE2E8F0)),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFull ? const Color(0xFFA0A6AC) : const Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFull ? 'Penuh' : 'Sisa ${grp.remainingQuota ?? 10} kursi',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isFull ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Jika tanpa grup, sediakan date picker fleksibel
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _preferredDate ?? now.add(const Duration(days: 30)),
          firstDate: now.add(const Duration(days: 1)),
          lastDate: now.add(const Duration(days: 365 * 2)),
        );
        if (picked != null) {
          setState(() => _preferredDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF72787D)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rencana tanggal (dikonfirmasi admin)', style: TextStyle(fontSize: 11, color: Color(0xFF72787D))),
                  Text(
                    _preferredDate != null
                        ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
                        : 'Pilih Tanggal',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF72787D)),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter({
    required int value,
    required int minValue,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: value > minValue ? () => onChanged(value - 1) : null,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value > minValue ? const Color(0xFFECC485) : const Color(0xFFF1F5F9),
            ),
            child: Icon(Icons.remove, size: 16, color: value > minValue ? const Color(0xFF1F1F1F) : const Color(0xFF94A3B8)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '$value',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(value + 1),
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFECC485),
            ),
            child: const Icon(Icons.add, size: 16, color: Color(0xFF1F1F1F)),
          ),
        ),
      ],
    );
  }

  // ---- STEP 3 (PEMBAYARAN - STEP 4 DI DESAIN FIGMA) ----
  Widget _buildStep3Pembayaran() {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = _remainingSeconds / 1800.0;
    final expireHour = _expireTime.hour.toString().padLeft(2, '0');
    final expireMin = _expireTime.minute.toString().padLeft(2, '0');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Circular Countdown Timer
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFECC485)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sisa Waktu',
                    style: TextStyle(fontSize: 11, color: Color(0xFF72787D)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bayar sebelum $expireHour.$expireMin WIB',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF72787D)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tagihan Anda Card with Segmented Switch
        const Text(
          'Tagihan Anda',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFECC485),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rp ${_formatRupiah(_payableAmount)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 14),
              // Segmented Switcher DP vs Lunas
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDpSelected = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isDpSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Bayar DP · Rp ${_formatRupiah(_dpPerPerson * _totalParticipants)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _isDpSelected ? const Color(0xFF1F1F1F) : const Color(0xFF4A3B22),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDpSelected = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isDpSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Bayar Lunas',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: !_isDpSelected ? const Color(0xFF1F1F1F) : const Color(0xFF4A3B22),
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
        ),
        const SizedBox(height: 20),

        // Metode Pembayaran Options
        const Text(
          'Metode Pembayaran',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
        ),
        const SizedBox(height: 10),
        _buildPaymentMethodOption(
          index: 0,
          title: 'Virtual Account',
          subtitle: 'BSI, BCA, Mandiri, BRI',
          icon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 10),
        _buildPaymentMethodOption(
          index: 1,
          title: 'QRIS',
          subtitle: 'GoPay, OVO, DANA, m-banking',
          icon: Icons.qr_code_2_rounded,
        ),
        const SizedBox(height: 10),
        _buildPaymentMethodOption(
          index: 2,
          title: 'Kartu Kredit / Debit',
          subtitle: 'Visa, Mastercard',
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 28),

        // Bottom Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Batalkan Pesanan?'),
                      content: const Text('Data pemesanan yang telah diisi tidak akan disimpan.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Lanjut Pesan'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Dialog
                            Navigator.pop(context); // Form
                          },
                          child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1F1F1F),
                  side: const BorderSide(color: Color(0xFFECC485)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Batalkan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFECC485),
                  foregroundColor: const Color(0xFF1F1F1F),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1F1F1F)),
                    )
                  : const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7EB) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFE8B972) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: const Color(0xFFB57F26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF72787D)),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFB57F26) : const Color(0xFFA0A6AC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1F1F1F)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF72787D), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE8B972), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPriceCompact(double amount) {
    if (amount >= 1000000) {
      final jt = amount / 1000000;
      if (jt == jt.roundToDouble()) {
        return '${jt.toInt()} jt';
      } else {
        return '${jt.toStringAsFixed(1).replaceAll('.', ',')} jt';
      }
    }
    return _formatRupiah(amount);
  }

  String _formatRupiah(double amount) {
    final intVal = amount.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  String _formatPriceCompact(double amount) {
    if (amount >= 1000000) {
      final jt = amount / 1000000;
      if (jt == jt.roundToDouble()) {
        return '${jt.toInt()} jt';
      } else {
        return '${jt.toStringAsFixed(1).replaceAll('.', ',')} jt';
      }
    }
    return _formatRupiah(amount);
  }

  String _formatRupiah(double amount) {
    final intVal = amount.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
