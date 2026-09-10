import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Handles compression of save files before encryption.
/// Uses GZIP compression (compatible with archive package on all platforms).
///
/// The compression pipeline:
///   1. Read save file(s) from disk
///   2. Compress with gzip (ratio ~2-10x depending on file type)
///   3. Pass compressed bytes to CryptoService for encryption
///   4. Upload encrypted payload to Google Drive
///
/// For decompression, the flow reverses:
///   1. Download from Drive
///   2. Decrypt (CryptoService)
///   3. Decompress here
///   4. Write to disk
class CompressService {
  CompressService._();
  static final CompressService instance = CompressService._();

  /// Compresses raw save file bytes with gzip.
  /// Returns the compressed payload.
  Uint8List compress(Uint8List rawBytes) {
    final compressed = GZipEncoder().encode(rawBytes);
    if (compressed == null) {
      throw StateError('Compression failed');
    }
    return Uint8List.fromList(compressed);
  }

  /// Decompresses a gzip payload back to raw bytes.
  /// Called after decryption during restore.
  Uint8List decompress(Uint8List compressedBytes) {
    final decompressed = GZipDecoder().decodeBytes(compressedBytes);
    return Uint8List.fromList(decompressed);
  }

  /// Useful stat: estimate compression ratio before uploading.
  double estimateRatio(int originalBytes, int compressedBytes) {
    if (originalBytes == 0) return 0;
    return (1 - (compressedBytes / originalBytes)) * 100;
  }
}
