import '../../core/errors/exceptions.dart';
import '../models/historial/historial_estado_ticket_model.dart';
import '../services/historial_estado_service.dart';

class HistorialEstadoRepository {
  final HistorialEstadoService _historialEstadoService;

  HistorialEstadoRepository(this._historialEstadoService);

  /// Obtener historial de un ticket específico
  Future<List<HistorialEstadoTicketModel>> getByTicketId(int ticketId) async {
    try {
      return await _historialEstadoService.getByTicketId(ticketId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener un registro de historial por ID
  Future<HistorialEstadoTicketModel> getById(int id) async {
    try {
      return await _historialEstadoService.getById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear un nuevo registro de historial
  Future<HistorialEstadoTicketModel> create(CreateHistorialEstadoTicketDto dto) async {
    try {
      // Validaciones del lado del cliente
      if (dto.estadoAnterior == dto.estadoNuevo) {
        throw ServerException('El estado anterior y el nuevo no pueden ser iguales');
      }

      if (dto.comentario != null && dto.comentario!.length > 1000) {
        throw ServerException('El comentario no puede exceder 1000 caracteres');
      }

      return await _historialEstadoService.create(dto);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener estadísticas de cambios de estado de un ticket
  Future<Map<String, int>> getEstadisticasByTicketId(int ticketId) async {
    try {
      return await _historialEstadoService.getEstadisticasByTicketId(ticketId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener tiempo promedio en cada estado para un ticket
  Future<Map<String, double>> getTiemposPromedioByTicketId(int ticketId) async {
    try {
      return await _historialEstadoService.getTiemposPromedioByTicketId(ticketId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
