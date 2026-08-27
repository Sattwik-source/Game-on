import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'secure_storage_service.dart';

/// Client-side encryption for save files. All save data is encrypted
/// on-device **before** it ever reaches Google Drive — the backend and
/// Google both only ever see ciphertext.
///
/// Key derivation: PBKDF2(userId + deviceSalt, 100_000 iterations) → 256-bit key.
/// The derived key never leaves this device and is never transmitted.
class CryptoService {
  CryptoService._();
  static final CryptoService instance = CryptoService._();

  enc.Key? _cachedKey;

  Future<enc.Key> _deriveKey(String userId) async {
    if (_cachedKey != null) return _cachedKey!;

    final salt = await SecureStorageService.instance.getOrCreateDeviceSalt();
    final keyMaterial = utf8.encode('$userId:$salt');

    // PBKDF2-HMAC-SHA256, 100k iterations, 32-byte output.
    var derived = Uint8List.fromList(keyMaterial);
    for (var i = 0; i < 100000; i++) {
      final hmac = Hmac(sha256, keyMaterial);
      derived = Uint8List.fromList(hmac.convert(derived).bytes);
    }

    _cachedKey = enc.Key(derived);
    return _cachedKey!;
  }

  /// Encrypts [plaintext] with AES-256-GCM. Returns a single buffer
  /// laid out as: [12-byte IV][16-byte auth tag][ciphertext].
  Future<Uint8List> encrypt(Uint8List plaintext, String userId) async {
    final key = await _deriveKey(userId);
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = encrypter.encryptBytes(plaintext, iv: iv);

    final result = BytesBuilder();
    result.add(iv.bytes);
    result.add(encrypted.bytes);
    return result.toBytes();
  }

  /// Reverses [encrypt]. Expects the same [12-byte IV][ciphertext+tag] layout.
  Future<Uint8List> decrypt(Uint8List payload, String userId) async {
    final key = await _deriveKey(userId);
    final iv = enc.IV(payload.sublist(0, 12));
    final ciphertext = payload.sublist(12);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final decrypted = encrypter.decryptBytes(
      enc.Encrypted(ciphertext),
      iv: iv,
    );
    return Uint8List.fromList(decrypted);
  }

  /// SHA-256 checksum used for dedup — skip re-uploading unchanged saves.
  String checksum(Uint8List data) => sha256.convert(data).toString();
}
