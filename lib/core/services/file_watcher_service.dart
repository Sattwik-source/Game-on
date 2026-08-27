import 'dart:async';
import 'dart:io';
import 'package:watcher/watcher.dart';

typedef SaveChangeCallback = void Function(String gameId, String changedPath);

/// Manages a `DirectoryWatcher` per registered game, debounces rapid
/// successive writes (games often write multiple files per save), and
/// invokes [SaveChangeCallback] once the dust settles.
///
/// This is the Dart equivalent of the Chokidar-based watcher in the
/// Electron version — same debounce contract, same ignore rules.
class FileWatcherService {
  FileWatcherService._();
  static final FileWatcherService instance = FileWatcherService._();

  final Map<String, List<StreamSubscription<WatchEvent>>> _subscriptions = {};
  final Map<String, Timer> _debounceTimers = {};

  static const _debounceDuration = Duration(seconds: 3);
  static final _ignoredSuffixes = ['.tmp', '.bak', '~'];

  /// Starts watching every path in [savePaths] for [gameId]. Fires
  /// [onChange] at most once per [_debounceDuration] window.
  void startWatching({
    required String gameId,
    required List<String> savePaths,
    required SaveChangeCallback onChange,
  }) {
    stopWatching(gameId);

    final subs = <StreamSubscription<WatchEvent>>[];

    for (final path in savePaths) {
      if (!Directory(path).existsSync() && !File(path).existsSync()) continue;

      final watcher = Directory(path).existsSync()
          ? DirectoryWatcher(path)
          : FileWatcher(path);

      final sub = watcher.events.listen((event) {
        if (_ignoredSuffixes.any((suffix) => event.path.endsWith(suffix))) {
          return;
        }
        _debounce(gameId, () => onChange(gameId, event.path));
      });

      subs.add(sub);
    }

    _subscriptions[gameId] = subs;
  }

  void _debounce(String gameId, void Function() action) {
    _debounceTimers[gameId]?.cancel();
    _debounceTimers[gameId] = Timer(_debounceDuration, action);
  }

  void stopWatching(String gameId) {
    _subscriptions[gameId]?.forEach((sub) => sub.cancel());
    _subscriptions.remove(gameId);
    _debounceTimers[gameId]?.cancel();
    _debounceTimers.remove(gameId);
  }

  void stopAll() {
    for (final gameId in _subscriptions.keys.toList()) {
      stopWatching(gameId);
    }
  }

  bool isWatching(String gameId) => _subscriptions.containsKey(gameId);
}
