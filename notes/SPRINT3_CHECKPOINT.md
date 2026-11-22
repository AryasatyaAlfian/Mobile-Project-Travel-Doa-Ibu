# Sprint 3 checkpoint
- Baseline ACC: c0467b7 / APK 7A827692…BA51
- Branch: feat/s2-fe-mobile (Sprint 3 WIP)
- Notion: 9 FE Sprint 3 tickets -> In Progress; tablet tickets revised to Android HP (Frontend & QA)
- Added: geolocator + permission_handler, ACCESS_FINE/COARSE/BACKGROUND_LOCATION, FOREGROUND_SERVICE_LOCATION, POST_NOTIFICATIONS, WAKE_LOCK
- Added LocationTrackingService: permission flow, GPS stream tiap 20s, foreground notification, kirim /me/location + status
- Added dialog "Aktifkan lokasi" di MapsPage; status izin/GPS/gagal di kartu lokasi
- Added locationAgeLabel (model) + tampilan di detail (WIP muthawwif list)
- MFE-009 guard initialGroupId missing retained
- BLOCKERS:
  1. GPS stream emulator: foreground service start, tetapi belum ada fix; UI "Lokasi gagal dibaca" (butuh cek provider/geo fix / forceLocationManager)
  2. flutter test: 285/286, 1 overflow 13px di muthawwif_flow_test (belum terlacak)
  3. MFE-014 cakupan antarjemaah masih TBD, butuh keputusan produk
- Next: fix GPS acquisition + overflow, test APK, build, audit sesi PROTEIN, Notion In Review, album.
