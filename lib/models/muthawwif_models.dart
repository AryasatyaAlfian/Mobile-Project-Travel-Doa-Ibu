/// Model representasi data untuk Modul Muthawwif (Detail Rombongan, Anggota, & Jadwal Kegiatan).
class MuthawwifGroupInfo {
  const MuthawwifGroupInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.departureDate,
    required this.returnDate,
    required this.durationDays,
    required this.airline,
    required this.hotelMakkah,
    required this.hotelMadinah,
    required this.muthawwifName,
    this.muthawwifPhone,
    this.muthawwifWhatsapp,
    required this.membersCount,
    this.safeCount = 0,
    this.outOfRadiusCount = 0,
    this.sosActiveCount = 0,
  });

  final int id;
  final String name;
  final String code;
  final String departureDate;
  final String returnDate;
  final int durationDays;
  final String airline;
  final String hotelMakkah;
  final String hotelMadinah;
  final String muthawwifName;
  final String? muthawwifPhone;
  final String? muthawwifWhatsapp;
  final int membersCount;
  final int safeCount;
  final int outOfRadiusCount;
  final int sosActiveCount;

  factory MuthawwifGroupInfo.fromBackend({
    required Map<String, dynamic> groupData,
    String? fallbackMuthawwifName,
    String? fallbackMuthawwifPhone,
  }) {
    final name = (groupData['name'] as String?) ?? 'Rombongan Umrah Reguler';
    final code = groupData['code'] as String? ?? (name.contains('-') ? name.split(' ').first : 'AGR-12');
    final depDate = groupData['departure_date'] as String? ?? '12 Januari 2027';
    final retDate = groupData['return_date'] as String? ?? '20 Januari 2027';
    final count = groupData['members_count'] as int? ?? (groupData['members'] as List?)?.length ?? 24;

    return MuthawwifGroupInfo(
      id: groupData['id'] as int? ?? 1,
      name: name,
      code: code,
      departureDate: depDate,
      returnDate: retDate,
      durationDays: groupData['duration_days'] as int? ?? 9,
      airline: groupData['airline'] as String? ?? 'Garuda Indonesia (GA-980)',
      hotelMakkah: groupData['hotel_makkah'] as String? ?? 'Anjum Hotel Makkah',
      hotelMadinah: groupData['hotel_madinah'] as String? ?? 'Dar Al Iman Madinah',
      muthawwifName: groupData['muthawwif']?['name'] as String? ?? fallbackMuthawwifName ?? 'Ust. Ahmad Fadli, Lc.',
      muthawwifPhone: groupData['muthawwif']?['phone'] as String? ?? fallbackMuthawwifPhone ?? '+62 812 3456 7890',
      muthawwifWhatsapp: groupData['whatsapp_group_url'] as String?,
      membersCount: count,
      safeCount: 22,
      outOfRadiusCount: 2,
      sosActiveCount: 0,
    );
  }

  static MuthawwifGroupInfo defaultPreset({String? muthawwifName, String? muthawwifPhone}) {
    return MuthawwifGroupInfo(
      id: 1,
      name: 'Rombongan Umrah Reguler Januari 2027',
      code: 'AGR-12',
      departureDate: '12 Januari 2027',
      returnDate: '20 Januari 2027',
      durationDays: 9,
      airline: 'Garuda Indonesia (GA-980)',
      hotelMakkah: 'Anjum Hotel Makkah',
      hotelMadinah: 'Dar Al Iman Madinah',
      muthawwifName: muthawwifName ?? 'Ust. Ahmad Fadli, Lc.',
      muthawwifPhone: muthawwifPhone ?? '+62 812 3456 7890',
      muthawwifWhatsapp: 'https://wa.me/6281234567890',
      membersCount: 24,
      safeCount: 22,
      outOfRadiusCount: 2,
      sosActiveCount: 0,
    );
  }
}

