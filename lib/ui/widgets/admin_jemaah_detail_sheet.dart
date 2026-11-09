import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_tracking_models.dart';

/// Bottom Sheet untuk detail informasi dan lacak satu Jemaah (Gambar 4).
class AdminJemaahDetailSheet extends StatelessWidget {
  const AdminJemaahDetailSheet({
    super.key,
    required this.member,
    required this.group,
    required this.onClose,
    required this.onCallJemaah,
    required this.onCallMuthawwif,
    this.isMuthawwif = false,
    this.onDirections,
  });

  final AdminTrackingMember member;
  final AdminDepartureGroupTrack group;
  final VoidCallback onClose;
  final VoidCallback onCallJemaah;
  final VoidCallback onCallMuthawwif;
  final bool isMuthawwif;
  final VoidCallback? onDirections;

  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _gold = Color(0xFFECC485);
  static const Color _sheetBg = Color(0xFFFFF9F0);

  @override
  Widget build(BuildContext context) {
    final double distMeters = member.distanceToMuthawwifMeters ?? 1200.0;
    final String straightDistStr = GeodesicHelper.formatDistance(distMeters);
    final int walkMin = GeodesicHelper.estimateWalkingMinutes(distMeters);
    final double routeKm = (distMeters * 1.25) / 1000.0;
    final String routeDistStr = '${routeKm.toStringAsFixed(1).replaceAll('.', ',')} km';

    // Arah kompas dari koordinat jemaah ke muthawwif
    String directionStr = 'Timur Laut';
    if (member.latitude != null &&
        member.longitude != null &&
        group.muthawwifLat != null &&
        group.muthawwifLon != null) {
      final bearing = GeodesicHelper.calculateBearing(
        member.latitude!,
        member.longitude!,
        group.muthawwifLat!,
        group.muthawwifLon!,
      );
      directionStr = GeodesicHelper.getBearingDirection(bearing);
    }

    final jemaahFirst = member.name.trim().split(' ').first;
    final muthawwifFirst = group.muthawwifName.replaceAll('Ust.', '').trim().split(' ').first;

    return Container(
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, isMuthawwif ? 85 : 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Header: Foto/Avatar, Nama Jemaah, Badge & Close Button
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold, width: 2.5),
                  color: const Color(0xFFFFF3E0),
                ),
                child: Center(
                  child: Text(
                    member.initials,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8D6E63),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECB3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Jemaah',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8D6E63),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rombongan ${group.code}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Tutup',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.close_rounded, size: 18, color: _ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Baris Lokasi Landmark & Status Live
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: _ink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.locationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          '${group.city} · 1 mnt lalu',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Live',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Kartu Metrik Jarak & Kompas (3 Kolom)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Diagram Garis Jarak Lurus Jemaah <-> Muthawwif
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFA000),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Jemaah\n$jemaahFirst',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          straightDistStr,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        Text(
                          isMuthawwif ? 'Jarak lurus ke Anda' : 'Jarak lurus ke mutawwif',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          isMuthawwif ? 'Mutawwif\nAnda' : 'Mutawwif\n$muthawwifFirst',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00897B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 14),

                // 3 Kolom Metrik
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCol(
                        value: '$walkMin mnt',
                        label: 'Jalan kaki',
                      ),
                    ),
                    Container(width: 1, height: 32, color: Colors.grey.shade200),
                    Expanded(
                      child: _buildMetricCol(
                        value: routeDistStr,
                        label: 'Lewat rute',
                      ),
                    ),
                    Container(width: 1, height: 32, color: Colors.grey.shade200),
                    Expanded(
                      child: _buildMetricCol(
                        value: directionStr,
                        label: isMuthawwif ? 'Arah jemaah' : 'Arah mutawwif',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. Dua Tombol Aksi Hitam
          Row(
            children: [
              Expanded(
                child: _buildDarkActionButton(
                  icon: Icons.phone_rounded,
                  title: isMuthawwif ? 'Hubungi' : 'Hubungi Jemaah',
                  subtitle: 'Telepon · Chat',
                  onTap: onCallJemaah,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: isMuthawwif
                    ? _buildDarkActionButton(
                        icon: Icons.navigation_rounded,
                        title: 'Petunjuk Arah',
                        subtitle: '$routeDistStr · $walkMin mnt',
                        onTap: onDirections ?? onCallMuthawwif,
                      )
                    : _buildDarkActionButton(
                        icon: Icons.shield_outlined,
                        title: 'Hubungi Mutawwif',
                        subtitle: group.muthawwifName,
                        onTap: onCallMuthawwif,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildDarkActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF191614),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          color: Colors.grey.shade400,
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
    );
  }
}

