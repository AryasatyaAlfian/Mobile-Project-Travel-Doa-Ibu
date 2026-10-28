import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Returns a freshly authenticated Google ID token, or null on user cancellation.
abstract interface class GoogleAuthService {
  Future<String?> authenticateIdToken();
}

/// Contains only safe, user-facing text; never raw SDK exception details.
class GoogleAuthException implements Exception {
  const GoogleAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Narrow SDK boundary: injectable without starting native account UI in tests.
abstract interface class GoogleAuthSdk {
  Future<void> initialize({required String serverClientId});
  bool supportsAuthenticate();
  Future<void> signOut();
  Future<String?> authenticateIdToken();
}

class GoogleSignInAuthService implements GoogleAuthService {
  GoogleSignInAuthService({required GoogleAuthSdk sdk}) : _sdk = sdk;

  /// Both auth pages use this one instance; initialize must run exactly once.
  static final GoogleAuthService instance = GoogleSignInAuthService(
    sdk: _GoogleSignInSdk(),
  );
  static const serverClientId =
      '405719934940-bel9ujgn18jgaiuhpivk17e9und4872a.apps.googleusercontent.com';

  final GoogleAuthSdk _sdk;
  Future<void>? _initialization;
  Future<String?>? _pending;

  static const _configurationError = GoogleAuthException(
    'Konfigurasi login Google belum sesuai. Hubungi pengelola aplikasi.',
  );
  static const _platformError = GoogleAuthException(
    'Layanan Google tidak tersedia di perangkat ini. Periksa Google Play Services.',
  );
  static const _unknownError = GoogleAuthException(
    'Gagal melakukan autentikasi Google. Silakan coba lagi.',
  );

  @override
  Future<String?> authenticateIdToken() =>
      _pending ??= _authenticate().whenComplete(() => _pending = null);

  Future<String?> _authenticate() async {
    try {
      // Keep even a failed initialization: the SDK forbids initializing twice.
      await (_initialization ??= Future<void>.sync(
        () => _sdk.initialize(serverClientId: serverClientId),
      ));
      if (!_sdk.supportsAuthenticate()) {
        throw const GoogleAuthException(
          'Login Google tidak didukung di platform ini.',
        );
      }
      // Reset local Google selection, not backend session or Google consent.
      // The official SDK recommends signing out before another authenticate.
      await _sdk.signOut();
      final token = await _sdk.authenticateIdToken();
      if (token == null || token.trim().isEmpty) {
        throw const GoogleAuthException(
          'Token Google tidak tersedia. Periksa konfigurasi login Google aplikasi.',
        );
      }
      return token;
    } on GoogleAuthException {
      rethrow;
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          return null;
        case GoogleSignInExceptionCode.clientConfigurationError:
          throw _configurationError;
        case GoogleSignInExceptionCode.providerConfigurationError:
        case GoogleSignInExceptionCode.uiUnavailable:
          throw _platformError;
        case GoogleSignInExceptionCode.interrupted:
          throw const GoogleAuthException(
            'Login Google terhenti. Silakan coba lagi.',
          );
        default:
          throw _unknownError;
      }
    } on MissingPluginException {
      throw _platformError;
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        throw const GoogleAuthException(
          'Tidak dapat terhubung ke Google. Periksa koneksi internet Anda.',
        );
      }
      throw _unknownError;
    } catch (_) {
      throw _unknownError;
    }
  }
}

class _GoogleSignInSdk implements GoogleAuthSdk {
  final GoogleSignIn _signIn = GoogleSignIn.instance;

  @override
  Future<void> initialize({required String serverClientId}) =>
      _signIn.initialize(serverClientId: serverClientId);

  @override
  bool supportsAuthenticate() => _signIn.supportsAuthenticate();

  @override
  Future<void> signOut() => _signIn.signOut();

  @override
  Future<String?> authenticateIdToken() async =>
      (await _signIn.authenticate()).authentication.idToken;
}
