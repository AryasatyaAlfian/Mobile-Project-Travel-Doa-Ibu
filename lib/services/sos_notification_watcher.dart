import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/admin_tracking_models.dart';
import 'notification_service.dart';
import 'travel_api.dart';

/// Pengawas (watcher) laporan SOS real-time dari backend untuk Admin.
/// Menghubungkan endpoint REST dengan library notifikasi dan pop-up dialog UI.
class SosNotificationWatcher {
  SosNotificationWatcher({
    required this.api,
    this.onNewSosAlert,
    this.pollInterval = const Duration(seconds: 10),
  });

  final TravelApi api;
  final ValueChanged<AdminSosAlert>? onNewSosAlert;
  final Duration pollInterval;

  Timer? _timer;
  final Set<int> _acknowledgedAlertIds = {};
  bool _isPolling = false;

  /// Memulai pengawasan latar belakang secara periodik.
  void start() {
    stop();
    // Jalankan segera sekali di awal
    _checkSosUpdates();
    _timer = Timer.periodic(pollInterval, (_) => _checkSosUpdates());
  }

  /// Menghentikan polling pengawasan.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkSosUpdates() async {
    if (_isPolling) return;
    _isPolling = true;

    try {
      final reports = await api.getSosReports(status: 'received');
      for (final report in reports) {
        final id = (report['id'] as num?)?.toInt();
        if (id == null) continue;

        // Jika ID belum pernah ditampilkan/diakui pada sesi ini
        if (!_acknowledgedAlertIds.contains(id)) {
          _acknowledgedAlertIds.add(id);

          final alert = AdminSosAlert.fromJson(report);

          // 1. Tampilkan notifikasi sistem HP (Heads-up banner dengan suara & getar)
          await NotificationService.instance.showSosNotification(
            id: alert.id,
            jemaahName: alert.jemaahName,
            groupName: alert.groupName,
            locationText: alert.locationText,
            payload: 'sos:${alert.id}',
          );

          // 2. Beri tahu listener UI agar memunculkan modal dialog (Gambar 2)
          onNewSosAlert?.call(alert);
        }
      }
    } catch (_) {
      // shortcut: Abaikan error jaringan sementara saat polling, retry di interval berikutnya
    } finally {
      _isPolling = false;
    }
  }

  /// Menandai alert sebagai sudah diketahui secara manual oleh Admin.
  void acknowledge(int alertId) {
    _acknowledgedAlertIds.add(alertId);
  }
}

