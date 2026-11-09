import 'dart:math' as math;

/// Utilitas perhitungan geodesik dan navigasi jarak lapangan.
class GeodesicHelper {
  static const double earthRadiusMeters = 6371000.0;

  /// Menghitung jarak lurus (lingkaran besar) antara dua koordinat GPS dalam meter (Rumus Haversine).
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Menghitung sudut arah (azimuth / bearing) dari koordinat asal ke target (0° - 360°).
  static double calculateBearing(
    double fromLat,
    double fromLon,
    double toLat,
    double toLon,
  ) {
    final dLon = _toRadians(toLon - fromLon);
    final y = math.sin(dLon) * math.cos(_toRadians(toLat));
    final x = math.cos(_toRadians(fromLat)) * math.sin(_toRadians(toLat)) -
        math.sin(_toRadians(fromLat)) *
            math.cos(_toRadians(toLat)) *
            math.cos(dLon);

    final degrees = _toDegrees(math.atan2(y, x));
    return (degrees + 360) % 360;
  }

  /// Memetakan sudut derajat ke arah mata angin dalam Bahasa Indonesia.
  static String getBearingDirection(double bearingDegrees) {
    final normalized = (bearingDegrees % 360 + 360) % 360;
    if (normalized >= 337.5 || normalized < 22.5) return 'Utara';
    if (normalized >= 22.5 && normalized < 67.5) return 'Timur Laut';
    if (normalized >= 67.5 && normalized < 112.5) return 'Timur';
    if (normalized >= 112.5 && normalized < 157.5) return 'Tenggara';
    if (normalized >= 157.5 && normalized < 202.5) return 'Selatan';
    if (normalized >= 202.5 && normalized < 247.5) return 'Barat Daya';
    if (normalized >= 247.5 && normalized < 292.5) return 'Barat';
    return 'Barat Laut';
  }

  /// Memformat meter ke teks string yang ramah pembaca ("650 m" atau "1,2 km").
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  /// Estimasi waktu tempuh jalan kaki (kecepatan rata-rata jamaah ~4.5 km/jam atau ~75 meter/menit).
  static int estimateWalkingMinutes(double meters) {
    if (meters <= 0) return 1;
    return math.max(1, (meters / 75.0).round());
  }

  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);
  static double _toDegrees(double radians) => radians * (180.0 / math.pi);
}

/// Representasi data laporan SOS untuk UI Admin (Banner atas & Modal Alert).
class AdminSosAlert {
  final int id;
  final int jemaahId;
  final String jemaahName;
  final String? phone;
  final String groupName;
  final String muthawwifName;
  final String? muthawwifPhone;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final double? distanceToMuthawwifMeters;
  final DateTime? createdAt;
  final String status;

  const AdminSosAlert({
    required this.id,
    required this.jemaahId,
    required this.jemaahName,
    this.phone,
    required this.groupName,
    required this.muthawwifName,
    this.muthawwifPhone,
    required this.locationText,
    this.latitude,
    this.longitude,
    this.distanceToMuthawwifMeters,
    this.createdAt,
    required this.status,
  });

