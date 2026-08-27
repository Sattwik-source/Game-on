/// Backend API base URL and endpoint paths.
///
/// In development this points at the local Spring Boot server.
/// Override with `--dart-define=API_BASE_URL=https://api.gameon.app`
/// when building for production.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Auth
  static const String googleAuthUrl   = '/api/auth/google/url';
  static const String googleExchange  = '/api/auth/google/exchange';
  static const String refreshToken    = '/api/auth/refresh';

  // Games
  static const String games           = '/api/games';
  static String game(String id)       => '/api/games/$id';

  // Backups
  static const String backups         = '/api/backups';
  static String backup(String id)     => '/api/backups/$id';
  static String backupRestore(String id) => '/api/backups/$id/restore';
  static String backupLabel(String id)   => '/api/backups/$id/label';

  // Users
  static const String me              = '/api/users/me';
  static const String devices         = '/api/users/devices';

  // Drive
  static const String driveQuota      = '/api/drive/quota';
}
