import '../models/user_model.dart';
import '../services/api_service.dart';

class AdminUsersPage {
  final List<UserModel> users;
  final int page;
  final int totalPages;
  final int total;

  AdminUsersPage({required this.users, required this.page, required this.totalPages, required this.total});
}

class AdminRepository {
  final ApiService apiService;

  AdminRepository({required this.apiService});

  Future<AdminUsersPage> fetchUsers({required int page, int limit = 20}) async {
    final resp = await apiService.get('/users', queryParameters: {'page': page, 'limit': limit});
    final data = resp.data['data'] as Map<String, dynamic>;
    final usersJson = data['users'] as List<dynamic>? ?? [];
    return AdminUsersPage(
      users: usersJson.map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList(),
      page: data['page'] as int? ?? page,
      totalPages: data['totalPages'] as int? ?? 1,
      total: data['total'] as int? ?? usersJson.length,
    );
  }

  Future<void> deleteUser(String id) async {
    await apiService.delete('/users/$id');
  }
}
