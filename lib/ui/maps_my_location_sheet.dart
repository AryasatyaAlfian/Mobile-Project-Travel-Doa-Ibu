import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/travel_api.dart';

/// Modal Bottom Sheet "Lokasi Saya"
/// Desain 1:1 Sesuai Figma Prototype media_1793605809848_e3a75d42.png
class MapsMyLocationSheet extends StatefulWidget {
  final TravelApi? api;
  final String address;
  final String coordinates;
  final double accuracyM;

  const MapsMyLocationSheet({
    super.key,
    this.api,
    this.address = 'Ibrahim Al Khalil St, Ajyad, Makkah 24231',
    this.coordinates = '21.4189° N, 39.8246° E',
    this.accuracyM = 8.0,
  });

  /// Helper statis untuk menampilkan bottom sheet dengan style Figma
  static Future<void> show(
    BuildContext context, {
    TravelApi? api,
    String address = 'Ibrahim Al Khalil St, Ajyad, Makkah 24231',
    String coordinates = '21.4189° N, 39.8246° E',
    double accuracyM = 8.0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MapsMyLocationSheet(
        api: api,
        address: address,
        coordinates: coordinates,
        accuracyM: accuracyM,
      ),
    );
  }

  @override
  State<MapsMyLocationSheet> createState() => _MapsMyLocationSheetState();
}

class _MapsMyLocationSheetState extends State<MapsMyLocationSheet> {
  static const Color _ink = Color(0xFF1E293B);
  static const Color _muted = Color(0xFF64748B);
  static const Color _green = Color(0xFF10B981);
  static const Color _cardBg = Color(0xFFFFFBEB);

  bool _isSharingWithGroup = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocationStatus();
  }

  Future<void> _fetchLocationStatus() async {
    if (widget.api == null) return;
    try {
      final tracker = await widget.api!.getTracker();
      if (!mounted) return;
      if (tracker['location_status'] != null) {
        final locStatus = tracker['location_status'] as Map<String, dynamic>;
        if (locStatus['state'] != null) {
          setState(() {
            _isSharingWithGroup = locStatus['state'] == 'available';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleSharing(bool value) async {
    setState(() {
      _isSharingWithGroup = value;
    });

    if (widget.api != null) {
      setState(() => _isLoading = true);
      try {
        final stateStr = value ? 'available' : 'gps_disabled';
        await widget.api!.sendLocationStatus(state: stateStr);
      } catch (_) {
        // Safe fallback jika offline / simulasi
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Lokasi Anda sekarang dibagikan ke Rombongan & Mutawwif.'
                : 'Berbagi lokasi ke rombongan dinonaktifkan.',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: value ? _green : const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tautan koordinat disalin: ${widget.coordinates} (${widget.address})',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        28 + MediaQuery.of(context).padding.bottom + 65,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title + Share Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lokasi Saya',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
                Material(
                  color: const Color(0xFFF1F5F9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _shareLocation,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.ios_share_rounded,
                        size: 20,
                        color: _ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Alamat Jalan
            Text(
              widget.address,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _ink,
              ),
            ),
            const SizedBox(height: 4),

            // Koordinat & Status Live
            Row(
              children: [
                Text(
                  widget.coordinates,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _muted,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Live',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Panel Fitur Lokasi
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Item 1: Lokasi Saya & Akurasi
                  _buildItemRow(
                    icon: Icons.navigation_rounded,
                    title: 'Lokasi Saya',
                    subtitle: 'Akurasi ±${widget.accuracyM.toInt()} m • diperbarui baru saja',
                  ),
                  const Divider(height: 1, indent: 68, endIndent: 16, color: Color(0xFFF1F5F9)),

                  // Item 2: Dibagikan dari Device
                  _buildItemRow(
                    icon: Icons.smartphone_rounded,
                    title: 'Dibagikan dari',
                    subtitle: 'Handphone ini',
                  ),
                  const Divider(height: 1, indent: 68, endIndent: 16, color: Color(0xFFF1F5F9)),

                  // Item 3: Bagikan ke Rombongan Switch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bagikan ke Rombongan',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _ink,
                                ),
                              ),
                              Text(
                                'Terlihat oleh Mutawwif',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Switch.adaptive(
                            value: _isSharingWithGroup,
                            onChanged: _toggleSharing,
                            activeTrackColor: _green,
                            activeThumbColor: Colors.white,
                          ),
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

  Widget _buildItemRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _muted,
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
