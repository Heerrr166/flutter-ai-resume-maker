import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../providers/resume_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../core/constants/app_spacing.dart';

class SkillsSection extends ConsumerStatefulWidget {
  const SkillsSection({super.key});

  @override
  ConsumerState<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends ConsumerState<SkillsSection> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _isSuggesting = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'skills', orElse: () => ResumeSection(key: 'skills', title: 'Skills', items: [], order: 5));
    final items = section.items;
    final filtered = _query.isEmpty
        ? items
        : items.where((it) => (it.data['name'] as String? ?? '').toLowerCase().contains(_query)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Skills', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      TextField(controller: _searchCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search skills')),
      const SizedBox(height: 8),
      if (filtered.isEmpty)
        Text(
          items.isEmpty ? 'No skills yet' : 'No skills matching "$_query"',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filtered
            .map((it) => GestureDetector(
                  onTap: () => _edit(it),
                  child: Chip(
                    label: Text('${it.data['name'] ?? ''} • ${it.data['rating'] ?? 0}'),
                    onDeleted: () => _confirmDelete(it),
                  ),
                ))
            .toList(),
      ),
      const SizedBox(height: 8),
      Row(children: [
        ElevatedButton(onPressed: _addSkill, child: const Text('Add Skill')),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _isSuggesting ? null : _suggestSkills,
          icon: _isSuggesting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.auto_awesome, size: 20),
          label: Text(_isSuggesting ? 'Finding suggestions...' : 'Suggest Skills'),
        ),
      ]),
    ]);
  }

  Future<void> _suggestSkills() async {
    setState(() => _isSuggesting = true);
    try {
      final repo = ref.read(resumeRepositoryProvider);
      final resume = ref.read(resumeEditorProvider).resume;
      final experienceSection = resume.sections.firstWhere(
        (s) => s.key == 'experience',
        orElse: () => ResumeSection(key: 'experience', title: '', items: [], order: 0),
      );
      final skillsSection = resume.sections.firstWhere(
        (s) => s.key == 'skills',
        orElse: () => ResumeSection(key: 'skills', title: 'Skills', items: [], order: 5),
      );
      final existingNames = skillsSection.items.map((it) => (it.data['name'] ?? '').toString()).where((s) => s.isNotEmpty).toList();

      final suggestions = await repo.recommendSkills(
        summary: resume.summary.isEmpty ? null : resume.summary,
        experience: experienceSection.items
            .map((it) => '${it.data['position'] ?? ''} at ${it.data['company'] ?? ''}')
            .where((s) => s.trim().isNotEmpty)
            .toList(),
        existingSkills: existingNames,
      );
      if (!mounted) return;
      if (suggestions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No new skill suggestions')));
        return;
      }
      _showSuggestions(suggestions);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to get skill suggestions'),
          action: SnackBarAction(label: 'Retry', onPressed: _suggestSkills),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSuggesting = false);
    }
  }

  void _showSuggestions(List<String> suggestions) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Suggested Skills'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions
                    .map((s) => ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: Text(s),
                          onPressed: () {
                            _addSuggestedSkill(s);
                            Navigator.of(ctx).pop();
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
        );
      },
    );
  }

  void _addSuggestedSkill(String name) {
    final editor = ref.read(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'skills', orElse: () => ResumeSection(key: 'skills', title: 'Skills', items: [], order: 5));
    final items = [...section.items];
    items.add(ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {'name': name, 'rating': 3, 'category': 'Technical'}));
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }

  void _addSkill() {
    final nameCtrl = TextEditingController();
    int rating = 3;
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(title: const Text('Add Skill'), content: StatefulBuilder(builder: (ctx2, setState) {
        return Column(mainAxisSize: MainAxisSize.min, spacing: AppSpacing.md, children: [TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Skill name')), Row(children: [Text('Rating:'), const SizedBox(width: 8), DropdownButton<int>(value: rating, items: List.generate(5, (i) => i+1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(), onChanged: (val){ if(val!=null) setState(()=>rating=val);})])]);
      }), actions: [TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: const Text('Cancel')), ElevatedButton(onPressed: (){ final name = nameCtrl.text.trim(); if(name.isEmpty)return; final editor = ref.read(resumeEditorProvider); final section = editor.resume.sections.firstWhere((s)=>s.key=='skills', orElse: ()=>ResumeSection(key:'skills', title:'Skills', items: [], order:5)); final items=[...section.items]; final newItem = ResumeSectionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), data: {'name':name,'rating':rating,'category':'Technical'}); items.add(newItem); final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order); ref.read(resumeEditorProvider.notifier).upsertSection(updated); Navigator.of(ctx).pop(); }, child: const Text('Add'))]);
    });
    // See achievements_section.dart's _edit() for why nameCtrl is
    // deliberately not disposed via .then() here.
  }

  void _edit(ResumeSectionItem item) {
    final nameCtrl = TextEditingController(text: item.data['name'] ?? '');
    int rating = (item.data['rating'] as int?) ?? 3;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Skill'),
          content: StatefulBuilder(builder: (ctx2, setState) {
            return Column(mainAxisSize: MainAxisSize.min, spacing: AppSpacing.md, children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Skill name')),
              Row(children: [
                const Text('Rating:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: rating,
                  items: List.generate(5, (i) => i + 1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => rating = val);
                  },
                ),
              ]),
            ]);
          }),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final updatedData = Map<String, dynamic>.from(item.data);
                updatedData['name'] = name;
                updatedData['rating'] = rating;
                _saveItem(item.id, updatedData);
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    // See achievements_section.dart's _edit() for why nameCtrl is
    // deliberately not disposed via .then() here.
  }

  void _saveItem(String id, Map<String, dynamic> data) {
    final editor = ref.read(resumeEditorProvider);
    final section = editor.resume.sections.firstWhere((s) => s.key == 'skills', orElse: () => ResumeSection(key: 'skills', title: 'Skills', items: [], order: 5));
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
          title: const Text('Delete Skill'),
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
    final section = editor.resume.sections.firstWhere((s) => s.key == 'skills', orElse: () => ResumeSection(key: 'skills', title: 'Skills', items: [], order: 5));
    final items = section.items.where((i) => i.id != id).toList();
    final updated = ResumeSection(key: section.key, title: section.title, items: items, order: section.order);
    ref.read(resumeEditorProvider.notifier).upsertSection(updated);
  }
}
