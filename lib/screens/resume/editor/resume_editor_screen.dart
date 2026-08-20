import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/score_ring.dart';
import '../../../models/resume_model.dart';
import '../../../models/resume_template.dart';
import '../../../providers/resume_editor_provider.dart';
import '../../../repositories/resume_repository.dart';
import '../../../providers/resume_progress_provider.dart';
import '../../../providers/resume_provider.dart';
import '../../../services/pdf/pdf_generator.dart';
import '../ai/ai_career_tools_screen.dart';
import '../preview/resume_preview_screen.dart';
import '../template/template_picker_screen.dart';
import 'sections/achievements_section.dart';
import 'sections/certifications_section.dart';
import 'sections/education_section.dart';
import 'sections/experience_section.dart';
import 'sections/languages_section.dart';
import 'sections/personal_info_section.dart';
import 'sections/professional_summary_section.dart';
import 'sections/projects_section.dart';
import 'sections/references_section.dart';
import 'sections/skills_section.dart';

// A fresh, screen-scoped ResumeEditorNotifier per mount. Without this, the
// provider was a single app-lifetime singleton: switching from one resume's
// editor straight to another's could flash the previous resume's data before
// loadById() overwrote it, and a pending autosave debounce from the previous
// resume could linger across the navigation.
class ResumeEditorScreen extends StatelessWidget {
  final String resumeId;
  const ResumeEditorScreen({super.key, required this.resumeId});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        resumeEditorProvider.overrideWith(
          (ref) => ResumeEditorNotifier(ref.read(resumeRepositoryProvider), ref),
        ),
      ],
      child: _ResumeEditorView(resumeId: resumeId),
    );
  }
}

class _ResumeEditorView extends ConsumerStatefulWidget {
  final String resumeId;
  const _ResumeEditorView({required this.resumeId});

  @override
  ConsumerState<_ResumeEditorView> createState() => _ResumeEditorViewState();
}

