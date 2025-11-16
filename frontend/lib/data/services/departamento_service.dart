import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/departamento/departamento_model.dart';

class DepartamentoService {
  final ApiClient _apiClient;

  DepartamentoService(this._apiClient);

  /// Obtener todos los departamentos
  Future<List<DepartamentoModel>> getAll() async {
    try {
      final response = await _apiClient.get('/departamentos');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => DepartamentoModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener departamentos');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener departamentos activos
  Future<List<DepartamentoModel>> getActivos() async {
    try {
      final response = await _apiClient.get('/departamentos/activos');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => DepartamentoModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener departamentos activos');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener departamento por ID
  Future<DepartamentoModel> getById(int id) async {
    try {
      final response = await _apiClient.get('/departamentos/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return DepartamentoModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener departamento');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear nuevo departamento
  Future<DepartamentoModel> create(CreateDepartamentoDto dto) async {
    try {
      final response = await _apiClient.post(
        '/departamentos',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return DepartamentoModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al crear departamento');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al crear departamento: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar departamento
  Future<DepartamentoModel> update(int id, UpdateDepartamentoDto dto) async {
    try {
      final response = await _apiClient.put(
        '/departamentos/$id',
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return DepartamentoModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al actualizar departamento');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al actualizar departamento: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar departamento
  Future<void> delete(int id) async {
    try {
      final response = await _apiClient.delete('/departamentos/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al eliminar departamento');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Activar/Desactivar departamento
  Future<DepartamentoModel> toggleActivo(int id) async {
    try {
      final response = await _apiClient.patch('/departamentos/$id/toggle-activo');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return DepartamentoModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al cambiar estado de departamento');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener estadísticas del departamento
  Future<Map<String, int>> getEstadisticas(int id) async {
    try {
      final response = await _apiClient.get('/departamentos/$id/estadisticas');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!.map((key, value) => MapEntry(key, value as int));
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener estadísticas');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
