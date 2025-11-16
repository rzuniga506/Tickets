import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/categoria/categoria_ticket_model.dart';

class CategoriaService {
  final ApiClient _apiClient;

  CategoriaService(this._apiClient);

  /// Obtener todas las categorías
  Future<List<CategoriaTicketModel>> getAll() async {
    try {
      final response = await _apiClient.get('/categoriasticket');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => CategoriaTicketModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener categorías');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener categorías activas
  Future<List<CategoriaTicketModel>> getActivos() async {
    try {
      final response = await _apiClient.get('/categoriasticket/activos');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => CategoriaTicketModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener categorías activas');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener categoría por ID
  Future<CategoriaTicketModel> getById(int id) async {
    try {
      final response = await _apiClient.get('/categoriasticket/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return CategoriaTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener categoría');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear nueva categoría
  Future<CategoriaTicketModel> create(CreateCategoriaTicketDto dto) async {
    try {
      final response = await _apiClient.post(
        '/categoriasticket',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return CategoriaTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al crear categoría');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al crear categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar categoría
  Future<CategoriaTicketModel> update(int id, UpdateCategoriaTicketDto dto) async {
    try {
      final response = await _apiClient.put(
        '/categoriasticket/$id',
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return CategoriaTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al actualizar categoría');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al actualizar categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar categoría
  Future<void> delete(int id) async {
    try {
      final response = await _apiClient.delete('/categoriasticket/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al eliminar categoría');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Activar/Desactivar categoría
  Future<CategoriaTicketModel> toggleActivo(int id) async {
    try {
      final response = await _apiClient.patch('/categoriasticket/$id/toggle-activo');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return CategoriaTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al cambiar estado de categoría');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Reordenar categorías
  Future<void> reorder(Map<int, int> ordenPorId) async {
    try {
      final response = await _apiClient.put(
        '/categoriasticket/reorder',
        data: ordenPorId,
      );

      if (response.statusCode != 200) {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al reordenar categorías');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
