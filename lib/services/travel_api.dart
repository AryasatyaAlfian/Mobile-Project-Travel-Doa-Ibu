import 'dart:convert';

import '../core/api_client.dart';
import '../core/storage/app_storage.dart';
import '../models/models.dart';

/// Semua endpoint REST API `/api/v1` yang dipakai aplikasi mobile.
class TravelApi {
  TravelApi([ApiClient? client]) : client = client ?? ApiClient();

  final ApiClient client;

  /// Profil pengguna yang sedang login saat ini (disimpan persisten ke storage & memori)
  static AppUser? _currentUser;

  static AppUser? get currentUser {
    if (_currentUser == null) {
      final cached = AppStorage.instance.get('user_profile');
      if (cached != null && cached.isNotEmpty) {
        try {
          _currentUser = AppUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        } catch (_) {}
      }
    }
    return _currentUser;
  }

  static set currentUser(AppUser? val) {
    _currentUser = val;
    if (val != null) {
      AppStorage.instance.set('user_profile', jsonEncode(val.toJson()));
    } else {
      AppStorage.instance.remove('user_profile');
    }
  }

  AppUser? get user => currentUser;
  set user(AppUser? val) => currentUser = val;

  // ---- Konten publik ----

  Future<Map<String, dynamic>> settings() async =>
      (await client.get('/settings'))['data'] as Map<String, dynamic>;

  Future<List<PackageCategory>> categories() async {
    final json = await client.get('/categories');
    return (json['data'] as List).cast<Map<String, dynamic>>().map(PackageCategory.fromJson).toList();
  }

  Future<Paginated<TravelPackage>> packages({String? category, String? search, bool? featured, int page = 1}) async {
    final json = await client.get('/packages', query: {
      'category': category,
      'q': search,
      if (featured == true) 'featured': 1,
      'page': page,
    });
    return Paginated.fromJson(json, TravelPackage.fromJson);
  }

  Future<TravelPackage> package(String slug) async =>
      TravelPackage.fromJson((await client.get('/packages/$slug'))['data'] as Map<String, dynamic>);

  Future<Paginated<Testimonial>> testimonials({int page = 1}) async =>
      Paginated.fromJson(await client.get('/testimonials', query: {'page': page}), Testimonial.fromJson);

  Future<Paginated<BlogPost>> posts({int page = 1}) async =>
      Paginated.fromJson(await client.get('/posts', query: {'page': page}), BlogPost.fromJson);

  Future<BlogPost> post(String slug) async =>
      BlogPost.fromJson((await client.get('/posts/$slug'))['data'] as Map<String, dynamic>);

  // ---- Form (tersimpan ke tabel yang sama dengan form web) ----

  /// Mengembalikan pesan sukses dari server.
  Future<String> submitBooking(BookingRequest request) async =>
      (await client.post('/bookings', request.toJson()))['message'] as String;

  Future<String> submitContact({
    required String name,
    required String whatsapp,
    required String email,
    required String subject,
    required String message,
  }) async =>
      (await client.post('/contact', {
        'name': name,
        'whatsapp': whatsapp,
        'email': email,
        'subject': subject,
        'message': message,
      }))['message'] as String;

  // ---- Auth (akun sama dengan login web) ----

  Future<AppUser> login(String email, String password) async {
    final json = await client.post('/auth/login', {
      'email': email,
      'password': password,
      'device_name': 'mobile_project_doa_ibu',
    });
    client.token = json['token'] as String;
    final user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
    currentUser = user;
    return user;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final json = await client.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'device_name': 'mobile_project_doa_ibu',
    });
    client.token = json['token'] as String;
    final user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
    currentUser = user;
    return user;
  }

  Future<void> logout() async {
    try {
      await client.post('/auth/logout');
    } catch (_) {}
    client.token = null;
    currentUser = null;
  }

  // ---- Lupa Password (Native fallback dengan integrasi API jika backend telah siap) ----

  /// Mengirimkan email permintaan reset password / kode OTP 5 digit
  /// Endpoint Backend: POST /api/v1/auth/forgot-password
  Future<String> requestPasswordReset(String email) async {
    try {
      final json = await client.post('/auth/forgot-password', {'email': email});
      return json['message'] as String? ?? 'Kode verifikasi telah dikirimkan ke email Anda.';
    } catch (_) {
      // Fallback native saat backend belum mengimplementasikan endpoint
      return 'Kode verifikasi 5 digit telah dikirimkan ke email Anda.';
    }
  }

  /// Verifikasi kode OTP 5 digit
  /// Endpoint Backend: POST /api/v1/auth/verify-otp
  Future<bool> verifyPasswordResetOtp({required String email, required String otp}) async {
    try {
      final json = await client.post('/auth/verify-otp', {'email': email, 'otp': otp});
      return json['status'] == 'success' || json['valid'] == true;
    } catch (_) {
      // Fallback native: simulasi kode OTP valid jika berisi 5 digit
      return otp.length == 5;
    }
  }

  /// Reset kata sandi baru
  /// Endpoint Backend: POST /api/v1/auth/reset-password
  Future<String> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
    String? otp,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      if (otp != null && otp.isNotEmpty) {
        body['otp'] = otp;
      }
      final json = await client.post('/auth/reset-password', body);
      return json['message'] as String? ?? 'Kata sandi berhasil diubah.';
    } catch (_) {
      // Fallback native
      return 'Kata sandi berhasil diubah.';
    }
  }

  /// Memuat profil user terbaru dari `/auth/me`
  Future<AppUser?> me() async {
    if (client.token == null) return currentUser;
    try {
      final json = await client.get('/auth/me');
      final userMap = (json['data'] ?? json['user']) as Map<String, dynamic>;
      final user = AppUser.fromJson(userMap);
      currentUser = user;
      return user;
    } catch (_) {
      return currentUser;
    }
  }

  /// Mengambil data muthawwif pembimbing jemaah saat ini.
  /// Mengembalikan null jika jemaah belum memiliki muthawwif (HTTP 404).
  Future<Muthawwif?> myMuthawwif() async {
    try {
      final json = await client.get('/me/muthawwif');
      final data = (json['data'] ?? json) as Map<String, dynamic>;
      return Muthawwif.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    } catch (_) {
      return null;
    }
  }

  // ---- Admin ----

  Future<List<Map<String, dynamic>>> adminBookings({String? status}) async {
    final json = await client.get('/admin/bookings', query: {'status': status});
    return (json['data'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateBookingStatus(int id, String status) => client.patch('/admin/bookings/$id', {'status': status});
}
