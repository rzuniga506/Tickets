import '../../core/errors/exceptions.dart';
import '../models/asignacion/asignacion_ticket_model.dart';
import '../services/asignacion_service.dart';

class AsignacionRepository {
  final AsignacionService _asignacionService;

  AsignacionRepository(this._asignacionService);

  /// Obtener historial de asignaciones de un ticket específico
  Future<List<AsignacionTicketModel>> getByTicketId(int ticketId) async {
    try {
      return await _asignacionService.getByTicketId(ticketId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener asignación por ID
  Future<AsignacionTicketModel> getById(int id) async {
    try {
      return await _asignacionService.getById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear una nueva asignación
  Future<AsignacionTicketModel> create(CreateAsignacionTicketDto dto) async {
    try {
      // Validaciones del lado del cliente
      if (dto.tecnicoAnteriorId != null && dto.tecnicoAnteriorId == dto.tecnicoNuevoId) {
        throw ServerException('No se puede asignar el ticket al mismo técnico');
      }

      if (dto.motivo != null && dto.motivo!.length > 500) {
        throw ServerException('El motivo no puede exceder 500 caracteres');
      }

      return await _asignacionService.create(dto);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener estadísticas de asignaciones por técnico
  Future<Map<String, int>> getEstadisticasPorTecnico() async {
    try {
      return await _asignacionService.getEstadisticasPorTecnico();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener carga de trabajo actual por técnico
  Future<Map<String, int>> getCargaActual() async {
    try {
      return await _asignacionService.getCargaActual();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener tiempo promedio de asignación por técnico
  Future<Map<String, double>> getTiemposPromedio() async {
    try {
      return await _asignacionService.getTiemposPromedio();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