  /// Format keterangan selisih waktu pelaporan ("2 mnt lalu", "Baru saja").
  String get timeAgo {
    if (createdAt == null) return 'Baru saja';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  /// Konversi dari JSON response `GET /api/v1/sos` backend Laravel.
  factory AdminSosAlert.fromJson(
    Map<String, dynamic> json, {
    String? fallbackMuthawwif,
    String? fallbackMuthawwifPhone,
    double? muthawwifLat,
    double? muthawwifLon,
  }) {
    final reporter = json['reporter'] as Map<String, dynamic>? ?? {};
    final group = json['group'] as Map<String, dynamic>? ?? {};
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final delivery = json['delivery'] as Map<String, dynamic>? ?? {};

    final double? lat = location['latitude'] != null ? (location['latitude'] as num).toDouble() : null;
    final double? lon = location['longitude'] != null ? (location['longitude'] as num).toDouble() : null;

    DateTime? createdAt;
    if (delivery['received_at'] != null) {
      createdAt = DateTime.tryParse(delivery['received_at'] as String);
    } else if (location['recorded_at'] != null) {
      createdAt = DateTime.tryParse(location['recorded_at'] as String);
    }

    final groupName = (group['departure_group'] as String?) ??
        (group['group_name'] as String?) ??
        (group['package'] as String?) ??
        'Rombongan Umrah';

    double? dist;
    if (lat != null && lon != null && muthawwifLat != null && muthawwifLon != null) {
      dist = GeodesicHelper.calculateDistanceMeters(lat, lon, muthawwifLat, muthawwifLon);
    }

    String locText = 'Sekitar Masjidil Haram';
    if (location['available'] == true && lat != null && lon != null) {
      locText = 'Dekat Gate 79, Masjidil Haram';
    } else if (location['unavailable_reason'] != null) {
      locText = 'Lokasi GPS Tidak Tersedia (${location['unavailable_reason']})';
    }

    return AdminSosAlert(
      id: (json['id'] as num?)?.toInt() ?? 0,
      jemaahId: (reporter['id'] as num?)?.toInt() ?? 0,
      jemaahName: (reporter['name'] as String?) ?? 'Jemaah',
      phone: reporter['phone'] as String?,
      groupName: groupName,
      muthawwifName: fallbackMuthawwif ?? 'Ust. Ahmad Fauzi',
      muthawwifPhone: fallbackMuthawwifPhone,
      locationText: locText,
      latitude: lat,
      longitude: lon,
      distanceToMuthawwifMeters: dist,
      createdAt: createdAt,
      status: (json['status'] as String?) ?? 'received',
    );
  }
}

/// Anggota rombongan yang dilacak posisinya dalam satu grup keberangkatan.
class AdminTrackingMember {
  final int id;
  final String name;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String locationText;
  final DateTime? updatedAt;
  final bool hasActiveSos;
  final double? distanceToMuthawwifMeters;

  const AdminTrackingMember({
    required this.id,
    required this.name,
    this.phone,
    this.latitude,
    this.longitude,
    required this.locationText,
    this.updatedAt,
    this.hasActiveSos = false,
    this.distanceToMuthawwifMeters,
  });

  /// Inisial dua huruf untuk lingkaran avatar (misal: "Siti Aminah" -> "SA").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'J';
    if (parts.length == 1) return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Status radius aman: aman bila jarak <= 2000 meter.
  bool get isOutOfRadius =>
      distanceToMuthawwifMeters != null && distanceToMuthawwifMeters! > 2000.0;

  /// Keterangan status lokasi ("Aman", "Di luar · 2,4 km", "SOS").
  String get statusBadgeLabel {
    if (hasActiveSos) return 'SOS';
    if (isOutOfRadius && distanceToMuthawwifMeters != null) {
      return 'Di luar · ${GeodesicHelper.formatDistance(distanceToMuthawwifMeters!)}';
    }
    return 'Aman';
  }

