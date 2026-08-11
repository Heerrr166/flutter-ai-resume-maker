import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../core/constants/app_spacing.dart';

class CertificationsSection extends ConsumerStatefulWidget {
  const CertificationsSection({super.key});

  @override
  ConsumerState<CertificationsSection> createState() => _CertificationsSectionState();
}

class _CertificationsSectionState extends ConsumerState<CertificationsSection> {
  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'certifications', orElse: () => ResumeSection(key: 'certifications', title: 'Certifications', items: [], order: 6));
    final items = section.items;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Certifications', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (items.isEmpty) const Center(child: Text('No certifications yet')),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return ListTile(
            key: ValueKey(it.id),
            title: Text(it.data['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${it.data['issuer'] ?? ''} • ${it.data['issueDate'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis),
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
      ElevatedButton(onPressed: _add, child: const Text('Add Certification')),
    ]);
  }

  void _add() {
    final name = TextEditingController();
    final issuer = TextEditingController();
    final credentialId = TextEditingController();
    final issueDate = TextEditingController();
    final expiryDate = TextEditingController();
    final url = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Certification'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Certificate Name', hintText: 'e.g. AWS Certified Developer')),
              TextField(controller: issuer, decoration: const InputDecoration(labelText: 'Issuer', hintText: 'e.g. Amazon Web Services')),
              TextField(controller: credentialId, decoration: const InputDecoration(labelText: 'Credential ID', hintText: 'e.g. ABC123')),
              TextField(controller: issueDate, decoration: const InputDecoration(labelText: 'Issue Date', hintText: 'e.g. Jan 2024')),
              TextField(controller: expiryDate, decoration: const InputDecoration(labelText: 'Expiry Date', hintText: 'e.g. Jan 2027')),
              TextField(controller: url, decoration: const InputDecoration(labelText: 'Credential URL', hintText: 'https://...')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final editor = ref.read(resumeEditorProvider);
                final section = editor.resume.sections.firstWhere((s) => s.key == 'certifications', orElse: () => ResumeSection(key: 'certifications', title: 'Certifications', items: [], order: 6));
                final items = [...section.items];
                final newItem = ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {
                  'name': name.text.trim(),
                  'issuer': issuer.text.trim(),
                  'credentialId': credentialId.text.trim(),
                  'issueDate': issueDate.text.trim(),
                  'expiryDate': expiryDate.text.trim(),
                  'url': url.text.trim(),
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
    final issuer = TextEditingController(text: item.data['issuer'] ?? '');
    final credentialId = TextEditingController(text: item.data['credentialId'] ?? '');
    final issueDate = TextEditingController(text: item.data['issueDate'] ?? '');
    final expiryDate = TextEditingController(text: item.data['expiryDate'] ?? '');
    final url = TextEditingController(text: item.data['url'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Certification'),
          content: SingleChildScrollView(
            child: Column(spacing: AppSpacing.md, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Certificate Name')),
              TextField(controller: issuer, decoration: const InputDecoration(labelText: 'Issuer')),
              TextField(controller: credentialId, decoration: const InputDecoration(labelText: 'Credential ID')),
              TextField(controller: issueDate, decoration: const InputDecoration(labelText: 'Issue Date')),
              TextField(controller: expiryDate, decoration: const InputDecoration(labelText: 'Expiry Date')),
              TextField(controller: url, decoration: const InputDecoration(labelText: 'Credential URL')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updatedData = Map<String, dynamic>.from(item.data);
                updatedData['name'] = name.text.trim();
                updatedData['issuer'] = issuer.text.trim();
                updatedData['credentialId'] = credentialId.text.trim();
                updatedData['issueDate'] = issueDate.text.trim();
                updatedData['expiryDate'] = expiryDate.text.trim();
                updatedData['url'] = url.text.trim();
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'certifications', orElse: () => ResumeSection(key: 'certifications', title: 'Certifications', items: [], order: 6));
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
          title: const Text('Delete Certification'),
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'certifications', orElse: () => ResumeSection(key: 'certifications', title: 'Certifications', items: [], order: 6));
    final items = section.items.where((i) => i.id != id).toList();
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }
}
