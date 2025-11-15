import 'package:equatable/equatable.dart';
import '../../data/models/rol/rol_model.dart';

abstract class RolState extends Equatable {
  const RolState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class RolInitial extends RolState {}

/// Estado de carga
class RolLoading extends RolState {
  final String? message;

  const RolLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Roles cargados
class RolesLoaded extends RolState {
  final List<RolModel> roles;

  const RolesLoaded(this.roles);

  @override
  List<Object?> get props => [roles];
}

/// Rol individual cargado
class RolLoaded extends RolState {
  final RolModel rol;

  const RolLoaded(this.rol);

  @override
  List<Object?> get props => [rol];
}

/// Rol creado
class RolCreated extends RolState {
  final RolModel rol;

  const RolCreated(this.rol);

  @override
  List<Object?> get props => [rol];
}

/// Rol actualizado
class RolUpdated extends RolState {
  final RolModel rol;

  const RolUpdated(this.rol);

  @override
  List<Object?> get props => [rol];
}

/// Rol eliminado
class RolDeleted extends RolState {}

/// Permisos asignados
class PermisosAsignados extends RolState {
  final RolModel rol;

  const PermisosAsignados(this.rol);

  @override
  List<Object?> get props => [rol];
}

/// Estado de error
class RolError extends RolState {
  final String message;

  const RolError(this.message);

  @override
  List<Object?> get props => [message];
}