  /// Factory untuk parsing dari item members `/departure-groups/{id}/tracker`.
  factory AdminTrackingMember.fromJson(
    Map<String, dynamic> json, {
    double? muthawwifLat,
    double? muthawwifLon,
    bool isSos = false,
  }) {
    final identity = json['identity'] as Map<String, dynamic>? ?? {};
    final lastLoc = json['last_location'] as Map<String, dynamic>?;

    final double? lat = lastLoc?['latitude'] != null ? (lastLoc!['latitude'] as num).toDouble() : null;
    final double? lon = lastLoc?['longitude'] != null ? (lastLoc!['longitude'] as num).toDouble() : null;

    DateTime? updated;
    if (lastLoc?['updated_at'] != null) {
      updated = DateTime.tryParse(lastLoc!['updated_at'] as String);
    }

    double? dist;
    if (lat != null && lon != null && muthawwifLat != null && muthawwifLon != null) {
      dist = GeodesicHelper.calculateDistanceMeters(lat, lon, muthawwifLat, muthawwifLon);
    }

    return AdminTrackingMember(
      id: (identity['id'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt() ?? 0,
      name: (identity['name'] as String?) ?? (json['name'] as String?) ?? 'Jemaah',
      phone: (identity['phone'] as String?) ?? (json['phone'] as String?),
      latitude: lat ?? (json['latitude'] != null ? (json['latitude'] as num).toDouble() : null),
      longitude: lon ?? (json['longitude'] != null ? (json['longitude'] as num).toDouble() : null),
      locationText: (json['location_text'] as String?) ?? (lat != null ? 'Sekitar Masjidil Haram' : 'Lokasi belum diperbarui'),
      updatedAt: updated,
      hasActiveSos: isSos,
      distanceToMuthawwifMeters: dist ?? (json['distance_meters'] as num?)?.toDouble(),
    );
  }
}

/// Data grup keberangkatan untuk peta cluster dan sheet "Grup Berangkat".
class AdminDepartureGroupTrack {
  final int id;
  final String code; // misal: "AGR-12"
  final String packageName; // misal: "Umrah Plus Turki"
  final String city; // "Makkah", "Madinah", "Istanbul"
  final int muthawwifId;
  final String muthawwifName;
  final String? muthawwifPhone;
  final double? muthawwifLat;
  final double? muthawwifLon;
  final int totalJemaah;
  final int safeCount;
  final int outOfRadiusCount;
  final int sosCount;
  final List<AdminTrackingMember> members;

  const AdminDepartureGroupTrack({
    required this.id,
    required this.code,
    required this.packageName,
    required this.city,
    required this.muthawwifId,
    required this.muthawwifName,
    this.muthawwifPhone,
    this.muthawwifLat,
    this.muthawwifLon,
    required this.totalJemaah,
    required this.safeCount,
    required this.outOfRadiusCount,
    required this.sosCount,
    this.members = const [],
  });

  /// Inisial muthawwif untuk avatar map/sheet.
  String get muthawwifInitials {
    final parts = muthawwifName.replaceAll('Ust.', '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Koordinat tengah cluster (mengutamakan posisi muthawwif atau titik Ka'bah/Masjidil Haram default).
  double get centerLatitude => muthawwifLat ?? 21.4225;
  double get centerLongitude => muthawwifLon ?? 39.8262;

  AdminDepartureGroupTrack copyWithMembers({
    required List<AdminTrackingMember> members,
    int? safeCount,
    int? outOfRadiusCount,
    int? sosCount,
  }) {
    return AdminDepartureGroupTrack(
      id: id,
      code: code,
      packageName: packageName,
      city: city,
      muthawwifId: muthawwifId,
      muthawwifName: muthawwifName,
      muthawwifPhone: muthawwifPhone,
      muthawwifLat: muthawwifLat,
      muthawwifLon: muthawwifLon,
      totalJemaah: members.isNotEmpty ? members.length : totalJemaah,
      safeCount: safeCount ?? this.safeCount,
      outOfRadiusCount: outOfRadiusCount ?? this.outOfRadiusCount,
      sosCount: sosCount ?? this.sosCount,
      members: members,
    );
  }
}

/// Ringkasan keseluruhan sistem pemantauan Admin (Counter Aman, Luar Radius, SOS).
class AdminMapsOverview {
  final int totalGroups;
  final int totalJemaah;
  final int safeCount;
  final int outOfRadiusCount;
  final int sosActiveCount;
  final List<AdminDepartureGroupTrack> groups;
  final List<AdminSosAlert> activeAlerts;

  const AdminMapsOverview({
    required this.totalGroups,
    required this.totalJemaah,
    required this.safeCount,
    required this.outOfRadiusCount,
    required this.sosActiveCount,
    required this.groups,
    this.activeAlerts = const [],
  });

  static const empty = AdminMapsOverview(
    totalGroups: 0,
    totalJemaah: 0,
    safeCount: 0,
    outOfRadiusCount: 0,
    sosActiveCount: 0,
    groups: [],
    activeAlerts: [],
  );
}
