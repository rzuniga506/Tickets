import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/rol/rol_model.dart';

class RolService {
  final ApiClient _apiClient;

  RolService(this._apiClient);

  /// Obtener todos los roles
  Future<List<RolModel>> getAll() async {
    try {
      final response = await _apiClient.get('/roles');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => RolModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener roles');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener rol por ID
  Future<RolModel> getById(int id) async {
    try {
      final response = await _apiClient.get('/roles/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return RolModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener rol');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear nuevo rol
  Future<RolModel> create(CreateRolDto dto) async {
    try {
      final response = await _apiClient.post(
        '/roles',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return RolModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al crear rol');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(
            apiResponse.error?.toString() ?? 'Error al crear rol: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar rol
  Future<RolModel> update(int id, UpdateRolDto dto) async {
    try {
      final response = await _apiClient.put(
        '/roles/$id',
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return RolModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(
              apiResponse.error?.toString() ?? 'Error al actualizar rol');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ??
            'Error al actualizar rol: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar rol
  Future<void> delete(int id) async {
    try {
      final response = await _apiClient.delete('/roles/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(
            apiResponse.error?.toString() ?? 'Error al eliminar rol');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Asignar permisos a un rol
  Future<RolModel> asignarPermisos(int id, List<int> permisosIds) async {
    try {
      final response = await _apiClient.post(
        '/roles/$id/permisos',
        data: permisosIds,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return RolModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(
              apiResponse.error?.toString() ?? 'Error al asignar permisos');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
