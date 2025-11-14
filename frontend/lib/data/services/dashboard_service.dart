import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../models/dashboard_stats_model.dart';

/// Servicio para obtener estadísticas del dashboard
class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  /// Obtiene las estadísticas del dashboard para el usuario autenticado
  Future<DashboardStatsModel> getEstadisticas() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/Dashboard/estadisticas',
    );

    if (response.success && response.data != null) {
      return DashboardStatsModel.fromJson(response.data!);
    }

    throw Exception(response.message ?? 'Error al obtener estadísticas');
  }

  /// Obtiene las estadísticas globales del sistema (solo administradores)
  Future<DashboardStatsModel> getEstadisticasGlobales() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/Dashboard/estadisticas/globales',
    );

    if (response.success && response.data != null) {
      return DashboardStatsModel.fromJson(response.data!);
    }

    throw Exception(response.message ?? 'Error al obtener estadísticas globales');
  }
}
