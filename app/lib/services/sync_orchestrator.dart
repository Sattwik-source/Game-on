import 'dart:async';
import '../core/models/game.dart';
import '../core/services/file_watcher_service.dart';
import '../state/backup_provider.dart';

/// Orchestrates the automatic backup flow when save files change.
///
/// Responsibilities:
///   1. Start file watchers for all user's games
///   2. Batch rapid save changes (debounce)
///   3. Trigger backups via BackupProvider
///   4. Track sync state (idle → syncing → idle/error)
///   5. Handle retry logic on failure
class SyncOrchestrator {
  SyncOrchestrator._();
  static final SyncOrchestrator instance = SyncOrchestrator._();

  final Map<String, Timer> _batchTimers = {};
  final Map<String, Set<String>> _pendingPaths = {};

  static const _batchDelay = Duration(seconds: 5);
  static const _maxRetries = 3;

  /// Starts watching all games in the user's library.
  /// Called on app boot after games are fetched.
  void startWatchingAll({
    required List<Game> games,
    required BackupProvider backupProvider,
    required String userId,
  }) {
    for (final game in games) {
      startWatching(
        game: game,
        backupProvider: backupProvider,
        userId: userId,
      );
    }
  }

  /// Starts watching a single game's save paths.
  void startWatching({
    required Game game,
    required BackupProvider backupProvider,
    required String userId,
  }) {
    if (game.savePaths.isEmpty) return;

    FileWatcherService.instance.startWatching(
      gameId: game.id,
      savePaths: game.savePaths,
      onChange: (gameId, changedPath) {
        _onSaveChanged(
          gameId: gameId,
          gameSlug: game.slug,
          changedPath: changedPath,
          backupProvider: backupProvider,
          userId: userId,
        );
      },
    );
  }

  /// Called when a file change is detected. Batches rapid changes
  /// to avoid uploading multiple times per second.
  void _onSaveChanged({
    required String gameId,
    required String gameSlug,
    required String changedPath,
    required BackupProvider backupProvider,
    required String userId,
  }) {
    // Accumulate changed paths
    _pendingPaths.putIfAbsent(gameId, () => {});
    _pendingPaths[gameId]!.add(changedPath);

    // Cancel any pending batch for this game
    _batchTimers[gameId]?.cancel();

    // Schedule a new batch after debounce delay
    _batchTimers[gameId] = Timer(_batchDelay, () async {
      await _processBatch(
        gameId: gameId,
        gameSlug: gameSlug,
        paths: _pendingPaths[gameId]!.toList(),
        backupProvider: backupProvider,
        userId: userId,
      );

      _pendingPaths.remove(gameId);
      _batchTimers.remove(gameId);
    });
  }

  /// Processes a batch of changed save files and triggers a backup.
  Future<void> _processBatch({
    required String gameId,
    required String gameSlug,
    required List<String> paths,
    required BackupProvider backupProvider,
    required String userId,
    int attempt = 1,
  }) async {
    try {
      // For now, backup the first changed file.
      // In a more advanced implementation, you could:
      //   - Compress multiple files into one archive
      //   - Track which files changed and backup selectively
      if (paths.isEmpty) return;

      await backupProvider.backupNow(
        gameId: gameId,
        gameSlug: gameSlug,
        savePath: paths.first,
        userId: userId,
      );
    } catch (e) {
      if (attempt < _maxRetries) {
        // Exponential backoff: 5s, 10s, 20s
        final delaySeconds = 5 * (1 << (attempt - 1));
        await Future.delayed(Duration(seconds: delaySeconds));
        await _processBatch(
          gameId: gameId,
          gameSlug: gameSlug,
          paths: paths,
          backupProvider: backupProvider,
          userId: userId,
          attempt: attempt + 1,
        );
      } else {
        // Backup failed after max retries — could set error state here for UI
        rethrow;
      }
    }
  }

  /// Stops watching all games and clears pending batches.
  void stopAll() {
    FileWatcherService.instance.stopAll();
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();
    _pendingPaths.clear();
  }

  /// Stops watching a specific game.
  void stop(String gameId) {
    FileWatcherService.instance.stopWatching(gameId);
    _batchTimers[gameId]?.cancel();
    _batchTimers.remove(gameId);
    _pendingPaths.remove(gameId);
  }
}
