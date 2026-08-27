/// Named routes used by [UiProvider] to switch pages inside the AppShell.
class AppRoutes {
  AppRoutes._();

  static const login    = 'login';
  static const home     = 'home';
  static const library  = 'library';
  static const backups  = 'backups';
  static const settings = 'settings';
  static const store    = 'store';
}

/// Sidebar navigation item definition.
class NavItem {
  final String route;
  final String icon;
  final String label;
  const NavItem(this.route, this.icon, this.label);
}

const List<NavItem> kNavItems = [
  NavItem(AppRoutes.home, '⌂', 'HOME'),
  NavItem(AppRoutes.library, '▦', 'LIBRARY'),
  NavItem(AppRoutes.store, '🏪', 'STORE'),
  NavItem(AppRoutes.backups, '☁', 'BACKUPS'),
];
