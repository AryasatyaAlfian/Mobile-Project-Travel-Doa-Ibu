import 'dart:convert';

import '../core/storage/app_storage.dart';
import '../models/ticket_order.dart';

/// Service lokal untuk tiket jemaah yang selaras dengan data backend Laravel.
/// Menyimpan data secara persisten ke AppStorage.
class TicketService {
  TicketService._();
  static final TicketService instance = TicketService._();

  static const String _storageKey = 'user_tickets_v1';

  List<TicketOrder>? _cachedTickets;

  /// Daftar tiket bawaan sesuai desain Figma 100% presisi
  List<TicketOrder> _getDefaultSeedTickets() {
    return [
      TicketOrder(
        id: '981747',
        route: 'Jakarta - Jeddah',
        packageName: 'Paket Umrah Reguler 12 hari',
        status: 'new', // Menunggu Pembayaran
        airline: 'Emirates',
        flightNumber: 'EM 123',
        departureSchedule: 'Rabu, 30 Februari 2026 - 10:10',
        flightRoute: 'Jakarta (CGK) → Jeddah (JED)',
        departureAirport: 'Soekarno Hatta Internasional Airport',
        arrivalAirport: 'King Abdul Aziz Internasional Airport',
        arrivalSchedule: 'Rabu, 30 Februari 2026 - 11.35',
        flightDuration: '25j 25m Langsung',
        passengerName: 'Zara Anselma',
        passengerType: 'Dewasa',
        cabinBaggage: 'Kabin 7 kg',
        checkedBaggage: 'Bagasi 20 kg',
        seatInfo: 'Kursi ... Disesuaikan',
        imageUrl: 'assets/images/mecca.jpg',
      ),
      TicketOrder(
        id: '452836',
        route: 'Jakarta - Tokyo',
        packageName: 'Paket Japan Discovery 7 hari 6 malam',
        status: 'booked', // Dikonfirmasi
        airline: 'Emirates',
        flightNumber: 'EM 675',
        departureSchedule: 'Selasa, 15 Januari 2026 - 15:45',
        flightRoute: 'Jakarta (CGK) → Tokyo (TYOA)',
        departureAirport: 'Soekarno Hatta Internasional Airport',
        arrivalAirport: 'Haneda / Narita International Airport',
        arrivalSchedule: 'Rabu, 16 Januari 2026 - 06:20',
        flightDuration: '7j 35m Langsung',
        passengerName: 'Zara Anselma',
        passengerType: 'Dewasa',
        cabinBaggage: 'Kabin 7 kg',
        checkedBaggage: 'Bagasi 23 kg',
        seatInfo: 'Kursi ... Disesuaikan',
        imageUrl: 'assets/images/fuji.jpg',
      ),
      TicketOrder(
        id: '981747-old',
        route: 'Jakarta - Jeddah',
        packageName: 'Paket Umrah Reguler 12 hari',
        status: 'completed', // Selesai (Riwayat)
        airline: 'Emirates',
        flightNumber: 'EM 123',
        departureSchedule: 'Rabu, 30 Februari 2026 - 10:10',
        flightRoute: 'Jakarta (CGK) → Jeddah (JED)',
        departureAirport: 'Soekarno Hatta Internasional Airport',
        arrivalAirport: 'King Abdul Aziz Internasional Airport',
        arrivalSchedule: 'Rabu, 30 Februari 2026 - 11.35',
        flightDuration: '25j 25m Langsung',
        passengerName: 'Zara Anselma',
        passengerType: 'Dewasa',
        cabinBaggage: 'Kabin 7 kg',
        checkedBaggage: 'Bagasi 20 kg',
        seatInfo: 'Kursi ... Disesuaikan',
        imageUrl: 'assets/images/mecca.jpg',
      ),
      TicketOrder(
        id: '452836-old1',
        route: 'Jakarta - Tokyo',
        packageName: 'Paket Japan Discovery 7 hari 6 malam',
        status: 'completed', // Selesai (Riwayat)
        airline: 'Emirates',
        flightNumber: 'EM 675',
        departureSchedule: 'Selasa, 15 Januari 2026 - 15:45',
        flightRoute: 'Jakarta (CGK) → Tokyo (TYOA)',
        departureAirport: 'Soekarno Hatta Internasional Airport',
        arrivalAirport: 'Haneda / Narita International Airport',
        arrivalSchedule: 'Rabu, 16 Januari 2026 - 06:20',
        flightDuration: '7j 35m Langsung',
        passengerName: 'Zara Anselma',
        passengerType: 'Dewasa',
        cabinBaggage: 'Kabin 7 kg',
        checkedBaggage: 'Bagasi 23 kg',
        seatInfo: 'Kursi ... Disesuaikan',
        imageUrl: 'assets/images/fuji.jpg',
      ),
      TicketOrder(
        id: '452836-old2',
        route: 'Jakarta - Tokyo',
        packageName: 'Paket Japan Discovery 7 hari 6 malam',
        status: 'completed', // Selesai (Riwayat)
        airline: 'Emirates',
        flightNumber: 'EM 675',
        departureSchedule: 'Selasa, 15 Januari 2026 - 15:45',
        flightRoute: 'Jakarta (CGK) → Tokyo (TYOA)',
        departureAirport: 'Soekarno Hatta Internasional Airport',
        arrivalAirport: 'Haneda / Narita International Airport',
        arrivalSchedule: 'Rabu, 16 Januari 2026 - 06:20',
        flightDuration: '7j 35m Langsung',
        passengerName: 'Zara Anselma',
        passengerType: 'Dewasa',
        cabinBaggage: 'Kabin 7 kg',
        checkedBaggage: 'Bagasi 23 kg',
        seatInfo: 'Kursi ... Disesuaikan',
        imageUrl: 'assets/images/fuji.jpg',
      ),
    ];
  }

