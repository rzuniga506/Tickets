import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/rol/rol_model.dart';
import '../../data/repositories/rol_repository.dart';
import 'rol_state.dart';

class RolCubit extends Cubit<RolState> {
  final RolRepository _rolRepository;

  RolCubit(this._rolRepository) : super(RolInitial());

  /// Obtener todos los roles
  Future<void> getRoles() async {
    try {
      emit(const RolLoading('Cargando roles...'));

      final roles = await _rolRepository.getAll();

      emit(RolesLoaded(roles));
    } catch (e) {
      emit(RolError(e.toString()));
    }
  }

  /// Obtener rol por ID
  Future<void> getRolById(int id) async {
    try {
      emit(const RolLoading('Cargando rol...'));

      final rol = await _rolRepository.getById(id);

      emit(RolLoaded(rol));
    } catch (e) {
      emit(RolError(e.toString()));
    }
  }

  /// Crear nuevo rol
  Future<void> createRol(CreateRolDto dto) async {
    try {
      emit(const RolLoading('Creando rol...'));

      final rol = await _rolRepository.create(dto);

      emit(RolCreated(rol));
    } catch (e) {
      emit(RolError(e.toString()));
    }
  }

  /// Actualizar rol
  Future<void> updateRol(int id, UpdateRolDto dto) async {
    try {
      emit(const RolLoading('Actualizando rol...'));

      final rol = await _rolRepository.update(id, dto);

      emit(RolUpdated(rol));
    } catch (e) {
      emit(RolError(e.toString()));
    }
  }

  /// Eliminar rol
  Future<void> deleteRol(int id) async {
    try {
      emit(const RolLoading('Eliminando rol...'));

      await _rolRepository.delete(id);

      emit(RolDeleted());
    } catch (e) {
      emit(RolError(e.toString()));
    }
  }

  /// Asignar permisos a un rol
  Future<void> asignarPermisos(int id, List<int> permisosIds) async {
    try {
      emit(const RolLoading('Asignando permisos...'));

      final rol = await _rolRepository.asignarPermisos(id, permisosIds);

      emit(PermisosAsignados(rol));
    } catch (e) {
      emit(RolError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(RolInitial());
  }
}
