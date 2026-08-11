import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/resume_model.dart';
import '../../../../providers/resume_editor_provider.dart';
import '../../../../providers/resume_provider.dart';

class ProfessionalSummarySection extends ConsumerStatefulWidget {
  const ProfessionalSummarySection({super.key});

  @override
  ConsumerState<ProfessionalSummarySection> createState() =>
      _ProfessionalSummarySectionState();
}

class _ProfessionalSummarySectionState
    extends ConsumerState<ProfessionalSummarySection> {
  final _ctrl = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    if (_ctrl.text.isEmpty && editor.resume.summary.isNotEmpty) {
      _ctrl.text = editor.resume.summary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Professional Summary', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrl,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Write a compelling professional summary...',
          ),
          onChanged: (v) => _onChanged(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('${_ctrl.text.length} chars'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _aiGenerate,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 20),
              label: Text(_isGenerating ? 'Generating...' : 'Generate Summary'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _aiGenerate() async {
    setState(() => _isGenerating = true);
    try {
      final repo = ref.read(resumeRepositoryProvider);
      final resume = ref.read(resumeEditorProvider).resume;
      final experience = resume.sections.firstWhere(
        (s) => s.key == 'experience',
        orElse: () => ResumeSection(key: 'experience', title: '', items: [], order: 0),
      );
      final skillsSection = resume.sections.firstWhere(
        (s) => s.key == 'skills',
        orElse: () => ResumeSection(key: 'skills', title: '', items: [], order: 0),
      );
      final education = resume.sections.firstWhere(
        (s) => s.key == 'education',
        orElse: () => ResumeSection(key: 'education', title: '', items: [], order: 0),
      );

      final generated = await repo.generateSummary(
        currentSummary: _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim(),
        experience: experience.items
            .map((it) => {
                  'position': (it.data['position'] ?? '').toString(),
                  'company': (it.data['company'] ?? '').toString(),
                })
            .toList(),
        skills: skillsSection.items.map((it) => (it.data['name'] ?? '').toString()).where((s) => s.isNotEmpty).toList(),
        education: education.items
            .map((it) => {
                  'degree': (it.data['degree'] ?? '').toString(),
                  'institution': (it.data['institution'] ?? '').toString(),
                })
            .toList(),
      );
      _ctrl.text = generated;
      _onChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Summary generated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to generate summary'),
            action: SnackBarAction(label: 'Retry', onPressed: _aiGenerate),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _onChanged() {
    ref.read(resumeEditorProvider.notifier).updateSummary(_ctrl.text);
  }
}
