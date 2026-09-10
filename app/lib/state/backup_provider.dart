import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../core/constants/api_endpoints.dart';
import '../core/models/backup.dart';
import '../core/services/api_client.dart';
import '../core/services/compress_service.dart';
import '../core/services/crypto_service.dart';
import '../core/services/drive_service.dart';

/// Owns backup history per game, active-sync flags, and Drive quota.
/// This is where the compress → encrypt → upload pipeline is triggered
/// from, and where restore reverses it.
class BackupProvider extends ChangeNotifier {
  final Map<String, List<Backup>> _backupsByGame = {};
  final Map<String, bool> _syncing = {};
  Map<String, int>? _driveQuota;

  List<Backup> gameBackups(String gameId) => _backupsByGame[gameId] ?? [];
  bool isSyncing(String gameId) => _syncing[gameId] ?? false;
  Map<String, int>? get driveQuota => _driveQuota;

  Future<void> fetchHistory(String gameId) async {
    final response = await ApiClient.instance.get(
      ApiConfig.backups,
      query: {'game_id': gameId, 'limit': 20},
    );
    final list = (response.data['backups'] as List)
        .map((j) => Backup.fromJson(j as Map<String, dynamic>))
        .toList();
    _backupsByGame[gameId] = list;
    notifyListeners();
  }

  /// Full upload pipeline for one save file:
  /// read → compress → encrypt → upload to Drive → record metadata.
  Future<void> backupNow({
    required String gameId,
    required String gameSlug,
    required String savePath,
    required String userId,
  }) async {
    _syncing[gameId] = true;
    notifyListeners();

    try {
      final file = File(savePath);
      final rawBytes = await file.readAsBytes();

      // Compress the save file
      final compressed = CompressService.instance.compress(rawBytes);

      // Encrypt the compressed data
      final encrypted = await CryptoService.instance.encrypt(compressed, userId);
      final checksum = CryptoService.instance.checksum(rawBytes);

      // Upload to Google Drive
      final fileName = p.basename(savePath);
      final driveFileId = await DriveService.instance.uploadFile(
        gameSlug: gameSlug,
        fileName: fileName,
        data: encrypted,
      );

      // Record metadata in backend
      await ApiClient.instance.post(ApiConfig.backups, data: {
        'gameId': gameId,
        'driveFileId': driveFileId,
        'fileName': fileName,
        'filePath': savePath,
        'sizeBytes': rawBytes.length,
        'compressedBytes': compressed.length,
        'checksum': checksum,
        'trigger': 'manual',
      });

      await fetchHistory(gameId);
    } finally {
      _syncing[gameId] = false;
      notifyListeners();
    }
  }

  /// Reverses the pipeline: download → decrypt → decompress → write to disk.
  Future<void> restore({
    required String backupId,
    required String savePath,
    required String userId,
  }) async {
    final response = await ApiClient.instance.get(ApiConfig.backup(backupId));
    final backup = Backup.fromJson(response.data as Map<String, dynamic>);

    // Download encrypted backup from Drive
    final encrypted = await DriveService.instance.downloadFile(backup.driveFileId);

    // Decrypt
    final compressed = await CryptoService.instance.decrypt(encrypted, userId);

    // Decompress back to original
    final plaintext = CompressService.instance.decompress(compressed);

    // Write to disk
    await File(savePath).writeAsBytes(plaintext);
  }

  Future<void> deleteBackup(String backupId, String gameId) async {
    await ApiClient.instance.delete(ApiConfig.backup(backupId));
    _backupsByGame[gameId] =
        gameBackups(gameId).where((b) => b.id != backupId).toList();
    notifyListeners();
  }

  Future<void> labelBackup(String backupId, String gameId, String label) async {
    await ApiClient.instance.post(ApiConfig.backupLabel(backupId), data: {'label': label});
    await fetchHistory(gameId);
  }

  Future<void> fetchQuota() async {
    _driveQuota = await DriveService.instance.getQuota();
    notifyListeners();
  }
}
