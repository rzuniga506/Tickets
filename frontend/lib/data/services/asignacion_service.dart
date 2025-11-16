import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/asignacion/asignacion_ticket_model.dart';

class AsignacionService {
  final ApiClient _apiClient;

  AsignacionService(this._apiClient);

  /// Obtener historial de asignaciones de un ticket específico
  Future<List<AsignacionTicketModel>> getByTicketId(int ticketId) async {
    try {
      final response = await _apiClient.get('/asignacionesticket/ticket/$ticketId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => AsignacionTicketModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error.toString() ?? 'Error al obtener historial de asignaciones');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener asignación por ID
  Future<AsignacionTicketModel> getById(int id) async {
    try {
      final response = await _apiClient.get('/asignacionesticket/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return AsignacionTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error.toString() ?? 'Error al obtener asignación');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear una nueva asignación
  Future<AsignacionTicketModel> create(CreateAsignacionTicketDto dto) async {
    try {
      final response = await _apiClient.post(
        '/asignacionesticket',
        data: json.encode(dto.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return AsignacionTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error.toString() ?? 'Error al crear asignación');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error.toString() ?? 'Error al crear asignación: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener estadísticas de asignaciones por técnico
  Future<Map<String, int>> getEstadisticasPorTecnico() async {
    try {
      final response = await _apiClient.get('/asignacionesticket/estadisticas/por-tecnico');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!.map((key, value) => MapEntry(key, value as int));
        } else {
          throw ServerException(apiResponse.error.toString() ?? 'Error al obtener estadísticas');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener carga de trabajo actual por técnico
  Future<Map<String, int>> getCargaActual() async {
    try {
      final response = await _apiClient.get('/asignacionesticket/carga-actual');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!.map((key, value) => MapEntry(key, value as int));
        } else {
          throw ServerException(apiResponse.error.toString() ?? 'Error al obtener carga de trabajo');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener tiempo promedio de asignación por técnico
  Future<Map<String, double>> getTiemposPromedio() async {
    try {
      final response = await _apiClient.get('/asignacionesticket/tiempos-promedio');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!.map((key, value) => MapEntry(key, (value as num).toDouble()));
        } else {
          throw ServerException(apiResponse.error.toString() ?? 'Error al obtener tiempos promedio');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
