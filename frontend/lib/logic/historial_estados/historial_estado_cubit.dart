import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/historial/historial_estado_ticket_model.dart';
import '../../data/repositories/historial_estado_repository.dart';
import 'historial_estado_state.dart';

class HistorialEstadoCubit extends Cubit<HistorialEstadoState> {
  final HistorialEstadoRepository _historialEstadoRepository;

  HistorialEstadoCubit(this._historialEstadoRepository) : super(HistorialEstadoInitial());

  /// Obtener historial de un ticket específico
  Future<void> getHistorialByTicketId(int ticketId) async {
    try {
      emit(const HistorialEstadoLoading('Cargando historial del ticket...'));

      final historiales = await _historialEstadoRepository.getByTicketId(ticketId);

      emit(HistorialEstadosLoaded(historiales));
    } catch (e) {
      emit(HistorialEstadoError(e.toString()));
    }
  }

  /// Obtener un registro de historial por ID
  Future<void> getHistorialById(int id) async {
    try {
      emit(const HistorialEstadoLoading('Cargando registro de historial...'));

      final historial = await _historialEstadoRepository.getById(id);

      emit(HistorialEstadoLoaded(historial));
    } catch (e) {
      emit(HistorialEstadoError(e.toString()));
    }
  }

  /// Crear un nuevo registro de historial
  Future<void> createHistorial(CreateHistorialEstadoTicketDto dto) async {
    try {
      emit(const HistorialEstadoLoading('Registrando cambio de estado...'));

      final historial = await _historialEstadoRepository.create(dto);

      emit(HistorialEstadoCreated(historial));
    } catch (e) {
      emit(HistorialEstadoError(e.toString()));
    }
  }

  /// Obtener estadísticas de cambios de estado de un ticket
  Future<void> getEstadisticasByTicketId(int ticketId) async {
    try {
      emit(const HistorialEstadoLoading('Cargando estadísticas...'));

      final estadisticas = await _historialEstadoRepository.getEstadisticasByTicketId(ticketId);

      emit(EstadisticasLoaded(estadisticas));
    } catch (e) {
      emit(HistorialEstadoError(e.toString()));
    }
  }

  /// Obtener tiempo promedio en cada estado para un ticket
  Future<void> getTiemposPromedioByTicketId(int ticketId) async {
    try {
      emit(const HistorialEstadoLoading('Cargando tiempos promedio...'));

      final tiempos = await _historialEstadoRepository.getTiemposPromedioByTicketId(ticketId);

      emit(TiemposPromedioLoaded(tiempos));
    } catch (e) {
      emit(HistorialEstadoError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(HistorialEstadoInitial());
  }
}
