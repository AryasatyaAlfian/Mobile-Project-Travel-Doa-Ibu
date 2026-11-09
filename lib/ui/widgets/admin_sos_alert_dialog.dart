import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_tracking_models.dart';

/// Modal Alert Pop-up Darurat ketika jemaah pertama kali mengaktifkan SOS (Gambar 2).
class AdminSosAlertDialog extends StatelessWidget {
  const AdminSosAlertDialog({
    super.key,
    required this.alert,
    required this.onViewLocation,
    required this.onCallJemaah,
    required this.onCallMuthawwif,
    this.isMuthawwif = false,
    this.onDirections,
  });

  final AdminSosAlert alert;
  final VoidCallback onViewLocation;
  final VoidCallback onCallJemaah;
  final VoidCallback onCallMuthawwif;
  final bool isMuthawwif;
  final VoidCallback? onDirections;

  static const Color _red = Color(0xFFD32F2F);
  static const Color _gold = Color(0xFFECC485);
  static const Color _creamBg = Color(0xFFFFF9F0);
  static const Color _ink = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    final distanceStr = alert.distanceToMuthawwifMeters != null
        ? '${GeodesicHelper.formatDistance(alert.distanceToMuthawwifMeters!)} dari mutawwif'
        : 'Dekat muthawwif pembimbing';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Icon Berdenyut Merah
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: _red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Headline Title & Subtitle
            Text(
              'SOS Darurat!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _red,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: GoogleFonts.poppins(fontSize: 14, color: _ink),
                children: [
                  TextSpan(
                    text: alert.jemaahName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' menekan tombol SOS'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 3. Info Details Card (Krem)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _creamBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3E5D8)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.people_outline_rounded,
                    text: 'Rombongan ${alert.groupName} · ${alert.muthawwifName}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    text: alert.locationText,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.navigation_outlined,
                    text: distanceStr,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.access_time_rounded,
                    text: 'Dikirim ${alert.timeAgo}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Tombol Utama: Lihat Lokasi Jemaah
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onViewLocation,
                icon: const Icon(Icons.location_on_outlined, size: 20, color: _ink),
                label: Text(
                  'Lihat Lokasi Jemaah',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 5. Tombol Sekunder: Telepon Jemaah & Hubungi Mutawwif
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCallJemaah,
                    icon: const Icon(Icons.phone_outlined, size: 16, color: _ink),
                    label: Text(
                      'Telepon Jemaah',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCallMuthawwif,
                    icon: const Icon(Icons.shield_outlined, size: 16, color: _ink),
                    label: Text(
                      'Hubungi Mutawwif',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8D6E63)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _ink,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

