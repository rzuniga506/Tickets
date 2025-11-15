import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/departamento/departamento_model.dart';
import '../../data/repositories/departamento_repository.dart';
import 'departamento_state.dart';

class DepartamentoCubit extends Cubit<DepartamentoState> {
  final DepartamentoRepository _departamentoRepository;

  DepartamentoCubit(this._departamentoRepository) : super(DepartamentoInitial());

  /// Obtener todos los departamentos
  Future<void> getDepartamentos() async {
    try {
      emit(const DepartamentoLoading('Cargando departamentos...'));

      final departamentos = await _departamentoRepository.getAll();

      emit(DepartamentosLoaded(departamentos));
    } catch (e) {
      emit(DepartamentoError(e.toString()));
    }
  }

  /// Obtener departamentos activos
  Future<void> getDepartamentosActivos() async {
    try {
      emit(const DepartamentoLoading('Cargando departamentos activos...'));

      final departamentos = await _departamentoRepository.getActivos();

      emit(DepartamentosLoaded(departamentos));
    } catch (e) {
      emit(DepartamentoError(e.toString()));
    }
  }

  /// Obtener departamento por ID
  Future<void> getDepartamentoById(int id) async {
    try {
      emit(const DepartamentoLoading('Cargando departamento...'));

      final departamento = await _departamentoRepository.getById(id);

      emit(DepartamentoLoaded(departamento));
    } catch (e) {
      emit(DepartamentoError(e.toString()));
    }
  }

  /// Crear nuevo departamento
  Future<void> createDepartamento(CreateDepartamentoDto dto) async {
    try {
      emit(const DepartamentoLoading('Creando departamento...'));

      final departamento = await _departamentoRepository.create(dto);

      emit(DepartamentoCreated(departamento));
    } catch (e) {
      emit(DepartamentoError(e.toString()));
    }
  }

  /// Actualizar departamento
  Future<void> updateDepartamento(int id, UpdateDepartamentoDto dto) async {
    try {
      emit(const DepartamentoLoading('Actualizando departamento...'));

      final departamento = await _departamentoRepository.update(id, dto);

      emit(DepartamentoUpdated(departamento));
    } catch (e) {
      emit(DepartamentoError(e.toString()));
    }
  }

  /// Eliminar departamento
  Future<void> deleteDepartamento(int id) async {
    try {
      emit(const DepartamentoLoading('Eliminando departamento...'));

      await _departamentoRepository.delete(id);

      emit(DepartamentoDeleted());
    } catch (e) {
      emit(DepartamentoError(e.toString()));
    }
  }

  /// Activar/Desactivar departamento
  Future<void> toggleActivo(int id) async {
    try {
      emit(const DepartamentoLoading('Cambiando estado de departamento...'));

      final departamento = await _departamentoRepository.toggleActivo(id);

      emit(DepartamentoUpdated(departamento));
    } catch (e) {
      emit(DepartamentoError(e.toString()));
    }
  }

  /// Obtener estadísticas del departamento
  Future<void> getEstadisticas(int id) async {
    try {
      emit(const DepartamentoLoading('Cargando estadísticas...'));

      final estadisticas = await _departamentoRepository.getEstadisticas(id);

      emit(EstadisticasDepartamentoLoaded(estadisticas));
    } catch (e) {
      emit(DepartamentoError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(DepartamentoInitial());
  }
}
