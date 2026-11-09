import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_tracking_models.dart';

/// Bottom Sheet saat menekan titik Muthawwif di peta (Gambar 3).
/// Menampilkan profil pembimbing dan daftar anggota jemaah dalam rombongannya.
class AdminMuthawwifSheet extends StatefulWidget {
  const AdminMuthawwifSheet({
    super.key,
    required this.group,
    required this.onSelectMember,
    required this.onCallMuthawwif,
  });

  final AdminDepartureGroupTrack group;
  final ValueChanged<AdminTrackingMember> onSelectMember;
  final VoidCallback onCallMuthawwif;

  @override
  State<AdminMuthawwifSheet> createState() => _AdminMuthawwifSheetState();
}

class _AdminMuthawwifSheetState extends State<AdminMuthawwifSheet> {
  int _selectedFilterIndex = 0; // 0: Semua, 1: Di luar radius, 2: SOS

  static const Color _ink = Color(0xFF1F1F1F);
  static const Color _gold = Color(0xFFECC485);
  static const Color _sosRed = Color(0xFFD32F2F);
  static const Color _peach = Color(0xFFFFE0B2);
  static const Color _sheetBg = Color(0xFFFFF9F0);

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final members = group.members;

    // Filter list anggota sesuai tab
    final filteredMembers = members.where((m) {
      if (_selectedFilterIndex == 1) return m.isOutOfRadius;
      if (_selectedFilterIndex == 2) return m.hasActiveSos;
      return true;
    }).toList();

    final sosCount = members.where((m) => m.hasActiveSos).length;
    final outOfRadiusCount = members.where((m) => m.isOutOfRadius).length;

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

          // 2. Profil Muthawwif Header
          Row(
            children: [
              // Avatar Muthawwif dengan Border Hijau
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
                  color: const Color(0xFFE8F5E9),
                ),
                child: Center(
                  child: Text(
                    group.muthawwifInitials,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nama & Badge Mutawwif
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.muthawwifName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Mutawwif',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00796B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Live · Gerbang King Abdul Aziz',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Call Muthawwif
              IconButton(
                onPressed: widget.onCallMuthawwif,
                tooltip: 'Hubungi Muthawwif',
                icon: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.phone_outlined, size: 20, color: _ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Filter Tabs (Semua, Di luar radius, SOS)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterTab(
                  index: 0,
                  label: 'Semua · ${members.length}',
                ),
                const SizedBox(width: 8),
                _buildFilterTab(
                  index: 1,
                  label: 'Di luar radius · $outOfRadiusCount',
                ),
                const SizedBox(width: 8),
                _buildFilterTab(
                  index: 2,
                  label: 'SOS · $sosCount',
                  isRed: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Daftar Jemaah Bimbingan
          if (filteredMembers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Tidak ada jemaah pada kategori ini',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: filteredMembers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  return _buildMemberCard(member);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required int index,
    required String label,
    bool isRed = false,
  }) {
    final isSelected = _selectedFilterIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _gold : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _gold : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? _ink
                : (isRed ? _sosRed : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(AdminTrackingMember member) {
    Color avatarBg = Colors.grey.shade200;
    Color avatarFg = _ink;

    if (member.hasActiveSos) {
      avatarBg = _sosRed;
      avatarFg = Colors.white;
    } else if (member.isOutOfRadius) {
      avatarBg = _peach;
      avatarFg = const Color(0xFF8D6E63);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => widget.onSelectMember(member),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Inisial Lingkaran Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      member.initials,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: avatarFg,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nama & Keterangan Lokasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.distanceToMuthawwifMeters != null
                            ? '${member.locationText} · ${GeodesicHelper.formatDistance(member.distanceToMuthawwifMeters!)} dari mutawwif'
                            : member.locationText,
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

                // Badge Kanan
                if (member.hasActiveSos)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _sosRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'SOS',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (member.isOutOfRadius && member.distanceToMuthawwifMeters != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _peach,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Di luar · ${GeodesicHelper.formatDistance(member.distanceToMuthawwifMeters!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
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

