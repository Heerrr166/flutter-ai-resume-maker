import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/score_ring.dart';
import '../../../models/resume_model.dart';
import '../../../providers/resume_provider.dart';

// A single hub for the newer, natural-language-heavy AI features (job
// analysis, resume/job match, tailoring, review, career insights, interview
// prep) so they read as one coherent assistant rather than buttons scattered
// across every section. Takes a read-only snapshot of the resume being
// edited (same pattern as ResumePreviewScreen/TemplatePickerScreen - this
// screen is pushed onto the root Navigator, outside the editor's local
// ProviderScope, so it can't watch resumeEditorProvider directly). The only
// write-back is "Apply to Summary", done by popping with the suggested text
// so the caller applies it through the editor's own provider - this screen
// never mutates resume data on its own.
class AiCareerToolsScreen extends ConsumerStatefulWidget {
  final ResumeModel resume;
  const AiCareerToolsScreen({super.key, required this.resume});

  @override
  ConsumerState<AiCareerToolsScreen> createState() => _AiCareerToolsScreenState();
}

class _AiCareerToolsScreenState extends ConsumerState<AiCareerToolsScreen> {
  final _jdCtrl = TextEditingController();
  final _targetRoleCtrl = TextEditingController();

  @override
  void dispose() {
    _jdCtrl.dispose();
    _targetRoleCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _sectionMaps(String key) {
    final matches = widget.resume.sections.where((s) => s.key == key);
    if (matches.isEmpty) return [];
    return matches.first.items.map((it) => it.data).toList();
  }

  List<String> _skillNames() {
    return _sectionMaps('skills').map((d) => (d['name'] ?? '').toString()).where((s) => s.isNotEmpty).toList();
  }

  void _applySuggestedSummary(String text) {
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final experience = _sectionMaps('experience');
    final education = _sectionMaps('education');
    final projects = _sectionMaps('projects');
    final skills = _skillNames();
    final summary = widget.resume.summary.isEmpty ? null : widget.resume.summary;
    final repo = ref.read(resumeRepositoryProvider);

    final hasProfile = summary != null || experience.isNotEmpty || education.isNotEmpty || skills.isNotEmpty || projects.isNotEmpty;
    final hasQuestionMaterial = experience.isNotEmpty || projects.isNotEmpty || skills.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Career Tools')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.accent.withAlpha((0.12 * 255).round()), shape: BoxShape.circle),
                    child: Icon(Icons.description_outlined, size: 18, color: AppColors.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Target Job Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 8),
                Text(
                  'Paste it once here - Job Analysis, Match, Tailoring, and Interview Prep below all use it.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _jdCtrl,
                  maxLines: 6,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Paste the job description here...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AiFeatureCard<Map<String, dynamic>>(
            title: 'Review My Resume',
            icon: Icons.fact_check_outlined,
            buttonLabel: 'Review Resume',
            disabledReason: hasProfile ? null : 'Add some resume content first.',
            onRun: () => repo.reviewResume(summary: summary, experience: experience, education: education, skills: skills, projects: projects),
            resultBuilder: _buildReview,
          ),
          const SizedBox(height: 12),
          _AiFeatureCard<Map<String, dynamic>>(
            title: 'Job Description Analysis',
            icon: Icons.travel_explore_outlined,
            buttonLabel: 'Analyze Job',
            disabledReason: _jdCtrl.text.trim().isEmpty ? 'Paste a job description above first.' : null,
            onRun: () => repo.analyzeJobDescription(jobDescription: _jdCtrl.text.trim()),
            resultBuilder: _buildJdAnalysis,
          ),
          const SizedBox(height: 12),
          _AiFeatureCard<Map<String, dynamic>>(
            title: 'Resume & Job Match',
            icon: Icons.compare_arrows,
            buttonLabel: 'Check Match',
            disabledReason: _jdCtrl.text.trim().isEmpty ? 'Paste a job description above first.' : null,
            onRun: () => repo.matchResumeToJob(
              jobDescription: _jdCtrl.text.trim(),
              summary: summary,
              experience: experience,
              education: education,
              skills: skills,
              projects: projects,
            ),
            resultBuilder: _buildMatch,
          ),
          const SizedBox(height: 12),
          _AiFeatureCard<Map<String, dynamic>>(
            title: 'Tailor Resume to This Job',
            icon: Icons.tune,
            buttonLabel: 'Tailor Resume',
            disabledReason: _jdCtrl.text.trim().isEmpty ? 'Paste a job description above first.' : null,
            onRun: () => repo.tailorResume(
              jobDescription: _jdCtrl.text.trim(),
              summary: summary,
              experience: experience,
              skills: skills,
              projects: projects,
            ),
            resultBuilder: (ctx, data) => _buildTailor(ctx, data),
          ),
          const SizedBox(height: 12),
          _AiFeatureCard<Map<String, dynamic>>(
            title: 'Career Insights',
            icon: Icons.insights_outlined,
            buttonLabel: 'Get Insights',
            disabledReason: hasProfile ? null : 'Add some resume content first.',
            extra: TextField(
              controller: _targetRoleCtrl,
              decoration: const InputDecoration(labelText: 'Target role (optional)', border: OutlineInputBorder()),
            ),
            onRun: () => repo.careerInsights(
              summary: summary,
              experience: experience,
              skills: skills,
              projects: projects,
              targetRole: _targetRoleCtrl.text.trim().isEmpty ? null : _targetRoleCtrl.text.trim(),
            ),
            resultBuilder: _buildCareer,
          ),
          const SizedBox(height: 12),
          _AiFeatureCard<Map<String, dynamic>>(
            title: 'Interview Preparation',
            icon: Icons.record_voice_over_outlined,
            buttonLabel: 'Generate Questions',
            disabledReason: hasQuestionMaterial ? null : 'Add some experience, projects, or skills first.',
            onRun: () => repo.interviewPrep(
              experience: experience,
              projects: projects,
              skills: skills,
              jobDescription: _jdCtrl.text.trim().isEmpty ? null : _jdCtrl.text.trim(),
            ),
            resultBuilder: _buildInterview,
          ),
        ],
      ),
    );
  }

  // ---------- result renderers ----------

  Widget _buildReview(BuildContext context, Map<String, dynamic> data) {
    final top = _strList(data['topPriorities']);
    final strong = _strList(data['strong']);
    final weak = _strList(data['weak']);
    final missing = _strList(data['missing']);
    final unclear = _strList(data['unclear']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (top.isNotEmpty) ...[
          _label(context, 'Top Priorities'),
          const SizedBox(height: 6),
          ...top.asMap().entries.map((e) => _priorityRow(context, e.key + 1, e.value)),
          const SizedBox(height: 12),
        ],
        if (strong.isNotEmpty) _iconListGroup(context, "What's Strong", strong, Icons.check_circle_outline, AppColors.success),
        if (weak.isNotEmpty) _iconListGroup(context, "What's Weak", weak, Icons.trending_down, AppColors.warning),
        if (missing.isNotEmpty) _iconListGroup(context, "What's Missing", missing, Icons.remove_circle_outline, AppColors.error),
        if (unclear.isNotEmpty) _iconListGroup(context, 'Unclear / Vague', unclear, Icons.help_outline, Colors.grey),
      ],
    );
  }

  Widget _buildJdAnalysis(BuildContext context, Map<String, dynamic> data) {
    final role = (data['role'] ?? '').toString();
    final seniority = (data['seniority'] ?? '').toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (role.isNotEmpty) _kv(context, 'Role', role),
        if (seniority.isNotEmpty) _kv(context, 'Seniority', seniority),
        const SizedBox(height: 8),
        _chipGroup(context, 'Required Skills', _strList(data['requiredSkills']), AppColors.accent),
        _chipGroup(context, 'Soft Skills', _strList(data['softSkills']), AppColors.success),
        _bulletGroup(context, 'Responsibilities', _strList(data['responsibilities'])),
        _bulletGroup(context, 'Experience Requirements', _strList(data['experienceRequirements'])),
        _bulletGroup(context, 'Education Requirements', _strList(data['educationRequirements'])),
        _chipGroup(context, 'Keywords', _strList(data['keywords']), Colors.grey),
      ],
    );
  }

  Widget _buildMatch(BuildContext context, Map<String, dynamic> data) {
    final overall = ((data['overallMatch'] as num?) ?? 0).round();
    final skillsMatch = ((data['skillsMatch'] as num?) ?? 0).round();
    final expRel = ((data['experienceRelevance'] as num?) ?? 0).round();
    final eduRel = ((data['educationRelevance'] as num?) ?? 0).round();
    final missing = _strList(data['missingSkills']);
    final recs = _strList(data['recommendations']);
    final semantic = (data['semanticAnalysis'] ?? '').toString();
    final km = data['keywordMatch'] as Map<String, dynamic>?;
    final kmPct = (km?['matchPercentage'] as num?)?.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(children: [
            ScoreRing(value: overall, label: '/ 100'),
            const SizedBox(height: 6),
            Text('Overall Match', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 16),
        _metricBar(context, 'Skills Match', skillsMatch),
        _metricBar(context, 'Experience Relevance', expRel),
        _metricBar(context, 'Education Relevance', eduRel),
        if (kmPct != null) _metricBar(context, 'Keyword Match', kmPct),
        _chipGroup(context, 'Missing Skills', missing, AppColors.warning),
        if (semantic.isNotEmpty) ...[
          const SizedBox(height: 8),
          _label(context, 'AI Analysis'),
          const SizedBox(height: 4),
          Text(semantic),
        ],
        _bulletGroup(context, 'Recommendations', recs),
      ],
    );
  }

  Widget _buildTailor(BuildContext context, Map<String, dynamic> data) {
    final skillsToHighlight = _strList(data['skillsToHighlight']);
    final bullets = _strList(data['bulletsToEmphasize']);
    final projects = _strList(data['projectsToEmphasize']);
    final keywords = _strList(data['keywordsToIncorporate']);
    final sections = _strList(data['sectionsNeedingImprovement']);
    final suggestedSummary = (data['suggestedSummary'] as String?)?.trim();
    final rewrittenBullets = ((data['rewrittenBullets'] as List?) ?? [])
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (suggestedSummary != null && suggestedSummary.isNotEmpty) ...[
          _label(context, 'Suggested Summary'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
            child: Text(suggestedSummary),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _applySuggestedSummary(suggestedSummary),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Apply to Summary'),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (rewrittenBullets.isNotEmpty) ...[
          _label(context, 'Rewritten Bullets (tap copy to use)'),
          const SizedBox(height: 6),
          ...rewrittenBullets.map((b) => _bulletRewriteCard(context, (b['original'] ?? '').toString(), (b['rewritten'] ?? '').toString())),
          const SizedBox(height: 12),
        ] else if (bullets.isNotEmpty)
          _bulletGroup(context, 'Bullets to Emphasize', bullets),
        _chipGroup(context, 'Skills to Highlight', skillsToHighlight, AppColors.success),
        _chipGroup(context, 'Projects to Emphasize', projects, AppColors.accent),
        _chipGroup(context, 'Keywords to Incorporate (only if truthful)', keywords, AppColors.warning),
        _bulletGroup(context, 'Sections Needing Improvement', sections),
      ],
    );
  }

  Widget _buildCareer(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advisory recommendations, not guarantees.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        _chipGroup(context, 'Suitable Roles', _strList(data['suitableRoles']), AppColors.primary),
        _chipGroup(context, 'Skills to Strengthen', _strList(data['skillsToStrengthen']), AppColors.accent),
        _chipGroup(context, 'Missing Common Skills', _strList(data['missingCommonSkills']), AppColors.warning),
        _bulletGroup(context, 'Learning Priorities', _strList(data['learningPriorities'])),
        _bulletGroup(context, 'Resume Improvement Priorities', _strList(data['resumeImprovementPriorities'])),
      ],
    );
  }

  Widget _buildInterview(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'For preparation only - this does not predict the actual interview.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        _questionGroup(context, 'About Your Projects', _strList(data['projectQuestions'])),
        _questionGroup(context, 'About Your Technologies', _strList(data['technologyQuestions'])),
        _questionGroup(context, 'General', _strList(data['generalQuestions'])),
        _questionGroup(context, 'Behavioral', _strList(data['behavioralQuestions'])),
        _chipGroup(context, 'Topics to Review', _strList(data['preparationTopics']), AppColors.accent),
      ],
    );
  }
}

