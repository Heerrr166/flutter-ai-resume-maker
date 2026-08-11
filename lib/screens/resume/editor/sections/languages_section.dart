import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../core/constants/app_spacing.dart';

class LanguagesSection extends ConsumerStatefulWidget {
  const LanguagesSection({super.key});

  @override
  ConsumerState<LanguagesSection> createState() => _LanguagesSectionState();
}

class _LanguagesSectionState extends ConsumerState<LanguagesSection> {
  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'languages', orElse: () => ResumeSection(key: 'languages', title: 'Languages', items: [], order: 7));
    final items = section.items;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Languages', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (items.isEmpty) const Center(child: Text('No languages yet')),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return ListTile(
            key: ValueKey(it.id),
            title: Text(it.data['language'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('Read: ${it.data['read'] ?? ''} • Write: ${it.data['write'] ?? ''} • Speak: ${it.data['speak'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis),
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
      ElevatedButton(onPressed: _add, child: const Text('Add Language')),
    ]);
  }

  void _add() {
    final language = TextEditingController();
    final read = TextEditingController();
    final write = TextEditingController();
    final speak = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Language'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: language, decoration: const InputDecoration(labelText: 'Language', hintText: 'e.g. Spanish')),
              TextField(controller: read, decoration: const InputDecoration(labelText: 'Read Proficiency', hintText: 'e.g. Good')),
              TextField(controller: write, decoration: const InputDecoration(labelText: 'Write Proficiency', hintText: 'e.g. Good')),
              TextField(controller: speak, decoration: const InputDecoration(labelText: 'Speak Proficiency', hintText: 'e.g. Good')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final editor = ref.read(resumeEditorProvider);
                final section = editor.resume.sections.firstWhere((s) => s.key == 'languages', orElse: () => ResumeSection(key: 'languages', title: 'Languages', items: [], order: 7));
                final items = [...section.items];
                final newItem = ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {
                  'language': language.text.trim(),
                  'read': read.text.trim(),
                  'write': write.text.trim(),
                  'speak': speak.text.trim(),
                  'native': false,
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
    final language = TextEditingController(text: item.data['language'] ?? '');
    final read = TextEditingController(text: item.data['read'] ?? '');
    final write = TextEditingController(text: item.data['write'] ?? '');
    final speak = TextEditingController(text: item.data['speak'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Language'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: language, decoration: const InputDecoration(labelText: 'Language')),
              TextField(controller: read, decoration: const InputDecoration(labelText: 'Read Proficiency')),
              TextField(controller: write, decoration: const InputDecoration(labelText: 'Write Proficiency')),
              TextField(controller: speak, decoration: const InputDecoration(labelText: 'Speak Proficiency')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updatedData = Map<String, dynamic>.from(item.data);
                updatedData['language'] = language.text.trim();
                updatedData['read'] = read.text.trim();
                updatedData['write'] = write.text.trim();
                updatedData['speak'] = speak.text.trim();
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'languages', orElse: () => ResumeSection(key: 'languages', title: 'Languages', items: [], order: 7));
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
          title: const Text('Delete Language'),
          content: Text('Remove "${item.data['language'] ?? 'this entry'}"?'),
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'languages', orElse: () => ResumeSection(key: 'languages', title: 'Languages', items: [], order: 7));
    final items = section.items.where((i) => i.id != id).toList();
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }
}
