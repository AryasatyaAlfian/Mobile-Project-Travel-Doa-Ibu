import 'package:flutter/material.dart';

import '../models/admin_tracking_models.dart';
import '../services/notification_service.dart';
import '../services/sos_notification_watcher.dart';
import '../services/travel_api.dart';
import 'muthawwif/muthawwif_home_page.dart';
import 'muthawwif/muthawwif_maps_page.dart';
import 'profile_page.dart';
import 'widgets/admin_sos_alert_dialog.dart';

/// Shell Navigasi Bawah khusus Muthawwif dengan 3 Tab:
/// 0: Home (Layanan Mutawwif, Detail Rombongan, Jadwal Kegiatan)
/// 1: Maps (Tracking Lapangan Rombongan)
/// 2: Profile (Akun & Preferensi Mutawwif)
class MuthawwifShellPage extends StatefulWidget {
  const MuthawwifShellPage({
    super.key,
    required this.api,
    this.onLogout,
  });

  final TravelApi api;
  final VoidCallback? onLogout;

  @override
  State<MuthawwifShellPage> createState() => _MuthawwifShellPageState();
}

class _MuthawwifShellPageState extends State<MuthawwifShellPage> {
  int _selectedTabIndex = 0; // 0: Home, 1: Maps, 2: Profile
  late final SosNotificationWatcher _sosWatcher;
  AdminSosAlert? _pendingAlert;

  static const Color _ink = Color(0xFF1F1F1F);

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Service Notifikasi Lokal
    NotificationService.instance.initialize(
      onTapped: (payload) {
        if (payload != null && payload.startsWith('sos:')) {
          if (mounted) {
            setState(() => _selectedTabIndex = 1); // Pindah ke tab Maps
          }
        }
      },
    );

    // 2. Setup Watcher Pengawas SOS Real-time untuk Muthawwif
    _sosWatcher = SosNotificationWatcher(
      api: widget.api,
      onNewSosAlert: (alert) {
        if (!mounted) return;
        _showEmergencyAlertPopup(alert);
      },
    );
    _sosWatcher.start();
  }

  @override
  void dispose() {
    _sosWatcher.stop();
    super.dispose();
  }

  void _showEmergencyAlertPopup(AdminSosAlert alert) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdminSosAlertDialog(
        alert: alert,
        isMuthawwif: true,
        onViewLocation: () {
          Navigator.of(ctx).pop();
          setState(() {
            _selectedTabIndex = 1; // Pindah ke Maps
            _pendingAlert = alert;
          });
        },
        onCallJemaah: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Menghubungi ${alert.jemaahName} (${alert.phone ?? "Nomor tidak tersedia"})...',
              ),
            ),
          );
        },
        onCallMuthawwif: () {
          Navigator.of(ctx).pop();
          setState(() {
            _selectedTabIndex = 1;
            _pendingAlert = alert;
          });
        },
        onDirections: () {
          Navigator.of(ctx).pop();
          setState(() {
            _selectedTabIndex = 1;
            _pendingAlert = alert;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Konten Halaman sesuai Tab Aktif
          IndexedStack(
            index: _selectedTabIndex,
            children: [
              MuthawwifHomePage(
                api: widget.api,
              ),
              MuthawwifMapsPage(
                api: widget.api,
                initialAlert: _pendingAlert,
              ),
              ProfilePage(
                api: widget.api,
                isMuthawwif: true,
                onLogout: widget.onLogout ?? () {},
              ),
            ],
          ),

          // Floating Capsule Bottom Navigation Bar (Gambar 1, 2, 3)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4DFD8),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tab 0: Home / Layanan Mutawwif
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      tooltip: 'Beranda Mutawwif',
                    ),
                    const SizedBox(width: 24),

                    // Tab 1: Maps Lapangan
                    _buildNavItem(
                      index: 1,
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map_rounded,
                      tooltip: 'Peta Lapangan',
                    ),
                    const SizedBox(width: 24),

                    // Tab 2: Akun / Profil Mutawwif
                    _buildNavItem(
                      index: 2,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      tooltip: 'Profil Mutawwif',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String tooltip,
  }) {
    final bool isSelected = _selectedTabIndex == index;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? _ink : Colors.grey.shade600,
            size: 26,
          ),
        ),
      ),
    );
  }
}

