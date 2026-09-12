import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../state/auth_provider.dart';
import '../../state/ui_provider.dart';
import '../common/storage_widget.dart';
import '../common/sync_indicator.dart';

/// Expandable sidebar with storage widget and sync status.
/// Default width: 220px, can collapse to 68px icon-only mode.
class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final ui = context.watch<UiProvider>();
    final user = context.watch<AuthProvider>().user;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _expanded ? 220 : 68,
      color: AppColors.bg2,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _LogoMark(expanded: _expanded),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          ...kNavItems.map((item) => _SidebarItem(
                item: item,
                active: ui.route == item.route,
                expanded: _expanded,
                onTap: () => ui.navigate(item.route),
              )),
          const Spacer(),
          if (_expanded) ...[
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _StorageSection(),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SyncStatusSection(),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
          ],
          const SizedBox(height: 8),
          _SidebarItem(
            item: const NavItem(AppRoutes.settings, Icons.settings, 'Settings'),
            active: ui.route == AppRoutes.settings,
            expanded: _expanded,
            onTap: () => ui.navigate(AppRoutes.settings),
          ),
          const SizedBox(height: 8),
          _UserAvatar(initial: user?.initial ?? '?', expanded: _expanded),
          const SizedBox(height: 8),
          _CollapseButton(
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  final bool expanded;
  const _LogoMark({required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports_esports, color: Colors.white, size: 18),
          ),
          if (expanded) ...[
            const SizedBox(width: 12),
            const Text(
              'GAMEON',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: AppColors.text,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final NavItem item;
  final bool active;
  final bool expanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.active,
    required this.expanded,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.active;
    final color = isActive ? AppColors.primary : (_hovered ? AppColors.textSecondary : AppColors.muted);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? const Border(left: BorderSide(color: AppColors.primary, width: 3))
                    : null,
              ),
              padding: EdgeInsets.symmetric(horizontal: widget.expanded ? 16 : 0),
              child: Row(
                children: [
                  if (!widget.expanded) const Spacer(),
                  Icon(
                    widget.item.icon is IconData ? widget.item.icon as IconData : Icons.circle,
                    size: 20,
                    color: color,
                  ),
                  if (widget.expanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                  if (!widget.expanded) const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StorageSection extends StatelessWidget {
  const _StorageSection();

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual storage data from provider
    return const Column(
      children: [
        Text(
          'Cloud Storage',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.muted2,
          ),
        ),
        SizedBox(height: 12),
        StorageWidget(
          usedGB: 2.4,
          totalGB: 15,
          size: 80,
          showDetails: false,
        ),
        SizedBox(height: 8),
        Text(
          '2.4 GB / 15 GB',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _SyncStatusSection extends StatelessWidget {
  const _SyncStatusSection();

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual sync status from provider
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          SyncIndicator(
            status: SyncStatus.synced,
            size: 10,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'All synced',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String initial;
  final bool expanded;
  const _UserAvatar({required this.initial, required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (!expanded) const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.orangeGradient,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sattwik',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.muted2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (!expanded) const Spacer(),
        ],
      ),
    );
  }
}

class _CollapseButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  const _CollapseButton({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          expanded ? Icons.chevron_left : Icons.chevron_right,
          size: 20,
          color: AppColors.muted,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

// Update NavItem to support IconData
class NavItem {
  final String route;
  final dynamic icon; // Can be IconData or String (emoji)
  final String label;
  const NavItem(this.route, this.icon, this.label);
}

const kNavItems = [
  NavItem(AppRoutes.home, Icons.home, 'Home'),
  NavItem(AppRoutes.library, Icons.videogame_asset, 'Library'),
  NavItem(AppRoutes.backups, Icons.cloud, 'Cloud Saves'),
];
