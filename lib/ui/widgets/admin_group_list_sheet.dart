import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_tracking_models.dart';

/// Bottom Sheet untuk daftar "Grup Berangkat" dengan ringkasan 3 counter (Gambar 1).
class AdminGroupListSheet extends StatelessWidget {
  const AdminGroupListSheet({
    super.key,
    required this.overview,
    required this.onSelectGroup,
  });

  final AdminMapsOverview overview;
  final ValueChanged<AdminDepartureGroupTrack> onSelectGroup;

  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _safeGreen = Color(0xFF2E7D32);
  static const Color _warnOrange = Color(0xFFE65100);
  static const Color _sosRed = Color(0xFFD32F2F);
  static const Color _sheetBg = Color(0xFFFFF9F0);

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Drag Handle Bar
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
          const SizedBox(height: 16),

          // 2. Header Row: Grup Berangkat & Total Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Grup Berangkat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${overview.totalGroups} grup · ${overview.totalJemaah} jemaah',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Ringkasan 3 Counter Indikator
          Row(
            children: [
              Expanded(
                child: _buildCounterCard(
                  count: overview.safeCount.toString(),
                  label: 'Aman',
                  color: _safeGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCounterCard(
                  count: overview.outOfRadiusCount.toString(),
                  label: 'Di luar radius',
                  color: _warnOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCounterCard(
                  count: overview.sosActiveCount.toString(),
                  label: 'SOS aktif',
                  color: _sosRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Daftar Kartu Grup
          if (overview.groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Tidak ada grup keberangkatan aktif',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: overview.groups.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final group = overview.groups[index];
                  return _buildGroupCard(group);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounterCard({
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(AdminDepartureGroupTrack group) {
    final bool hasSos = group.sosCount > 0;
    final bool hasOutOfRadius = group.outOfRadiusCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onSelectGroup(group),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Icon Rombongan
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasSos
                        ? const Color(0xFFE0F2F1)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.groups_outlined,
                    color: hasSos ? const Color(0xFF00796B) : const Color(0xFF8D6E63),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Info Grup & Paket
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${group.code} · ${group.packageName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${group.muthawwifName} · ${group.city} · ${group.totalJemaah} jemaah',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Badge Status Kanan
                if (hasSos)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _sosRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${group.sosCount} SOS',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (hasOutOfRadius)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0B2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${group.outOfRadiusCount} di luar',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE65100),
                      ),
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

