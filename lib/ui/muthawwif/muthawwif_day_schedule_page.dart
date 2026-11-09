import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/muthawwif_models.dart';
import '../../services/travel_api.dart';

/// Halaman Detail Jadwal Harian & Checklist Kegiatan (Gambar 2, Screen 2).
/// Mengizinkan muthawwif menandai setiap kegiatan (checklist interaktif),
/// melihat progres kegiatan hari tersebut secara real-time, dan menyimpannya.
class MuthawwifDaySchedulePage extends StatefulWidget {
  const MuthawwifDaySchedulePage({
    super.key,
    required this.api,
    required this.day,
    required this.onScheduleUpdated,
  });

  final TravelApi api;
  final ItineraryDayItem day;
  final VoidCallback onScheduleUpdated;

  @override
  State<MuthawwifDaySchedulePage> createState() => _MuthawwifDaySchedulePageState();
}

class _MuthawwifDaySchedulePageState extends State<MuthawwifDaySchedulePage> {
  static const Color _bg = Color(0xFFFFF8EC);
  static const Color _gold = Color(0xFFECC485);
  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _green = Color(0xFF22C55E);

  late List<ItineraryChecklistItem> _activities;

  @override
  void initState() {
    super.initState();
    _activities = widget.day.activities;
  }

  void _toggleActivity(int index) {
    setState(() {
      _activities[index].isCompleted = !_activities[index].isCompleted;
    });
    widget.onScheduleUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + 115.0;
    final completedCount = widget.day.completedCount;
    final totalCount = widget.day.totalCount;
    final progress = widget.day.progress;
    final percentage = (progress * 100).toInt();

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
                            'Detail Jadwal (Hari ${widget.day.dayNumber})',
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
                const SizedBox(height: 12),

                // Card Utama Jadwal
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Header Hari & Judul Kegiatan Utama
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hari ${widget.day.dayNumber} - ${widget.day.dayName}, ${widget.day.dateLabel}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: _muted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.day.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1E7D5)),
                              const SizedBox(height: 14),

                              // Daftar Checklist Kegiatan Hari Ini
                              ...List.generate(_activities.length, (idx) {
                                final item = _activities[idx];
                                return InkWell(
                                  onTap: () => _toggleActivity(idx),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    child: Row(
                                      children: [
                                        // Checkbox Status
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: item.isCompleted ? _green : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: item.isCompleted ? _green : const Color(0xFFCBD5E1),
                                              width: 1.8,
                                            ),
                                          ),
                                          child: item.isCompleted
                                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 14),

                                        // Waktu Kegiatan
                                        Text(
                                          item.time,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _ink,
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Deskripsi Kegiatan
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: item.isCompleted ? const Color(0xFF64748B) : _ink,
                                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                              fontWeight: item.isCompleted ? FontWeight.w400 : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Card Progress Hari Ini
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Progress Hari Ini',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _ink,
                                        ),
                                      ),
                                      Text(
                                        '$completedCount dari $totalCount kegiatan selesai',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: _muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$percentage%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Progress Bar Hijau
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(_green),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}