class _ResumeEditorViewState extends ConsumerState<_ResumeEditorView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resumeEditorProvider.notifier).loadById(widget.resumeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(resumeEditorProvider);
    final editorNotifier = ref.read(resumeEditorProvider.notifier);

    return PopScope(
      // canPop: false + an async gate before manually popping is what
      // previously caused 'package:flutter/src/widgets/framework.dart':
      // Failed assertion: '_dependents.isEmpty': is not true. - blocking the
      // pop and completing it later fights with Android's predictive-back
      // handling whenever a dialog/bottom sheet (Resume Score, Cover Letter)
      // is open on top of this route, tearing down this screen's
      // ProviderScope while the modal's element tree still depends on it.
      // Letting the pop happen immediately and firing the flush afterward
      // (already backed by the 10s autosave debounce and the Save Draft
      // button) avoids that race entirely.
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        if (ref.read(resumeEditorProvider).dirty) {
          ref.read(resumeEditorProvider.notifier).saveDraft();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            editorState.resume.title.isEmpty
                ? 'Resume Editor'
                : editorState.resume.title,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Change Template',
              onPressed: () => _pickTemplate(context),
            ),
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              tooltip: 'Resume Score',
              onPressed: () => _showAiScore(context),
            ),
            IconButton(
              icon: const Icon(Icons.psychology_outlined),
              tooltip: 'AI Career Tools',
              onPressed: () => _openAiCareerTools(context),
            ),
            IconButton(
              icon: const Icon(Icons.description_outlined),
              tooltip: 'Generate Cover Letter',
              onPressed: () => _showCoverLetterDialog(context),
            ),
          ],
        ),
        body: editorState.resume.id.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref2, _) {
                        final prog = ref2.watch(resumeEditorProvider).resume;
                        final p = ref2.watch(resumeProgressProvider(prog));
                        return PremiumCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ScoreRing(value: p.percent, size: 72, strokeWidth: 7, valueColor: AppColors.forScore(p.percent)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Resume Strength: ${p.strength}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.missingSections.isEmpty
                                          ? 'All key sections complete!'
                                          : 'Missing: ${p.missingSections.join(', ')}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildAiCareerToolsSection(context),
                    const SizedBox(height: 12),
                    // Responsive section grid: single column on narrow screens,
                    // two columns on wide screens for a compact, professional layout.
                    LayoutBuilder(builder: (context, constraints) {
                      final sections = <Widget>[
                        const PremiumCard(child: PersonalInfoSection()),
                        const PremiumCard(child: ProfessionalSummarySection()),
                        const PremiumCard(child: EducationSection()),
                        const PremiumCard(child: ExperienceSection()),
                        const PremiumCard(child: ProjectsSection()),
                        const PremiumCard(child: SkillsSection()),
                        const PremiumCard(child: CertificationsSection()),
                        const PremiumCard(child: LanguagesSection()),
                        const PremiumCard(child: AchievementsSection()),
                        const PremiumCard(child: ReferencesSection()),
                      ];

                      if (constraints.maxWidth >= 900) {
                        // Two-column grid with consistent spacing and min card width
                        final gutter = 16.0;
                        final totalWidth = constraints.maxWidth - gutter;
                        final half = (totalWidth / 2) - (gutter / 2);
                        final cardWidth = half.clamp(420.0, half);
                        return Wrap(
                          spacing: gutter,
                          runSpacing: 16,
                          children: sections.map((w) => SizedBox(width: cardWidth, child: w)).toList(),
                        );
                      }

                      return Column(
                        children: sections.expand((w) => [w, const SizedBox(height: 12)]).toList(),
                      );
                    }),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
        bottomSheet: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha((0.06 * 255).round()), blurRadius: 12, offset: const Offset(0, -4)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async => await editorNotifier.saveDraft(),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Draft'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _openPreview(context, editorState.resume),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Preview'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _exportPdf(context, editorState.resume),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('Export PDF'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  ),
                  const SizedBox(width: 20),
                  if (editorState.isSaving)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text('Saving...', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    )
                  else if (editorState.saveMessage.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          editorState.saveMessage == 'Saved' ? Icons.check_circle_outline : Icons.error_outline,
                          size: 16,
                          color: editorState.saveMessage == 'Saved' ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(editorState.saveMessage, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTemplate(BuildContext context) async {
    final currentId = ref.read(resumeEditorProvider).resume.template;
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => TemplatePickerScreen(currentTemplateId: currentId)),
    );
    if (result == null || result == currentId) return;
    await ref.read(resumeEditorProvider.notifier).updateTemplate(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Template changed to ${ResumeTemplateType.fromId(result).label}')),
    );
  }

  Future<void> _openAiCareerTools(BuildContext context) async {
    final resume = ref.read(resumeEditorProvider).resume;
    final appliedSummary = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => AiCareerToolsScreen(resume: resume)),
    );
    if (appliedSummary == null || appliedSummary.isEmpty) return;
    ref.read(resumeEditorProvider.notifier).updateSummary(appliedSummary);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary updated from AI Career Tools')),
    );
  }

  void _openPreview(BuildContext context, ResumeModel resume) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResumePreviewScreen(resume: resume)),
    );
  }

  Future<void> _exportPdf(BuildContext context, ResumeModel resume) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Expanded(child: Text('Generating PDF...')),
        ]),
      ),
    );

    try {
      final bytes = await PdfGenerator.generate(resume);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      final safeName = resume.title.isEmpty ? 'resume' : resume.title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      await Printing.sharePdf(bytes: bytes, filename: '$safeName.pdf');
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to generate PDF'),
          action: SnackBarAction(label: 'Retry', onPressed: () => _exportPdf(context, resume)),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _sectionItemMaps(ResumeModel resume, String key) {
    final matches = resume.sections.where((s) => s.key == key);
    if (matches.isEmpty) return [];
    return matches.first.items.map((it) => it.data).toList();
  }

  List<String> _skillNames(ResumeModel resume) {
    return _sectionItemMaps(resume, 'skills').map((d) => (d['name'] ?? '').toString()).where((s) => s.isNotEmpty).toList();
  }

  void _showAiScore(BuildContext context) {
    final repo = ref.read(resumeRepositoryProvider);
    final resume = ref.read(resumeEditorProvider).resume;
    final jdController = TextEditingController();

    Future<Map<String, dynamic>> fetchScore({String? jobDescription}) {
      return repo.scoreResume(
        summary: resume.summary.isEmpty ? null : resume.summary,
        experience: _sectionItemMaps(resume, 'experience'),
        education: _sectionItemMaps(resume, 'education'),
        skills: _skillNames(resume),
        projects: _sectionItemMaps(resume, 'projects'),
        jobDescription: jobDescription,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var scoreFuture = fetchScore();
        String? jdError;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: scoreFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('Failed to score resume'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setSheetState(() => scoreFuture = fetchScore()),
                              child: const Text('Retry'),
                            ),
                          ]),
                        ),
                      );
                    }
                    final data = snapshot.data!;
                    final score = (data['score'] as num?)?.round() ?? 0;
                    final strengths = (data['strengths'] as List?)?.map((e) => e.toString()).toList() ?? [];
                    final improvements = (data['improvements'] as List?)?.map((e) => e.toString()).toList() ?? [];
                    final completeness = data['completeness'] as Map<String, dynamic>?;
                    final completenessPercent = (completeness?['percent'] as num?)?.round();
                    final missingSections = (completeness?['missingSections'] as List?)?.map((e) => e.toString()).toList() ?? [];
                    final keywordMatch = data['keywordMatch'] as Map<String, dynamic>?;
                    final matchedKeywords = (keywordMatch?['matched'] as List?)?.map((e) => e.toString()).toList() ?? [];
                    final missingKeywords = (keywordMatch?['missing'] as List?)?.map((e) => e.toString()).toList() ?? [];
                    final matchPercentage = (keywordMatch?['matchPercentage'] as num?)?.round();
                    return ListView(
                      controller: scrollController,
                      // Bottom padding grows with the keyboard so the
                      // job-description field below is never covered by it.
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
                      children: [
                        Center(
                          child: Column(children: [
                            ScoreRing(value: score, label: '/ 100'),
                            const SizedBox(height: 8),
                            Text('Resume Score', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ]),
                        ),
                        if (completenessPercent != null) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Completeness', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('$completenessPercent%', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.forScore(completenessPercent))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: completenessPercent / 100.0,
                              minHeight: 8,
                              color: AppColors.forScore(completenessPercent),
                            ),
                          ),
                          if (missingSections.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Missing: ${missingSections.join(', ')}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                            ),
                          ],
                        ],
                        const Divider(height: 32),
                        Text('Match against a job description (optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: jdController,
                          maxLines: 3,
                          onChanged: (_) {
                            if (jdError != null) setSheetState(() => jdError = null);
                          },
                          decoration: InputDecoration(
                            hintText: 'Paste a job description to see how well your resume matches it...',
                            border: const OutlineInputBorder(),
                            // Shown inline rather than via a SnackBar - a
                            // SnackBar targets the underlying page's
                            // Scaffold and renders behind this modal sheet,
                            // making it invisible while the sheet is open.
                            errorText: jdError,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final jd = jdController.text.trim();
                              if (jd.isEmpty) {
                                setSheetState(() => jdError = 'Paste a job description first to check the match.');
                                return;
                              }
                              setSheetState(() {
                                jdError = null;
                                scoreFuture = fetchScore(jobDescription: jd);
                              });
                            },
                            icon: const Icon(Icons.compare_arrows, size: 18),
                            label: const Text('Check Match'),
                          ),
                        ),
                        const Divider(height: 32),
                        if (strengths.isNotEmpty) ...[
                          Text('Strengths', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...strengths.map((s) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(s)),
                                ]),
                              )),
                          const SizedBox(height: 16),
                        ],
                        if (improvements.isNotEmpty) ...[
                          Text('Suggested Improvements', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...improvements.map((s) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(s)),
                                ]),
                              )),
                        ],
                        if (keywordMatch != null) ...[
                          const Divider(height: 32),
                          Text('Keyword Match', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (matchPercentage != null)
                            Text('$matchPercentage% of the job description\'s key terms appear in your resume.'),
                          const SizedBox(height: 12),
                          if (matchedKeywords.isNotEmpty) ...[
                            const Text('Matched', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: matchedKeywords
                                  .map((k) => Chip(
                                        label: Text(k),
                                        backgroundColor: Colors.green.withAlpha((0.14 * 255).round()),
                                        side: BorderSide.none,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (missingKeywords.isNotEmpty) ...[
                            const Text('Missing', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: missingKeywords
                                  .map((k) => Chip(
                                        label: Text(k),
                                        backgroundColor: Colors.grey.withAlpha((0.14 * 255).round()),
                                        side: BorderSide.none,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
    // Deliberately not disposed here: .then() on the sheet's Future fires
    // as soon as the route is popped, before its exit-transition animation
    // finishes rebuilding the still-focused TextField, and hits "A
    // TextEditingController was used after being disposed." This is a
    // small, short-lived controller - once this closure is released it's
    // eligible for normal garbage collection without an explicit dispose().
  }

  void _showCoverLetterDialog(BuildContext context) {
    final repo = ref.read(resumeRepositoryProvider);
    final resume = ref.read(resumeEditorProvider).resume;
    final jobTitleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final jobDescriptionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Generate Cover Letter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: jobTitleCtrl, decoration: const InputDecoration(labelText: 'Job Title')),
                const SizedBox(height: 8),
                TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Company')),
                const SizedBox(height: 8),
                TextField(
                  controller: jobDescriptionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Job description (optional, for tailoring)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final jobTitle = jobTitleCtrl.text.trim();
                final company = companyCtrl.text.trim();
                if (jobTitle.isEmpty || company.isEmpty) return;
                Navigator.of(dialogContext).pop();
                _generateAndShowCoverLetter(context, repo, resume, jobTitle, company, jobDescriptionCtrl.text.trim());
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
    // Deliberately not disposed here: .then() on the dialog's Future fires
    // as soon as the route is popped, before its exit-transition animation
    // finishes rebuilding the still-focused TextField, and hits "A
    // TextEditingController was used after being disposed." These are
    // small, short-lived controllers - once this closure is released they're
    // eligible for normal garbage collection without an explicit dispose().
  }

  void _generateAndShowCoverLetter(BuildContext context, ResumeRepository repo, ResumeModel resume, String jobTitle, String company, [String? jobDescription]) {
    // Persisted to the resume (via the standard editor save path) as soon as
    // it's generated, so it survives closing the sheet / app restart.
    // Regenerating only ever touches this one field, never other data.
    Future<String> fetchLetter() async {
      final text = await repo.generateCoverLetter(
        jobTitle: jobTitle,
        company: company,
        jobDescription: (jobDescription == null || jobDescription.isEmpty) ? null : jobDescription,
        summary: resume.summary.isEmpty ? null : resume.summary,
        experience: _sectionItemMaps(resume, 'experience')
            .map((d) => '${d['position'] ?? ''} at ${d['company'] ?? ''}')
            .where((s) => s.trim().isNotEmpty)
            .toList(),
      );
      await ref.read(resumeEditorProvider.notifier).updateCoverLetter(text);
      return text;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var letterFuture = fetchLetter();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return FutureBuilder<String>(
                  future: letterFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('Failed to generate cover letter'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setSheetState(() => letterFuture = fetchLetter()),
                              child: const Text('Retry'),
                            ),
                          ]),
                        ),
                      );
                    }
                    final text = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cover Letter', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy to clipboard',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: text));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(
                                'Saved to this resume',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success),
                              ),
                            ],
                          ),
                          const Divider(),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Text(text),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAiCareerToolsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tools = [
      _AiToolItem(
        icon: Icons.analytics_outlined,
        title: 'Resume Score',
        subtitle: 'ATS score & feedback',
        color: const Color(0xFF3B82F6),
        onTap: () => _showAiScore(context),
      ),
      _AiToolItem(
        icon: Icons.psychology_outlined,
        title: 'AI Suggestions',
        subtitle: 'Tailoring & smart insights',
        color: const Color(0xFF8B5CF6),
        onTap: () => _openAiCareerTools(context),
      ),
      _AiToolItem(
        icon: Icons.description_outlined,
        title: 'Cover Letter',
        subtitle: 'Job-targeted letters',
        color: const Color(0xFF10B981),
        onTap: () => _showCoverLetterDialog(context),
      ),
      _AiToolItem(
        icon: Icons.palette_outlined,
        title: 'Templates',
        subtitle: 'Change style & layout',
        color: const Color(0xFFF59E0B),
        onTap: () => _pickTemplate(context),
      ),
    ];

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Career Tools',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AI ASSISTED',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 720) {
                return Row(
                  children: tools.map((tool) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildToolCard(context, tool, isDark),
                      ),
                    );
                  }).toList(),
                );
              } else if (constraints.maxWidth >= 420) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildToolCard(context, tools[0], isDark)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildToolCard(context, tools[1], isDark)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildToolCard(context, tools[2], isDark)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildToolCard(context, tools[3], isDark)),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: tools.map((tool) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildToolCard(context, tool, isDark),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _AiToolItem tool, bool isDark) {
    final theme = Theme.of(context);
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : theme.colorScheme.outline.withAlpha(35);
    final cardBg = isDark
        ? AppColors.darkSurfaceHigh
        : theme.colorScheme.surfaceVariant.withAlpha(80);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tool.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tool.color.withAlpha(28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(tool.icon, color: tool.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tool.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((0.65 * 255).round()),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.colorScheme.onSurface.withAlpha((0.35 * 255).round()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AiToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
