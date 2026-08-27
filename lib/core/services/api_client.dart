import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'secure_storage_service.dart';

/// Thin wrapper around Dio that automatically attaches the JWT access
/// token to every request and refreshes it on a 401 response.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.instance.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final clonedRequest = await _dio.fetch(error.requestOptions);
            return handler.resolve(clonedRequest);
          }
        }
        handler.next(error);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(ApiConfig.refreshToken, data: {
        'refreshToken': refreshToken,
      });

      final newAccessToken = response.data['accessToken'] as String;
      await SecureStorageService.instance.saveAccessToken(newAccessToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) =>
      _dio.get(path, queryParameters: query);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
