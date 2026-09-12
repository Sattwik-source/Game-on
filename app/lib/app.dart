import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'state/auth_provider.dart';
import 'state/games_provider.dart';
import 'state/backup_provider.dart';
import 'state/ui_provider.dart';
import 'screens/login_screen.dart';
import 'widgets/layout/app_shell.dart';

class GameOnApp extends StatelessWidget {
  const GameOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..hydrate()),
        ChangeNotifierProvider(create: (_) => GamesProvider()),
        ChangeNotifierProvider(create: (_) => BackupProvider()),
        ChangeNotifierProvider(create: (_) => UiProvider()),
      ],
      child: MaterialApp(
        title: 'GameOn',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _RootGate(),
      ),
    );
  }
}

/// Decides whether to show the login screen or the full app shell.
/// - If user has a previous session, hydrate it in the background
/// - Otherwise, allow browsing the app without auth (lazy auth)
/// - Auth is only required when accessing backup/restore features
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Show loading only on first hydration attempt, not indefinitely
    if (auth.loading && auth.user == null && !auth.hydrationAttempted) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFA855F7)),
              SizedBox(height: 16),
              Text('Loading GameOn…', style: TextStyle(color: Color(0xFF8890B0))),
            ],
          ),
        ),
      );
    }

    // Always show AppShell (user can browse without auth)
    // Auth is only required when they try to backup/restore
    return const AppShell();
  }
}
