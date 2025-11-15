import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/permiso/permiso_model.dart';

class PermisoService {
  final ApiClient _apiClient;

  PermisoService(this._apiClient);

  /// Obtener todos los permisos
  Future<List<PermisoModel>> getAll() async {
    try {
      final response = await _apiClient.get('/permisos');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) =>
                  PermisoModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
              apiResponse.error ?? 'Error al obtener permisos');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener permisos por módulo
  Future<List<PermisoModel>> getByModulo(String modulo) async {
    try {
      final response = await _apiClient.get('/permisos/modulo/$modulo');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) =>
                  PermisoModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
              apiResponse.error ?? 'Error al obtener permisos por módulo');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener permiso por ID
  Future<PermisoModel> getById(int id) async {
    try {
      final response = await _apiClient.get('/permisos/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return PermisoModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(
              apiResponse.error ?? 'Error al obtener permiso');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
