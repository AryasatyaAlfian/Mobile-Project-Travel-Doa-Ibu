import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/main.dart';
import 'package:mobile_project_doa_ibu/services/ticket_service.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/ticket_page.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/skeleton_view.dart';

void main() {
  setUp(() async {
    await TicketService.instance.resetSeed();
  });

  group('TicketService Unit Tests', () {
    test('membaca tiket bawaan seed dengan benar', () {
      final active = TicketService.instance.getActiveTickets();
      final history = TicketService.instance.getCompletedTickets();

      expect(active.length, greaterThanOrEqualTo(2));
      expect(history.length, greaterThanOrEqualTo(2));

      expect(active.any((t) => t.id == '981747' && t.isPendingPayment), isTrue);
      expect(active.any((t) => t.id == '452836' && t.isConfirmed), isTrue);
    });

    test('addBookingTicket menambahkan tiket baru dengan status new', () async {
      final newTicket = await TicketService.instance.addBookingTicket(
        packageName: 'Paket Umrah Plus Turki',
        customerName: 'Ahmad Dahlan',
        imageUrl: null,
      );

      expect(newTicket.status, 'new');
      expect(newTicket.isPendingPayment, isTrue);
      expect(newTicket.passengerName, 'Ahmad Dahlan');

      final active = TicketService.instance.getActiveTickets();
      expect(active.first.id, newTicket.id);
    });

    test('cancelTicket menghapus pesanan tiket', () async {
      await TicketService.instance.cancelTicket('981747');
      final active = TicketService.instance.getActiveTickets();
      expect(active.any((t) => t.id == '981747'), isFalse);
    });
  });

  group('TicketPage Widget Tests', () {
    testWidgets('menampilkan header dan 3 segmented tabs', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TicketPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tiket Saya'), findsWidgets);
      expect(find.text('Riwayat Order'), findsOneWidget);
      expect(find.text('Detail Order'), findsOneWidget);

      // Kartu pesanan aktif awal
      expect(find.text('Jakarta - Jeddah'), findsOneWidget);
      expect(find.text('Menunggu Pembayaran'), findsOneWidget);
      expect(find.text('E-tiket'), findsWidgets);
      expect(find.text('Bukti Pembayaran'), findsWidgets);
      expect(find.text('Lihat Detail'), findsWidgets);
    });

    testWidgets('menekan Bukti Pembayaran menampilkan dialog tanpa overflow pada nama paket panjang', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await TicketService.instance.addBookingTicket(
        packageName: 'Open Trip Labuan Bajo 3 Hari 2 Malam',
        customerName: 'test',
        imageUrl: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TicketPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tekan tombol Bukti Pembayaran pada tiket pertama
      await tester.tap(find.text('Bukti Pembayaran').first);
      await tester.pumpAndSettle();

      // Verifikasi dialog bukti pembayaran muncul tanpa overflow
      expect(find.text('Bukti Pembayaran'), findsWidgets);
      expect(find.text('Paket'), findsOneWidget);
      expect(find.text('Open Trip Labuan Bajo 3 Hari 2 Malam'), findsWidgets);
      expect(find.text('test'), findsOneWidget);
      expect(find.text('Transfer Bank / Midtrans'), findsOneWidget);

      // Tutup dialog
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('berpindah ke tab Riwayat Order dengan mulus', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TicketPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tekan tab Riwayat Order
      await tester.tap(find.text('Riwayat Order'));
      await tester.pumpAndSettle();

      // Badge 'Selesai' muncul pada daftar riwayat
      expect(find.text('Selesai'), findsWidgets);
    });

    testWidgets('menekan Lihat Detail berpindah ke Detail Order dan menampilkan rincian sesuai Gambar 2', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TicketPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tekan tombol Lihat Detail pertama
      await tester.tap(find.text('Lihat Detail').first);
      await tester.pumpAndSettle();

      // Masuk ke Detail Order (Gambar 2)
      expect(find.text('Grup WhatsApp Keberangkatan'), findsOneWidget);
      expect(find.text('Gabung Grup WhatsApp'), findsOneWidget);
      expect(find.text('Detail Penerbangan'), findsOneWidget);
      expect(find.text('Detail Pesanan'), findsOneWidget);
      expect(find.text('Pembayaran'), findsOneWidget);
      expect(find.text('Tour Leader'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('menekan riwayat order berpindah ke Halaman E-Tiket (Gambar 1)', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TicketPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pindah ke tab Riwayat Order
      await tester.tap(find.text('Riwayat Order'));
      await tester.pumpAndSettle();

      // Tekan item riwayat pertama
      await tester.tap(find.text('Paket Umrah Reguler 12 hari').first);
      await tester.pump();
      await tester.pumpAndSettle();

      // Verifikasi masuk ke Halaman E-Tiket (Gambar 1)
      expect(find.text('E-Tiket'), findsOneWidget);
      expect(find.text('CGK'), findsOneWidget);
      expect(find.text('Tunjukkan QR ini saat check-in di bandara'), findsOneWidget);
      expect(find.text('Bagikan'), findsOneWidget);
      expect(find.text('Unduh E-Tiket'), findsOneWidget);

      // Tekan tombol kembali
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Riwayat Order'), findsWidgets);
    });

    testWidgets('alur dialog pembatalan/penghapusan tiket', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TicketPage(initialTab: 2, initialTicketId: '981747'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tekan tombol Hapus/Batalkan Pesanan di Detail Order
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      // Dialog konfirmasi muncul
      expect(find.text('Batalkan Pesanan?'), findsOneWidget);
      expect(find.text('Ya, Batalkan'), findsOneWidget);

      // Konfirmasi pembatalan
      await tester.tap(find.text('Ya, Batalkan'));
      await tester.pumpAndSettle();

      // Tiket 981747 telah terhapus
      expect(TicketService.instance.getTickets().any((t) => t.id == '981747'), isFalse);
    });

    testWidgets('integrasi MainScreen dengan 4 item tab bottom navbar', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': [],
            'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final api = TravelApi(ApiClient(httpClient: mockClient, baseUrl: 'http://test/api/v1'));

      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(api: api),
        ),
      );
      await tester.pumpAndSettle();

      // Tekan ikon tiket di bottom navbar (index 1)
      final ticketNavFinder = find.byIcon(Icons.confirmation_num_outlined);
      expect(ticketNavFinder, findsOneWidget);

      await tester.tap(ticketNavFinder);
      await tester.pumpAndSettle();

      // Halaman TicketPage terbuka
      expect(find.byType(TicketPage), findsOneWidget);
      expect(find.text('Tiket Saya'), findsWidgets);
    });

    testWidgets('menampilkan skeleton loading saat isLoading = true', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TicketPage(isLoading: true),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SkeletonBox), findsWidgets);
    });

    testWidgets('membuka tab Detail Order langsung menampilkan daftar pilihan pesanan, lalu bisa memilih dan ganti pesanan', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TicketPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka tab Detail Order secara langsung lewat segment header
      await tester.tap(find.text('Detail Order'));
      await tester.pumpAndSettle();

      // Menampilkan daftar pilihan pesanan terlebih dahulu (bukan langsung detail satu tiket)
      expect(find.text('Pilih Pesanan'), findsOneWidget);
      expect(find.text('Pilih Detail'), findsWidgets);

      // Pilih pesanan pertama dari daftar pilihan
      await tester.tap(find.text('Pilih Detail').first);
      await tester.pumpAndSettle();

      // Menampilkan rincian lengkap Detail Order sesuai pesanan yang dipilih
      expect(find.text('Grup WhatsApp Keberangkatan'), findsOneWidget);
      expect(find.text('Ganti Pesanan'), findsOneWidget);

      // Tekan tombol Ganti Pesanan untuk kembali ke daftar pilihan pesanan
      await tester.tap(find.text('Ganti Pesanan'));
      await tester.pumpAndSettle();

      // Kembali ke tampilan pilihan pesanan
      expect(find.text('Pilih Pesanan'), findsOneWidget);
    });
  });
}

