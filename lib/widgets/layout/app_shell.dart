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

/// Rendered once the user is authenticated. Owns the persistent
/// TitleBar + Sidebar frame and swaps the center content based on
/// [UiProvider.route] — no Navigator stack needed for a single-window app.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final route = context.watch<UiProvider>().route;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Row(
              children: [
                const Sidebar(),
                Expanded(child: _routedPage(route)),
              ],
            ),
          ),
        ],
      ),
    );
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
