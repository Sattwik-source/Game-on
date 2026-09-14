import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../core/constants/colors.dart';
import '../state/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _features = [
    ('☁️', 'Auto-backup to your Google Drive'),
    ('🕹️', 'Supports modded & offline games'),
    ('🔒', 'AES-256 encrypted before upload'),
    ('📱', 'Restore on any PC instantly'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: DragToMoveArea(
        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sports_esports, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('GameOn',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.text)),
                const SizedBox(height: 8),
                const Text(
                  'Never lose your game saves again.\nBack up automatically to Google Drive.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
                ),
                const SizedBox(height: 28),
                ..._features.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(f.$1, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 10),
                          Text(f.$2, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                if (auth.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      border: Border.all(color: AppColors.danger),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(auth.error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: auth.loading ? null : () => auth.signInWithGoogle(),
                    icon: auth.loading
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.login, size: 16),
                    label: Text(auth.loading ? 'Connecting…' : 'Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your saves are encrypted on your device before upload.\nGameOn never sees your files in plain text.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: AppColors.muted2, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
