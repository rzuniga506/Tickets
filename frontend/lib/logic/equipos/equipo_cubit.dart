import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/equipo_repository.dart';
import '../../data/models/equipo/equipo_model.dart';
import '../../core/api/api_response.dart';
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
    EstadoEquipo? estado,
    CondicionEquipo? condicion,
    int? usuarioAsignadoId,
    int? departamentoId,
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
        estado: estado?.toJson(), // Convierte enum a int (0-6)
        condicion: condicion?.toJson(), // Convierte enum a int (0-5)
        usuarioAsignadoId: usuarioAsignadoId,
        departamentoId: departamentoId,
        searchTerm: searchTerm,
      );

      if (loadMore && state is EquiposLoaded) {
        // Combinar resultados existentes con nuevos
        final currentState = state as EquiposLoaded;
        final updatedItems = [...currentState.equipos.items, ...result.items];
        final updatedResult = PagedResult<EquipoModel>(
          items: updatedItems,
          totalRecords: result.totalItems,
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
  /// Campos requeridos según EquipoCreateDto del backend
  Future<void> createEquipo({
    required String codigoInterno,
    required String nombre,
    required EstadoEquipo estado,
    required CondicionEquipo condicion,
    String? numeroSerie,
    String? descripcion,
    String? modelo,
    String? especificacionesJson,
    double? costoAdquisicion,
    DateTime? fechaAdquisicion,
    int vidaUtilMeses = 36,
    double? valorResidual,
    DateTime? fechaInicioGarantia,
    DateTime? fechaFinGarantia,
    String? observaciones,
    int? usuarioAsignadoId,
    int? departamentoAsignadoId,
  }) async {
    try {
      emit(EquipoActionLoading('Creando equipo...'));

      final data = {
        'codigoInterno': codigoInterno,
        'nombre': nombre,
        'estado': estado.toJson(), // Convierte enum a int (0-6)
        'condicion': condicion.toJson(), // Convierte enum a int (0-5)
        if (numeroSerie != null) 'numeroSerie': numeroSerie,
        if (descripcion != null) 'descripcion': descripcion,
        if (modelo != null) 'modelo': modelo,
        if (especificacionesJson != null)
          'especificacionesJson': especificacionesJson,
        if (costoAdquisicion != null) 'costoAdquisicion': costoAdquisicion,
        if (fechaAdquisicion != null)
          'fechaAdquisicion': fechaAdquisicion.toIso8601String(),
        'vidaUtilMeses': vidaUtilMeses,
        if (valorResidual != null) 'valorResidual': valorResidual,
        if (fechaInicioGarantia != null)
          'fechaInicioGarantia': fechaInicioGarantia.toIso8601String(),
        if (fechaFinGarantia != null)
          'fechaFinGarantia': fechaFinGarantia.toIso8601String(),
        if (observaciones != null) 'observaciones': observaciones,
        if (usuarioAsignadoId != null) 'usuarioAsignadoId': usuarioAsignadoId,
        if (departamentoAsignadoId != null)
          'departamentoAsignadoId': departamentoAsignadoId,
      };

      final equipo = await _equipoRepository.createEquipo(data);
      emit(EquipoCreated(equipo));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Actualizar equipo
  /// Campos según EquipoUpdateDto del backend
  Future<void> updateEquipo({
    required int id,
    required String nombre,
    required EstadoEquipo estado,
    required CondicionEquipo condicion,
    String? numeroSerie,
    String? descripcion,
    String? modelo,
    String? especificacionesJson,
    double? costoAdquisicion,
    DateTime? fechaAdquisicion,
    int vidaUtilMeses = 36, // Campo requerido por backend
    double? valorResidual,
    DateTime? fechaInicioGarantia,
    DateTime? fechaFinGarantia,
    String? observaciones,
  }) async {
    try {
      emit(EquipoActionLoading('Actualizando equipo...'));

      final data = {
        'nombre': nombre,
        'estado': estado.toJson(), // Convierte enum a int
        'condicion': condicion.toJson(), // Convierte enum a int
        'vidaUtilMeses': vidaUtilMeses, // Campo requerido por backend
        if (numeroSerie != null) 'numeroSerie': numeroSerie,
        if (descripcion != null) 'descripcion': descripcion,
        if (modelo != null) 'modelo': modelo,
        if (especificacionesJson != null)
          'especificacionesJson': especificacionesJson,
        if (costoAdquisicion != null) 'costoAdquisicion': costoAdquisicion,
        if (fechaAdquisicion != null)
          'fechaAdquisicion': fechaAdquisicion.toIso8601String(),
        if (valorResidual != null) 'valorResidual': valorResidual,
        if (fechaInicioGarantia != null)
          'fechaInicioGarantia': fechaInicioGarantia.toIso8601String(),
        if (fechaFinGarantia != null)
          'fechaFinGarantia': fechaFinGarantia.toIso8601String(),
        if (observaciones != null) 'observaciones': observaciones,
      };

      final equipo = await _equipoRepository.updateEquipo(id, data);
      emit(EquipoUpdated(equipo));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Asignar equipo a un usuario
  Future<void> asignarEquipo(int equipoId, int usuarioId) async {
    try {
      emit(EquipoActionLoading('Asignando equipo...'));
      await _equipoRepository.asignarEquipo(equipoId, usuarioId);
      // Recargar el equipo actualizado
      await getEquipoById(equipoId);
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Desasignar equipo de usuario actual
  Future<void> desasignarEquipo(int equipoId) async {
    try {
      emit(EquipoActionLoading('Desasignando equipo...'));
      await _equipoRepository.desasignarEquipo(equipoId);
      // Recargar el equipo actualizado
      await getEquipoById(equipoId);
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
  Future<void> getEquiposDisponibles() async {
    try {
      emit(EquipoLoading());
      final equipos = await _equipoRepository.getEquiposDisponibles();
      // Convertir List a PagedResult para mantener consistencia
      final result = PagedResult<EquipoModel>(
        items: equipos,
        totalRecords: equipos.length,
        pageNumber: 1,
        pageSize: equipos.length,
      );
      emit(EquiposLoaded(result));
    } catch (e) {
      emit(EquipoError(e.toString()));
    }
  }

  /// Obtener mis equipos asignados
  Future<void> getMisEquipos() async {
    try {
      emit(EquipoLoading());
      final equipos = await _equipoRepository.getMisEquipos();
      // Convertir List a PagedResult para mantener consistencia
      final result = PagedResult<EquipoModel>(
        items: equipos,
        totalRecords: equipos.length,
        pageNumber: 1,
        pageSize: equipos.length,
      );
      emit(EquiposLoaded(result));
    } catch (e) {
      final errorMessage = e.toString().contains('Exception:')
          ? e.toString().replaceAll('Exception:', '').trim()
          : 'Error al cargar los equipos: ${e.toString()}';
      emit(EquipoError(errorMessage));
    }
  }

  /// Eliminar equipo
  Future<void> deleteEquipo(int id) async {
    try {
      emit(EquipoActionLoading('Eliminando equipo...'));
      await _equipoRepository.deleteEquipo(id);
      emit(const EquipoActionSuccess('Equipo eliminado correctamente', null));
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
