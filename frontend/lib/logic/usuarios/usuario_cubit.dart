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

        final updatedResult = PagedResult<UserModel>(
          items: updatedItems,
          totalRecords: result.totalRecords,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        );
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

  /// Mapea el string de rol a ID de rol del backend
  /// IDs según ApplicationDbContext.cs:
  /// - 1: Super Admin
  /// - 2: Administrador TI
  /// - 3: Técnico
  /// - 4: Usuario Final
  int _getRolId(String rol) {
    switch (rol.toLowerCase()) {
      case 'administrador':
        return 2; // Administrador TI
      case 'tecnico':
      case 'técnico':
        return 3; // Técnico
      case 'usuario':
      default:
        return 4; // Usuario Final
    }
  }

  /// Separa el nombre completo en nombre y apellido
  /// para cumplir con el DTO del backend
  Map<String, String> _splitNombreCompleto(String nombreCompleto) {
    final parts = nombreCompleto.trim().split(' ');
    if (parts.isEmpty) return {'nombre': '', 'apellido': ''};
    if (parts.length == 1) return {'nombre': parts[0], 'apellido': ''};

    final nombre = parts.first;
    final apellido = parts.sublist(1).join(' ');
    return {'nombre': nombre, 'apellido': apellido};
  }

  /// Crea un nuevo usuario
  /// Backend espera: nombre, apellido, email, password, rolesIds (List<int>)
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

      final nombres = _splitNombreCompleto(nombreCompleto);
      final rolId = _getRolId(rol);

      final data = {
        'nombre': nombres['nombre'],
        'apellido': nombres['apellido'],
        'email': email,
        'password': password,
        'rolesIds': [rolId], // Backend espera array de IDs
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
  /// Backend espera: nombre, apellido, telefono, departamentoId, activo, rolesIds (List<int>)
  /// NOTA: El email NO se puede actualizar según UsuarioUpdateDto
  Future<void> updateUsuario({
    required int id,
    required String nombreCompleto,
    required String rol,
    String? telefono,
    int? departamentoId,
    bool activo = true,
  }) async {
    try {
      emit(UsuarioActionLoading());

      final nombres = _splitNombreCompleto(nombreCompleto);
      final rolId = _getRolId(rol);

      final data = {
        'nombre': nombres['nombre'],
        'apellido': nombres['apellido'],
        'activo': activo, // Campo requerido por backend
        'rolesIds': [rolId], // Backend espera array de IDs
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