// ---------- shared small widgets/helpers ----------

List<String> _strList(dynamic v) => (v as List?)?.map((e) => e.toString()).where((s) => s.isNotEmpty).toList() ?? [];

Widget _label(BuildContext context, String text) => Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold));

Widget _kv(BuildContext context, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );

Widget _chipGroup(BuildContext context, String title, List<String> items, Color color) {
  if (items.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, title),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((s) => Chip(
                    label: Text(s),
                    backgroundColor: color.withAlpha((0.14 * 255).round()),
                    side: BorderSide.none,
                  ))
              .toList(),
        ),
      ],
    ),
  );
}

Widget _bulletGroup(BuildContext context, String title, List<String> items) {
  if (items.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, title),
        const SizedBox(height: 6),
        ...items.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('•  '),
                Expanded(child: Text(s)),
              ]),
            )),
      ],
    ),
  );
}

Widget _iconListGroup(BuildContext context, String title, List<String> items, IconData icon, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, title),
        const SizedBox(height: 6),
        ...items.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(s)),
              ]),
            )),
      ],
    ),
  );
}

Widget _priorityRow(BuildContext context, int index, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(radius: 11, backgroundColor: AppColors.primary, child: Text('$index', style: const TextStyle(fontSize: 12, color: Colors.white))),
      const SizedBox(width: 10),
      Expanded(child: Text(text)),
    ]),
  );
}

