import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({required this._apiService});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return {
      'user': user,
      'accessToken': data['accessToken'] as String,
      'refreshToken': data['refreshToken'] as String,
    };
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await _apiService.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
    return response.data['data']['message'] as String;
  }

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'otp': otp,
        'password': password,
      },
    );
    return response.data['data']['message'] as String;
  }

  Future<UserModel> fetchProfile() async {
    final response = await _apiService.get('/users/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({required String fullName, required String phone}) async {
    final response = await _apiService.put(
      '/users/profile',
      data: {
        'fullName': fullName,
        'phone': phone,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout({required String refreshToken}) async {
    await _apiService.post('/auth/logout', data: {'refreshToken': refreshToken});
  }

  Future<String> refreshAccessToken({required String refreshToken}) async {
    final response = await _apiService.post(
      '/auth/refresh-token',
      data: {'refreshToken': refreshToken},
    );
    return response.data['data']['accessToken'] as String;
  }
}
