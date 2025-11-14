import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../services/ticket_service.dart';
import '../models/ticket/ticket_model.dart';

/// Repositorio de tickets
class TicketRepository {
  final TicketService _ticketService;

  TicketRepository(this._ticketService);

  /// Obtener tickets con filtros
  Future<PagedResult<TicketModel>> getTickets({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    int? estado,
    int? prioridad,
    int? solicitanteId,
    int? tecnicoId,
    bool? slaCumplido,
  }) async {
    try {
      return await _ticketService.getTickets(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchTerm: searchTerm,
        estado: estado,
        prioridad: prioridad,
        solicitanteId: solicitanteId,
        tecnicoId: tecnicoId,
        slaCumplido: slaCumplido,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener ticket por ID
  Future<TicketModel> getTicketById(int id) async {
    try {
      return await _ticketService.getTicketById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear ticket
  Future<TicketModel> createTicket({
    required String asunto,
    required String descripcion,
    required int prioridad,
    int? equipoId,
  }) async {
    try {
      return await _ticketService.createTicket(
        asunto: asunto,
        descripcion: descripcion,
        prioridad: prioridad,
        equipoId: equipoId,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar ticket
  Future<TicketModel> updateTicket({
    required int id,
    required String asunto,
    required String descripcion,
    required int prioridad,
    int? equipoId,
  }) async {
    try {
      return await _ticketService.updateTicket(
        id: id,
        asunto: asunto,
        descripcion: descripcion,
        prioridad: prioridad,
        equipoId: equipoId,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Asignar técnico
  Future<void> asignarTecnico(int ticketId, int tecnicoId) async {
    try {
      await _ticketService.asignarTecnico(ticketId, tecnicoId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Iniciar proceso
  Future<void> iniciarProceso(int ticketId) async {
    try {
      await _ticketService.iniciarProceso(ticketId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Resolver ticket
  Future<void> resolverTicket({
    required int ticketId,
    required String solucion,
    required int tipoSolucion,
    int? minutosInvertidos,
  }) async {
    try {
      await _ticketService.resolverTicket(
        ticketId: ticketId,
        solucion: solucion,
        tipoSolucion: tipoSolucion,
        minutosInvertidos: minutosInvertidos,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Cerrar ticket
  Future<void> cerrarTicket(int ticketId) async {
    try {
      await _ticketService.cerrarTicket(ticketId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Reabrir ticket
  Future<void> reabrirTicket(int ticketId, String motivo) async {
    try {
      await _ticketService.reabrirTicket(ticketId, motivo);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Evaluar ticket
  Future<void> evaluarTicket({
    required int ticketId,
    required int calificacion,
    String? comentario,
  }) async {
    try {
      await _ticketService.evaluarTicket(
        ticketId: ticketId,
        calificacion: calificacion,
        comentario: comentario,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Mis tickets
  Future<List<TicketModel>> getMisTickets() async {
    try {
      return await _ticketService.getMisTickets();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Tickets asignados
  Future<List<TicketModel>> getTicketsAsignados() async {
    try {
      return await _ticketService.getTicketsAsignados();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Tickets pendientes
  Future<List<TicketModel>> getTicketsPendientes() async {
    try {
      return await _ticketService.getTicketsPendientes();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar ticket
  Future<void> deleteTicket(int id) async {
    try {
      await _ticketService.deleteTicket(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
