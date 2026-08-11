import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../core/constants/app_spacing.dart';

class EducationSection extends ConsumerStatefulWidget {
  const EducationSection({super.key});

  @override
  ConsumerState<EducationSection> createState() => _EducationSectionState();
}

class _EducationSectionState extends ConsumerState<EducationSection> {
  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'education', orElse: () => ResumeSection(key: 'education', title: 'Education', items: [], order: 2));
    final items = section.items;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Education', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (items.isEmpty) Center(child: Text('No education entries yet')),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return ListTile(
            key: ValueKey(it.id),
            title: Text(it.data['institution'] ?? 'Untitled', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(it.data['degree'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _edit(it)),
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
      Row(children: [ElevatedButton(onPressed: _add, child: const Text('Add Education'))]),
    ]);
  }

  void _add() {
    final institution = TextEditingController();
    final degree = TextEditingController();
    final start = TextEditingController();
    final end = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Education'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: institution, decoration: const InputDecoration(labelText: 'Institution', hintText: 'e.g. Stanford University')),
              TextField(controller: degree, decoration: const InputDecoration(labelText: 'Degree', hintText: 'e.g. B.Tech Computer Science')),
              TextField(controller: start, decoration: const InputDecoration(labelText: 'Start Date', hintText: 'e.g. Aug 2022')),
              TextField(controller: end, decoration: const InputDecoration(labelText: 'End Date', hintText: 'e.g. May 2026')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final editor = ref.read(resumeEditorProvider);
                final section = editor.resume.sections.firstWhere((s) => s.key == 'education', orElse: () => ResumeSection(key: 'education', title: 'Education', items: [], order: 2));
                final items = [...section.items];
                final newItem = ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {
                  'institution': institution.text.trim(),
                  'degree': degree.text.trim(),
                  'start': start.text.trim(),
                  'end': end.text.trim(),
                });
                items.add(newItem);
                final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
                ref.read(resumeEditorProvider.notifier).upsertSection(updated);
                Navigator.of(ctx).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    // See achievements_section.dart's _edit() for why these are
    // deliberately not disposed via .then() here.
  }

  void _edit(ResumeSectionItem item) {
    final institution = TextEditingController(text: item.data['institution'] ?? '');
    final degree = TextEditingController(text: item.data['degree'] ?? '');
    final start = TextEditingController(text: item.data['start'] ?? '');
    final end = TextEditingController(text: item.data['end'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Education'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: institution, decoration: const InputDecoration(labelText: 'Institution')),
              TextField(controller: degree, decoration: const InputDecoration(labelText: 'Degree')),
              TextField(controller: start, decoration: const InputDecoration(labelText: 'Start Date')),
              TextField(controller: end, decoration: const InputDecoration(labelText: 'End Date')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updatedData = Map<String, dynamic>.from(item.data);
                updatedData['institution'] = institution.text.trim();
                updatedData['degree'] = degree.text.trim();
                updatedData['start'] = start.text.trim();
                updatedData['end'] = end.text.trim();
                _saveItem(item.id, updatedData);
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    // See achievements_section.dart's _edit() for why these are
    // deliberately not disposed via .then() here.
  }

  void _saveItem(String id, Map<String, dynamic> data) {
    final editor = ref.read(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'education', orElse: () => ResumeSection(key: 'education', title: 'Education', items: [], order: 2));
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
          title: const Text('Delete Education'),
          content: Text('Remove "${item.data['institution'] ?? 'this entry'}"?'),
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'education', orElse: () => ResumeSection(key: 'education', title: 'Education', items: [], order: 2));
    final items = section.items.where((i) => i.id != id).toList();
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }
}
