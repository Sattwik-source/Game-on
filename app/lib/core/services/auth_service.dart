import 'dart:async';
import 'dart:io';
import '../constants/api_endpoints.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'secure_storage_service.dart';

/// Handles the Google OAuth "loopback" flow for desktop apps:
///
///  1. Spin up a temporary HTTP server on a random localhost port.
///  2. Ask the backend for the Google consent URL (with redirect_uri
///     pointing at that loopback port).
///  3. Open the URL in the system's default browser.
///  4. Catch the `?code=` query param when Google redirects back.
///  5. POST the code to the backend, which exchanges it for tokens
///     and returns our own JWT + the user profile.
///  6. Persist everything in the OS keychain via [SecureStorageService].
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _storage = SecureStorageService.instance;

  /// Runs the full OAuth flow. Returns the logged-in [User] on success.
  Future<User> signInWithGoogle() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;

    try {
      final urlResponse = await ApiClient.instance.get(
        ApiConfig.googleAuthUrl,
        query: {'redirect_port': port},
      );
      final consentUrl = urlResponse.data['url'] as String;

      await _openInBrowser(consentUrl);

      final code = await _awaitCallback(server);

      final exchangeResponse = await ApiClient.instance.post(
        ApiConfig.googleExchange,
        data: {'code': code, 'redirectPort': port},
      );

      final data = exchangeResponse.data as Map<String, dynamic>;

      await _storage.saveAccessToken(data['accessToken'] as String);
      await _storage.saveRefreshToken(data['refreshToken'] as String);

      final googleTokens = data['googleTokens'] as Map<String, dynamic>?;
      if (googleTokens != null) {
        await _storage.saveGoogleTokens(
          accessToken: googleTokens['accessToken'] as String,
          refreshToken: googleTokens['refreshToken'] as String?,
        );
      }

      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await _storage.saveUser(user);
      return user;
    } finally {
      await server.close(force: true);
    }
  }

  /// Waits for Google's redirect to hit our loopback server and extracts
  /// the `code` query parameter. Serves a simple confirmation HTML page.
  Future<String> _awaitCallback(HttpServer server) async {
    final completer = Completer<String>();

    server.listen((HttpRequest request) async {
      final code = request.uri.queryParameters['code'];
      final error = request.uri.queryParameters['error'];

      request.response.headers.contentType = ContentType.html;
      request.response.write('''
        <html><body style="font-family:sans-serif;background:#07080f;color:#fff;
          display:flex;align-items:center;justify-content:center;height:100vh;margin:0">
          <div style="text-align:center">
            <h2>${error != null ? '❌ Login failed' : '✅ Logged in!'}</h2>
            <p>You can close this tab and return to GameOn.</p>
          </div>
        </body></html>
      ''');
      await request.response.close();

      if (!completer.isCompleted) {
        if (code != null) {
          completer.complete(code);
        } else {
          completer.completeError(Exception(error ?? 'No code returned'));
        }
      }
    });

    return completer.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () => throw TimeoutException('Login timed out'),
    );
  }

  Future<void> _openInBrowser(String url) async {
    if (Platform.isWindows) {
      // Use rundll32 to open URLs on Windows to avoid cmd.exe parsing issues
      await Process.run('rundll32', ['url.dll,FileProtocolHandler', url]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [url]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [url]);
    }
  }

  /// Reads the cached session from the OS keychain. Returns null if
  /// there is no session or the access token cannot be found.
  Future<User?> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    return _storage.getUser();
  }

  Future<void> signOut() async {
    await _storage.clearAll();
  }
}