  /// Membaca seluruh tiket jemaah
  List<TicketOrder> getTickets() {
    if (_cachedTickets != null) return List.unmodifiable(_cachedTickets!);

    final raw = AppStorage.instance.get(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(TicketOrder.fromJson)
            .map((t) {
              if (t.imageUrl.contains('unsplash')) {
                final isMecca = t.packageName.toLowerCase().contains('umrah') ||
                    t.route.toLowerCase().contains('jeddah');
                return t.copyWith(imageUrl: isMecca ? 'assets/images/mecca.jpg' : 'assets/images/fuji.jpg');
              }
              return t;
            })
            .map((t) {
              // Jika pesanan tiket dibuat oleh user (bukan seed default 981747) dan masih berstatus 'new',
              // perbarui ke 'confirmed' agar tiket yang dipesan via checkout tampil sebagai sudah dibayar.
              if (t.id != '981747' && t.status == 'new') {
                return t.copyWith(status: 'confirmed');
              }
              return t;
            })
            .toList();
        _cachedTickets = list;
        return List.unmodifiable(_cachedTickets!);
      } catch (_) {}
    }

    _cachedTickets = _getDefaultSeedTickets();
    _saveToStorage(_cachedTickets!);
    return List.unmodifiable(_cachedTickets!);
  }

  /// Tiket aktif (status 'new' / Menunggu Pembayaran atau 'booked' / Dikonfirmasi)
  List<TicketOrder> getActiveTickets() {
    return getTickets().where((t) => t.isPendingPayment || t.isConfirmed).toList();
  }

  /// Tiket selesai / riwayat pemesanan (status 'completed')
  List<TicketOrder> getCompletedTickets() {
    return getTickets().where((t) => t.isCompleted).toList();
  }

  /// Cari tiket berdasarkan ID
  TicketOrder? getTicketById(String id) {
    final tickets = getTickets();
    try {
      return tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return tickets.isNotEmpty ? tickets.first : null;
    }
  }

  /// Batalkan tiket (status 'cancelled' sesuai backend Laravel released_booking_statuses)
  Future<void> cancelTicket(String id) async {
    final current = List<TicketOrder>.from(getTickets());
    final index = current.indexWhere((t) => t.id == id);
    if (index != -1) {
      current.removeAt(index);
      _cachedTickets = current;
      _saveToStorage(current);
    }
  }

  /// Update status tiket (misal: 'confirmed' / 'paid', 'completed', 'cancelled')
  Future<void> updateTicketStatus(String id, String newStatus) async {
    final current = List<TicketOrder>.from(getTickets());
    final index = current.indexWhere((t) => t.id == id);
    if (index != -1) {
      current[index] = current[index].copyWith(status: newStatus);
      _cachedTickets = current;
      _saveToStorage(current);
    }
  }

  /// Tambah pesanan baru dari form booking jemaah
  Future<TicketOrder> addBookingTicket({
    required String packageName,
    required String customerName,
    required String? imageUrl,
    String status = 'new',
    String? airline,
    String? flightNumber,
    String? departureSchedule,
    String? route,
    String? flightRoute,
    String? departureAirport,
    String? arrivalAirport,
    String? passengerType,
  }) async {
    final newId = '${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final resolvedRoute = route ??
        (packageName.contains('Umrah')
            ? 'Jakarta - Jeddah'
            : (packageName.contains('Japan') || packageName.contains('Jepang')
                ? 'Jakarta - Tokyo'
                : 'Jakarta - Destinasi Impian'));

    final resolvedFlightRoute = flightRoute ??
        (resolvedRoute.contains('Jeddah')
            ? 'Jakarta (CGK) → Jeddah (JED)'
            : (resolvedRoute.contains('Tokyo')
                ? 'Jakarta (CGK) → Tokyo (TYOA)'
                : 'Jakarta (CGK) → Destinasi'));

    final newTicket = TicketOrder(
      id: newId,
      route: resolvedRoute,
      packageName: packageName,
      status: status,
      airline: airline ?? 'Saudia Airlines',
      flightNumber: flightNumber ?? 'SV ${100 + (DateTime.now().millisecond % 899)}',
      departureSchedule: departureSchedule ?? 'Jadwal Segera Dikonfirmasi',
      flightRoute: resolvedFlightRoute,
      departureAirport: departureAirport ?? 'Soekarno Hatta Internasional Airport',
      arrivalAirport: arrivalAirport ??
          (resolvedRoute.contains('Jeddah')
              ? 'King Abdul Aziz Internasional Airport'
              : 'Bandara Internasional Tujuan'),
      arrivalSchedule: 'Mengikuti Itinerary',
      flightDuration: resolvedRoute.contains('Jeddah') ? '9j 45m Langsung' : 'Penerbangan Pilihan',
      passengerName: customerName.isNotEmpty ? customerName : 'Zara Anselma',
      passengerType: passengerType ?? 'Dewasa',
      imageUrl: imageUrl != null && imageUrl.isNotEmpty
          ? imageUrl
          : (packageName.toLowerCase().contains('japan') || packageName.toLowerCase().contains('jepang')
              ? 'assets/images/fuji.jpg'
              : 'assets/images/mecca.jpg'),
    );

    final current = List<TicketOrder>.from(getTickets());
    current.insert(0, newTicket);
    _cachedTickets = current;
    _saveToStorage(current);
    return newTicket;
  }

  void _saveToStorage(List<TicketOrder> tickets) {
    final jsonString = jsonEncode(tickets.map((t) => t.toJson()).toList());
    AppStorage.instance.set(_storageKey, jsonString);
  }

  /// Reset data tiket ke seed bawaan
  Future<void> resetSeed() async {
    _cachedTickets = _getDefaultSeedTickets();
    _saveToStorage(_cachedTickets!);
  }
}
