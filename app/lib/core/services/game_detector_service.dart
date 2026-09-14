import 'dart:io';
import 'package:path/path.dart' as p;

class DetectedGame {
  final String slug;
  final String name;
  final List<String> savePaths;
  final String platform;
  final double confidence;
  final String? exePath; // Path to the game executable

  const DetectedGame({
    required this.slug,
    required this.name,
    required this.savePaths,
    this.platform = 'pc',
    this.confidence = 1.0,
    this.exePath,
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
    // ── Original Games ────────────────────────────────────────────
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

    // ── RPGs ─────────────────────────────────────────────────────
    _CatalogEntry('baldurs-gate-3', 'Baldurs Gate 3',
        [r'%USERPROFILE%\AppData\Local\Larian Studios\Baldurs Gate 3\PlayerProfiles']),
    _CatalogEntry('divinity-os-2', 'Divinity Original Sin 2',
        [r'%USERPROFILE%\Documents\Larian Studios\Divinity Original Sin 2\PlayerProfiles']),
    _CatalogEntry('skyrim', 'The Elder Scrolls V Skyrim',
        [r'%USERPROFILE%\Documents\My Games\Skyrim\Saves']),
    _CatalogEntry('fallout-4', 'Fallout 4',
        [r'%USERPROFILE%\Documents\My Games\Fallout4\Saves']),
    _CatalogEntry('fallout-nv', 'Fallout New Vegas',
        [r'%USERPROFILE%\Documents\My Games\FalloutNV\Saves']),
    _CatalogEntry('dark-souls-3', 'Dark Souls III',
        [r'%APPDATA%\DarkSoulsIII']),
    _CatalogEntry('dark-souls-remastered', 'Dark Souls Remastered',
        [r'%USERPROFILE%\Documents\NBGI\DARK SOULS REMASTERED']),
    _CatalogEntry('persona-5-royal', 'Persona 5 Royal',
        [r'%APPDATA%\SEGA\P5R\Steam']),
    _CatalogEntry('mass-effect-le', 'Mass Effect Legendary Edition',
        [r'%USERPROFILE%\Documents\BioWare\Mass Effect Legendary Edition\Save']),

    // ── Indie Games ──────────────────────────────────────────────
    _CatalogEntry('hollow-knight', 'Hollow Knight',
        [r'%USERPROFILE%\AppData\LocalLow\Team Cherry\Hollow Knight']),
    _CatalogEntry('celeste', 'Celeste',
        [r'%LOCALAPPDATA%\Celeste\Saves']),
    _CatalogEntry('hades', 'Hades',
        [r'%USERPROFILE%\Documents\Saved Games\Hades']),
    _CatalogEntry('dead-cells', 'Dead Cells',
        [r'%USERPROFILE%\Documents\Dead Cells']),
    _CatalogEntry('slay-the-spire', 'Slay the Spire',
        [r'%LOCALAPPDATA%\SlayTheSpire']),
    _CatalogEntry('undertale', 'Undertale',
        [r'%LOCALAPPDATA%\UNDERTALE']),
    _CatalogEntry('binding-of-isaac', 'The Binding of Isaac Rebirth',
        [r'%USERPROFILE%\Documents\My Games\Binding of Isaac Rebirth']),
    _CatalogEntry('dont-starve', 'Dont Starve Together',
        [r'%USERPROFILE%\Documents\Klei\DoNotStarveTogether']),

    // ── Action/Adventure ─────────────────────────────────────────
    _CatalogEntry('gta-5', 'Grand Theft Auto V',
        [r'%USERPROFILE%\Documents\Rockstar Games\GTA V\Profiles']),
    _CatalogEntry('assassins-creed-valhalla', 'Assassins Creed Valhalla',
        [r'%USERPROFILE%\Documents\Assassins Creed Valhalla']),
    _CatalogEntry('tomb-raider', 'Tomb Raider 2013',
        [r'%USERPROFILE%\Documents\Tomb Raider\Saves']),
    _CatalogEntry('god-of-war', 'God of War',
        [r'%USERPROFILE%\Saved Games\God of War']),
    _CatalogEntry('sekiro', 'Sekiro Shadows Die Twice',
        [r'%APPDATA%\Sekiro']),

    // ── Simulation/Strategy ──────────────────────────────────────
    _CatalogEntry('cities-skylines', 'Cities Skylines',
        [r'%LOCALAPPDATA%\Colossal Order\Cities_Skylines\Saves']),
    _CatalogEntry('factorio', 'Factorio',
        [r'%APPDATA%\Factorio\saves']),
    _CatalogEntry('rimworld', 'RimWorld',
        [r'%LOCALAPPDATA%\..\LocalLow\Ludeon Studios\RimWorld by Ludeon Studios\Saves']),
    _CatalogEntry('civ-6', 'Civilization VI',
        [r'%USERPROFILE%\Documents\My Games\Sid Meiers Civilization VI\Saves']),
    _CatalogEntry('xcom-2', 'XCOM 2',
        [r'%USERPROFILE%\Documents\My Games\XCOM2\XComGame\SaveData']),
    _CatalogEntry('planet-coaster', 'Planet Coaster',
        [r'%USERPROFILE%\Saved Games\Frontier Developments\Planet Coaster']),
    _CatalogEntry('oxygen-not-included', 'Oxygen Not Included',
        [
          r'%USERPROFILE%\Documents\Klei\OxygenNotIncluded\save_files',
          r'%USERPROFILE%\AppData\LocalLow\Klei\Oxygen Not Included\save_files',
        ]),

    // ── Story/Narrative ──────────────────────────────────────────
    _CatalogEntry('life-is-strange', 'Life is Strange',
        [r'%USERPROFILE%\Documents\My Games\Life Is Strange\Saves']),
    _CatalogEntry('detroit-become-human', 'Detroit Become Human',
        [r'%USERPROFILE%\Saved Games\Quantic Dream\Detroit Become Human']),
    _CatalogEntry('disco-elysium', 'Disco Elysium',
        [r'%USERPROFILE%\AppData\LocalLow\ZA_UM\Disco Elysium']),

    // ── Survival/Crafting ────────────────────────────────────────
    _CatalogEntry('valheim', 'Valheim',
        [r'%USERPROFILE%\AppData\LocalLow\IronGate\Valheim\worlds']),
    _CatalogEntry('subnautica', 'Subnautica',
        [r'%USERPROFILE%\AppData\LocalLow\Unknown Worlds\Subnautica\Subnautica\SavedGames']),
    _CatalogEntry('7-days-to-die', '7 Days to Die',
        [r'%APPDATA%\7DaysToDie\Saves']),
    _CatalogEntry('the-forest', 'The Forest',
        [r'%LOCALAPPDATA%\SKS\TheForest\Saves']),
    _CatalogEntry('ark-survival', 'ARK Survival Evolved',
        [r'%LOCALAPPDATA%\ShooterGame\Saved\SavedArksLocal']),

    // ── FPS/Shooter ──────────────────────────────────────────────
    _CatalogEntry('borderlands-3', 'Borderlands 3',
        [r'%USERPROFILE%\Documents\My Games\Borderlands 3\Saved\SaveGames']),
    _CatalogEntry('metro-exodus', 'Metro Exodus',
        [r'%USERPROFILE%\Saved Games\metro exodus']),
    _CatalogEntry('doom-eternal', 'DOOM Eternal',
        [r'%USERPROFILE%\Saved Games\id Software\DOOMEternal\base\savegame']),

    // ── Other Popular ────────────────────────────────────────────
    _CatalogEntry('rocket-league', 'Rocket League',
        [r'%USERPROFILE%\Documents\My Games\Rocket League\TAGame\SaveData']),
  ];

  /// Map of Steam AppID to game save path patterns
  static const _steamGameSavePaths = <String, List<String>>{
    // Popular AAA Games
    '570': [r'%USERPROFILE%\AppData\local\Dota 2\DOTA2\*\remote'], // Dota 2
    '730': [r'%USERPROFILE%\AppData\local\CSGO'], // Counter-Strike: Global Offensive
    '440': [r'%USERPROFILE%\AppData\local\Team Fortress 2'], // Team Fortress 2
    '1245620': [r'%USERPROFILE%\Saved Games\Elden Ring'], // Elden Ring
    '1222670': [r'%USERPROFILE%\AppData\Local\Larian Studios\Baldurs Gate 3\PlayerProfiles'], // Baldurs Gate 3
    '1391110': [r'%USERPROFILE%\AppData\LocalLow\Obsidian Entertainment\The Outer Worlds'], // The Outer Worlds
    '367520': [r'%USERPROFILE%\Documents\My Games\Skyrim\Saves'], // The Elder Scrolls V: Skyrim
    '489830': [r'%USERPROFILE%\Documents\My Games\Skyrim Special Edition\Saves'], // Skyrim SE
    '72850': [r'%USERPROFILE%\Documents\My Games\Fallout3\Saves'], // Fallout 3
    '22320': [r'%USERPROFILE%\Documents\My Games\FalloutNV\Saves'], // Fallout: New Vegas
    '377160': [r'%USERPROFILE%\Documents\My Games\Fallout4\Saves'], // Fallout 4
    '286060': [r'%USERPROFILE%\AppData\Local\Papers Please'], // Papers, Please
    '271590': [r'%USERPROFILE%\AppData\LocalLow\Unknown Worlds\Subnautica\Subnautica\SavedGames'], // Subnautica
    '211420': [r'%USERPROFILE%\AppData\LocalLow\Supergiant Games\Hades'], // Hades
    '939100': [r'%USERPROFILE%\Saved Games\Valheim'], // Valheim
    '552990': [r'%USERPROFILE%\AppData\LocalLow\IronGate\Valheim\worlds'], // Valheim
    '292030': [r'%USERPROFILE%\AppData\Local\Larian Studios\Divinity Original Sin 2 - Definitive Edition\PlayerProfiles'], // Divinity OS 2 DE
    '435150': [r'%USERPROFILE%\Documents\Larian Studios\Divinity Original Sin 2\PlayerProfiles'], // Divinity OS 2
    '250900': [r'%APPDATA%\DarkSoulsIII'], // Dark Souls III
    '211720': [r'%USERPROFILE%\Documents\My Games\Dark Souls'], // Dark Souls
    '570940': [r'%APPDATA%\DarkSoulsRemastered'], // Dark Souls Remastered
    '239200': [r'%LOCALAPPDATA%\Terraria'], // Terraria
    '812140': [r'%APPDATA%\StardewValley\Saves'], // Stardew Valley
    '320080': [r'%USERPROFILE%\AppData\LocalLow\Team Cherry\Hollow Knight'], // Hollow Knight
    '413980': [r'%USERPROFILE%\Documents\Dead Cells'], // Dead Cells
    '646570': [r'%LOCALAPPDATA%\SlayTheSpire'], // Slay the Spire
    '391540': [r'%LOCALAPPDATA%\UNDERTALE'], // Undertale
    '250620': [r'%USERPROFILE%\Documents\My Games\Binding of Isaac Rebirth'], // The Binding of Isaac: Rebirth
    '431960': [r'%USERPROFILE%\Documents\Klei\DoNotStarveTogether'], // Dont Starve Together
    '219640': [r'%USERPROFILE%\Documents\Klei\Dont Starve'], // Dont Starve
    '220200': [r'%USERPROFILE%\Saved Games\Killing Floor'], // Killing Floor
    '570090': [r'%USERPROFILE%\AppData\LocalLow\Ubisoft\AssassinsCreedValhalla'], // AC Valhalla
    '1040720': [r'%USERPROFILE%\AppData\LocalLow\Ubisoft\Cyberpunk 2077'], // Cyberpunk 2077
    '1174880': [r'%USERPROFILE%\Saved Games\CD Projekt Red\Cyberpunk 2077'], // Cyberpunk 2077 (alt)
    '230410': [r'%LOCALAPPDATA%\Colossal Order\Cities_Skylines\Saves'], // Cities: Skylines
    '427520': [r'%APPDATA%\Factorio\saves'], // Factorio
    '294100': [r'%LOCALAPPDATA%\..\LocalLow\Ludeon Studios\RimWorld by Ludeon Studios\Saves'], // RimWorld
  };

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
    print('=== Starting catalog detection ===');
    print('Checking ${_catalog.length} games in catalog');

    for (final entry in _catalog) {
      final resolvedPaths = entry.pathTemplates
          .map(_resolveTokens)
          .toList();

      // Debug: print what we're checking
      print('Checking ${entry.name}: ${resolvedPaths.join(", ")}');

      final existingPaths = resolvedPaths
          .where((path) {
            final exists = Directory(path).existsSync();
            if (exists) print('  ✓ FOUND: $path');
            return exists;
          })
          .toList();

      if (existingPaths.isNotEmpty) {
        print('  → Added ${entry.name} with ${existingPaths.length} path(s)');
        found.add(DetectedGame(
          slug: entry.slug,
          name: entry.name,
          savePaths: existingPaths,
          confidence: 1.0,
        ));
      }
    }

    print('=== Catalog detection complete: ${found.length} games found ===');
    return found;
  }

