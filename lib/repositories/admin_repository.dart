import '../models/admin_stats_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AdminUsersPage {
  final List<UserModel> users;
  final int page;
  final int totalPages;
  final int total;

  const AdminUsersPage({
    required this.users,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

class AdminResumesPage {
  final List<AdminResumeItem> resumes;
  final int page;
  final int totalPages;
  final int total;
  final int publishedCount;
  final int draftCount;

  const AdminResumesPage({
    required this.resumes,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.publishedCount,
    required this.draftCount,
  });
}

class AdminRepository {
  final ApiService apiService;

  AdminRepository({required this.apiService});

  Future<AdminOverviewData> fetchOverview() async {
    final resp = await apiService.get('/users/admin/stats');
    final data = resp.data['data'] as Map<String, dynamic>;
    return AdminOverviewData.fromJson(data);
  }

  Future<AdminUsersPage> fetchUsers({
    required int page,
    int limit = 20,
    String search = '',
    String role = '',
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search.isNotEmpty) query['search'] = search;
    if (role.isNotEmpty && role != 'any' && role != 'all') query['role'] = role;

    final resp = await apiService.get('/users', queryParameters: query);
    final data = resp.data['data'] as Map<String, dynamic>;
    final usersJson = data['users'] as List<dynamic>? ?? [];

    return AdminUsersPage(
      users: usersJson.map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList(),
      page: data['page'] as int? ?? page,
      totalPages: data['totalPages'] as int? ?? 1,
      total: data['total'] as int? ?? usersJson.length,
    );
  }

  Future<AdminResumesPage> fetchResumes({
    required int page,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search.isNotEmpty) query['search'] = search;
    if (status.isNotEmpty && status != 'any' && status != 'all') query['status'] = status;

    final resp = await apiService.get('/resumes/admin/all', queryParameters: query);
    final data = resp.data['data'] as Map<String, dynamic>;
    final resumesJson = data['resumes'] as List<dynamic>? ?? [];
    final stats = data['stats'] as Map<String, dynamic>? ?? {};

    return AdminResumesPage(
      resumes: resumesJson.map((r) => AdminResumeItem.fromJson(r as Map<String, dynamic>)).toList(),
      page: data['page'] as int? ?? page,
      totalPages: data['totalPages'] as int? ?? 1,
      total: data['total'] as int? ?? resumesJson.length,
      publishedCount: stats['publishedCount'] as int? ?? 0,
      draftCount: stats['draftCount'] as int? ?? 0,
    );
  }

  Future<void> deleteUser(String id) async {
    await apiService.delete('/users/$id');
  }

  Future<void> deleteResume(String id) async {
    await apiService.delete('/resumes/$id');
  }
}
