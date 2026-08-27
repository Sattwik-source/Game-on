import 'package:flutter/foundation.dart';
import '../core/constants/routes.dart';

class ModalState {
  final String type;
  final Map<String, dynamic> props;
  const ModalState(this.type, [this.props = const {}]);
}

/// Lightweight in-app "router" — GameOn doesn't need Navigator stacks
/// since it's a single-window app shell that swaps its center content.
class UiProvider extends ChangeNotifier {
  String _route = AppRoutes.home;
  ModalState? _modal;
  bool _sidebarCollapsed = false;

  String get route => _route;
  ModalState? get modal => _modal;
  bool get sidebarCollapsed => _sidebarCollapsed;

  void navigate(String route) {
    _route = route;
    notifyListeners();
  }

  void openModal(String type, [Map<String, dynamic> props = const {}]) {
    _modal = ModalState(type, props);
    notifyListeners();
  }

  void closeModal() {
    _modal = null;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarCollapsed = !_sidebarCollapsed;
    notifyListeners();
  }
}
