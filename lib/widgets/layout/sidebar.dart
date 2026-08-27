import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../state/auth_provider.dart';
import '../../state/ui_provider.dart';

/// 68px icon sidebar. Mirrors the Electron version's Sidebar.jsx —
/// active route gets a purple left accent bar and glow background.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = context.watch<UiProvider>();
    final user = context.watch<AuthProvider>().user;

    return Container(
      width: 68,
      color: AppColors.bg2,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _LogoMark(),
          const SizedBox(height: 8),
          ...kNavItems.map((item) => _SidebarItem(
                item: item,
                active: ui.route == item.route,
                onTap: () => ui.navigate(item.route),
              )),
          const Spacer(),
          _SidebarItem(
            item: const NavItem(AppRoutes.settings, '⚙', 'CONFIG'),
            active: ui.route == AppRoutes.settings,
            onTap: () => ui.navigate(AppRoutes.settings),
          ),
          const SizedBox(height: 8),
          _UserAvatar(initial: user?.initial ?? '?'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.sports_esports, color: Colors.white, size: 18),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _SidebarItem({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Material(
        color: active ? AppColors.purpleGlow : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: active
                  ? const Border(left: BorderSide(color: AppColors.purple2, width: 3))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.icon, style: TextStyle(
                  fontSize: 16,
                  color: active ? AppColors.purple2 : AppColors.muted2,
                )),
                const SizedBox(height: 2),
                Text(item.label, style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: active ? AppColors.purple2 : AppColors.muted2,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String initial;
  const _UserAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purple3]),
        border: Border.all(color: AppColors.purple, width: 2),
      ),
      child: Center(
        child: Text(initial, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}
