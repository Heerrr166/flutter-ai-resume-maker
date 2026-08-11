import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resume_model.dart';
import '../repositories/resume_repository.dart';
import 'resume_provider.dart';

class ResumeEditorState {
  final ResumeModel resume;
  final bool isSaving;
  final String saveMessage;
  final bool dirty;

  ResumeEditorState({required this.resume, this.isSaving = false, this.saveMessage = '', this.dirty = false});

  ResumeEditorState copyWith({ResumeModel? resume, bool? isSaving, String? saveMessage, bool? dirty}) {
    return ResumeEditorState(
      resume: resume ?? this.resume,
      isSaving: isSaving ?? this.isSaving,
      saveMessage: saveMessage ?? this.saveMessage,
      dirty: dirty ?? this.dirty,
    );
  }
}

class ResumeEditorNotifier extends StateNotifier<ResumeEditorState> {
  ResumeEditorNotifier(this._repo, this._ref)
      : super(ResumeEditorState(resume: ResumeModel(id: '', title: 'Untitled', summary: '', sections: [], status: 'draft')));

  final ResumeRepository _repo;
  final Ref _ref;
  Timer? _debounce;
  bool _savingInProgress = false;

  void loadResume(ResumeModel resume) {
    state = state.copyWith(resume: resume, dirty: false);
  }

  Future<void> loadById(String id) async {
    final res = await _repo.fetchResumeById(id);
    state = state.copyWith(resume: res, dirty: false);
  }

  void updateTitle(String title) {
    _markDirty(state.resume.copyWith(title: title));
  }

  void updateSummary(String summary) {
    _markDirty(state.resume.copyWith(summary: summary));
  }

  void upsertSection(ResumeSection section) {
    final r = state.resume;
    final sections = [...r.sections];
    final idx = sections.indexWhere((s) => s.key == section.key);
    if (idx >= 0) {
      sections[idx] = section;
    } else {
      sections.add(section);
    }
    _markDirty(r.copyWith(sections: sections));
  }

  // Persists immediately (not debounced) so a template pick from the picker
  // screen is never lost if the user navigates away before the 10s debounce
  // would otherwise fire.
  Future<void> updateTemplate(String template) async {
    state = state.copyWith(resume: state.resume.copyWith(template: template), dirty: true);
    await saveDraft();
  }

  // Same immediate-save reasoning as updateTemplate: a freshly generated
  // cover letter is a discrete, complete result the user should not lose by
  // navigating away before the debounce fires.
  Future<void> updateCoverLetter(String coverLetter) async {
    state = state.copyWith(resume: state.resume.copyWith(coverLetter: coverLetter), dirty: true);
    await saveDraft();
  }

  void _markDirty(ResumeModel updated) {
    state = state.copyWith(resume: updated, dirty: true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 10), () {
      saveDraft();
    });
  }

  Future<void> saveDraft() async {
    if (!_savingInProgress && state.dirty) {
      _savingInProgress = true;
      state = state.copyWith(isSaving: true, saveMessage: 'Saving...');
      try {
        if (state.resume.id.isEmpty) {
          final created = await _repo.createResume(title: state.resume.title, template: state.resume.template);
          // createResume only accepts title/template, so it can't carry any
          // sections/summary the user already entered locally before this
          // first save. Merge the newly assigned id into the existing local
          // resume and persist that immediately, rather than overwriting
          // local state with the bare (sections-less) server response and
          // silently losing that work.
          final withId = ResumeModel(
            id: created.id,
            title: state.resume.title,
            summary: state.resume.summary,
            sections: state.resume.sections,
            status: state.resume.status,
            template: state.resume.template,
            coverLetter: state.resume.coverLetter,
          );
          final updated = await _repo.updateResume(id: created.id, payload: withId.toJson());
          state = state.copyWith(resume: updated, isSaving: false, saveMessage: 'Saved', dirty: false);
          _ref.read(resumeNotifierProvider.notifier).applyUpdatedResume(updated);
        } else {
          final payload = state.resume.toJson();
          final updated = await _repo.updateResume(id: state.resume.id, payload: payload);
          state = state.copyWith(resume: updated, isSaving: false, saveMessage: 'Saved', dirty: false);
          _ref.read(resumeNotifierProvider.notifier).applyUpdatedResume(updated);
        }
      } catch (e) {
        state = state.copyWith(isSaving: false, saveMessage: 'Error saving');
      } finally {
        _savingInProgress = false;
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final resumeEditorProvider = StateNotifierProvider<ResumeEditorNotifier, ResumeEditorState>((ref) {
  final repo = ref.read(resumeRepositoryProvider);
  return ResumeEditorNotifier(repo, ref);
});
