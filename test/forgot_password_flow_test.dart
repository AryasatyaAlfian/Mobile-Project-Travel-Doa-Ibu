import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/forgot_password_page.dart';

void main() {
  group('TravelApi Password Reset API Sync', () {
    test('requestPasswordReset memanggil /auth/password/forgot dengan email dan membaca resend_after', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/password/forgot'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'zara@traveldoaibu.test');
        return http.Response(
          jsonEncode({
            'message': 'Kode verifikasi berhasil dikirimkan.',
            'expires_in': 600,
            'resend_after': 60,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = TravelApi(ApiClient(httpClient: mock, baseUrl: 'http://test/api/v1'));
      final result = await api.requestPasswordReset('zara@traveldoaibu.test');
      expect(result['message'], 'Kode verifikasi berhasil dikirimkan.');
      expect(result['resend_after'], 60);
    });

    test('verifyPasswordResetOtp memanggil /auth/password/verify-otp dan mengembalikan reset_token', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/password/verify-otp'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'zara@traveldoaibu.test');
        expect(body['otp'], '123456');
        return http.Response(
          jsonEncode({
            'reset_token': 'secret_token_abc_123',
            'expires_in': 900,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = TravelApi(ApiClient(httpClient: mock, baseUrl: 'http://test/api/v1'));
      final token = await api.verifyPasswordResetOtp(email: 'zara@traveldoaibu.test', otp: '123456');
      expect(token, 'secret_token_abc_123');
    });

    test('resetPassword memanggil /auth/password/reset dengan reset_token dan password baru', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/password/reset'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'zara@traveldoaibu.test');
        expect(body['reset_token'], 'secret_token_abc_123');
        expect(body['password'], 'NewPassword123!');
        expect(body['password_confirmation'], 'NewPassword123!');
        return http.Response(
          jsonEncode({'message': 'Password berhasil diubah.'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = TravelApi(ApiClient(httpClient: mock, baseUrl: 'http://test/api/v1'));
      final message = await api.resetPassword(
        email: 'zara@traveldoaibu.test',
        resetToken: 'secret_token_abc_123',
        password: 'NewPassword123!',
        passwordConfirmation: 'NewPassword123!',
      );
      expect(message, 'Password berhasil diubah.');
    });
  });

  group('ForgotPasswordPage Widget Flow', () {
    testWidgets('alur penuh 5 langkah dengan 6 kotak OTP terhubung mulus', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/auth/password/forgot')) {
          return http.Response(
            jsonEncode({'message': 'Kode dikirim.', 'expires_in': 600, 'resend_after': 60}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/auth/password/verify-otp')) {
          return http.Response(
            jsonEncode({'reset_token': 'verified_token_xyz', 'expires_in': 900}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/auth/password/reset')) {
          return http.Response(
            jsonEncode({'message': 'Kata sandi berhasil diubah.'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final api = TravelApi(ApiClient(httpClient: mock, baseUrl: 'http://test/api/v1'));

      await tester.pumpWidget(MaterialApp(home: ForgotPasswordPage(api: api)));
      await tester.pumpAndSettle();

      // Step 1: Input Email
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Kirim Email'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'user@doaibu.test');
      await tester.tap(find.text('Kirim Email'));
      await tester.pumpAndSettle();

      // Step 2: Cek Email Anda
      expect(find.text('Cek Email Anda'), findsOneWidget);
      expect(find.text('Lanjutkan'), findsOneWidget);

      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Step 3: 6-Digit OTP Verification
      expect(find.text('6- Digit Verifikasi Kode'), findsOneWidget);
      final otpFields = find.byType(TextFormField);
      expect(otpFields, findsNWidgets(6));

      // Isi 6 digit OTP: 1, 2, 3, 4, 5, 6
      for (int i = 0; i < 6; i++) {
        await tester.enterText(otpFields.at(i), '${i + 1}');
      }
      await tester.pump();

      await tester.tap(find.text('Verifikasi Kode'));
      await tester.pumpAndSettle();

      // Step 4: Kata Sandi Baru
      expect(find.text('Kata Sandi Baru anda Harus Berbeda\ndari Kata Sandi anda Sebelumnya'), findsOneWidget);
      final passwordFields = find.byType(TextFormField);
      expect(passwordFields, findsNWidgets(2));

      await tester.enterText(passwordFields.at(0), 'Baru12345!');
      await tester.enterText(passwordFields.at(1), 'Baru12345!');
      await tester.tap(find.text('Reset Password').last);
      await tester.pumpAndSettle();

      // Step 5: Sukses
      expect(find.text('Kata Sandi Berhasil Diubah!'), findsOneWidget);
      expect(find.text('Masuk Sekarang'), findsOneWidget);
    });
  });
}
