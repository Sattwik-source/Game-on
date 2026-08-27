import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/constants/colors.dart';

/// Frameless window title bar. The whole bar is a drag handle
/// (via [DragToMoveArea]) except for the interactive nav/buttons.
class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            _Logo(),
            const SizedBox(width: 32),
            const _TopNav(),
            const Spacer(),
            _SearchButton(),
            const SizedBox(width: 10),
            _DownloadButton(),
            const SizedBox(width: 12),
            _WindowControls(),
          ],
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.power_settings_new, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: AppColors.text),
            children: [
              TextSpan(text: 'GAME'),
              TextSpan(text: 'ON', style: TextStyle(color: AppColors.purple2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav();

  static const _items = ['Home', 'Games', 'Library', 'Store', 'Community', 'About'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items.asMap().entries.map((e) {
        final isActive = e.key == 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: isActive ? AppColors.text : AppColors.muted,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            child: Text(e.value, style: const TextStyle(fontSize: 13)),
          ),
        );
      }).toList(),
    );
  }
}

class _SearchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _IconBtn(icon: Icons.search, onTap: () {});
  }
}

class _DownloadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: const Text('DOWNLOAD LAUNCHER', style: TextStyle(fontSize: 11)),
    );
  }
}

class _WindowControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBtn(icon: Icons.remove, onTap: () => windowManager.minimize()),
        _IconBtn(icon: Icons.crop_square, onTap: () async {
          if (await windowManager.isMaximized()) {
            windowManager.unmaximize();
          } else {
            windowManager.maximize();
          }
        }),
        _IconBtn(icon: Icons.close, onTap: () => windowManager.hide(), hoverColor: AppColors.red),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? hoverColor;
  const _IconBtn({required this.icon, required this.onTap, this.hoverColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: 16),
        color: AppColors.muted,
        hoverColor: (hoverColor ?? AppColors.surface2).withOpacity(0.2),
        onPressed: onTap,
      ),
    );
  }
}
