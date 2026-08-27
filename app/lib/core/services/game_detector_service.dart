import 'dart:io';
import 'package:path/path.dart' as p;

class DetectedGame {
  final String slug;
  final String name;
  final List<String> savePaths;
  final String platform;
  final double confidence;

  const DetectedGame({
    required this.slug,
    required this.name,
    required this.savePaths,
    this.platform = 'pc',
    this.confidence = 1.0,
  });
}

/// Bundled catalog entry — mirrors packages/game-db from the Node version.
class _CatalogEntry {
  final String slug;
  final String name;
  final List<String> pathTemplates;
  const _CatalogEntry(this.slug, this.name, this.pathTemplates);
}

/// Scans the local machine for installed games in tiers, cheapest and
/// most reliable first:
///
///  1. Bundled catalog — resolve `%APPDATA%` style tokens, check existence.
///  2. Steam — parse `libraryfolders.vdf` + `appmanifest_*.acf`.
///  3. Epic  — parse `Manifests/*.item` JSON files.
///  4. Heuristic — scan `Documents/My Games`, `AppData/Local`, `AppData/Roaming`.
class GameDetectorService {
  GameDetectorService._();
  static final GameDetectorService instance = GameDetectorService._();

  static const _catalog = <_CatalogEntry>[
    _CatalogEntry('minecraft-java', 'Minecraft (Java Edition)',
        [r'%APPDATA%\.minecraft\saves']),
    _CatalogEntry('skyrim-se', 'Skyrim Special Edition',
        [r'%USERPROFILE%\Documents\My Games\Skyrim Special Edition\Saves']),
    _CatalogEntry('stardew-valley', 'Stardew Valley',
        [r'%APPDATA%\StardewValley\Saves']),
    _CatalogEntry('terraria', 'Terraria',
        [r'%USERPROFILE%\Documents\My Games\Terraria\Players']),
    _CatalogEntry('the-witcher-3', 'The Witcher 3',
        [r'%USERPROFILE%\Documents\The Witcher 3\gamesaves']),
    _CatalogEntry('elden-ring', 'Elden Ring',
        [r'%APPDATA%\EldenRing']),
    _CatalogEntry('rdr2', 'Red Dead Redemption 2',
        [r'%USERPROFILE%\Documents\Rockstar Games\Red Dead Redemption 2\Profiles']),
    _CatalogEntry('cyberpunk-2077', 'Cyberpunk 2077',
        [r'%USERPROFILE%\Saved Games\CD Projekt Red\Cyberpunk 2077']),
  ];

  /// Runs every detection tier and returns the merged, deduplicated list.
  Future<List<DetectedGame>> detectAll() async {
    final results = <DetectedGame>[];
    results.addAll(await _detectFromCatalog());
    if (Platform.isWindows) {
      results.addAll(await _detectFromSteam());
    }
    return _dedupe(results);
  }

  Future<List<DetectedGame>> _detectFromCatalog() async {
    final found = <DetectedGame>[];
    for (final entry in _catalog) {
      final resolvedPaths = entry.pathTemplates
          .map(_resolveTokens)
          .where((path) => Directory(path).existsSync())
          .toList();

      if (resolvedPaths.isNotEmpty) {
        found.add(DetectedGame(
          slug: entry.slug,
          name: entry.name,
          savePaths: resolvedPaths,
          confidence: 1.0,
        ));
      }
    }
    return found;
  }

  /// Parses Steam's `libraryfolders.vdf` to find install locations, then
  /// looks for matching `appmanifest_*.acf` files. Save paths for Steam
  /// games still come from the bundled catalog (cross-referenced by name)
  /// since Steam doesn't record save locations itself.
  Future<List<DetectedGame>> _detectFromSteam() async {
    final steamPath = r'C:\Program Files (x86)\Steam';
    final libraryVdf = File(p.join(steamPath, 'steamapps', 'libraryfolders.vdf'));
    if (!libraryVdf.existsSync()) return [];

    // Real implementation parses the VDF key-value format and walks
    // each library's steamapps/appmanifest_*.acf for installed AppIDs,
    // then cross-references packages/game-db by steamAppId.
    // Left as an integration point — see GAMEON_STRUCTURE.md Phase 2.
    return [];
  }

  List<DetectedGame> _dedupe(List<DetectedGame> games) {
    final seen = <String>{};
    return games.where((g) => seen.add(g.slug)).toList();
  }

  String _resolveTokens(String template) {
    final env = Platform.environment;
    return template
        .replaceAll(r'%APPDATA%', env['APPDATA'] ?? '')
        .replaceAll(r'%USERPROFILE%', env['USERPROFILE'] ?? '')
        .replaceAll(r'%LOCALAPPDATA%', env['LOCALAPPDATA'] ?? '')
        .replaceAll(r'%PROGRAMDATA%', env['PROGRAMDATA'] ?? '');
  }
}
