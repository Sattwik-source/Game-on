import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../state/games_provider.dart';
import '../state/ui_provider.dart';
import '../widgets/games/game_list_item.dart';
import '../widgets/games/game_detail_panel.dart';
import '../widgets/common/empty_state.dart';

/// Full library management screen — searchable list on the left,
/// detail panel + backup history on the right. Mirrors Library.jsx.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamesProvider>().fetchGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamesProvider = context.watch<GamesProvider>();
    final query = _searchController.text.toLowerCase();
    final filtered = gamesProvider.games
        .where((g) => g.name.toLowerCase().contains(query))
        .toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text('Your Library',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
                    const Spacer(),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search games…',
                          isDense: true,
                          prefixIcon: Icon(Icons.search, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => context.read<UiProvider>().openModal('addGame'),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Game'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: gamesProvider.loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.purple2))
                    : filtered.isEmpty
                        ? const EmptyState(
                            icon: '🎮',
                            title: 'No games added yet',
                            message: 'Add your first game and GameOn will automatically back up your saves.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => GameListItem(
                              game: filtered[i],
                              selected: filtered[i].id == gamesProvider.selectedGameId,
                              onTap: () => gamesProvider.selectGame(filtered[i].id),
                            ),
                          ),
              ),
            ],
          ),
        ),
        Container(width: 1, color: AppColors.border),
        const SizedBox(
          width: 300,
          child: GameDetailPanel(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
