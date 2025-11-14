import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/equipo_repository.dart';
import '../../data/models/equipo_model.dart';
import '../../data/models/paged_result.dart';
import '../../config/constants.dart';
import 'equipo_state.dart';

/// Cubit para gestionar equipos/inventario
class EquipoCubit extends Cubit<EquipoState> {
  final EquipoRepository _equipoRepository;

  EquipoCubit(this._equipoRepository) : super(EquipoInitial());

  /// Obtener lista de equipos con filtros y paginación
  Future<void> getEquipos({
    int pageNumber = 1,
    int pageSize = 10,
    TipoEquipo? tipo,
    EstadoEquipo? estado,
    CondicionEquipo? condicion,
    String? ubicacion,
    int? usuarioAsignadoId,
    String? searchTerm,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore && state is EquiposLoaded) {
        // Mostrar indicador de carga adicional
        final currentState = state as EquiposLoaded;
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(EquipoLoading());
      }

      final result = await _equipoRepository.getEquipos(
        pageNumber: pageNumber,
        pageSize: pageSize,
        tipo: tipo,
        estado: estado,
        condicion: condicion,
        ubicacion: ubicacion,
        usuarioAsignadoId: usuarioAsignadoId,
        searchTerm: searchTerm,
      );

      if (loadMore && state is EquiposLoaded) {
        // Combinar resultados existentes con nuevos
        final currentState = state as EquiposLoaded;
        final updatedItems = [...currentState.equipos.items, ...result.items];
        final updatedResult = PagedResult<EquipoModel>(
          items: updatedItems,
          totalItems: result.totalItems,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        );
        emit(EquiposLoaded(updatedResult));
      } else {
        emit(EquiposLoaded(result));
      }
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Obtener detalle de un equipo
  Future<void> getEquipoById(int id) async {
    try {
      emit(EquipoLoading());
      final equipo = await _equipoRepository.getEquipoById(id);
      emit(EquipoDetailLoaded(equipo));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Buscar equipo por código QR
  Future<void> getEquipoByQR(String codigoQR) async {
    try {
      emit(EquipoActionLoading('Buscando equipo...'));
      final equipo = await _equipoRepository.getEquipoByQR(codigoQR);
      emit(EquipoFoundByQR(equipo));
    } catch (e) {
      emit(EquipoError('Equipo no encontrado con código QR: $codigoQR'));
    }
  }

  /// Crear nuevo equipo
  Future<void> createEquipo(CreateEquipoRequest request) async {
    try {
      emit(EquipoActionLoading('Creando equipo...'));
      final equipo = await _equipoRepository.createEquipo(request);
      emit(EquipoCreated(equipo));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Actualizar equipo
  Future<void> updateEquipo(int id, UpdateEquipoRequest request) async {
    try {
      emit(EquipoActionLoading('Actualizando equipo...'));
      final equipo = await _equipoRepository.updateEquipo(id, request);
      emit(EquipoUpdated(equipo));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Asignar equipo a un usuario
  Future<void> asignarEquipo(int equipoId, int usuarioId) async {
    try {
      emit(EquipoActionLoading('Asignando equipo...'));
      final equipo = await _equipoRepository.asignarEquipo(equipoId, usuarioId);
      emit(EquipoActionSuccess('Equipo asignado correctamente', equipo));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Desasignar equipo de usuario actual
  Future<void> desasignarEquipo(int equipoId) async {
    try {
      emit(EquipoActionLoading('Desasignando equipo...'));
      final equipo = await _equipoRepository.desasignarEquipo(equipoId);
      emit(EquipoActionSuccess('Equipo desasignado correctamente', equipo));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Generar código QR para un equipo
  Future<void> generarQR(int equipoId) async {
    try {
      emit(EquipoActionLoading('Generando código QR...'));
      final qrCode = await _equipoRepository.generarQR(equipoId);

      // Recargar el equipo actualizado
      final equipo = await _equipoRepository.getEquipoById(equipoId);

      emit(QRGenerated(qrCode, equipo));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Obtener equipos disponibles (no asignados)
  Future<void> getEquiposDisponibles({
    int pageNumber = 1,
    int pageSize = 10,
    TipoEquipo? tipo,
  }) async {
    try {
      emit(EquipoLoading());
      final result = await _equipoRepository.getEquiposDisponibles(
        pageNumber: pageNumber,
        pageSize: pageSize,
        tipo: tipo,
      );
      emit(EquiposLoaded(result));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Obtener mis equipos asignados
  Future<void> getMisEquipos({
    int pageNumber = 1,
    int pageSize = 10,
    TipoEquipo? tipo,
  }) async {
    try {
      emit(EquipoLoading());
      final result = await _equipoRepository.getMisEquipos(
        pageNumber: pageNumber,
        pageSize: pageSize,
        tipo: tipo,
      );
      emit(EquiposLoaded(result));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Eliminar equipo
  Future<void> deleteEquipo(int id) async {
    try {
      emit(EquipoActionLoading('Eliminando equipo...'));
      await _equipoRepository.deleteEquipo(id);
      emit(const EquipoActionSuccess('Equipo eliminado correctamente', null as EquipoModel));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Iniciar escaneo de QR
  void startQRScanning() {
    emit(QRScanning());
  }

  /// Resetear estado
  void reset() {
    emit(EquipoInitial());
  }
}
