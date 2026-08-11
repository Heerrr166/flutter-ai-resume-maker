import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../providers/resume_provider.dart';
import '../../../../core/constants/app_spacing.dart';

class ExperienceSection extends ConsumerStatefulWidget {
  const ExperienceSection({super.key});

  @override
  ConsumerState<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends ConsumerState<ExperienceSection> {

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'experience', orElse: () => ResumeSection(key: 'experience', title: 'Experience', items: [], order: 3));
    final items = section.items;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Experience', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (items.isEmpty) const Center(child: Text('No experience entries yet')),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return ListTile(
            key: ValueKey(it.id),
            title: Text(it.data['company'] ?? 'Company', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${it.data['position'] ?? ''} • ${it.data['start'] ?? ''} - ${it.data['end'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.auto_fix_high), tooltip: 'Improve with AI', onPressed: () => _improveExperience(it)),
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _editItem(it)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _confirmDelete(it)),
            ]),
          );
        },
        onReorderItem: (oldIndex, newIndex) {
          final newItems = [...items];
          final el = newItems.removeAt(oldIndex);
          newItems.insert(newIndex, el);
          final updated = ResumeSection(key: section.key, title: section.title, items: newItems, order: section.order);
          ref.read(resumeEditorProvider.notifier).upsertSection(updated);
        },
      ),
      const SizedBox(height: 8),
      Row(children: [ElevatedButton(onPressed: _add, child: const Text('Add Experience'))]),
    ]);
  }

  void _add() {
    final company = TextEditingController();
    final position = TextEditingController();
    final start = TextEditingController();
    final end = TextEditingController();
    final responsibilities = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Experience'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: company, decoration: const InputDecoration(labelText: 'Company', hintText: 'e.g. Acme Corp')),
              TextField(controller: position, decoration: const InputDecoration(labelText: 'Position', hintText: 'e.g. Software Engineer')),
              TextField(controller: start, decoration: const InputDecoration(labelText: 'Start Date', hintText: 'e.g. Jan 2023')),
              TextField(controller: end, decoration: const InputDecoration(labelText: 'End Date', hintText: 'e.g. Present')),
              TextField(controller: responsibilities, decoration: const InputDecoration(labelText: 'Responsibilities (one per line)', hintText: 'e.g. Built REST APIs'), maxLines: 4),
            ]),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')), ElevatedButton(onPressed: () {
            final editor = ref.read(resumeEditorProvider);
            final section = editor.resume.sections.firstWhere((s) => s.key == 'experience', orElse: () => ResumeSection(key: 'experience', title: 'Experience', items: [], order: 3));
            final items = [...section.items];
            final newItem = ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {
              'company': company.text.trim(),
              'position': position.text.trim(),
              'employmentType': 'Full-time',
              'location': '',
              'start': start.text.trim(),
              'end': end.text.trim(),
              'current': false,
              'responsibilities': responsibilities.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
              'achievements': []
            });
            items.add(newItem);
            final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
            ref.read(resumeEditorProvider.notifier).upsertSection(updated);
            Navigator.of(ctx).pop();
          }, child: const Text('Add'))],
        );
      },
    );
    // See achievements_section.dart's _edit() for why these are
    // deliberately not disposed via .then() here.
  }

  void _editItem(ResumeSectionItem item) {
    final company = TextEditingController(text: item.data['company'] ?? '');
    final position = TextEditingController(text: item.data['position'] ?? '');
    final start = TextEditingController(text: item.data['start'] ?? '');
    final end = TextEditingController(text: item.data['end'] ?? '');
    final responsibilities = TextEditingController(text: (item.data['responsibilities'] as List?)?.join('\n') ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Experience'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: company, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: position, decoration: const InputDecoration(labelText: 'Position')),
              TextField(controller: start, decoration: const InputDecoration(labelText: 'Start Date')),
              TextField(controller: end, decoration: const InputDecoration(labelText: 'End Date')),
              TextField(controller: responsibilities, decoration: const InputDecoration(labelText: 'Responsibilities (one per line)'), maxLines: 4),
            ]),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')), ElevatedButton(onPressed: () {
            final updatedData = Map<String, dynamic>.from(item.data);
            updatedData['company'] = company.text.trim();
            updatedData['position'] = position.text.trim();
            updatedData['start'] = start.text.trim();
            updatedData['end'] = end.text.trim();
            updatedData['responsibilities'] = responsibilities.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
            _saveItem(item.id, updatedData);
            Navigator.of(ctx).pop();
          }, child: const Text('Save'))],
        );
      },
    );
    // See achievements_section.dart's _edit() for why these are
    // deliberately not disposed via .then() here.
  }

  void _saveItem(String id, Map<String, dynamic> data) {
    final editor = ref.read(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'experience', orElse: () => ResumeSection(key: 'experience', title: 'Experience', items: [], order: 3));
    final items = [...section.items];
    final idx = items.indexWhere((i) => i.id == id);
    if (idx >= 0) items[idx] = ResumeSectionItem(id: id, data: data);
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }

  void _confirmDelete(ResumeSectionItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Experience'),
          content: Text('Remove "${item.data['company'] ?? 'this entry'}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteItem(item.id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String id) {
    final editor = ref.read(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'experience', orElse: () => ResumeSection(key: 'experience', title: 'Experience', items: [], order: 3));
    final items = section.items.where((i) => i.id != id).toList();
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }

  Future<void> _improveExperience(ResumeSectionItem item) async {
    try {
      final repo = ref.read(resumeRepositoryProvider);
      final improved = await repo.improveExperience(
        text: (item.data['responsibilities'] as List?)?.join('\n') ?? '',
        position: item.data['position']?.toString(),
        company: item.data['company']?.toString(),
      );
      if (!mounted) return;
      final newData = Map<String, dynamic>.from(item.data);
      newData['responsibilities'] = improved.split('\n').map((l) => l.replaceFirst(RegExp(r'^[-•]\s*'), '')).where((s) => s.trim().isNotEmpty).toList();
      _saveItem(item.id, newData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Experience improved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to improve'),
          action: SnackBarAction(label: 'Retry', onPressed: () => _improveExperience(item)),
        ),
      );
    }
  }
}
