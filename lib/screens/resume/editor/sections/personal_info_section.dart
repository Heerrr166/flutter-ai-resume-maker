import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/resume_editor_provider.dart';
import '../../../../models/resume_model.dart';
import '../../../../core/utils/validators.dart';

class PersonalInfoSection extends ConsumerStatefulWidget {
  const PersonalInfoSection({super.key});

  @override
  ConsumerState<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends ConsumerState<PersonalInfoSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(resumeEditorProvider);
    final data = editor.resume.sections.firstWhere((s) => s.key == 'personal', orElse: () => ResumeSection(key: 'personal', title: 'Personal', items: [], order: 0));
    if (data.items.isNotEmpty && _nameCtrl.text.isEmpty) {
      final map = data.items.first.data;
      _nameCtrl.text = map['fullName'] ?? '';
      _titleCtrl.text = map['title'] ?? '';
      _emailCtrl.text = map['email'] ?? '';
      _phoneCtrl.text = map['phone'] ?? '';
    }

    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Personal Information', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => v==null||v.trim().isEmpty? 'Required': null, onChanged: (_) => _onChanged()),
        const SizedBox(height: 8),
        TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Professional title'), onChanged: (_) => _onChanged()),
        const SizedBox(height: 8),
        TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => Validators.validateEmail(v), onChanged: (_) => _onChanged()),
        const SizedBox(height: 8),
        TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), validator: (v) => Validators.validatePhone(v), onChanged: (_) => _onChanged()),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _save, child: const Text('Save'))
      ]),
    );
  }

  void _onChanged() {
    // mark dirty; will be saved by provider debounce
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final section = ResumeSection(key: 'personal', title: 'Personal', items: [ResumeSectionItem(id: 'me', data: {
      'fullName': _nameCtrl.text.trim(),
      'title': _titleCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    })], order: 0);
    ref.read(resumeEditorProvider.notifier).upsertSection(section);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personal information saved')));
  }
}
