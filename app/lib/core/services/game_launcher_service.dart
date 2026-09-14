import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

/// Launches installed games by finding their executable
class GameLauncherService {
  GameLauncherService._();
  static final GameLauncherService instance = GameLauncherService._();

  /// Map of game slugs to possible executable names and paths
  static const _gameExecutables = <String, List<String>>{
    'oxygen-not-included': ['OxygenNotIncluded.exe'],
    'minecraft-java': ['javaw.exe'],
    'skyrim-se': ['SkyrimSE.exe'],
    'stardew-valley': ['Stardew Valley.exe'],
    'terraria': ['Terraria.exe'],
    'the-witcher-3': ['witcher3.exe'],
    'elden-ring': ['eldenring.exe'],
    'cyberpunk-2077': ['Cyberpunk2077.exe'],
    'baldurs-gate-3': ['bg3.exe', 'bg3_dx11.exe'],
    'hollow-knight': ['hollow_knight.exe'],
    'celeste': ['Celeste.exe'],
    'hades': ['Hades.exe'],
    'dead-cells': ['DeadCells.exe'],
    'valheim': ['valheim.exe'],
  };

  /// Attempts to launch a game by name and save paths
  Future<bool> launchGame(String slug, String name, List<String> savePaths, {String? exePath}) async {
    try {
      print('🎮 Attempting to launch: $name (slug: $slug)');
      print('🎮 ExePath provided: $exePath');

      // If exePath is provided, use it directly
      if (exePath != null && exePath.isNotEmpty) {
        print('🎮 Checking if file exists: $exePath');
        if (File(exePath).existsSync()) {
          print('🎮 File exists! Launching from: $exePath');
          await Process.start(exePath, [], runInShell: true);
          print('🎮 Process started successfully');
          return true;
        } else {
          print('❌ File does not exist: $exePath');
        }
      }

      print('❌ No valid exePath provided or file not found');
      return false;
    } catch (e) {
      print('❌ Error launching game: $e');
      return false;
    }
  }

