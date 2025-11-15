import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/historial/historial_estado_ticket_model.dart';

class HistorialEstadoService {
  final ApiClient _apiClient;

  HistorialEstadoService(this._apiClient);

  /// Obtener historial de un ticket específico
  Future<List<HistorialEstadoTicketModel>> getByTicketId(int ticketId) async {
    try {
      final response = await _apiClient.get('/historialestadosticket/ticket/$ticketId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => HistorialEstadoTicketModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error ?? 'Error al obtener historial del ticket');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener un registro de historial por ID
  Future<HistorialEstadoTicketModel> getById(int id) async {
    try {
      final response = await _apiClient.get('/historialestadosticket/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return HistorialEstadoTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error ?? 'Error al obtener registro de historial');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear un nuevo registro de historial
  Future<HistorialEstadoTicketModel> create(CreateHistorialEstadoTicketDto dto) async {
    try {
      final response = await _apiClient.post(
        '/historialestadosticket',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return HistorialEstadoTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error ?? 'Error al crear registro de historial');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error ?? 'Error al crear registro: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener estadísticas de cambios de estado de un ticket
  Future<Map<String, int>> getEstadisticasByTicketId(int ticketId) async {
    try {
      final response = await _apiClient.get('/historialestadosticket/ticket/$ticketId/estadisticas');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!.map((key, value) => MapEntry(key, value as int));
        } else {
          throw ServerException(apiResponse.error ?? 'Error al obtener estadísticas');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener tiempo promedio en cada estado para un ticket
  Future<Map<String, double>> getTiemposPromedioByTicketId(int ticketId) async {
    try {
      final response = await _apiClient.get('/historialestadosticket/ticket/$ticketId/tiempos-promedio');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!.map((key, value) => MapEntry(key, (value as num).toDouble()));
        } else {
          throw ServerException(apiResponse.error ?? 'Error al obtener tiempos promedio');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