Widget _metricBar(BuildContext context, String label, int percent) {
  final color = AppColors.forScore(percent);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$percent%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: percent / 100.0, minHeight: 6, color: color),
        ),
      ],
    ),
  );
}

Widget _questionGroup(BuildContext context, String title, List<String> questions) {
  if (questions.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: ExpansionTile(
      title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: questions
          .map((q) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.question_answer_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(q)),
                ]),
              ))
          .toList(),
    ),
  );
}

Widget _bulletRewriteCard(BuildContext context, String original, String rewritten) {
  if (rewritten.isEmpty) return const SizedBox.shrink();
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (original.isNotEmpty)
          Text(original, style: Theme.of(context).textTheme.bodySmall?.copyWith(decoration: TextDecoration.lineThrough, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round()))),
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(rewritten, style: const TextStyle(fontWeight: FontWeight.w600))),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rewritten));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
            },
          ),
        ]),
      ],
    ),
  );
}

// A single reusable AI-action card: title, optional extra input, a run
// button (disabled with a reason when the inputs aren't ready yet), and a
// FutureBuilder-driven result area with loading/error/retry - the same
// interaction shape as the existing Resume Score / Cover Letter sheets in
// resume_editor_screen.dart, generalized so it isn't rewritten six times.
class _AiFeatureCard<T> extends StatefulWidget {
  final String title;
  final IconData icon;
  final String buttonLabel;
  final String? disabledReason;
  final Widget? extra;
  final Future<T> Function() onRun;
  final Widget Function(BuildContext, T) resultBuilder;

