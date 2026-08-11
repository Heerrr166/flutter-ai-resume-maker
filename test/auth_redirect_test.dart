// Regression test for a Phase 1 bug: AuthNotifier.clearAuth() used to reset
// state to AuthState.initial(), which hardcodes isLoading: true. Since the
// router's redirect logic treats isLoading: true as "always go to splash",
// and nothing ever set it back to false afterwards, a device with no stored
// session (every first-time user, and anyone right after logout) got stuck
// on the splash screen forever with no way to reach onboarding/login.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_resume_maker/main.dart';
import 'package:ai_resume_maker/providers/app_providers.dart';
import 'package:ai_resume_maker/providers/auth_provider.dart';
import 'package:ai_resume_maker/services/preferences_service.dart';
import 'package:ai_resume_maker/services/secure_storage_service.dart';

class _FakeSecureStorage extends SecureStorageService {
  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> clearAll() async {}
}

void main() {
  testWidgets('a device with no stored session reaches onboarding, not stuck on splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
          preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
        ],
        child: const AiResumeMakerApp(),
      ),
    );

    // Multiple bounded pumps rather than pumpAndSettle: the splash screen
    // runs an infinitely-repeating AnimationController, which would make
    // pumpAndSettle time out waiting for animations to finish.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Welcome to AI Resume Maker'), findsOneWidget);
  });
}
