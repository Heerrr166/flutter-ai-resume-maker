import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../providers/resume_provider.dart';
import '../../../../core/constants/app_spacing.dart';

class ProjectsSection extends ConsumerStatefulWidget {
  const ProjectsSection({super.key});

  @override
  ConsumerState<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends ConsumerState<ProjectsSection> {
  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'projects', orElse: () => ResumeSection(key: 'projects', title: 'Projects', items: [], order: 4));
    final items = section.items;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Projects', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (items.isEmpty) const Center(child: Text('No projects yet')),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return ListTile(key: ValueKey(it.id), title: Text(it.data['name'] ?? 'Project', maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text(it.data['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit), onPressed: () => _edit(it)), IconButton(icon: const Icon(Icons.auto_fix_high), tooltip: 'Improve with AI', onPressed: () => _improve(it)), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _confirmDelete(it))]),);
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
      Row(children: [ElevatedButton(onPressed: _add, child: const Text('Add Project'))]),
    ]);
  }

  void _add() {
    final name = TextEditingController();
    final desc = TextEditingController();
    final tech = TextEditingController();
    final github = TextEditingController();
    final live = TextEditingController();
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(title: const Text('Add Project'), content: SingleChildScrollView(child: Column(spacing: AppSpacing.md, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Project Name', hintText: 'e.g. AI Resume Maker')),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description', hintText: 'What does it do?'), maxLines: 4),
        TextField(controller: tech, decoration: const InputDecoration(labelText: 'Technologies (comma separated)', hintText: 'e.g. Flutter, Node.js')),
        TextField(controller: github, decoration: const InputDecoration(labelText: 'GitHub URL', hintText: 'https://github.com/...')),
        TextField(controller: live, decoration: const InputDecoration(labelText: 'Live URL', hintText: 'https://...')),
      ])), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')), ElevatedButton(onPressed: () {
        final editor = ref.read(resumeEditorProvider);
        final section = editor.resume.sections.firstWhere((s) => s.key == 'projects', orElse: () => ResumeSection(key: 'projects', title: 'Projects', items: [], order: 4));
        final items = [...section.items];
        final newItem = ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {
          'name': name.text.trim(),
          'description': desc.text.trim(),
          'technologies': tech.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
          'github': github.text.trim(),
          'live': live.text.trim(),
          'teamSize': 1,
          'role': ''
        });
        items.add(newItem);
        final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
        ref.read(resumeEditorProvider.notifier).upsertSection(updated);
        Navigator.of(ctx).pop();
      }, child: const Text('Add'))]);
    });
    // See achievements_section.dart's _edit() for why these are
    // deliberately not disposed via .then() here.
  }

  void _edit(ResumeSectionItem item) {
    final name = TextEditingController(text: item.data['name'] ?? '');
    final desc = TextEditingController(text: item.data['description'] ?? '');
    final tech = TextEditingController(text: (item.data['technologies'] as List?)?.join(', ') ?? '');
    final github = TextEditingController(text: item.data['github'] ?? '');
    final live = TextEditingController(text: item.data['live'] ?? '');
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(title: const Text('Edit Project'), content: SingleChildScrollView(child: Column(spacing: AppSpacing.md, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Project Name')), TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 4), TextField(controller: tech, decoration: const InputDecoration(labelText: 'Technologies (comma separated)')), TextField(controller: github, decoration: const InputDecoration(labelText: 'GitHub URL')), TextField(controller: live, decoration: const InputDecoration(labelText: 'Live URL'))])), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')), ElevatedButton(onPressed: () { final updatedData = Map<String,dynamic>.from(item.data); updatedData['name']=name.text.trim(); updatedData['description']=desc.text.trim(); updatedData['technologies']=tech.text.split(',').map((s)=>s.trim()).where((s)=>s.isNotEmpty).toList(); updatedData['github']=github.text.trim(); updatedData['live']=live.text.trim(); _saveItem(item.id, updatedData); Navigator.of(ctx).pop(); }, child: const Text('Save'))]);
    });
    // See achievements_section.dart's _edit() for why these are
    // deliberately not disposed via .then() here.
  }

  void _saveItem(String id, Map<String, dynamic> data) {
    final editor = ref.read(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'projects', orElse: () => ResumeSection(key: 'projects', title: 'Projects', items: [], order: 4));
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
          title: const Text('Delete Project'),
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'projects', orElse: () => ResumeSection(key: 'projects', title: 'Projects', items: [], order: 4));
    final items = section.items.where((i) => i.id != id).toList();
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }

  Future<void> _improve(ResumeSectionItem item) async {
    try {
      final repo = ref.read(resumeRepositoryProvider);
      final technologies = (item.data['technologies'] as List?)?.map((e) => e.toString()).toList();
      final improved = await repo.improveProject(
        text: item.data['description'] ?? '',
        name: item.data['name']?.toString(),
        technologies: technologies,
      );
      final newData = Map<String, dynamic>.from(item.data);
      newData['description'] = improved;
      _saveItem(item.id, newData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project description improved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to improve description'),
          action: SnackBarAction(label: 'Retry', onPressed: () => _improve(item)),
        ),
      );
    }
  }
}
