import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resume_model.dart';
import '../repositories/resume_repository.dart';
import 'auth_provider.dart';

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return ResumeRepository(apiService: api);
});

final resumeNotifierProvider = StateNotifierProvider<ResumeNotifier, AsyncValue<List<ResumeModel>>>((ref) {
  // Rebuilding on the logged-in user's id (rather than just reading it once)
  // means Riverpod disposes and recreates this notifier whenever the
  // account changes - without this, a logout followed by a different
  // account logging in in the same app session would keep showing the
  // previous user's cached resume list until an unrelated action happened
  // to trigger a refetch.
  ref.watch(authNotifierProvider.select((s) => s.user?.id));
  return ResumeNotifier(ref.read(resumeRepositoryProvider));
});

class ResumeNotifier extends StateNotifier<AsyncValue<List<ResumeModel>>> {
  ResumeNotifier(this._repo) : super(const AsyncValue.loading()) {
    fetchResumes();
  }

  final ResumeRepository _repo;

  Future<void> fetchResumes() async {
    try {
      state = const AsyncValue.loading();
      final res = await _repo.fetchResumes();
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createResume(String title, {String? template}) async {
    try {
      final created = await _repo.createResume(title: title, template: template);
      final list = <ResumeModel>[...(state.value ?? <ResumeModel>[]), created];
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateResume(String id, Map<String, dynamic> payload) async {
    try {
      final updated = await _repo.updateResume(id: id, payload: payload);
      final list = (state.value ?? <ResumeModel>[])
          .map((r) => r.id == id ? updated : r)
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Merges an already-fetched/saved resume (e.g. from the editor's autosave)
  // into the cached list without an extra network round-trip, so Dashboard
  // and Resume List reflect edits made in the editor immediately.
  void applyUpdatedResume(ResumeModel resume) {
    final list = state.value ?? <ResumeModel>[];
    final idx = list.indexWhere((r) => r.id == resume.id);
    if (idx >= 0) {
      final updated = [...list];
      updated[idx] = resume;
      state = AsyncValue.data(updated);
    } else {
      state = AsyncValue.data([...list, resume]);
    }
  }

  Future<void> deleteResume(String id) async {
    try {
      await _repo.deleteResume(id: id);
      final list = (state.value ?? <ResumeModel>[])
          .where((r) => r.id != id)
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