  /// Shows a file picker to manually select the game executable
  Future<String?> browseForExecutable() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['exe'],
        dialogTitle: 'Select Game Executable',
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      print('Error opening file picker: $e');
      return null;
    }
  }

  /// Map of game slugs to Steam AppIDs
  static const _steamAppIds = <String, String>{
    'oxygen-not-included': '457140',
    'skyrim-se': '489830',
    'stardew-valley': '413150',
    'terraria': '105600',
    'the-witcher-3': '292030',
    'elden-ring': '1245620',
    'cyberpunk-2077': '1091500',
    'baldurs-gate-3': '1086940',
    'hollow-knight': '367520',
    'celeste': '504230',
    'hades': '1145360',
    'dead-cells': '588650',
    'valheim': '892970',
  };

  /// Finds game via Steam installation
  Future<String?> _findSteamGamePath(String slug, String name) async {
    try {
      final appId = _steamAppIds[slug];
      if (appId == null) {
        print('   No Steam AppID mapped for $slug');
        return null;
      }

      print('   Checking Steam for AppID: $appId');

      // Read Steam library folders
      final steamPath = r'C:\Program Files (x86)\Steam';
      final libraryFile = File(p.join(steamPath, 'steamapps', 'libraryfolders.vdf'));

      if (!libraryFile.existsSync()) {
        print('   Steam not found at default location');
        return null;
      }

      // Parse library folders
      final content = await libraryFile.readAsString();
      final libraries = <String>[steamPath];

      // Extract additional library paths from VDF
      final pathRegex = RegExp(r'"path"\s+"([^"]+)"');
      final matches = pathRegex.allMatches(content);
      for (final match in matches) {
        final path = match.group(1);
        if (path != null && path != steamPath) {
          libraries.add(path.replaceAll(r'\\', r'\'));
        }
      }

      print('   Found ${libraries.length} Steam libraries');

      // Check each library for the game
      for (final library in libraries) {
        final manifestPath = p.join(library, 'steamapps', 'appmanifest_$appId.acf');
        final manifestFile = File(manifestPath);

        if (!manifestFile.existsSync()) continue;

        print('   ✓ Found game manifest: $manifestPath');

        // Parse ACF to get install dir
        final manifestContent = await manifestFile.readAsString();
        final installDirRegex = RegExp(r'"installdir"\s+"([^"]+)"');
        final installDirMatch = installDirRegex.firstMatch(manifestContent);

        if (installDirMatch == null) continue;

        final installDir = installDirMatch.group(1);
        final gamePath = p.join(library, 'steamapps', 'common', installDir);

        print('   Game installed at: $gamePath');

        // Find the executable in the game directory
        final possibleExes = _gameExecutables[slug] ?? ['$name.exe'];

        for (final exeName in possibleExes) {
          final exePath = p.join(gamePath, exeName);
          if (File(exePath).existsSync()) {
            print('   ✓ Found executable: $exePath');
            return exePath;
          }
        }

        // Search recursively in game folder
        try {
          final gameDir = Directory(gamePath);
          if (gameDir.existsSync()) {
            await for (final entity in gameDir.list(recursive: true, followLinks: false)) {
              if (entity is File && entity.path.endsWith('.exe')) {
                for (final exeName in possibleExes) {
                  if (entity.path.endsWith(exeName)) {
                    print('   ✓ Found executable: ${entity.path}');
                    return entity.path;
                  }
                }
              }
            }
          }
        } catch (e) {
          print('   Error searching game directory: $e');
        }
      }

      print('   Game not found in Steam libraries');
      return null;
    } catch (e) {
      print('   Error searching Steam: $e');
      return null;
    }
  }

  /// Tries to find the game executable in common locations
  Future<String?> _findGameExecutable(String slug, String name, List<String> savePaths) async {
    final possibleExes = _gameExecutables[slug] ?? [name.replaceAll(' ', '') + '.exe'];

    print('   Looking for: ${possibleExes.join(", ")}');

    // Search in common game directories
    final commonPaths = [
      r'C:\Program Files\',
      r'C:\Program Files (x86)\',
      r'C:\Games\',
      r'D:\Games\',
      r'E:\Games\',
      Platform.environment['USERPROFILE'] ?? '',
    ];

    // Try direct path checks first
    for (final basePath in commonPaths) {
      if (basePath.isEmpty) continue;

      for (final exeName in possibleExes) {
        try {
          // Try exact match
          final fullPath = p.join(basePath, name, exeName);
          if (File(fullPath).existsSync()) {
            print('   ✓ Found at: $fullPath');
            return fullPath;
          }

          // Try with normalized names
          final altName = name.replaceAll(' ', '_').replaceAll('-', '_');
          final altPath = p.join(basePath, altName, exeName);
          if (File(altPath).existsSync()) {
            print('   ✓ Found at: $altPath');
            return altPath;
          }

          // Try without subdirectory
          final directPath = p.join(basePath, exeName);
          if (File(directPath).existsSync()) {
            print('   ✓ Found at: $directPath');
            return directPath;
          }
        } catch (e) {
          print('   ! Error checking $basePath: $e');
        }
      }
    }

    // Search near save paths
    print('   Searching near save folders...');
    for (final savePath in savePaths) {
      try {
        final saveDir = Directory(savePath);
        if (!saveDir.existsSync()) continue;

        // Search parent and sibling directories
        final parents = [
          saveDir.parent,
          saveDir.parent.parent,
          saveDir.parent.parent.parent,
        ];

        for (final parent in parents) {
          if (!parent.existsSync()) continue;

          try {
            final items = parent.listSync();
            for (final item in items) {
              if (item is File && item.path.endsWith('.exe')) {
                for (final exeName in possibleExes) {
                  if (item.path.endsWith(exeName)) {
                    print('   ✓ Found executable near save path: ${item.path}');
                    return item.path;
                  }
                }
              } else if (item is Directory) {
                // Search inside subdirectories
                try {
                  final subItems = item.listSync();
                  for (final subItem in subItems) {
                    if (subItem is File) {
                      for (final exeName in possibleExes) {
                        if (subItem.path.endsWith(exeName)) {
                          print('   ✓ Found in subdirectory: ${subItem.path}');
                          return subItem.path;
                        }
                      }
                    }
                  }
                } catch (_) {}
              }
            }
          } catch (e) {
            print('   ! Error searching $parent: $e');
          }
        }
      } catch (e) {
        print('   ! Error with save path $savePath: $e');
      }
    }

    return null;
  }
}

