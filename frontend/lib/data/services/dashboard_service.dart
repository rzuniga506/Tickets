import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/dashboard_stats_model.dart';

/// Servicio para obtener estadísticas del dashboard
class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  /// Obtiene las estadísticas del dashboard para el usuario autenticado
  Future<DashboardStatsModel> getEstadisticas() async {
    try {
      final response = await _apiClient.get('/Dashboard/estadisticas');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return DashboardStatsModel.fromJson(apiResponse.data!);
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

  /// Obtiene las estadísticas globales del sistema (solo administradores)
  Future<DashboardStatsModel> getEstadisticasGlobales() async {
    try {
      final response = await _apiClient.get('/Dashboard/estadisticas/globales');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return DashboardStatsModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener estadísticas globales');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
