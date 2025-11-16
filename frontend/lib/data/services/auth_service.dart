import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/auth_response.dart';
import '../models/user/user_model.dart';

/// Servicio de autenticación
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Login
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<AuthResponse>.fromJson(
      response.data,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al iniciar sesión');
    }

    return apiResponse.data!;
  }

  /// Refresh token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );

    final apiResponse = ApiResponse<AuthResponse>.fromJson(
      response.data,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al renovar token');
    }

    return apiResponse.data!;
  }

  /// Logout
  Future<void> logout([String? refreshToken]) async {
    await _apiClient.post(
      ApiEndpoints.logout,
      data: refreshToken,
    );
  }

  /// Obtener perfil
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);

    final apiResponse = ApiResponse<UserModel>.fromJson(
      response.data,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener perfil');
    }

    return apiResponse.data!;
  }

  /// Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Verificar si email existe
  Future<bool> emailExists(String email) async {
    final response = await _apiClient.get(
      ApiEndpoints.emailExists,
      queryParameters: {'email': email},
    );

    final apiResponse = ApiResponse<bool>.fromJson(
      response.data,
      (json) => json as bool,
    );

    return apiResponse.data ?? false;
  }
}
