import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'dashboard_state.dart';

/// Cubit para gestión de estadísticas del dashboard
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit(this._repository) : super(DashboardInitial());

  /// Carga las estadísticas del dashboard
  Future<void> loadEstadisticas({bool refresh = false}) async {
    try {
      if (refresh && state is DashboardLoaded) {
        emit(DashboardRefreshing((state as DashboardLoaded).stats));
      } else {
        emit(DashboardLoading());
      }

      final stats = await _repository.getEstadisticas();
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  /// Carga las estadísticas globales (solo admin)
  Future<void> loadEstadisticasGlobales({bool refresh = false}) async {
    try {
      if (refresh && state is DashboardLoaded) {
        emit(DashboardRefreshing((state as DashboardLoaded).stats));
      } else {
        emit(DashboardLoading());
      }

      final stats = await _repository.getEstadisticasGlobales();
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  /// Refresca las estadísticas
  Future<void> refresh() async {
    await loadEstadisticas(refresh: true);
  }
}
