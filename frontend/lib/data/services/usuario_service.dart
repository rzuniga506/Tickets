import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';
import '../models/user/user_model.dart';

/// Servicio de usuarios
class UsuarioService {
  final ApiClient _apiClient;

  UsuarioService(this._apiClient);

  /// Obtener todos los usuarios con filtros
  Future<PagedResult<UserModel>> getUsuarios({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    bool? activo,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.usuarios,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (searchTerm != null) 'searchTerm': searchTerm,
        if (activo != null) 'activo': activo,
      },
    );

    final apiResponse = ApiResponse<PagedResult<UserModel>>.fromJson(
      response.data,
      (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        (item) => UserModel.fromJson(item),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener usuarios');
    }

    return apiResponse.data!;
  }

  /// Obtener usuario por ID
  Future<UserModel> getUsuarioById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.usuarioById(id));

    final apiResponse = ApiResponse<UserModel>.fromJson(
      response.data,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener usuario');
    }

    return apiResponse.data!;
  }

  /// Obtener técnicos
  Future<List<UserModel>> getTecnicos() async {
    final response = await _apiClient.get(ApiEndpoints.tecnicos);

    final apiResponse = ApiResponse<List<UserModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener técnicos');
    }

    return apiResponse.data!;
  }

  /// Crear usuario
  Future<UserModel> createUsuario(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiEndpoints.usuarios,
      data: data,
    );

    final apiResponse = ApiResponse<UserModel>.fromJson(
      response.data,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al crear usuario');
    }

    return apiResponse.data!;
  }

  /// Actualizar usuario
  Future<UserModel> updateUsuario(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiEndpoints.usuarioById(id),
      data: data,
    );

    final apiResponse = ApiResponse<UserModel>.fromJson(
      response.data,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al actualizar usuario');
    }

    return apiResponse.data!;
  }

  /// Eliminar usuario
  Future<void> deleteUsuario(int id) async {
    await _apiClient.delete(ApiEndpoints.usuarioById(id));
  }

  /// Toggle activo/inactivo
  Future<void> toggleActivo(int id) async {
    await _apiClient.patch(ApiEndpoints.toggleActivo(id));
  }
}
