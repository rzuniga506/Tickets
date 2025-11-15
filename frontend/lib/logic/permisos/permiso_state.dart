import 'package:equatable/equatable.dart';
import '../../data/models/permiso/permiso_model.dart';

abstract class PermisoState extends Equatable {
  const PermisoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PermisoInitial extends PermisoState {}

/// Estado de carga
class PermisoLoading extends PermisoState {
  final String? message;

  const PermisoLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Permisos cargados
class PermisosLoaded extends PermisoState {
  final List<PermisoModel> permisos;

  const PermisosLoaded(this.permisos);

  @override
  List<Object?> get props => [permisos];
}

/// Permisos por módulo cargados
class PermisosPorModuloLoaded extends PermisoState {
  final List<PermisoModel> permisos;
  final String modulo;

  const PermisosPorModuloLoaded(this.permisos, this.modulo);

  @override
  List<Object?> get props => [permisos, modulo];
}

/// Permiso individual cargado
class PermisoLoaded extends PermisoState {
  final PermisoModel permiso;

  const PermisoLoaded(this.permiso);

  @override
  List<Object?> get props => [permiso];
}

/// Estado de error
class PermisoError extends PermisoState {
  final String message;

  const PermisoError(this.message);

  @override
  List<Object?> get props => [message];
}
