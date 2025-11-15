import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/asignacion/asignacion_ticket_model.dart';
import '../../data/repositories/asignacion_repository.dart';
import 'asignacion_state.dart';

class AsignacionCubit extends Cubit<AsignacionState> {
  final AsignacionRepository _asignacionRepository;

  AsignacionCubit(this._asignacionRepository) : super(AsignacionInitial());

  /// Obtener historial de asignaciones de un ticket específico
  Future<void> getAsignacionesByTicketId(int ticketId) async {
    try {
      emit(const AsignacionLoading('Cargando historial de asignaciones...'));

      final asignaciones = await _asignacionRepository.getByTicketId(ticketId);

      emit(AsignacionesLoaded(asignaciones));
    } catch (e) {
      emit(AsignacionError(e.toString()));
    }
  }

  /// Obtener asignación por ID
  Future<void> getAsignacionById(int id) async {
    try {
      emit(const AsignacionLoading('Cargando asignación...'));

      final asignacion = await _asignacionRepository.getById(id);

      emit(AsignacionLoaded(asignacion));
    } catch (e) {
      emit(AsignacionError(e.toString()));
    }
  }

  /// Crear una nueva asignación
  Future<void> createAsignacion(CreateAsignacionTicketDto dto) async {
    try {
      emit(const AsignacionLoading('Creando asignación...'));

      final asignacion = await _asignacionRepository.create(dto);

      emit(AsignacionCreated(asignacion));
    } catch (e) {
      emit(AsignacionError(e.toString()));
    }
  }

  /// Obtener estadísticas de asignaciones por técnico
  Future<void> getEstadisticasPorTecnico() async {
    try {
      emit(const AsignacionLoading('Cargando estadísticas...'));

      final estadisticas = await _asignacionRepository.getEstadisticasPorTecnico();

      emit(EstadisticasAsignacionesLoaded(estadisticas));
    } catch (e) {
      emit(AsignacionError(e.toString()));
    }
  }

  /// Obtener carga de trabajo actual por técnico
  Future<void> getCargaActual() async {
    try {
      emit(const AsignacionLoading('Cargando carga de trabajo...'));

      final cargaTrabajo = await _asignacionRepository.getCargaActual();

      emit(CargaActualLoaded(cargaTrabajo));
    } catch (e) {
      emit(AsignacionError(e.toString()));
    }
  }

  /// Obtener tiempo promedio de asignación por técnico
  Future<void> getTiemposPromedio() async {
    try {
      emit(const AsignacionLoading('Cargando tiempos promedio...'));

      final tiempos = await _asignacionRepository.getTiemposPromedio();

      emit(TiemposPromedioAsignacionesLoaded(tiempos));
    } catch (e) {
      emit(AsignacionError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(AsignacionInitial());
  }
}
