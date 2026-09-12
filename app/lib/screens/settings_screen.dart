import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../state/auth_provider.dart';
import '../state/backup_provider.dart';

/// App configuration — Drive connection, sync behaviour, startup options.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _syncInterval = 3;
  bool _startOnLogin = true;
  bool _minimizeToTray = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final quota = context.watch<BackupProvider>().driveQuota;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
            const SizedBox(height: 24),

            _SettingsCard(
              title: 'Google Drive',
              children: [
                if (auth.isAuthenticated)
                  // Connected state
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text('☁️', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Connected', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                                Text(user?.email ?? '', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          const _StatusPill(text: 'Active', color: AppColors.success),
                        ],
                      ),
                      if (quota != null) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: quota['total'] != null && quota['total']! > 0
                              ? quota['used']! / quota['total']!
                              : 0,
                          backgroundColor: AppColors.surface2,
                          valueColor: const AlwaysStoppedAnimation(AppColors.purple2),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => auth.signOut(),
                          child: const Text('Disconnect Google Drive'),
                        ),
                      ),
                    ],
                  )
                else
                  // Not connected state
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text('☁️', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Not connected', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                                const Text('Sign in to enable backups', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          const _StatusPill(text: 'Offline', color: AppColors.muted),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: auth.loading ? null : () => auth.signInWithGoogle(),
                          icon: auth.loading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.login, size: 16),
                          label: Text(auth.loading ? 'Connecting…' : 'Sign in with Google'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 16),

            if (auth.isAuthenticated)
              Column(
                children: [
                  _SettingsCard(
                    title: 'Sync Behaviour',
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('Auto-sync interval', style: TextStyle(fontSize: 13, color: AppColors.text))),
                          Text('${_syncInterval.round()} min', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                      Slider(
                        value: _syncInterval,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: AppColors.purple2,
                        inactiveColor: AppColors.surface2,
                        onChanged: (v) => setState(() => _syncInterval = v),
                      ),
                      _ToggleRow(
                        label: 'Start GameOn on Windows login',
                        value: _startOnLogin,
                        onChanged: (v) => setState(() => _startOnLogin = v),
                      ),
                      _ToggleRow(
                        label: 'Minimize to tray on close',
                        value: _minimizeToTray,
                        onChanged: (v) => setState(() => _minimizeToTray = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            _SettingsCard(
              title: 'Security',
              children: const [
                Text(
                  'Your encryption key is derived on this device and never transmitted. '
                  'Save files are encrypted with AES-256-GCM before upload — GameOn and '
                  'Google both only ever see ciphertext.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.muted)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.text))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.purple2),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
