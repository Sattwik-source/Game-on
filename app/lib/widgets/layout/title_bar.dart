import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/constants/colors.dart';
import '../common/sync_indicator.dart';

/// Frameless window title bar with enhanced layout:
/// Logo | Search | Spacer | Sync Status | Notifications | Theme | User Menu | Window Controls
class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _Logo(),
              const SizedBox(width: 24),
              const _SearchBar(),
              const Spacer(),
              const _SyncStatusButton(),
              const SizedBox(width: 8),
              _NotificationsButton(),
              const SizedBox(width: 8),
              _ThemeToggleButton(),
              const SizedBox(width: 12),
              _UserMenuButton(),
              const SizedBox(width: 16),
              _WindowControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.sports_esports, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Text(
          'GameOn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _focused ? AppColors.surface : AppColors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _focused ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Focus(
          onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
          child: TextField(
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            style: const TextStyle(fontSize: 13, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Search games... (Ctrl+K)',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted2),
              prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.muted2),
              suffixIcon: _focused
                  ? GestureDetector(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.close, size: 14, color: AppColors.muted2),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ),
    );
  }
}

class _SyncStatusButton extends StatelessWidget {
  const _SyncStatusButton();

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual sync status from provider
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SyncIndicator(
            status: SyncStatus.synced,
            size: 8,
          ),
          SizedBox(width: 8),
          Text(
            'Synced',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsButton extends StatefulWidget {
  @override
  State<_NotificationsButton> createState() => _NotificationsButtonState();
}

class _NotificationsButtonState extends State<_NotificationsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual notification count from provider
    const hasNotifications = true;
    const notificationCount = 3;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            color: _hovered ? AppColors.primary : AppColors.muted,
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: _hovered ? AppColors.surface : Colors.transparent,
            ),
          ),
          if (hasNotifications)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatefulWidget {
  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual theme mode from provider
    const isDark = true;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: IconButton(
        icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20),
        color: _hovered ? AppColors.secondary : AppColors.muted,
        onPressed: () {
          // TODO: Toggle theme
        },
        style: IconButton.styleFrom(
          backgroundColor: _hovered ? AppColors.surface : Colors.transparent,
        ),
      ),
    );
  }
}

class _UserMenuButton extends StatefulWidget {
  @override
  State<_UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<_UserMenuButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          // TODO: Show user menu dropdown
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _hovered ? Border.all(color: AppColors.border) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: _hovered ? AppColors.text : AppColors.muted2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _WindowControlButton(
          icon: Icons.remove,
          onTap: () => windowManager.minimize(),
        ),
        _WindowControlButton(
          icon: Icons.crop_square,
          onTap: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
        ),
        _WindowControlButton(
          icon: Icons.close,
          onTap: () => windowManager.hide(),
          isDanger: true,
        ),
      ],
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;

  const _WindowControlButton({
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: IconButton(
        icon: Icon(widget.icon, size: 16),
        color: _hovered && widget.isDanger ? AppColors.danger : (_hovered ? AppColors.primary : AppColors.muted),
        hoverColor: Colors.transparent,
        onPressed: widget.onTap,
        style: IconButton.styleFrom(
          backgroundColor: _hovered && widget.isDanger
              ? AppColors.danger.withValues(alpha: 0.1)
              : (_hovered ? AppColors.surface : Colors.transparent),
        ),
      ),
    );
  }
}
