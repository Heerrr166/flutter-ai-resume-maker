import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((_) => SecureStorageService());
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(secureStorage: ref.read(secureStorageProvider));
});
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(apiService: ref.read(apiServiceProvider));
});
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
    ref.read(apiServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository, this._storage, this._apiService) : super(AuthState.initial()) {
    _apiService.onSessionExpired = clearAuth;
    _loadStoredAuth();
  }

  final AuthRepository _authRepository;
  final SecureStorageService _storage;
  final ApiService _apiService;

  Future<void> _loadStoredAuth() async {
    state = state.copyWith(isBootstrapping: true, errorMessage: null);

    final storedAccessToken = await _storage.readAccessToken();
    final storedRefreshToken = await _storage.readRefreshToken();

    if (storedAccessToken != null) {
      _apiService.updateAccessToken(storedAccessToken);
      try {
        final user = await _authRepository.fetchProfile();
        state = state.copyWith(
          isBootstrapping: false,
          user: user,
          accessToken: storedAccessToken,
          refreshToken: storedRefreshToken,
        );
        return;
      } catch (error) {
        if (storedRefreshToken != null) {
          try {
            final accessToken = await _authRepository.refreshAccessToken(refreshToken: storedRefreshToken);
            await _storage.saveAccessToken(accessToken);
            _apiService.updateAccessToken(accessToken);
            final user = await _authRepository.fetchProfile();
            state = state.copyWith(
              isBootstrapping: false,
              user: user,
              accessToken: accessToken,
              refreshToken: storedRefreshToken,
            );
            return;
          } catch (_) {
            // Fall through to clear auth state.
          }
        }
      }
    }

    await clearAuth();
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authRepository.login(email: email, password: password);
      final user = result['user'] as dynamic;
      final accessToken = result['accessToken'] as String;
      final refreshToken = result['refreshToken'] as String;

      await _storage.saveAccessToken(accessToken);
      await _storage.saveRefreshToken(refreshToken);
      _apiService.updateAccessToken(accessToken);

      state = state.copyWith(
        isLoading: false,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapError(error, stackTrace),
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(isLoading: false, errorMessage: _mapError(error, stackTrace));
      return false;
    }
  }

  Future<String?> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final message = await _authRepository.forgotPassword(email: email);
      state = state.copyWith(isLoading: false);
      return message;
    } catch (error, stackTrace) {
      state = state.copyWith(isLoading: false, errorMessage: _mapError(error, stackTrace));
      return null;
    }
  }

  Future<String?> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final message = await _authRepository.resetPassword(email: email, otp: otp, password: password);
      state = state.copyWith(isLoading: false);
      return message;
    } catch (error, stackTrace) {
      state = state.copyWith(isLoading: false, errorMessage: _mapError(error, stackTrace));
      return null;
    }
  }

  Future<bool> updateProfile({required String fullName, required String phone}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedUser = await _authRepository.updateProfile(fullName: fullName, phone: phone);
      state = state.copyWith(isLoading: false, user: updatedUser);
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(isLoading: false, errorMessage: _mapError(error, stackTrace));
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = state.refreshToken;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (refreshToken != null) {
        await _authRepository.logout(refreshToken: refreshToken);
      }
    } catch (_) {
      // Ignore logout failures; still clear local auth.
    } finally {
      await clearAuth();
    }
  }

  Future<void> clearAuth() async {
    await _storage.clearAll();
    _apiService.updateAccessToken(null);
    // Not AuthState.initial() — that means "still checking storage"
    // (isBootstrapping: true), which the router treats as "always redirect
    // to splash". Once we've concluded there's no valid session, bootstrap
    // is done and the router needs isBootstrapping: false to route to
    // onboarding/login instead of stalling forever.
    state = const AuthState(isBootstrapping: false, isLoading: false, user: null, accessToken: null, refreshToken: null);
  }

  String _mapError(Object error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      // The backend already sends a specific, user-safe message for
      // expected failures (wrong credentials, duplicate email, etc.) -
      // surface that verbatim rather than a generic one.
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        return responseData['message'] as String;
      }
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Unable to connect to the server. Please check your connection.';
        default:
          break;
      }
      if ((error.response?.statusCode ?? 0) >= 500) {
        return 'Something went wrong on our end. Please try again later.';
      }
      return 'Unexpected network error. Please try again.';
    }
    if (error is String) {
      return error;
    }
    // Anything else failed outside the network layer entirely (token
    // storage, response parsing, etc). The user only ever sees the generic
    // message below - log the real error so it's diagnosable instead of
    // silently indistinguishable from every other unexpected failure.
    debugPrint('Unexpected auth error: $error\n$stackTrace');
    return 'Something went wrong. Please try again.';
  }
}