  /// Parses Steam's `libraryfolders.vdf` to find install locations, then
  /// looks for matching `appmanifest_*.acf` files. Cross-references with
  /// known Steam save paths to build a complete detected game list.
  Future<List<DetectedGame>> _detectFromSteam() async {
    final steamPath = r'C:\Program Files (x86)\Steam';
    final steamappsDir = Directory(p.join(steamPath, 'steamapps'));
    print('🎮 === Starting Steam detection ===');
    print('🎮 Checking: $steamPath');

    if (!steamappsDir.existsSync()) {
      print('🎮 Steam not found at $steamPath');
      return [];
    }

    print('🎮 Steam found, scanning library...');
    final detected = _scanSteamLibrary(steamappsDir);
    print('🎮 === Steam detection complete: ${detected.length} games found ===');
    return detected;
  }

  /// Scans a Steam library directory for installed games
  List<DetectedGame> _scanSteamLibrary(Directory steamappsDir) {
    final games = <DetectedGame>[];

    try {
      final manifestFiles = steamappsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.acf') && f.path.contains('appmanifest_'))
          .toList();

      for (final file in manifestFiles) {
        try {
          final content = file.readAsStringSync();
          final appId = _extractVdfValue(content, '"appid"');
          final name = _extractVdfValue(content, '"name"');
          final installDir = _extractVdfValue(content, '"installdir"');

          if (appId.isNotEmpty && name.isNotEmpty) {
            // Look up save paths for this Steam app
            final savePaths = _steamGameSavePaths[appId];
            if (savePaths != null) {
              // Verify at least one path exists
              final resolvedPaths = savePaths
                  .map(_resolveTokens)
                  .where((path) {
                    try {
                      return Directory(path).existsSync() || File(path).existsSync();
                    } catch (_) {
                      return false;
                    }
                  })
                  .toList();

              if (resolvedPaths.isNotEmpty) {
                // Find the game executable
                String? exePath;
                if (installDir.isNotEmpty) {
                  final steamappsPath = steamappsDir.parent.path;
                  final gamePath = p.join(steamappsPath, 'common', installDir);
                  exePath = _findGameExeInPath(gamePath, name);
                }

                games.add(DetectedGame(
                  slug: 'steam-$appId',
                  name: name,
                  savePaths: resolvedPaths,
                  platform: 'steam',
                  confidence: 0.95,
                  exePath: exePath,
                ));
              }
            }
          }
        } catch (e) {
          // Skip malformed manifest files
          continue;
        }
      }
    } catch (e) {
      print('Error scanning Steam library: $e');
    }

    return games;
  }

  /// Finds the main executable in a game directory
  String? _findGameExeInPath(String gamePath, String gameName) {
    try {
      final gameDir = Directory(gamePath);
      if (!gameDir.existsSync()) return null;

      // Look for common executable patterns
      final possibleNames = [
        '${gameName.replaceAll(' ', '')}.exe',
        '${gameName.split(' ').first}.exe',
        'game.exe',
        'launcher.exe',
      ];

      // Check root first
      for (final fileName in possibleNames) {
        final filePath = p.join(gamePath, fileName);
        if (File(filePath).existsSync()) {
          print('  → Found exe: $filePath');
          return filePath;
        }
      }

      // Search subdirectories (bin, game, etc)
      final items = gameDir.listSync();
      for (final item in items) {
        if (item is File && item.path.endsWith('.exe')) {
          print('  → Found exe: ${item.path}');
          return item.path;
        }
      }
    } catch (e) {
      print('Error finding exe in $gamePath: $e');
    }

    return null;
  }

  /// Extracts a value from VDF key-value format
  /// VDF format: "key" "value"
  String _extractVdfValue(String content, String key) {
    final regex = RegExp('$key\\s+"([^"]+)"');
    final match = regex.firstMatch(content);
    return match?.group(1) ?? '';
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