  const _AiFeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.buttonLabel,
    required this.onRun,
    required this.resultBuilder,
    this.disabledReason,
    this.extra,
  });

  @override
  State<_AiFeatureCard<T>> createState() => _AiFeatureCardState<T>();
}

class _AiFeatureCardState<T> extends State<_AiFeatureCard<T>> {
  Future<T>? _future;

  void _run() {
    // setState()'s callback must be void - an arrow-bodied closure here
    // (`() => _future = future`) evaluates to the assignment's value, i.e. a
    // Future, which Flutter's setState explicitly detects and throws on
    // ("setState() callback argument returned a Future"). That assertion
    // aborts setState before it calls markNeedsBuild(), so the field was set
    // internally but the screen never actually rebuilt to show it - a block
    // body avoids this entirely.
    final future = widget.onRun();
    setState(() {
      _future = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha((0.12 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
          ]),
          if (widget.extra != null) ...[const SizedBox(height: 12), widget.extra!],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.disabledReason != null ? null : _run,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: Text(widget.buttonLabel),
            ),
          ),
          if (widget.disabledReason != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                widget.disabledReason!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round())),
              ),
            ),
          if (_future != null) ...[
            const Divider(height: 28),
            FutureBuilder<T>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.error_outline, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Something went wrong. Please try again.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _run,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  );
                }
                return widget.resultBuilder(context, snapshot.data as T);
              },
            ),
          ],
        ],
      ),
    );
  }
}
