import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// flutter_secure_storage's web backend encrypts values with the browser's
// WebCrypto SubtleCrypto API, which browsers only expose in a "secure
// context" (HTTPS, or the http://localhost exception) - see
// https://developer.mozilla.org/en-US/docs/Web/API/Crypto/subtle. Serving the
// app over plain http:// on a LAN IP (e.g. for testing on a phone) is not a
// secure context, so window.crypto.subtle is undefined there and every
// write()/read() throws a raw JS error. That error isn't a DioException, so
// AuthNotifier's error mapping had nothing to show but a generic failure -
// even though the login request itself had already succeeded. Web storage
// falls back to SharedPreferences (plain localStorage) instead: the "AES
// encryption" flutter_secure_storage_web provides is also stored key-and-all
// in localStorage right next to the ciphertext, so this is no less secure in
// practice, and it works regardless of secure-context status.
class SecureStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) => _write(_accessTokenKey, token);

  Future<void> saveRefreshToken(String token) => _write(_refreshTokenKey, token);

  Future<String?> readAccessToken() => _read(_accessTokenKey);

  Future<String?> readRefreshToken() => _read(_refreshTokenKey);

  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      return;
    }
    await _storage.deleteAll();
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _storage.read(key: key);
  }
}
