import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game.dart';
import '../../core/services/game_launcher_service.dart';
import '../../state/games_provider.dart';
import '../../state/ui_provider.dart';

/// Modal for adding a game — either via auto-detection scan or manual entry.
class AddGameModal extends StatefulWidget {
  const AddGameModal({super.key});

  @override
  State<AddGameModal> createState() => _AddGameModalState();
}

class _AddGameModalState extends State<AddGameModal> {
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();
  String? _exePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamesProvider>().detectGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamesProvider = context.watch<GamesProvider>();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add a game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
            const SizedBox(height: 16),

            if (gamesProvider.detecting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (gamesProvider.detectedCandidates.isNotEmpty) ...[
              const Text('Detected on this PC',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: AppColors.muted)),
              const SizedBox(height: 8),
              ...gamesProvider.detectedCandidates.map((c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.name, style: const TextStyle(fontSize: 13, color: AppColors.text)),
                    subtitle: Text(c.savePaths.first, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                    trailing: TextButton(
                      onPressed: () async {
                        await gamesProvider.addGame(
                          Game(id: '', name: c.name, slug: c.slug, savePaths: c.savePaths, exePath: c.exePath),
                          onSaveChange: (_, __) {},
                        );
                        if (context.mounted) context.read<UiProvider>().closeModal();
                      },
                      child: const Text('ADD'),
                    ),
                  )),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
            ],

            const Text('ADD MANUALLY',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.muted)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Game name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pathController,
              decoration: const InputDecoration(hintText: 'Save folder path'),
            ),
            const SizedBox(height: 12),

            // Browse for executable section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Game executable (optional)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.muted)),
                const SizedBox(height: 6),
                if (_exePath != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.bg3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _exePath!.split('\\').last,
                            style: const TextStyle(fontSize: 11, color: AppColors.text),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.clear, size: 14),
                            onPressed: () => setState(() => _exePath = null),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open, size: 16),
                    label: const Text('Browse for executable'),
                    onPressed: () async {
                      final path = await GameLauncherService.instance.browseForExecutable();
                      if (path != null && mounted) {
                        setState(() => _exePath = path);
                        print('🎮 Selected executable: $path');
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.read<UiProvider>().closeModal(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isEmpty || _pathController.text.isEmpty) return;
                    await context.read<GamesProvider>().addGame(
                          Game(
                            id: '',
                            name: _nameController.text,
                            slug: _nameController.text.toLowerCase().replaceAll(' ', '-'),
                            savePaths: [_pathController.text],
                            exePath: _exePath,
                          ),
                          onSaveChange: (_, __) {},
                        );
                    if (context.mounted) context.read<UiProvider>().closeModal();
                  },
                  child: const Text('Add game'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    super.dispose();
  }
}