/// Anggota rombongan yang dibimbing oleh muthawwif.
class MuthawwifMemberInfo {
  const MuthawwifMemberInfo({
    required this.id,
    required this.name,
    this.roleLabel = 'Anggota',
    this.isLeader = false,
    this.passportNumber,
    this.birthDate,
    this.phone,
    this.roomMakkah,
    this.roomMadinah,
    this.avatarUrl,
    this.locationText,
    this.lastSeenMinutes,
    this.distanceMeters,
    this.isOutOfRadius = false,
    this.isSosActive = false,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final String roleLabel;
  final bool isLeader;
  final String? passportNumber;
  final String? birthDate;
  final String? phone;
  final String? roomMakkah;
  final String? roomMadinah;
  final String? avatarUrl;
  final String? locationText;
  final int? lastSeenMinutes;
  final double? distanceMeters;
  final bool isOutOfRadius;
  final bool isSosActive;
  final double? latitude;
  final double? longitude;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : 'J';
  }

  factory MuthawwifMemberInfo.fromBackendJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final lastLoc = json['last_location'] as Map<String, dynamic>?;
    final id = json['id'] as int? ?? 0;
    final name = (json['name'] as String?) ?? 'Jemaah';
    final isLeader = name.toLowerCase().contains('zara') || id == 3;

    return MuthawwifMemberInfo(
      id: id,
      name: name,
      roleLabel: isLeader ? 'Ketua Rombongan' : 'Anggota',
      isLeader: isLeader,
      passportNumber: profile?['passport_number'] as String? ?? 'A${1234500 + id}',
      birthDate: profile?['birth_date'] as String? ?? '12 Januari 2004',
      phone: (json['phone'] as String?) ?? '+62 812 3456 7890',
      roomMakkah: '101 (Double)',
      roomMadinah: '205 (Double)',
      latitude: lastLoc?['latitude'] as double?,
      longitude: lastLoc?['longitude'] as double?,
    );
  }

