enum SyncState { idle, watching, syncing, error }

class Game {
  final String id;
  final String name;
  final String slug;
  final String? exePath;
  final List<String> savePaths;
  final String? driveFolderId;
  final String platform; // pc | steam | epic
  final bool isActive;
  final DateTime? lastSyncedAt;
  final SyncState syncState;
  final int sizeBytes;

  const Game({
    required this.id,
    required this.name,
    required this.slug,
    this.exePath,
    this.savePaths = const [],
    this.driveFolderId,
    this.platform = 'pc',
    this.isActive = true,
    this.lastSyncedAt,
    this.syncState = SyncState.idle,
    this.sizeBytes = 0,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        exePath: json['exePath'] as String?,
        savePaths: (json['savePaths'] as List?)?.cast<String>() ?? [],
        driveFolderId: json['driveFolderId'] as String?,
        platform: json['platform'] as String? ?? 'pc',
        isActive: json['isActive'] as bool? ?? true,
        lastSyncedAt: json['lastSyncedAt'] != null
            ? DateTime.tryParse(json['lastSyncedAt'] as String)
            : null,
        sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'exePath': exePath,
        'savePaths': savePaths,
        'platform': platform,
      };

  Game copyWith({SyncState? syncState, DateTime? lastSyncedAt}) => Game(
        id: id,
        name: name,
        slug: slug,
        exePath: exePath,
        savePaths: savePaths,
        driveFolderId: driveFolderId,
        platform: platform,
        isActive: isActive,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        syncState: syncState ?? this.syncState,
        sizeBytes: sizeBytes,
      );

  String get formattedSize {
    if (sizeBytes <= 0) return '—';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = sizeBytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}
