import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

/// Wraps [FlutterSecureStorage] to persist auth tokens and the cached
/// user profile in the OS-native secure store:
///   • Windows  → Credential Manager (DPAPI)
///   • macOS    → Keychain
///   • Linux    → Secret Service (libsecret)
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  final _storage = const FlutterSecureStorage(
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
    lOptions: LinuxOptions(),
  );

  static const _kAccessToken  = 'gameon_access_token';
  static const _kRefreshToken = 'gameon_refresh_token';
  static const _kUser         = 'gameon_user';
  static const _kGoogleAccess = 'gameon_google_access_token';
  static const _kGoogleRefresh = 'gameon_google_refresh_token';
  static const _kDeviceSalt   = 'gameon_device_salt';

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> saveGoogleTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _kGoogleAccess, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _kGoogleRefresh, value: refreshToken);
    }
  }

  Future<String?> getGoogleAccessToken() => _storage.read(key: _kGoogleAccess);
  Future<String?> getGoogleRefreshToken() => _storage.read(key: _kGoogleRefresh);

  Future<void> saveUser(User user) =>
      _storage.write(key: _kUser, value: jsonEncode(user.toJson()));

  Future<User?> getUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Per-device random salt used for PBKDF2 key derivation in [CryptoService].
  /// Generated once and persisted — never transmitted anywhere.
  Future<String> getOrCreateDeviceSalt() async {
    var salt = await _storage.read(key: _kDeviceSalt);
    if (salt == null) {
      salt = DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
          (1000 + DateTime.now().millisecond).toRadixString(16);
      await _storage.write(key: _kDeviceSalt, value: salt);
    }
    return salt;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
