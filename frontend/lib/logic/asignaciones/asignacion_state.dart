import 'package:equatable/equatable.dart';
import '../../data/models/asignacion/asignacion_ticket_model.dart';

abstract class AsignacionState extends Equatable {
  const AsignacionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AsignacionInitial extends AsignacionState {}

/// Estado de carga
class AsignacionLoading extends AsignacionState {
  final String? message;

  const AsignacionLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Asignaciones cargadas (lista)
class AsignacionesLoaded extends AsignacionState {
  final List<AsignacionTicketModel> asignaciones;

  const AsignacionesLoaded(this.asignaciones);

  @override
  List<Object?> get props => [asignaciones];
}

/// Asignación individual cargada
class AsignacionLoaded extends AsignacionState {
  final AsignacionTicketModel asignacion;

  const AsignacionLoaded(this.asignacion);

  @override
  List<Object?> get props => [asignacion];
}

/// Asignación creada
class AsignacionCreated extends AsignacionState {
  final AsignacionTicketModel asignacion;

  const AsignacionCreated(this.asignacion);

  @override
  List<Object?> get props => [asignacion];
}

/// Estadísticas de asignaciones cargadas
class EstadisticasAsignacionesLoaded extends AsignacionState {
  final Map<String, int> estadisticas;

  const EstadisticasAsignacionesLoaded(this.estadisticas);

  @override
  List<Object?> get props => [estadisticas];
}

/// Carga de trabajo actual cargada
class CargaActualLoaded extends AsignacionState {
  final Map<String, int> cargaTrabajo;

  const CargaActualLoaded(this.cargaTrabajo);

  @override
  List<Object?> get props => [cargaTrabajo];
}

/// Tiempos promedio cargados
class TiemposPromedioAsignacionesLoaded extends AsignacionState {
  final Map<String, double> tiemposPromedio;

  const TiemposPromedioAsignacionesLoaded(this.tiemposPromedio);

  @override
  List<Object?> get props => [tiemposPromedio];
}

/// Estado de error
class AsignacionError extends AsignacionState {
  final String message;

  const AsignacionError(this.message);

  @override
  List<Object?> get props => [message];
}
