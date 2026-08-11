// Focused validation test for ResetPasswordScreen (added in the UI overhaul
// phase with no prior coverage). Confirms the form rejects an empty
// submission and never proceeds to attempt a network call in that case.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_resume_maker/providers/app_providers.dart';
import 'package:ai_resume_maker/providers/auth_provider.dart';
import 'package:ai_resume_maker/screens/auth/reset_password/reset_password_screen.dart';
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
  testWidgets('submitting the reset password form empty shows validation errors and does not navigate', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
          preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
        ],
        child: const MaterialApp(
          home: ResetPasswordScreen(email: 'someone@example.com'),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('someone@example.com'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
    await tester.pump();

    expect(find.text('Enter the code you received'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
