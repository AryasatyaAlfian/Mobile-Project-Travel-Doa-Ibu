import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

import 'travel_api.dart';

enum LocationTrackingState {
  idle,
  permissionDenied,
  gpsDisabled,
  acquiring,
  running,
  failed,
}

/// Mengelola izin, pembacaan GPS, dan pengiriman lokasi berkala.
/// Stream memakai foreground notification Android; saat aplikasi di background
/// proses tetap hidup dan interval pengiriman dijaga sekitar 20 detik.
class LocationTrackingService {
  LocationTrackingService._();
  static final LocationTrackingService instance = LocationTrackingService._();

  final ValueNotifier<LocationTrackingState> state =
      ValueNotifier<LocationTrackingState>(LocationTrackingState.idle);
  final ValueNotifier<DateTime?> lastSentAt = ValueNotifier<DateTime?>(null);
  final ValueNotifier<Position?> lastPosition = ValueNotifier<Position?>(null);
  final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);
  final ValueNotifier<Position?> lastFix = ValueNotifier<Position?>(null);
  final ValueNotifier<DateTime?> lastServerAt = ValueNotifier<DateTime?>(null);

  StreamSubscription<Position>? _subscription;
  StreamSubscription<ServiceStatus>? _serviceSubscription;
  TravelApi? _api;
  bool _starting = false;
  DateTime? _lastAttempt;

  bool get isRunning => _subscription != null;

  Future<bool> requestPermissions() async {
    final service = await Permission.location.serviceStatus;
    if (!service.isEnabled) {
      state.value = LocationTrackingState.gpsDisabled;
      return false;
    }
    var status = await Permission.location.status;
    if (!status.isGranted) status = await Permission.location.request();
    if (!status.isGranted) {
      state.value = LocationTrackingState.permissionDenied;
      return false;
    }
    // Android 10+ memisahkan izin background; jangan paksa bila ditolak.
    if (await Permission.locationAlways.isDenied) {
      await Permission.locationAlways.request();
    }
    await Permission.notification.request();
    return true;
  }

  Future<void> start(TravelApi api) async {
    if (_starting || isRunning) return;
    _starting = true;
    _api = api;
    state.value = LocationTrackingState.acquiring;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        state.value = LocationTrackingState.gpsDisabled;
        await _reportStatus('gps_disabled');
        return;
      }
      if (!await requestPermissions()) {
        final status = await Permission.location.status;
        await _reportStatus(status.isPermanentlyDenied ? 'permission_denied' : 'permission_denied');
        return;
      }
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state.value = LocationTrackingState.permissionDenied;
        await _reportStatus('permission_denied');
        return;
      }
      _serviceSubscription ??= Geolocator.getServiceStatusStream().listen((status) {
        if (status == ServiceStatus.disabled) {
          state.value = LocationTrackingState.gpsDisabled;
        } else if (isRunning) {
          state.value = LocationTrackingState.running;
        }
      });
      _subscription = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          forceLocationManager: true,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 20),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Doa Ibu — lokasi aktif',
            notificationText: 'Lokasi dikirim berkala untuk keselamatan jemaah.',
            notificationChannelName: 'Pelacakan Lokasi',
            enableWakeLock: true,
            setOngoing: true,
          ),
        ),
      ).listen(_onPosition, onError: _onStreamError, cancelOnError: false);
    } catch (e) {
      lastError.value = e.toString();
      state.value = LocationTrackingState.failed;
      await _reportStatus('acquisition_failed');
    } finally {
      _starting = false;
    }
  }

  Future<void> _onPosition(Position position) async {
    lastPosition.value = position;
    lastFix.value = position;
    if (state.value != LocationTrackingState.running) {
      state.value = LocationTrackingState.running;
    }
    final now = DateTime.now();
    if (_lastAttempt != null && now.difference(_lastAttempt!) < const Duration(seconds: 15)) {
      return;
    }
    _lastAttempt = now;
    try {
      final response = await _api?.sendLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyM: position.accuracy,
        recordedAt: position.timestamp,
      );
      if (response == null || response.isEmpty) {
        throw StateError('Server tidak mengonfirmasi penerimaan lokasi.');
      }
      lastSentAt.value = DateTime.now();
      final ack = response['received_at'] ?? response['updated_at'] ?? response['recorded_at'];
      if (ack is String) {
        final parsed = DateTime.tryParse(ack)?.toLocal();
        if (parsed != null) lastServerAt.value = parsed;
      }
      lastError.value = null;
    } catch (e) {
      lastError.value = e.toString();
    }
  }

  Future<void> _onStreamError(Object error) async {
    lastError.value = error.toString();
    state.value = LocationTrackingState.failed;
    await _reportStatus('acquisition_failed');
  }

  Future<void> _reportStatus(String stateName) async {
    try {
      await _api?.sendLocationStatus(state: stateName);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _serviceSubscription?.cancel();
    _subscription = null;
    _serviceSubscription = null;
    state.value = LocationTrackingState.idle;
  }
}
