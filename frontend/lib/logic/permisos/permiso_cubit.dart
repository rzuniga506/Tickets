import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/permiso_repository.dart';
import 'permiso_state.dart';

class PermisoCubit extends Cubit<PermisoState> {
  final PermisoRepository _permisoRepository;

  PermisoCubit(this._permisoRepository) : super(PermisoInitial());

  /// Obtener todos los permisos
  Future<void> getPermisos() async {
    try {
      emit(const PermisoLoading('Cargando permisos...'));

      final permisos = await _permisoRepository.getAll();

      emit(PermisosLoaded(permisos));
    } catch (e) {
      emit(PermisoError(e.toString()));
    }
  }

  /// Obtener permisos por módulo
  Future<void> getPermisosByModulo(String modulo) async {
    try {
      emit(const PermisoLoading('Cargando permisos por módulo...'));

      final permisos = await _permisoRepository.getByModulo(modulo);

      emit(PermisosPorModuloLoaded(permisos, modulo));
    } catch (e) {
      emit(PermisoError(e.toString()));
    }
  }

  /// Obtener permiso por ID
  Future<void> getPermisoById(int id) async {
    try {
      emit(const PermisoLoading('Cargando permiso...'));

      final permiso = await _permisoRepository.getById(id);

      emit(PermisoLoaded(permiso));
    } catch (e) {
      emit(PermisoError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(PermisoInitial());
  }
}