  static List<MuthawwifMemberInfo> defaultMemberList() {
    return const [
      MuthawwifMemberInfo(
        id: 1,
        name: 'Zara Anselma',
        roleLabel: 'Ketua Rombongan',
        isLeader: true,
        passportNumber: 'A1234567',
        birthDate: '12 Januari 2004',
        phone: '+62 812 3456 7890',
        roomMakkah: '101 (Double)',
        roomMadinah: '205 (Double)',
        locationText: 'Abraj Al Bait',
        lastSeenMinutes: 1,
        distanceMeters: 1200,
        isOutOfRadius: false,
        latitude: 21.4190,
        longitude: 39.8260,
      ),
      MuthawwifMemberInfo(
        id: 2,
        name: 'Aisyah Rahma',
        roleLabel: 'Anggota',
        isLeader: false,
        passportNumber: 'A1234568',
        birthDate: '15 Maret 1999',
        phone: '+62 812 9988 7766',
        roomMakkah: '102 (Triple)',
        roomMadinah: '206 (Triple)',
        locationText: 'Abraj Al Bait, Lantai Dasar',
        lastSeenMinutes: 1,
        distanceMeters: 1200,
        isOutOfRadius: false,
        latitude: 21.4195,
        longitude: 39.8250,
      ),
      MuthawwifMemberInfo(
        id: 3,
        name: 'Budi Santoso',
        roleLabel: 'Anggota',
        isLeader: false,
        passportNumber: 'A1234569',
        birthDate: '20 Juni 1990',
        phone: '+62 813 4455 6677',
        roomMakkah: '103 (Quad)',
        roomMadinah: '207 (Quad)',
        locationText: 'Pelataran Masjidil Haram',
        lastSeenMinutes: 4,
        distanceMeters: 450,
        isOutOfRadius: false,
        latitude: 21.4220,
        longitude: 39.8265,
      ),
      MuthawwifMemberInfo(
        id: 4,
        name: 'Dewi Lestari',
        roleLabel: 'Anggota',
        isLeader: false,
        passportNumber: 'A1234570',
        birthDate: '5 Mei 1995',
        phone: '+62 812 1122 3344',
        roomMakkah: '104 (Double)',
        roomMadinah: '208 (Double)',
        locationText: 'Misfalah',
        lastSeenMinutes: 5,
        distanceMeters: 1800,
        isOutOfRadius: false,
        latitude: 21.4150,
        longitude: 39.8240,
      ),
      MuthawwifMemberInfo(
        id: 5,
        name: 'Fahri Alamsyah',
        roleLabel: 'Anggota',
        isLeader: false,
        passportNumber: 'A1234571',
        birthDate: '8 Agustus 1988',
        phone: '+62 815 6677 8899',
        roomMakkah: '105 (Triple)',
        roomMadinah: '209 (Triple)',
        locationText: 'Jabal Omar',
        lastSeenMinutes: 2,
        distanceMeters: 900,
        isOutOfRadius: false,
        latitude: 21.4210,
        longitude: 39.8220,
      ),
      MuthawwifMemberInfo(
        id: 6,
        name: 'Hana Fitriani',
        roleLabel: 'Anggota',
        isLeader: false,
        passportNumber: 'A1234572',
        birthDate: '10 November 2001',
        phone: '+62 819 2233 4455',
        roomMakkah: '106 (Double)',
        roomMadinah: '210 (Double)',
        locationText: 'Gerbang King Fahd',
        lastSeenMinutes: 2,
        distanceMeters: 550,
        isOutOfRadius: false,
        latitude: 21.4230,
        longitude: 39.8245,
      ),
      MuthawwifMemberInfo(
        id: 7,
        name: 'Rina Kartika',
        roleLabel: 'Anggota',
        isLeader: false,
        passportNumber: 'A1234573',
        birthDate: '14 Februari 1993',
        phone: '+62 855 3668 1111',
        roomMakkah: '107 (Double)',
        roomMadinah: '211 (Double)',
        locationText: 'Ajyad',
        lastSeenMinutes: 3,
        distanceMeters: 2400,
        isOutOfRadius: true,
        latitude: 21.4110,
        longitude: 39.8320,
      ),
      MuthawwifMemberInfo(
        id: 8,
        name: 'Hendra Wijaya',
        roleLabel: 'Anggota',
        isLeader: false,
        passportNumber: 'A1234574',
        birthDate: '25 Juli 1985',
        phone: '+62 855 3668 2222',
        roomMakkah: '108 (Triple)',
        roomMadinah: '212 (Triple)',
        locationText: 'Misfalah',
        lastSeenMinutes: 1,
        distanceMeters: 2100,
        isOutOfRadius: true,
        latitude: 21.4100,
        longitude: 39.8210,
      ),
      MuthawwifMemberInfo(
        id: 9,
        name: 'Siti Aminah',
        roleLabel: 'Anggota',
        isLeader: false,
        passportNumber: 'A1234575',
        birthDate: '3 September 1997',
        phone: '+62 855 3668 3333',
        roomMakkah: '109 (Double)',
        roomMadinah: '213 (Double)',
        locationText: 'Dekat Gate 79, Masjidil Haram',
        lastSeenMinutes: 2,
        distanceMeters: 650,
        isOutOfRadius: false,
        isSosActive: false,
        latitude: 21.4235,
        longitude: 39.8255,
      ),
    ];
  }
}

/// Item checklist kegiatan jadwal harian muthawwif.
class ItineraryChecklistItem {
  ItineraryChecklistItem({
    required this.time,
    required this.title,
    this.isCompleted = false,
  });

  final String time;
  final String title;
  bool isCompleted;
}

/// Satu hari perjalanan manasik / ibadah.
class ItineraryDayItem {
  ItineraryDayItem({
    required this.dayNumber,
    required this.dayName,
    required this.dateLabel,
    required this.title,
    required this.activities,
  });

  final int dayNumber;
  final String dayName;
  final String dateLabel;
  final String title;
  final List<ItineraryChecklistItem> activities;

