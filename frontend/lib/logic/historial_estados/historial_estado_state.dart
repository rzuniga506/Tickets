import 'package:equatable/equatable.dart';
import '../../data/models/historial/historial_estado_ticket_model.dart';

abstract class HistorialEstadoState extends Equatable {
  const HistorialEstadoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class HistorialEstadoInitial extends HistorialEstadoState {}

/// Estado de carga
class HistorialEstadoLoading extends HistorialEstadoState {
  final String? message;

  const HistorialEstadoLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Historial cargado (lista)
class HistorialEstadosLoaded extends HistorialEstadoState {
  final List<HistorialEstadoTicketModel> historiales;

  const HistorialEstadosLoaded(this.historiales);

  @override
  List<Object?> get props => [historiales];
}

/// Registro individual cargado
class HistorialEstadoLoaded extends HistorialEstadoState {
  final HistorialEstadoTicketModel historial;

  const HistorialEstadoLoaded(this.historial);

  @override
  List<Object?> get props => [historial];
}

/// Registro creado
class HistorialEstadoCreated extends HistorialEstadoState {
  final HistorialEstadoTicketModel historial;

  const HistorialEstadoCreated(this.historial);

  @override
  List<Object?> get props => [historial];
}

/// Estadísticas cargadas
class EstadisticasLoaded extends HistorialEstadoState {
  final Map<String, int> estadisticas;

  const EstadisticasLoaded(this.estadisticas);

  @override
  List<Object?> get props => [estadisticas];
}

/// Tiempos promedio cargados
class TiemposPromedioLoaded extends HistorialEstadoState {
  final Map<String, double> tiemposPromedio;

  const TiemposPromedioLoaded(this.tiemposPromedio);

  @override
  List<Object?> get props => [tiemposPromedio];
}

/// Estado de error
class HistorialEstadoError extends HistorialEstadoState {
  final String message;

  const HistorialEstadoError(this.message);

  @override
  List<Object?> get props => [message];
}
