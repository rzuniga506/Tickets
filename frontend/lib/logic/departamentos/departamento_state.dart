import 'package:equatable/equatable.dart';
import '../../data/models/departamento/departamento_model.dart';

abstract class DepartamentoState extends Equatable {
  const DepartamentoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DepartamentoInitial extends DepartamentoState {}

/// Estado de carga
class DepartamentoLoading extends DepartamentoState {
  final String? message;

  const DepartamentoLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Departamentos cargados
class DepartamentosLoaded extends DepartamentoState {
  final List<DepartamentoModel> departamentos;

  const DepartamentosLoaded(this.departamentos);

  @override
  List<Object?> get props => [departamentos];
}

/// Departamento individual cargado
class DepartamentoLoaded extends DepartamentoState {
  final DepartamentoModel departamento;

  const DepartamentoLoaded(this.departamento);

  @override
  List<Object?> get props => [departamento];
}

/// Departamento creado
class DepartamentoCreated extends DepartamentoState {
  final DepartamentoModel departamento;

  const DepartamentoCreated(this.departamento);

  @override
  List<Object?> get props => [departamento];
}

/// Departamento actualizado
class DepartamentoUpdated extends DepartamentoState {
  final DepartamentoModel departamento;

  const DepartamentoUpdated(this.departamento);

  @override
  List<Object?> get props => [departamento];
}

/// Departamento eliminado
class DepartamentoDeleted extends DepartamentoState {}

/// Estadísticas cargadas
class EstadisticasDepartamentoLoaded extends DepartamentoState {
  final Map<String, int> estadisticas;

  const EstadisticasDepartamentoLoaded(this.estadisticas);

  @override
  List<Object?> get props => [estadisticas];
}

/// Estado de error
class DepartamentoError extends DepartamentoState {
  final String message;

  const DepartamentoError(this.message);

  @override
  List<Object?> get props => [message];
}
