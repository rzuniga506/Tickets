import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/usuario_repository.dart';
import 'usuario_state.dart';

/// Cubit para gestión de usuarios
class UsuarioCubit extends Cubit<UsuarioState> {
  final UsuarioRepository _repository;

  UsuarioCubit(this._repository) : super(UsuarioInitial());

  /// Obtiene todos los usuarios con paginación y filtros
  Future<void> getUsuarios({
    int pageNumber = 1,
    int pageSize = 20,
    String? searchTerm,
    bool? activo,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore && state is UsuariosLoaded) {
        // Cargar más sin cambiar el estado actual
        emit((state as UsuariosLoaded).copyWith(isLoadingMore: true));
      } else {
        emit(UsuarioLoading());
      }

      final result = await _repository.getUsuarios(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchTerm: searchTerm,
        activo: activo,
      );

      if (loadMore && state is UsuariosLoaded) {
        final currentState = state as UsuariosLoaded;
        final updatedItems = [...currentState.usuarios.items, ...result.items];

        final updatedResult = result.copyWith(items: updatedItems);
        emit(UsuariosLoaded(updatedResult));
      } else {
        emit(UsuariosLoaded(result));
      }
    } catch (e) {
      emit(UsuarioError(e.toString()));
    }
  }

  /// Obtiene un usuario por ID
  Future<void> getUsuarioById(int id) async {
    try {
      emit(UsuarioLoading());

      final usuario = await _repository.getUsuarioById(id);
      emit(UsuarioDetailLoaded(usuario));
    } catch (e) {
      emit(UsuarioError(e.toString()));
    }
  }

  /// Obtiene la lista de técnicos
  Future<void> getTecnicos() async {
    try {
      emit(UsuarioLoading());

      final tecnicos = await _repository.getTecnicos();
      emit(TecnicosLoaded(tecnicos));
    } catch (e) {
      emit(UsuarioError(e.toString()));
    }
  }

  /// Crea un nuevo usuario
  Future<void> createUsuario({
    required String nombreCompleto,
    required String email,
    required String password,
    required String rol,
    String? telefono,
    int? departamentoId,
  }) async {
    try {
      emit(UsuarioActionLoading());

      final data = {
        'nombreCompleto': nombreCompleto,
        'email': email,
        'password': password,
        'rol': rol,
        if (telefono != null) 'telefono': telefono,
        if (departamentoId != null) 'departamentoId': departamentoId,
      };

      final usuario = await _repository.createUsuario(data);
      emit(UsuarioCreated(usuario));
      emit(UsuarioActionSuccess('Usuario creado exitosamente'));
    } catch (e) {
      emit(UsuarioError(e.toString()));
    }
  }

  /// Actualiza un usuario existente
  Future<void> updateUsuario({
    required int id,
    required String nombreCompleto,
    required String email,
    required String rol,
    String? telefono,
    int? departamentoId,
  }) async {
    try {
      emit(UsuarioActionLoading());

      final data = {
        'nombreCompleto': nombreCompleto,
        'email': email,
        'rol': rol,
        if (telefono != null) 'telefono': telefono,
        if (departamentoId != null) 'departamentoId': departamentoId,
      };

      final usuario = await _repository.updateUsuario(id, data);
      emit(UsuarioUpdated(usuario));
      emit(UsuarioActionSuccess('Usuario actualizado exitosamente'));
    } catch (e) {
      emit(UsuarioError(e.toString()));
    }
  }

  /// Elimina un usuario
  Future<void> deleteUsuario(int id) async {
    try {
      emit(UsuarioActionLoading());

      await _repository.deleteUsuario(id);
      emit(UsuarioDeleted(id));
      emit(UsuarioActionSuccess('Usuario eliminado exitosamente'));
    } catch (e) {
      emit(UsuarioError(e.toString()));
    }
  }

  /// Activa o desactiva un usuario
  Future<void> toggleActivo(int id, bool currentState) async {
    try {
      emit(UsuarioActionLoading());

      await _repository.toggleActivo(id);
      emit(UsuarioToggled(id, !currentState));
      emit(UsuarioActionSuccess(
        !currentState ? 'Usuario activado' : 'Usuario desactivado',
      ));
    } catch (e) {
      emit(UsuarioError(e.toString()));
    }
  }
}
