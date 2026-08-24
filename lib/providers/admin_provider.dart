import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_stats_model.dart';
import '../models/user_model.dart';
import '../repositories/admin_repository.dart';
import 'auth_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(apiService: ref.read(apiServiceProvider));
});

// ==========================================
// 1. ADMIN OVERVIEW PROVIDER (autoDispose)
// ==========================================
class AdminOverviewState {
  final AdminOverviewData data;
  final bool isLoading;
  final String? error;

  const AdminOverviewState({
    this.data = const AdminOverviewData(),
    this.isLoading = false,
    this.error,
  });

  AdminOverviewState copyWith({
    AdminOverviewData? data,
    bool? isLoading,
    String? error,
  }) {
    return AdminOverviewState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminOverviewNotifier extends StateNotifier<AdminOverviewState> {
  AdminOverviewNotifier(this._repo) : super(const AdminOverviewState()) {
    fetchOverview();
  }

  final AdminRepository _repo;

  Future<void> fetchOverview({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final overview = await _repo.fetchOverview();
      state = state.copyWith(data: overview, isLoading: false, error: null);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load platform overview');
    }
  }
}

final adminOverviewProvider = StateNotifierProvider.autoDispose<AdminOverviewNotifier, AdminOverviewState>((ref) {
  return AdminOverviewNotifier(ref.read(adminRepositoryProvider));
});

// ==========================================
// 2. ADMIN USERS PROVIDER (autoDispose)
// ==========================================
class AdminUsersState {
  final List<UserModel> users;
  final int page;
  final int totalPages;
  final int total;
  final bool isLoading;
  final String? error;
  final Set<String> deletingIds;
  final String searchQuery;
  final String roleFilter;

  const AdminUsersState({
    this.users = const [],
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.isLoading = false,
    this.error,
    this.deletingIds = const {},
    this.searchQuery = '',
    this.roleFilter = 'any',
  });

  AdminUsersState copyWith({
    List<UserModel>? users,
    int? page,
    int? totalPages,
    int? total,
    bool? isLoading,
    String? error,
    Set<String>? deletingIds,
    String? searchQuery,
    String? roleFilter,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      deletingIds: deletingIds ?? this.deletingIds,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
    );
  }
}

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  AdminUsersNotifier(this._repo) : super(const AdminUsersState()) {
    fetchPage(1);
  }

  final AdminRepository _repo;

  Future<void> fetchPage(int page, {String? search, String? role}) async {
    final query = search ?? state.searchQuery;
    final r = role ?? state.roleFilter;

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: query,
      roleFilter: r,
    );

    try {
      final result = await _repo.fetchUsers(
        page: page,
        search: query,
        role: r,
      );
      state = state.copyWith(
        users: result.users,
        page: result.page,
        totalPages: result.totalPages,
        total: result.total,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load users');
    }
  }

  void setSearch(String query) {
    fetchPage(1, search: query.trim());
  }

  void setRole(String role) {
    fetchPage(1, role: role);
  }

  Future<bool> deleteUser(String id) async {
    state = state.copyWith(deletingIds: {...state.deletingIds, id});
    try {
      await _repo.deleteUser(id);
      final remaining = state.users.where((u) => u.id != id).toList();
      final nextDeleting = {...state.deletingIds}..remove(id);
      state = state.copyWith(
        users: remaining,
        total: state.total > 0 ? state.total - 1 : 0,
        deletingIds: nextDeleting,
      );
      if (remaining.isEmpty && state.page > 1) {
        await fetchPage(state.page - 1);
      }
      return true;
    } catch (_) {
      final nextDeleting = {...state.deletingIds}..remove(id);
      state = state.copyWith(deletingIds: nextDeleting);
      return false;
    }
  }
}

final adminUsersProvider = StateNotifierProvider.autoDispose<AdminUsersNotifier, AdminUsersState>((ref) {
  return AdminUsersNotifier(ref.read(adminRepositoryProvider));
});

// ==========================================
// 3. ADMIN RESUMES PROVIDER (autoDispose)
// ==========================================
class AdminResumesState {
  final List<AdminResumeItem> resumes;
  final int page;
  final int totalPages;
  final int total;
  final int publishedCount;
  final int draftCount;
  final bool isLoading;
  final String? error;
  final Set<String> deletingIds;
  final String searchQuery;
  final String statusFilter;

  const AdminResumesState({
    this.resumes = const [],
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.publishedCount = 0,
    this.draftCount = 0,
    this.isLoading = false,
    this.error,
    this.deletingIds = const {},
    this.searchQuery = '',
    this.statusFilter = 'any',
  });

  AdminResumesState copyWith({
    List<AdminResumeItem>? resumes,
    int? page,
    int? totalPages,
    int? total,
    int? publishedCount,
    int? draftCount,
    bool? isLoading,
    String? error,
    Set<String>? deletingIds,
    String? searchQuery,
    String? statusFilter,
  }) {
    return AdminResumesState(
      resumes: resumes ?? this.resumes,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      publishedCount: publishedCount ?? this.publishedCount,
      draftCount: draftCount ?? this.draftCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      deletingIds: deletingIds ?? this.deletingIds,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class AdminResumesNotifier extends StateNotifier<AdminResumesState> {
  AdminResumesNotifier(this._repo) : super(const AdminResumesState()) {
    fetchPage(1);
  }

  final AdminRepository _repo;

  Future<void> fetchPage(int page, {String? search, String? status}) async {
    final query = search ?? state.searchQuery;
    final st = status ?? state.statusFilter;

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: query,
      statusFilter: st,
    );

    try {
      final result = await _repo.fetchResumes(
        page: page,
        search: query,
        status: st,
      );
      state = state.copyWith(
        resumes: result.resumes,
        page: result.page,
        totalPages: result.totalPages,
        total: result.total,
        publishedCount: result.publishedCount,
        draftCount: result.draftCount,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load resumes');
    }
  }

  void setSearch(String query) {
    fetchPage(1, search: query.trim());
  }

  void setStatus(String status) {
    fetchPage(1, status: status);
  }

  Future<bool> deleteResume(String id) async {
    state = state.copyWith(deletingIds: {...state.deletingIds, id});
    try {
      await _repo.deleteResume(id);
      final remaining = state.resumes.where((r) => r.id != id).toList();
      final nextDeleting = {...state.deletingIds}..remove(id);
      state = state.copyWith(
        resumes: remaining,
        total: state.total > 0 ? state.total - 1 : 0,
        deletingIds: nextDeleting,
      );
      if (remaining.isEmpty && state.page > 1) {
        await fetchPage(state.page - 1);
      }
      return true;
    } catch (_) {
      final nextDeleting = {...state.deletingIds}..remove(id);
      state = state.copyWith(deletingIds: nextDeleting);
      return false;
    }
  }
}

final adminResumesProvider = StateNotifierProvider.autoDispose<AdminResumesNotifier, AdminResumesState>((ref) {
  return AdminResumesNotifier(ref.read(adminRepositoryProvider));
});
