import 'package:flutter/material.dart';

import '../services/travel_api.dart';
import 'profile_page.dart';

/// Halaman Profil Administrator (Tab 1 pada [AdminShellPage]).
/// Menyesuaikan halaman profil standar ke mode Administrator:
/// - Menyembunyikan menu pembayaran digital jemaah
/// - Menghubungkan sub-halaman informasi akun, preferensi pengaturan,
///   keamanan akun, dan konfirmasi keluar khusus administrator.
class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({
    super.key,
    required this.api,
    required this.onLogout,
  });

  final TravelApi api;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      api: api,
      onLogout: onLogout,
      isAdmin: true,
    );
  }
}

