import '../models/dashboard_stats_model.dart';
import '../services/dashboard_service.dart';

/// Repositorio para estadísticas del dashboard
class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository(this._dashboardService);

  /// Obtiene las estadísticas del dashboard
  Future<DashboardStatsModel> getEstadisticas() async {
    try {
      return await _dashboardService.getEstadisticas();
    } catch (e) {
      throw Exception('Error al cargar estadísticas: ${e.toString()}');
    }
  }

  /// Obtiene las estadísticas globales (solo admin)
  Future<DashboardStatsModel> getEstadisticasGlobales() async {
    try {
      return await _dashboardService.getEstadisticasGlobales();
    } catch (e) {
      throw Exception('Error al cargar estadísticas globales: ${e.toString()}');
    }
  }
}
