import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resume_model.dart';

class ResumeProgress {
  final int percent;
  final String strength;
  final List<String> missingSections;

  ResumeProgress({required this.percent, required this.strength, required this.missingSections});
}

// autoDispose matters here: ResumeModel has no == / hashCode override, so
// each fetch produces new instances that are distinct family keys — without
// autoDispose, every one of those keyed providers would live for the app's
// entire lifetime instead of being cleaned up once nothing watches it.
final resumeProgressProvider = Provider.autoDispose.family<ResumeProgress, ResumeModel>((ref, resume) {
  // 'summary' isn't a sections entry - it's the resume's own top-level
  // `summary` field (same field the PDF templates read), so its
  // completeness check can't use the sections lookup the other keys share.
  final requiredKeys = ['personal', 'summary', 'education', 'experience', 'projects', 'skills'];
  int total = requiredKeys.length;
  int completed = 0;
  final missing = <String>[];
  for (var key in requiredKeys) {
    final bool done;
    if (key == 'summary') {
      done = resume.summary.trim().isNotEmpty;
    } else {
      final sec = resume.sections.firstWhere((s) => s.key == key, orElse: () => ResumeSection(key: key, title: key, items: [], order: 0));
      done = sec.items.isNotEmpty;
    }
    if (done) {
      completed += 1;
    } else {
      missing.add(key);
    }
  }
  final percent = ((completed / total) * 100).round();
  final strength = percent >= 90 ? 'Excellent' : percent >= 70 ? 'Good' : percent >= 40 ? 'Fair' : 'Weak';
  return ResumeProgress(percent: percent, strength: strength, missingSections: missing);
});
