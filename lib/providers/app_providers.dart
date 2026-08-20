import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/auth_state.dart';
import '../routes/app_routes.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_overview_screen.dart';
import '../screens/admin/admin_resumes_screen.dart';
import '../screens/admin/admin_analytics_screen.dart';
import '../screens/auth/forgot_password/forgot_password_screen.dart';
import '../screens/auth/login/login_screen.dart';
import '../screens/auth/reset_password/reset_password_screen.dart';
import '../screens/auth/signup/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/resume/editor/resume_editor_screen.dart';
import '../screens/resume/resume_home_screen.dart';
import '../screens/resume/resume_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../services/preferences_service.dart';
import 'auth_provider.dart';

// Overridden in main() once SharedPreferences has loaded, so no screen ever
// reads a stale/default value before persisted settings are available.
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('preferencesServiceProvider must be overridden in main()');
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_fromStored(_prefs.getThemeMode()));

  final PreferencesService _prefs;

  static ThemeMode _fromStored(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void setMode(ThemeMode mode) {
    state = mode;
    _prefs.setThemeMode(switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    });
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(preferencesServiceProvider));
});

// Shared by both settings toggles — a persisted bool with no other behavior
// doesn't need its own notifier class per toggle.
class PersistedBoolNotifier extends StateNotifier<bool> {
  PersistedBoolNotifier(super.initial, this._onChanged);

  final void Function(bool) _onChanged;

  void set(bool value) {
    state = value;
    _onChanged(value);
  }
}

final notificationsEnabledProvider = StateNotifierProvider<PersistedBoolNotifier, bool>((ref) {
  final prefs = ref.read(preferencesServiceProvider);
  return PersistedBoolNotifier(prefs.getNotificationsEnabled(), prefs.setNotificationsEnabled);
});

final weeklySummaryEnabledProvider = StateNotifierProvider<PersistedBoolNotifier, bool>((ref) {
  final prefs = ref.read(preferencesServiceProvider);
  return PersistedBoolNotifier(prefs.getWeeklySummaryEnabled(), prefs.setWeeklySummaryEnabled);
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authNotifierProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

String? _authRedirect(GoRouterState state, AuthState auth) {
  final location = state.matchedLocation;
  final isPublic = AppRoutes.publicRoutes.contains(location);

  if (auth.isBootstrapping) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (auth.isAuthenticated) {
    if (AppRoutes.authEntryRoutes.contains(location)) {
      return AppRoutes.dashboard;
    }
    // Protect any admin route under /admin/*
    if (location.startsWith('/admin') && auth.user?.role != 'admin') {
      return AppRoutes.dashboard;
    }
    return null;
  }

  if (location == AppRoutes.splash) {
    return AppRoutes.onboarding;
  }

  if (!isPublic) {
    return AppRoutes.login;
  }

  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      return _authRedirect(state, auth);
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRoutes.resetPasswordName,
        builder: (context, state) => ResetPasswordScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboardName,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.resume,
        name: AppRoutes.resumeName,
        builder: (context, state) => const ResumeHomeScreen(),
        routes: [
          GoRoute(
            path: 'list',
            name: AppRoutes.resumeListName,
            builder: (context, state) => const ResumeListScreen(),
          ),
          GoRoute(
            path: ':resumeId/edit',
            name: AppRoutes.resumeEditorName,
            builder: (context, state) {
              final resumeId = state.pathParameters['resumeId']!;
              return ResumeEditorScreen(resumeId: resumeId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        name: AppRoutes.adminUsersName,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminOverview,
        name: AppRoutes.adminOverviewName,
        builder: (context, state) => const AdminOverviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminResumes,
        name: AppRoutes.adminResumesName,
        builder: (context, state) => const AdminResumesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAnalytics,
        name: AppRoutes.adminAnalyticsName,
        builder: (context, state) => const AdminAnalyticsScreen(),
      ),
    ],
  );
});
