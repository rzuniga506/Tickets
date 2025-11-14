import 'dart:convert';
import '../../core/storage/secure_storage.dart';
import '../../core/errors/exceptions.dart';
import '../services/auth_service.dart';
import '../models/auth/login_request.dart';
import '../models/auth/auth_response.dart';
import '../models/user/user_model.dart';

/// Repositorio de autenticación
class AuthRepository {
  final AuthService _authService;
  final SecureStorage _storage;

  AuthRepository(this._authService, this._storage);

  /// Login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final authResponse = await _authService.login(request);

      // Guardar tokens
      await _storage.saveAccessToken(authResponse.accessToken);
      await _storage.saveRefreshToken(authResponse.refreshToken);

      // Guardar datos del usuario
      await _storage.saveUserData(jsonEncode(authResponse.usuario.toJson()));

      return authResponse;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      await _authService.logout(refreshToken);
    } catch (e) {
      // Ignorar errores del servidor al hacer logout
    } finally {
      await _storage.deleteAllTokens();
    }
  }

  /// Verificar si está autenticado
  Future<bool> isAuthenticated() async {
    return await _storage.isAuthenticated();
  }

  /// Obtener usuario actual desde storage
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await _storage.getUserData();
      if (userData == null) return null;

      final json = jsonDecode(userData);
      return UserModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Obtener perfil actualizado del servidor
  Future<UserModel> getProfile() async {
    try {
      final user = await _authService.getProfile();

      // Actualizar datos en storage
      await _storage.saveUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      // Al cambiar contraseña, se revocan todos los tokens
      // Así que hacemos logout
      await logout();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Verificar si email existe
  Future<bool> emailExists(String email) async {
    try {
      return await _authService.emailExists(email);
    } catch (e) {
      return false;
    }
  }
}
