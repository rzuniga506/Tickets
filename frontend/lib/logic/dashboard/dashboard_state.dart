import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_stats_model.dart';

/// Estados del Dashboard
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DashboardInitial extends DashboardState {}

/// Cargando estadísticas
class DashboardLoading extends DashboardState {}

/// Estadísticas cargadas exitosamente
class DashboardLoaded extends DashboardState {
  final DashboardStatsModel stats;

  const DashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Error al cargar estadísticas
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Refrescando estadísticas (mantiene datos anteriores)
class DashboardRefreshing extends DashboardState {
  final DashboardStatsModel previousStats;

  const DashboardRefreshing(this.previousStats);

  @override
  List<Object?> get props => [previousStats];
}
