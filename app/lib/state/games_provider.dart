import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import '../core/models/game.dart';
import '../core/services/api_client.dart';
import '../core/services/file_watcher_service.dart';
import '../core/services/game_detector_service.dart';

/// Holds the registered games list, the currently selected game (for
/// the detail panel), and drives auto-detection.
class GamesProvider extends ChangeNotifier {
  List<Game> _games = [];
  String? _selectedGameId;
  bool _loading = false;
  bool _detecting = false;
  List<DetectedGame> _detectedCandidates = [];

  List<Game> get games => _games;
  String? get selectedGameId => _selectedGameId;
  bool get loading => _loading;
  bool get detecting => _detecting;
  List<DetectedGame> get detectedCandidates => _detectedCandidates;

  Game? get selectedGame {
    if (_selectedGameId == null) return null;
    try {
      return _games.firstWhere((g) => g.id == _selectedGameId);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchGames() async {
    _loading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConfig.games);
      final list = (response.data['games'] as List)
          .map((j) => Game.fromJson(j as Map<String, dynamic>))
          .toList();
      _games = list;
      if (_selectedGameId == null && _games.isNotEmpty) {
        _selectedGameId = _games.first.id;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addGame(Game game, {required void Function(String, String) onSaveChange}) async {
    final response = await ApiClient.instance.post(ApiConfig.games, data: game.toJson());
    final created = Game.fromJson(response.data as Map<String, dynamic>);
    _games = [..._games, created];

    FileWatcherService.instance.startWatching(
      gameId: created.id,
      savePaths: created.savePaths,
      onChange: onSaveChange,
    );

    notifyListeners();
  }

  Future<void> removeGame(String id) async {
    await ApiClient.instance.delete(ApiConfig.game(id));
    FileWatcherService.instance.stopWatching(id);
    _games = _games.where((g) => g.id != id).toList();
    if (_selectedGameId == id) {
      _selectedGameId = _games.isNotEmpty ? _games.first.id : null;
    }
    notifyListeners();
  }

  Future<void> detectGames() async {
    _detecting = true;
    notifyListeners();
    try {
      _detectedCandidates = await GameDetectorService.instance.detectAll();
    } finally {
      _detecting = false;
      notifyListeners();
    }
  }

  void selectGame(String id) {
    _selectedGameId = id;
    notifyListeners();
  }

  void updateSyncState(String gameId, SyncState state) {
    _games = _games.map((g) {
      if (g.id == gameId) {
        return g.copyWith(
          syncState: state,
          lastSyncedAt: state == SyncState.idle ? DateTime.now() : null,
        );
      }
      return g;
    }).toList();
    notifyListeners();
  }
}
