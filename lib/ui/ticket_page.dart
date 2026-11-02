import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ticket_order.dart';
import '../services/ticket_service.dart';
import 'widgets/skeleton_view.dart';

/// Elysian Horizon — Halaman Tiket Saya (Tiket, Riwayat Order, Detail Order)
/// Mengimplementasikan 3 sub-tab dengan transisi animasi halus (smooth slide & fade)
/// dan 100% presisi visual sesuai desain Figma.
class TicketPage extends StatefulWidget {
  const TicketPage({
    super.key,
    this.initialTab = 0,
    this.initialTicketId,
    this.isLoading = false,
  });

  final int initialTab;
  final String? initialTicketId;
  final bool isLoading;

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late final PageController _pageController;
  int _currentTab = 0;
  bool _isLoading = false;

  late List<TicketOrder> _activeTickets;
  late List<TicketOrder> _completedTickets;
  TicketOrder? _selectedTicket;

  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _bg = Color(0xFFFFF8EC);

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
    _currentTab = widget.initialTab.clamp(0, 2);
    _pageController = PageController(initialPage: _currentTab);
    _loadTickets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache background dan asset lokal ke memory cache agar langsung muncul instan
    precacheImage(const AssetImage('assets/images/Background.webp'), context);
    precacheImage(const AssetImage('assets/images/Background.png'), context);
    precacheImage(const AssetImage('assets/images/mecca.jpg'), context);
    precacheImage(const AssetImage('assets/images/fuji.jpg'), context);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _loadTickets();
      _isLoading = false;
    });
  }

  void _loadTickets() {
    _activeTickets = TicketService.instance.getActiveTickets();
    _completedTickets = TicketService.instance.getCompletedTickets();

    if (widget.initialTicketId != null) {
      _selectedTicket = TicketService.instance.getTicketById(widget.initialTicketId!);
    }
    _selectedTicket ??= _activeTickets.isNotEmpty
        ? _activeTickets.first
        : (_completedTickets.isNotEmpty ? _completedTickets.first : null);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_currentTab == index) return;
    setState(() => _currentTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openDetailOrder(TicketOrder ticket) {
    setState(() {
      _selectedTicket = ticket;
      _currentTab = 2;
    });
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _handleDeleteTicket(TicketOrder ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Batalkan Pesanan?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan/menghapus pesanan tiket ${ticket.packageName} (${ticket.id})?\n\nSesuai sistem backend, kuota kursi akan dilepaskan kembali.',
          style: GoogleFonts.poppins(fontSize: 13, height: 1.45, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Kembali',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Ya, Batalkan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TicketService.instance.cancelTicket(ticket.id);
      if (!mounted) return;

      setState(() {
        _loadTickets();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pesanan ${ticket.id} berhasil dibatalkan.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xFFC0392B),
        ),
      );

      _switchTab(0);
    }
  }

  void _showEticketDialog(TicketOrder ticket) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'E-Tiket Digital',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.route, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(ticket.packageName, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                    const Divider(height: 20),
                    Text('Penumpang: ${ticket.passengerName}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Maskapai: ${ticket.airline} (${ticket.flightNumber})', style: GoogleFonts.poppins(fontSize: 12)),
                    Text('Jadwal: ${ticket.departureSchedule}', style: GoogleFonts.poppins(fontSize: 12)),
                    Text('Order ID: ${ticket.id}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 180,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('||||| |||| || |||||||', style: GoogleFonts.poppins(fontSize: 18, letterSpacing: 4, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text('Tunjukkan barcode ini kepada petugas saat check-in.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentProofDialog(TicketOrder ticket) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bukti Pembayaran',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 48),
                    const SizedBox(height: 8),
                    Text(
                      ticket.isPendingPayment ? 'Menunggu Pembayaran' : 'Transaksi Terverifikasi',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const Divider(height: 24),
                    _buildProofRow('Order ID', ticket.id),
                    _buildProofRow('Paket', ticket.packageName),
                    _buildProofRow('Nama', ticket.passengerName),
                    _buildProofRow('Status', ticket.statusLabel),
                    _buildProofRow('Metode', 'Transfer Bank / Midtrans'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProofRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // 1. Header Latar Belakang Ka'bah & Lentera Emas (WebP Cepat ~19KB)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 280,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/Background.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/Background.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF2B2117), Color(0xFF19120B)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          _bg.withValues(alpha: 0.7),
                          _bg,
                        ],
                        stops: const [0.0, 0.65, 0.9, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Konten Utama
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Judul "Tiket Saya"
                  Text(
                    'Tiket Saya',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _gold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3-Tab Segmented Capsule (Glassmorphism)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildSegmentButton(0, 'Tiket Saya', Icons.confirmation_num_outlined),
                              _buildSegmentButton(1, 'Riwayat Order', Icons.format_list_bulleted_rounded),
                              _buildSegmentButton(2, 'Detail Order', Icons.description_outlined),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. PageView untuk 3 Tab dengan transisi animasi halus
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const ClampingScrollPhysics(),
                      onPageChanged: (idx) {
                        setState(() => _currentTab = idx);
                      },
                      children: [
                        _buildTiketSayaTab(),
                        _buildRiwayatOrderTab(),
                        _buildDetailOrderTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol Kapsul Segmented Navigasi
  Widget _buildSegmentButton(int index, String label, IconData icon) {
    final isSelected = _currentTab == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? _gold : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? _ink : Colors.white.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? _ink : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SUB-TAB 1: TIKET SAYA (Active Tickets)
  // ===========================================================================
  Widget _buildTiketSayaTab() {
    if (_isLoading) {
      return _buildSkeletonTicketList();
    }

    if (_activeTickets.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: _gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 380,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.airplane_ticket_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Belum Ada Tiket Aktif',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tiket perjalanan Anda yang akan datang akan tampil di sini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: _gold,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        itemCount: _activeTickets.length,
        itemBuilder: (context, index) {
          final ticket = _activeTickets[index];
          return _buildTicketCard(ticket, isHistory: false);
        },
      ),
    );
  }

  // ===========================================================================
  // SUB-TAB 2: RIWAYAT ORDER (Completed Tickets)
  // ===========================================================================
  Widget _buildRiwayatOrderTab() {
    if (_isLoading) {
      return _buildSkeletonHistoryList();
    }

    if (_completedTickets.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: _gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 380,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_rounded, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Belum Ada Riwayat Order',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pesanan perjalanan yang telah selesai akan diarsipkan di sini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: _gold,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        itemCount: _completedTickets.length,
        itemBuilder: (context, index) {
          final ticket = _completedTickets[index];
          return _buildTicketCard(ticket, isHistory: true);
        },
      ),
    );
  }

  // ===========================================================================
  // SUB-TAB 3: DETAIL ORDER (Full Order Inspection)
  // ===========================================================================
  Widget _buildDetailOrderTab() {
    if (_isLoading) {
      return _buildSkeletonDetailView();
    }

    final ticket = _selectedTicket ?? (_activeTickets.isNotEmpty ? _activeTickets.first : null);

    if (ticket == null) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: _gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 380,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Text(
              'Pilih tiket dari tab Tiket Saya atau Riwayat Order.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: _gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Kartu Ringkasan Tiket (Dengan Tombol Hapus)
            _buildTicketCard(ticket, isHistory: false, isDetailMode: true),
            const SizedBox(height: 16),

          // 2. Kartu Detail Keberangkatan (Flight Timeline)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Keberangkatan',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 16),

                // Flight Timeline Vertikal
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: Ikon & Garis Vertikal Emas
                    Column(
                      children: [
                        const Icon(Icons.flight_takeoff_rounded, color: _gold, size: 24),
                        Container(
                          width: 2,
                          height: 70,
                          color: _gold,
                        ),
                        const Icon(Icons.flight_land_rounded, color: _gold, size: 24),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Kolom Kanan: Rincian Jadwal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titik Berangkat
                          Text(
                            ticket.route.split(' - ').first,
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            ticket.departureSchedule,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          Text(
                            ticket.departureAirport,
                            style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 14),

                          // Kartu Info Maskapai di Tengah
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ticket.airline,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFD71921),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      ticket.flightNumber,
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    ticket.flightDuration,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Titik Tiba
                          Text(
                            ticket.route.split(' - ').last,
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            ticket.arrivalSchedule,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          Text(
                            ticket.arrivalAirport,
                            style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Kartu Informasi Penumpang
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Penumpang',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 12),

                // Nama Penumpang & Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Text(
                        ticket.passengerName,
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ticket.passengerType,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: _ink),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Fasilitas Kabin, Bagasi, Kursi
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildAmenityItem(Icons.work_outline_rounded, ticket.cabinBaggage),
                    _buildAmenityItem(Icons.luggage_outlined, ticket.checkedBaggage),
                    _buildAmenityItem(Icons.airline_seat_recline_normal_rounded, ticket.seatInfo),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAmenityItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: _gold),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  // ===========================================================================
  // KARTU TIKET (Reusable Card untuk Tab 0, 1, dan 2)
  // ===========================================================================
  Widget _buildTicketCard(TicketOrder ticket, {required bool isHistory, bool isDetailMode = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isHistory ? () => _openDetailOrder(ticket) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Baris Atas: Thumbnail & Detail Pesanan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 68,
                        height: 68,
                        child: _buildTicketThumbnail(ticket.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge Status
                          _buildStatusBadge(ticket),
                          const SizedBox(height: 5),
                          Text(
                            ticket.route,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          Text(
                            ticket.packageName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Order ID: ${ticket.id}',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isHistory)
                      Padding(
                        padding: const EdgeInsets.only(top: 24, left: 4),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: _ink.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Baris Tengah: Container Rincian Penerbangan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Kiri: Logo Emirates & No Penerbangan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.airline,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD71921),
                            ),
                          ),
                          Text(
                            ticket.flightNumber,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Kanan: Tanggal & Rute Bandara
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              ticket.departureSchedule,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              ticket.flightRoute,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Baris Bawah: 3 Tombol Aksi Kapsul (Hanya untuk Tiket Aktif & Detail)
                if (!isHistory) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'E-tiket',
                          icon: Icons.confirmation_num_outlined,
                          onTap: () => _showEticketDialog(ticket),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          label: 'Bukti Pembayaran',
                          icon: Icons.credit_card_outlined,
                          onTap: () => _showPaymentProofDialog(ticket),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: isDetailMode
                            ? _buildActionButton(
                                label: 'Hapus',
                                icon: Icons.delete_outline_rounded,
                                onTap: () => _handleDeleteTicket(ticket),
                              )
                            : _buildActionButton(
                                label: 'Lihat Detail',
                                icon: Icons.info_outline_rounded,
                                onTap: () => _openDetailOrder(ticket),
                              ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Badge status sesuai status backend ('new', 'booked', 'completed')
  Widget _buildStatusBadge(TicketOrder ticket) {
    if (ticket.isPendingPayment) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF856404)),
            const SizedBox(width: 4),
            Text(
              'Menunggu Pembayaran',
              style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600, color: const Color(0xFF856404)),
            ),
          ],
        ),
      );
    }

    if (ticket.isConfirmed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFD4EDDA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF155724)),
            const SizedBox(width: 4),
            Text(
              'Dikonfirmasi',
              style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600, color: const Color(0xFF155724)),
            ),
          ],
        ),
      );
    }

    // Default / History: Selesai
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E3E5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Selesai',
        style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600, color: const Color(0xFF383D41)),
      ),
    );
  }

  /// Tombol aksi rounded bergaris halus
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: const Color(0xFFC79848)),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 8.5, fontWeight: FontWeight.w600, color: _ink),
            ),
          ],
        ),
      ),
    );
  }

  /// Thumbnail tiket teroptimasi (cacheWidth & cacheHeight 140px untuk render cepat instan)
  Widget _buildTicketThumbnail(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        cacheWidth: 140,
        cacheHeight: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildThumbnailFallback(),
      );
    }
    return Image.network(
      imageUrl,
      cacheWidth: 140,
      cacheHeight: 140,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildThumbnailFallback(),
    );
  }

  Widget _buildThumbnailFallback() {
    return Container(
      color: _gold.withValues(alpha: 0.5),
      child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 32),
    );
  }

  // ===========================================================================
  // SKELETON LOADERS
  // ===========================================================================
  Widget _buildSkeletonTicketList() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: const [
        _SkeletonTicketCard(isHistory: false),
        _SkeletonTicketCard(isHistory: false),
      ],
    );
  }

  Widget _buildSkeletonHistoryList() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: const [
        _SkeletonTicketCard(isHistory: true),
        _SkeletonTicketCard(isHistory: true),
        _SkeletonTicketCard(isHistory: true),
      ],
    );
  }

  Widget _buildSkeletonDetailView() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SkeletonTicketCard(isHistory: false, isDetailMode: true),
          const SizedBox(height: 16),
          // Skeleton Detail Keberangkatan
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 170, height: 18, borderRadius: 4),
                SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 32, height: 32, borderRadius: 8),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 120, height: 16, borderRadius: 4),
                          SizedBox(height: 6),
                          SkeletonBox(width: 180, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SkeletonBox(height: 52, borderRadius: 14),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 32, height: 32, borderRadius: 8),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 120, height: 16, borderRadius: 4),
                          SizedBox(height: 6),
                          SkeletonBox(width: 180, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Skeleton Info Penumpang
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 170, height: 18, borderRadius: 4),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 140, height: 18, borderRadius: 4),
                    SkeletonBox(width: 70, height: 22, borderRadius: 11),
                  ],
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    SkeletonBox(width: 90, height: 14, borderRadius: 4),
                    SizedBox(width: 16),
                    SkeletonBox(width: 90, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu placeholder skeleton shimmer untuk tiket dan riwayat
class _SkeletonTicketCard extends StatelessWidget {
  const _SkeletonTicketCard({
    required this.isHistory,
    this.isDetailMode = false,
  });

  final bool isHistory;
  final bool isDetailMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 64, height: 64, borderRadius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: isHistory ? 65 : 140,
                      height: 20,
                      borderRadius: isHistory ? 6 : 10,
                    ),
                    const SizedBox(height: 8),
                    const SkeletonBox(width: 150, height: 16, borderRadius: 4),
                    const SizedBox(height: 6),
                    const SkeletonBox(width: 110, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              if (isHistory)
                const SkeletonBox(width: 20, height: 20, borderRadius: 10),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: const [
                SkeletonBox(width: 30, height: 30, borderRadius: 8),
                SizedBox(width: 10),
                SkeletonBox(width: 60, height: 14, borderRadius: 4),
                Spacer(),
                SkeletonBox(width: 130, height: 14, borderRadius: 4),
              ],
            ),
          ),
          if (!isHistory) ...[
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(child: SkeletonBox(height: 38, borderRadius: 12)),
                SizedBox(width: 8),
                Expanded(child: SkeletonBox(height: 38, borderRadius: 12)),
                SizedBox(width: 8),
                Expanded(child: SkeletonBox(height: 38, borderRadius: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
