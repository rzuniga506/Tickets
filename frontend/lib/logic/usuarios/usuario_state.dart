import 'package:equatable/equatable.dart';
import '../../core/api/api_response.dart';
import '../../data/models/user/user_model.dart';

/// Estados de gestión de usuarios
abstract class UsuarioState extends Equatable {
  const UsuarioState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class UsuarioInitial extends UsuarioState {}

/// Cargando usuarios
class UsuarioLoading extends UsuarioState {}

/// Usuarios cargados exitosamente
class UsuariosLoaded extends UsuarioState {
  final PagedResult<UserModel> usuarios;
  final bool isLoadingMore;

  const UsuariosLoaded(this.usuarios, {this.isLoadingMore = false});

  UsuariosLoaded copyWith({
    PagedResult<UserModel>? usuarios,
    bool? isLoadingMore,
  }) {
    return UsuariosLoaded(
      usuarios ?? this.usuarios,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [usuarios, isLoadingMore];
}

/// Detalle de usuario cargado
class UsuarioDetailLoaded extends UsuarioState {
  final UserModel usuario;

  const UsuarioDetailLoaded(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

/// Técnicos cargados
class TecnicosLoaded extends UsuarioState {
  final List<UserModel> tecnicos;

  const TecnicosLoaded(this.tecnicos);

  @override
  List<Object?> get props => [tecnicos];
}

/// Usuario creado exitosamente
class UsuarioCreated extends UsuarioState {
  final UserModel usuario;

  const UsuarioCreated(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

/// Usuario actualizado exitosamente
class UsuarioUpdated extends UsuarioState {
  final UserModel usuario;

  const UsuarioUpdated(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

/// Usuario eliminado exitosamente
class UsuarioDeleted extends UsuarioState {
  final int usuarioId;

  const UsuarioDeleted(this.usuarioId);

  @override
  List<Object?> get props => [usuarioId];
}

/// Estado activo actualizado
class UsuarioToggled extends UsuarioState {
  final int usuarioId;
  final bool activo;

  const UsuarioToggled(this.usuarioId, this.activo);

  @override
  List<Object?> get props => [usuarioId, activo];
}

/// Acción en progreso (crear, actualizar, eliminar)
class UsuarioActionLoading extends UsuarioState {}

/// Acción completada exitosamente
class UsuarioActionSuccess extends UsuarioState {
  final String message;

  const UsuarioActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error en operaciones de usuario
class UsuarioError extends UsuarioState {
  final String message;

  const UsuarioError(this.message);

  @override
  List<Object?> get props => [message];
}
