enum BackupStatus { pending, uploading, uploaded, failed }

enum BackupTrigger { auto, manual }

class Backup {
  final String id;
  final String gameId;
  final String driveFileId;
  final String? driveRevId;
  final String fileName;
  final int sizeBytes;
  final int compressedBytes;
  final String checksum;
  final String? label;
  final BackupTrigger trigger;
  final BackupStatus status;
  final DateTime createdAt;

  const Backup({
    required this.id,
    required this.gameId,
    required this.driveFileId,
    this.driveRevId,
    required this.fileName,
    this.sizeBytes = 0,
    this.compressedBytes = 0,
    this.checksum = '',
    this.label,
    this.trigger = BackupTrigger.auto,
    this.status = BackupStatus.uploaded,
    required this.createdAt,
  });

  factory Backup.fromJson(Map<String, dynamic> json) => Backup(
        id: json['id'] as String,
        gameId: json['gameId'] as String,
        driveFileId: json['driveFileId'] as String,
        driveRevId: json['driveRevId'] as String?,
        fileName: json['fileName'] as String,
        sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
        compressedBytes: (json['compressedBytes'] as num?)?.toInt() ?? 0,
        checksum: json['checksum'] as String? ?? '',
        label: json['label'] as String?,
        trigger: (json['trigger'] as String?) == 'manual'
            ? BackupTrigger.manual
            : BackupTrigger.auto,
        status: _statusFromString(json['status'] as String?),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  static BackupStatus _statusFromString(String? s) {
    switch (s) {
      case 'uploading':
        return BackupStatus.uploading;
      case 'failed':
        return BackupStatus.failed;
      case 'pending':
        return BackupStatus.pending;
      default:
        return BackupStatus.uploaded;
    }
  }
}