  int get completedCount => activities.where((a) => a.isCompleted).length;
  int get totalCount => activities.length;
  bool get isAllCompleted => totalCount > 0 && completedCount == totalCount;
  double get progress => totalCount > 0 ? (completedCount / totalCount) : 0.0;

  static List<ItineraryDayItem> defaultPreset() {
    return [
      ItineraryDayItem(
        dayNumber: 1,
        dayName: 'Sen',
        dateLabel: '12 Jan',
        title: 'Keberangkatan ke Jeddah',
        activities: [
          ItineraryChecklistItem(time: '08.00', title: 'Kumpul di Bandara Soekarno Hatta', isCompleted: true),
          ItineraryChecklistItem(time: '11.30', title: 'Penerbangan GA-980 ke Jeddah', isCompleted: true),
          ItineraryChecklistItem(time: '18.00', title: 'Mendarat di Bandara King Abdul Aziz', isCompleted: true),
          ItineraryChecklistItem(time: '20.00', title: 'Perjalanan Bus ke Hotel Makkah', isCompleted: true),
        ],
      ),
      ItineraryDayItem(
        dayNumber: 2,
        dayName: 'Sel',
        dateLabel: '13 Jan',
        title: 'Tiba di Makkah & Check-in Hotel',
        activities: [
          ItineraryChecklistItem(time: '06.00', title: 'Sarapan Pagi Bersama di Restoran Hotel', isCompleted: true),
          ItineraryChecklistItem(time: '09.00', title: 'Pembagian Kunci Kamar & Istirahat', isCompleted: true),
          ItineraryChecklistItem(time: '16.00', title: 'Briefing Persiapan Thawaf & Sa\'i', isCompleted: true),
        ],
      ),
      ItineraryDayItem(
        dayNumber: 3,
        dayName: 'Rab',
        dateLabel: '14 Jan',
        title: 'Umrah Pertama',
        activities: [
          ItineraryChecklistItem(time: '03.30', title: 'Shalat Tahajud (Mandiri)', isCompleted: true),
          ItineraryChecklistItem(time: '04.30', title: 'Persiapan & Sarapan', isCompleted: true),
          ItineraryChecklistItem(time: '06.00', title: 'Briefing Umrah', isCompleted: true),
          ItineraryChecklistItem(time: '07.00', title: 'Berangkat ke Masjidil Haram', isCompleted: false),
          ItineraryChecklistItem(time: '07.30', title: 'Pelaksanaan Umrah', isCompleted: false),
          ItineraryChecklistItem(time: '10.30', title: 'Istirahat & Kegiatan Bebas', isCompleted: false),
        ],
      ),
      ItineraryDayItem(
        dayNumber: 4,
        dayName: 'Kam',
        dateLabel: '15 Jan',
        title: 'Kajian & Ziarah Sekitar Makkah',
        activities: [
          ItineraryChecklistItem(time: '07.00', title: 'Ziarah Jabal Tsur & Jabal Rahmah', isCompleted: false),
          ItineraryChecklistItem(time: '13.30', title: 'Kajian Manasik Pasca Umrah', isCompleted: false),
          ItineraryChecklistItem(time: '16.00', title: 'Ibadah Shalat Ashar & Maghrib di Haram', isCompleted: false),
        ],
      ),
      ItineraryDayItem(
        dayNumber: 5,
        dayName: 'Jum',
        dateLabel: '16 Jan',
        title: 'Shalat Jumat di Masjidil Haram',
        activities: [
          ItineraryChecklistItem(time: '09.30', title: 'Berangkat Awal ke Masjidil Haram', isCompleted: false),
          ItineraryChecklistItem(time: '12.30', title: 'Pelaksanaan Shalat Jumat Berjamaah', isCompleted: false),
          ItineraryChecklistItem(time: '15.30', title: 'Kumpul di Lobby Hotel', isCompleted: false),
        ],
      ),
    ];
  }
}

