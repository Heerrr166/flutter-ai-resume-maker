import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import 'secure_storage_service.dart';

class ApiService {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  String? _accessToken;

  // Set by AuthNotifier at construction time so a failed silent-refresh can
  // clear the app's auth state without ApiService depending on Riverpod/auth
  // providers directly (would create a circular provider dependency).
  void Function()? onSessionExpired;

  Future<String?>? _refreshInFlight;

  ApiService({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService(),
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final options = error.requestOptions;
          final isAuthEndpoint = options.path.contains('/auth/');
          final alreadyRetried = options.extra['retriedAfterRefresh'] == true;

          if (error.response?.statusCode != 401 || isAuthEndpoint) {
            return handler.next(error);
          }

          if (alreadyRetried) {
            onSessionExpired?.call();
            return handler.next(error);
          }

          final newToken = await _refreshAccessToken();
          if (newToken == null) {
            onSessionExpired?.call();
            return handler.next(error);
          }

          options.extra['retriedAfterRefresh'] = true;
          options.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } catch (_) {
            return handler.next(error);
          }
        },
      ),
    );
  }

  void updateAccessToken(String? token) {
    _accessToken = token;
  }

  // De-dupes concurrent 401s so only one refresh call is ever in flight.
  Future<String?> _refreshAccessToken() {
    return _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      final newAccessToken = response.data['data']['accessToken'] as String;
      await _secureStorage.saveAccessToken(newAccessToken);
      updateAccessToken(newAccessToken);
      return newAccessToken;
    } catch (_) {
      return null;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data, Duration? receiveTimeout}) async {
    return _dio.post(
      path,
      data: data,
      options: receiveTimeout != null ? Options(receiveTimeout: receiveTimeout) : null,
    );
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {Map<String, dynamic>? data}) async {
    return _dio.delete(path, data: data);
  }
}
