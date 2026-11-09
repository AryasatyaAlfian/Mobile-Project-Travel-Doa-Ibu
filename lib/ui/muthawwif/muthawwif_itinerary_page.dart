import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/smooth_page_route.dart';
import '../../models/muthawwif_models.dart';
import '../../services/travel_api.dart';
import 'muthawwif_day_schedule_page.dart';

/// Halaman Jadwal Kegiatan / Manasik Muthawwif (Gambar 2, Screen 1 & 3).
/// Menampilkan ringkasan hari perjalanan ibadah, status penyelesaian,
/// dan dialog ringkasan pencapaian kegiatan (Gambar 2, Screen 4).
class MuthawwifItineraryPage extends StatefulWidget {
  const MuthawwifItineraryPage({
    super.key,
    required this.api,
    required this.group,
  });

  final TravelApi api;
  final MuthawwifGroupInfo group;

  @override
  State<MuthawwifItineraryPage> createState() => _MuthawwifItineraryPageState();
}

class _MuthawwifItineraryPageState extends State<MuthawwifItineraryPage> {
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _green = Color(0xFF22C55E);

  late List<ItineraryDayItem> _days;

  @override
  void initState() {
    super.initState();
    _days = ItineraryDayItem.defaultPreset();
  }

  int get _completedDaysCount => _days.where((d) => d.isAllCompleted).length;
  double get _overallProgress => _days.isNotEmpty ? (_completedDaysCount / _days.length) : 0.0;

  void _showProgressDialog() {
    final percentage = (_overallProgress * 100).toInt();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Lingkaran Hijau Centang Berkilau (Gambar 2, Screen 4)
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _green.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: _green,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Judul
                Text(
                  'Progres Kegiatan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  'Rombongan Umrah',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 18),

                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _overallProgress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(_green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$percentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Catatan Penyelesaian
                Text(
                  '$_completedDaysCount dari ${_days.length} hari kegiatan telah selesai.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Lihat Jadwal
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8BD7C),
                      foregroundColor: _ink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Lihat Jadwal',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
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
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + 115.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // 1. Header Ka'bah Malam
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
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

          // 2. Konten
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar Navigasi (Tinggi 44px, Ikon Back Putih & Judul Emas)
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
                            'Jadwal Kegiatan',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _gold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.analytics_outlined, color: Colors.white, size: 22),
                          onPressed: _showProgressDialog,
                          tooltip: 'Progres Kegiatan',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card Rangkuman Jadwal Perjalanan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: _showProgressDialog,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF6EE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Color(0xFFC89745),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jadwal Perjalanan Umrah',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.group.departureDate} - ${widget.group.returnDate}\n(${widget.group.durationDays} Hari)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: _muted,
                                    height: 1.3,
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
                const SizedBox(height: 14),

                // Daftar Hari Jadwal Scrollable
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 40),
                    itemCount: _days.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      return _buildDayCard(context, day);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, ItineraryDayItem day) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SmoothPageRoute(
              page: MuthawwifDaySchedulePage(
                api: widget.api,
                day: day,
                onScheduleUpdated: () => setState(() {}),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: day.isAllCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFF1E7D5),
              width: 0.8,
            ),
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
              // Icon Bendera / Hari
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF6EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: Color(0xFFC89745),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),

              // Info Hari & Judul Kegiatan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari ${day.dayNumber} - ${day.dayName}, ${day.dateLabel}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.title,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing Status: Green Checkmark / In-progress Badge / Chevron
              if (day.isAllCompleted) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ] else if (day.completedCount > 0) ...[
                Text(
                  '(${day.completedCount}/${day.totalCount})',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: _ink, size: 20),
              ] else ...[
                const Icon(Icons.chevron_right_rounded, color: _ink, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

