// Widget-level proof that the AI Career Tools screen's button -> loading ->
// result pipeline works, independent of any real network call or emulator/
// ADB touch delivery (which has proven flaky for manual verification of this
// screen - see project memory). Overrides resumeRepositoryProvider with a
// fake that returns canned data instead of hitting the network, then drives
// a real tap through Flutter's test framework and asserts the result renders.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_resume_maker/models/resume_model.dart';
import 'package:ai_resume_maker/providers/resume_provider.dart';
import 'package:ai_resume_maker/repositories/resume_repository.dart';
import 'package:ai_resume_maker/screens/resume/ai/ai_career_tools_screen.dart';
import 'package:ai_resume_maker/services/api_service.dart';

class _FakeResumeRepository extends ResumeRepository {
  _FakeResumeRepository() : super(apiService: ApiService());

  @override
  Future<Map<String, dynamic>> reviewResume({
    String? summary,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
    List<String>? skills,
    List<Map<String, dynamic>>? projects,
  }) async {
    return {
      'strong': ['Clear professional summary'],
      'weak': <String>[],
      'missing': <String>[],
      'unclear': <String>[],
      'topPriorities': ['Add work experience'],
    };
  }
}

void main() {
  testWidgets('AI Career Tools: tapping Review Resume runs the request and renders the result', (tester) async {
    final resume = ResumeModel(
      id: 'r1',
      title: 'Test Resume',
      summary: 'Backend engineer with distributed systems experience.',
      sections: const [],
      status: 'draft',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [resumeRepositoryProvider.overrideWithValue(_FakeResumeRepository())],
        child: MaterialApp(home: AiCareerToolsScreen(resume: resume)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review Resume'), findsOneWidget);
    expect(find.text('Add work experience'), findsNothing);

    await tester.tap(find.text('Review Resume'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Add work experience'), findsOneWidget);
    expect(find.text('Clear professional summary'), findsOneWidget);
  });
}
