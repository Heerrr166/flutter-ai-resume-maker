import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../providers/resume_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../core/constants/app_spacing.dart';

class AchievementsSection extends ConsumerStatefulWidget {
  const AchievementsSection({super.key});

  @override
  ConsumerState<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends ConsumerState<AchievementsSection> {
  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'achievements', orElse: () => ResumeSection(key: 'achievements', title: 'Achievements', items: [], order: 8));
    final items = section.items;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (items.isEmpty) const Center(child: Text('No achievements yet')),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return ListTile(
            key: ValueKey(it.id),
            title: Text(it.data['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(it.data['date'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.auto_fix_high), tooltip: 'Improve with AI', onPressed: () => _improve(it)),
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
      ElevatedButton(onPressed: _add, child: const Text('Add Achievement')),
    ]);
  }

  void _add() {
    final title = TextEditingController();
    final date = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Achievement'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Won college hackathon')),
              TextField(controller: date, decoration: const InputDecoration(labelText: 'Date', hintText: 'e.g. Mar 2025')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final editor = ref.read(resumeEditorProvider);
                final section = editor.resume.sections.firstWhere((s) => s.key == 'achievements', orElse: () => ResumeSection(key: 'achievements', title: 'Achievements', items: [], order: 8));
                final items = [...section.items];
                final newItem = ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {
                  'title': title.text.trim(),
                  'date': date.text.trim(),
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
    // Deliberately not disposed here: .then() on the dialog's Future fires
    // as soon as the route is popped, which is before its exit-transition
    // animation finishes rebuilding the still-focused TextField, and hits
    // "A TextEditingController was used after being disposed." These are
    // small, short-lived controllers - once this closure is released they're
    // eligible for normal garbage collection without an explicit dispose().
  }

  void _edit(ResumeSectionItem item) {
    final title = TextEditingController(text: item.data['title'] ?? '');
    final date = TextEditingController(text: item.data['date'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Achievement'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: date, decoration: const InputDecoration(labelText: 'Date')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updatedData = Map<String, dynamic>.from(item.data);
                updatedData['title'] = title.text.trim();
                updatedData['date'] = date.text.trim();
                _saveItem(item.id, updatedData);
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    // Deliberately not disposed here: .then() on the dialog's Future fires
    // as soon as the route is popped, which is before its exit-transition
    // animation finishes rebuilding the still-focused TextField, and hits
    // "A TextEditingController was used after being disposed." These are
    // small, short-lived controllers - once this closure is released they're
    // eligible for normal garbage collection without an explicit dispose().
  }

  void _saveItem(String id, Map<String, dynamic> data) {
    final editor = ref.read(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'achievements', orElse: () => ResumeSection(key: 'achievements', title: 'Achievements', items: [], order: 8));
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
          title: const Text('Delete Achievement'),
          content: Text('Remove "${item.data['title'] ?? 'this entry'}"?'),
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'achievements', orElse: () => ResumeSection(key: 'achievements', title: 'Achievements', items: [], order: 8));
    final items = section.items.where((i) => i.id != id).toList();
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }

  Future<void> _improve(ResumeSectionItem item) async {
    final title = (item.data['title'] ?? '').toString();
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a title first')));
      return;
    }
    try {
      final repo = ref.read(resumeRepositoryProvider);
      final improved = await repo.writeAchievement(text: title);
      final newData = Map<String, dynamic>.from(item.data);
      newData['title'] = improved;
      _saveItem(item.id, newData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Achievement improved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to improve'),
          action: SnackBarAction(label: 'Retry', onPressed: () => _improve(item)),
        ),
      );
    }
  }
}
