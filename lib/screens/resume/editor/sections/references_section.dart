import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../core/constants/app_spacing.dart';

class ReferencesSection extends ConsumerStatefulWidget {
  const ReferencesSection({super.key});

  @override
  ConsumerState<ReferencesSection> createState() => _ReferencesSectionState();
}

class _ReferencesSectionState extends ConsumerState<ReferencesSection> {
  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'references', orElse: () => ResumeSection(key: 'references', title: 'References', items: [], order: 9));
    final items = section.items;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('References', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (items.isEmpty) const Center(child: Text('No references yet')),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return ListTile(
            key: ValueKey(it.id),
            title: Text(it.data['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${it.data['designation'] ?? ''} • ${it.data['company'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis),
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
      ElevatedButton(onPressed: _add, child: const Text('Add Reference')),
    ]);
  }

  void _add() {
    final name = TextEditingController();
    final company = TextEditingController();
    final designation = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final relationship = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Reference'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Jane Smith')),
              TextField(controller: company, decoration: const InputDecoration(labelText: 'Company', hintText: 'e.g. Acme Corp')),
              TextField(controller: designation, decoration: const InputDecoration(labelText: 'Designation', hintText: 'e.g. Engineering Manager')),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', hintText: 'e.g. jane@acme.com')),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone', hintText: 'e.g. +1 555 123 4567')),
              TextField(controller: relationship, decoration: const InputDecoration(labelText: 'Relationship', hintText: 'e.g. Former Manager')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final editor = ref.read(resumeEditorProvider);
                final section = editor.resume.sections.firstWhere((s) => s.key == 'references', orElse: () => ResumeSection(key: 'references', title: 'References', items: [], order: 9));
                final items = [...section.items];
                final newItem = ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {
                  'name': name.text.trim(),
                  'company': company.text.trim(),
                  'designation': designation.text.trim(),
                  'email': email.text.trim(),
                  'phone': phone.text.trim(),
                  'relationship': relationship.text.trim(),
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
    final name = TextEditingController(text: item.data['name'] ?? '');
    final company = TextEditingController(text: item.data['company'] ?? '');
    final designation = TextEditingController(text: item.data['designation'] ?? '');
    final email = TextEditingController(text: item.data['email'] ?? '');
    final phone = TextEditingController(text: item.data['phone'] ?? '');
    final relationship = TextEditingController(text: item.data['relationship'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Reference'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: company, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: designation, decoration: const InputDecoration(labelText: 'Designation')),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: relationship, decoration: const InputDecoration(labelText: 'Relationship')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updatedData = Map<String, dynamic>.from(item.data);
                updatedData['name'] = name.text.trim();
                updatedData['company'] = company.text.trim();
                updatedData['designation'] = designation.text.trim();
                updatedData['email'] = email.text.trim();
                updatedData['phone'] = phone.text.trim();
                updatedData['relationship'] = relationship.text.trim();
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'references', orElse: () => ResumeSection(key: 'references', title: 'References', items: [], order: 9));
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
          title: const Text('Delete Reference'),
          content: Text('Remove "${item.data['name'] ?? 'this entry'}"?'),
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'references', orElse: () => ResumeSection(key: 'references', title: 'References', items: [], order: 9));
    final items = section.items.where((i) => i.id != id).toList();
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }
}
