import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

/// Wraps the Google Drive v3 API. Every save file GameOn uploads lives
/// in the user's own Drive under a `GameOn/<GameName>/` folder — this
/// service owns all of that folder/file management plus resumable
/// uploads, downloads, and revision history.
///
/// Scope used: `drive.file` only — GameOn can only see files/folders
/// it created itself, never the rest of the user's Drive.
class DriveService {
  DriveService._();
  static final DriveService instance = DriveService._();

  drive.DriveApi? _api;
  String? _rootFolderId;

  Future<drive.DriveApi> _client() async {
    if (_api != null) return _api!;

    final accessToken = await SecureStorageService.instance.getGoogleAccessToken();
    if (accessToken == null) {
      throw StateError('No Google access token — user must sign in first.');
    }

    final credentials = auth.AccessCredentials(
      auth.AccessToken('Bearer', accessToken,
          DateTime.now().toUtc().add(const Duration(hours: 1))),
      null,
      ['https://www.googleapis.com/auth/drive.file'],
    );

    final client = auth.authenticatedClient(http.Client(), credentials);
    _api = drive.DriveApi(client);
    return _api!;
  }

  /// Creates (or finds) the root `GameOn/` folder in the user's Drive.
  Future<String> ensureRootFolder() async {
    if (_rootFolderId != null) return _rootFolderId!;

    final api = await _client();
    final existing = await api.files.list(
      q: "name = 'GameOn' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
    );

    if (existing.files != null && existing.files!.isNotEmpty) {
      _rootFolderId = existing.files!.first.id;
      return _rootFolderId!;
    }

    final folder = drive.File()
      ..name = 'GameOn'
      ..mimeType = 'application/vnd.google-apps.folder';
    final created = await api.files.create(folder);
    _rootFolderId = created.id;
    return _rootFolderId!;
  }

  /// Creates (or finds) a per-game subfolder under `GameOn/`.
  Future<String> ensureGameFolder(String gameSlug) async {
    final api = await _client();
    final root = await ensureRootFolder();

    final existing = await api.files.list(
      q: "name = '$gameSlug' and '$root' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
    );

    if (existing.files != null && existing.files!.isNotEmpty) {
      return existing.files!.first.id!;
    }

    final folder = drive.File()
      ..name = gameSlug
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [root];
    final created = await api.files.create(folder);
    return created.id!;
  }

  /// Uploads an already-compressed-and-encrypted buffer.
  /// Returns the Drive file ID.
  Future<String> uploadFile({
    required String gameSlug,
    required String fileName,
    required Uint8List data,
  }) async {
    final api = await _client();
    final folderId = await ensureGameFolder(gameSlug);

    final media = drive.Media(Stream.value(data), data.length);
    final fileMetadata = drive.File()
      ..name = fileName
      ..parents = [folderId];

    final result = await api.files.create(fileMetadata, uploadMedia: media);
    return result.id!;
  }

  Future<Uint8List> downloadFile(String fileId) async {
    final api = await _client();
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final chunks = <int>[];
    await for (final chunk in media.stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  Future<List<drive.Revision>> listRevisions(String fileId) async {
    final api = await _client();
    final result = await api.revisions.list(fileId);
    return result.revisions ?? [];
  }

  Future<void> deleteFile(String fileId) async {
    final api = await _client();
    await api.files.delete(fileId);
  }

  /// Returns { usedBytes, totalBytes } from the user's Drive quota.
  Future<Map<String, int>> getQuota() async {
    final api = await _client();
    final about = await api.about.get($fields: 'storageQuota');
    return {
      'used': int.tryParse(about.storageQuota?.usage ?? '0') ?? 0,
      'total': int.tryParse(about.storageQuota?.limit ?? '0') ?? 0,
    };
  }
}
