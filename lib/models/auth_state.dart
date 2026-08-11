import 'user_model.dart';

class AuthState {
  /// True only while the app is checking whether a stored session exists
  /// (the one-time startup check). Distinct from [isLoading], which flags an
  /// individual action (login/register/etc.) in flight - the router used to
  /// key its "still figure out where to go" redirect off [isLoading], which
  /// meant every button press (not just startup) briefly bounced the app
  /// back to the splash screen. A failed login would then fall through
  /// splash's own routing straight to onboarding instead of back to the
  /// login form with its error message.
  final bool isBootstrapping;
  final bool isLoading;
  final String? errorMessage;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({
    required this.isBootstrapping,
    required this.isLoading,
    this.errorMessage,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthState.initial() {
    return const AuthState(
      isBootstrapping: true,
      isLoading: false,
      errorMessage: null,
      user: null,
      accessToken: null,
      refreshToken: null,
    );
  }

  AuthState copyWith({
    bool? isBootstrapping,
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  bool get isAuthenticated => user != null && accessToken != null;
}
