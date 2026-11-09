/// Model data untuk pesanan tiket jemaah.
/// Selaras dengan skema database backend Laravel: status 'new', 'booked', 'completed', 'cancelled'.
class TicketOrder {
  TicketOrder({
    required this.id,
    required this.route,
    required this.packageName,
    required this.status,
    required this.airline,
    required this.flightNumber,
    required this.departureSchedule,
    required this.flightRoute,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.arrivalSchedule,
    required this.flightDuration,
    required this.passengerName,
    this.passengerType = 'Dewasa',
    this.cabinBaggage = 'Kabin 7 kg',
    this.checkedBaggage = 'Bagasi 20 kg',
    this.seatInfo = 'Kursi ... Disesuaikan',
    required this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String route;
  final String packageName;

  /// Status mengikuti backend:
  /// - 'new' -> Menunggu Pembayaran
  /// - 'booked' / 'confirmed' -> Dikonfirmasi
  /// - 'completed' -> Selesai
  /// - 'cancelled' -> Dibatalkan
  final String status;

  final String airline;
  final String flightNumber;
  final String departureSchedule;
  final String flightRoute;
  final String departureAirport;
  final String arrivalAirport;
  final String arrivalSchedule;
  final String flightDuration;

  final String passengerName;
  final String passengerType;
  final String cabinBaggage;
  final String checkedBaggage;
  final String seatInfo;
  final String imageUrl;
  final DateTime createdAt;

  bool get isPendingPayment => status == 'new' || status == 'pending';
  bool get isConfirmed => status == 'booked' || status == 'confirmed' || status == 'paid';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get statusLabel {
    if (status == 'paid' || status == 'confirmed') return 'Sudah Dibayar';
    if (status == 'booked') return 'Dikonfirmasi';
    if (isPendingPayment) return 'Menunggu Pembayaran';
    if (isCompleted) return 'Selesai';
    if (isCancelled) return 'Dibatalkan';
    return status;
  }

  /// Helper untuk tampilan E-Tiket & Detail Order presisi sesuai Figma
  String get bookingCode => 'TDI-$id';
  String get ticketNumber => '176-2400$id';

  String get originCode => 'CGK';
  String get originCity => 'Jakarta';

  String get destinationCode {
    if (route.toLowerCase().contains('tokyo') || packageName.toLowerCase().contains('japan') || packageName.toLowerCase().contains('jepang')) {
      return 'NRT';
    }
    return 'JED';
  }

  String get destinationCity {
    if (route.toLowerCase().contains('tokyo') || packageName.toLowerCase().contains('japan') || packageName.toLowerCase().contains('jepang')) {
      return 'Tokyo Narita';
    }
    return 'Jeddah';
  }

  String get transitInfo {
    if (airline.toLowerCase().contains('saudia')) return 'Penerbangan Langsung';
    return '1x transit · Dubai (DXB)';
  }

  String get flightCodePair => flightNumber.contains('·') ? flightNumber : 'EK 357 · EK 318';
  String get cabinClass => 'Ekonomi';
  String get seatNumber => seatInfo.contains('Disesuaikan') ? '32A' : seatInfo;
  String get baggageWeight => checkedBaggage.contains('Bagasi') ? checkedBaggage.replaceAll('Bagasi ', '') : '30 kg';

  String get whatsappGroupUrl => 'chat.whatsapp.com/JpD15Jan-Doaibu';
  String get tourLeaderName => 'Rizal Hakim';
  String get tourLeaderRole => 'Tour Leader · ${packageName.toLowerCase().contains('japan') ? 'Japan Discovery' : 'Umrah Reguler'}';
  String get paymentMethod => 'Virtual Account BSI';
  String get totalPaidFormatted => 'Rp 15.000.000';
  String get roomType => 'Double';
  String get returnDateFormatted => '21 Januari 2026';

  TicketOrder copyWith({
    String? id,
    String? route,
    String? packageName,
    String? status,
    String? airline,
    String? flightNumber,
    String? departureSchedule,
    String? flightRoute,
    String? departureAirport,
    String? arrivalAirport,
    String? arrivalSchedule,
    String? flightDuration,
    String? passengerName,
    String? passengerType,
    String? cabinBaggage,
    String? checkedBaggage,
    String? seatInfo,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return TicketOrder(
      id: id ?? this.id,
      route: route ?? this.route,
      packageName: packageName ?? this.packageName,
      status: status ?? this.status,
      airline: airline ?? this.airline,
      flightNumber: flightNumber ?? this.flightNumber,
      departureSchedule: departureSchedule ?? this.departureSchedule,
      flightRoute: flightRoute ?? this.flightRoute,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      arrivalSchedule: arrivalSchedule ?? this.arrivalSchedule,
      flightDuration: flightDuration ?? this.flightDuration,
      passengerName: passengerName ?? this.passengerName,
      passengerType: passengerType ?? this.passengerType,
      cabinBaggage: cabinBaggage ?? this.cabinBaggage,
      checkedBaggage: checkedBaggage ?? this.checkedBaggage,
      seatInfo: seatInfo ?? this.seatInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'route': route,
        'package_name': packageName,
        'status': status,
        'airline': airline,
        'flight_number': flightNumber,
        'departure_schedule': departureSchedule,
        'flight_route': flightRoute,
        'departure_airport': departureAirport,
        'arrival_airport': arrivalAirport,
        'arrival_schedule': arrivalSchedule,
        'flight_duration': flightDuration,
        'passenger_name': passengerName,
        'passenger_type': passengerType,
        'cabin_baggage': cabinBaggage,
        'checked_baggage': checkedBaggage,
        'seat_info': seatInfo,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
      };

  factory TicketOrder.fromJson(Map<String, dynamic> json) => TicketOrder(
        id: json['id'] as String,
        route: json['route'] as String,
        packageName: json['package_name'] as String,
        status: json['status'] as String? ?? 'new',
        airline: json['airline'] as String? ?? 'Emirates',
        flightNumber: json['flight_number'] as String? ?? 'EM 123',
        departureSchedule: json['departure_schedule'] as String? ?? '',
        flightRoute: json['flight_route'] as String? ?? '',
        departureAirport: json['departure_airport'] as String? ?? '',
        arrivalAirport: json['arrival_airport'] as String? ?? '',
        arrivalSchedule: json['arrival_schedule'] as String? ?? '',
        flightDuration: json['flight_duration'] as String? ?? 'Langsung',
        passengerName: json['passenger_name'] as String? ?? 'Jemaah',
        passengerType: json['passenger_type'] as String? ?? 'Dewasa',
        cabinBaggage: json['cabin_baggage'] as String? ?? 'Kabin 7 kg',
        checkedBaggage: json['checked_baggage'] as String? ?? 'Bagasi 20 kg',
        seatInfo: json['seat_info'] as String? ?? 'Kursi ... Disesuaikan',
        imageUrl: json['image_url'] as String? ?? '',
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      );
}

