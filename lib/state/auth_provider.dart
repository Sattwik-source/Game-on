import 'package:flutter/foundation.dart';
import '../core/models/user.dart';
import '../core/services/auth_service.dart';

/// Holds the current authentication state and exposes actions to
/// [Consumer]/[context.watch] widgets throughout the app.
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  /// Called once on app boot — checks the OS keychain for an existing
  /// session before showing the login screen.
  Future<void> hydrate() async {
    _setLoading(true);
    try {
      _user = await AuthService.instance.restoreSession();
    } catch (_) {
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      _user = await AuthService.instance.signInWithGoogle();
    } catch (e) {
      _error = 'Sign-in failed. Please try again.';
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
