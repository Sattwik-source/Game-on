import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../state/ui_provider.dart';
import 'title_bar.dart';
import 'sidebar.dart';
import '../../screens/home_screen.dart';
import '../../screens/library_screen.dart';
import '../../screens/backups_screen.dart';
import '../../screens/settings_screen.dart';
import '../../widgets/games/add_game_modal.dart';

/// Rendered once the user is authenticated. Owns the persistent
/// TitleBar + Sidebar frame and swaps the center content based on
/// [UiProvider.route] — no Navigator stack needed for a single-window app.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = context.watch<UiProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              const TitleBar(),
              Expanded(
                child: Row(
                  children: [
                    const Sidebar(),
                    Expanded(child: _routedPage(ui.route)),
                  ],
                ),
              ),
            ],
          ),
          // Modal overlay
          if (ui.modal != null)
            GestureDetector(
              onTap: ui.closeModal,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: GestureDetector(
                  onTap: () {}, // Prevent close on modal click
                  child: Center(
                    child: _renderModal(ui.modal!.type),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _renderModal(String type) {
    switch (type) {
      case 'addGame':
        return const AddGameModal();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _routedPage(String route) {
    switch (route) {
      case AppRoutes.library:
        return const LibraryScreen();
      case AppRoutes.backups:
        return const BackupsScreen();
      case AppRoutes.settings:
        return const SettingsScreen();
      case AppRoutes.home:
      default:
        return const HomeScreen();
    }
  }
}
