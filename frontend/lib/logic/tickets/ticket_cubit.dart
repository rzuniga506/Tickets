import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/ticket_repository.dart';
import '../../data/models/ticket/ticket_model.dart';
import '../../core/api/api_response.dart';
import '../../config/constants.dart';
import 'ticket_state.dart';

/// Cubit para gestionar tickets
class TicketCubit extends Cubit<TicketState> {
  final TicketRepository _ticketRepository;

  TicketCubit(this._ticketRepository) : super(TicketInitial());

  /// Obtener lista de tickets con filtros y paginación
  Future<void> getTickets({
    int pageNumber = 1,
    int pageSize = 10,
    EstadoTicket? estado,
    PrioridadTicket? prioridad,
    int? usuarioId,
    int? tecnicoId,
    String? searchTerm,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore && state is TicketsLoaded) {
        // Mostrar indicador de carga adicional
        final currentState = state as TicketsLoaded;
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(TicketLoading());
      }

      final result = await _ticketRepository.getTickets(
        pageNumber: pageNumber,
        pageSize: pageSize,
        estado: estado?.toJson(), // Convierte enum a int si no es null
        prioridad: prioridad?.toJson(), // Convierte enum a int (1-4) si no es null
        solicitanteId: usuarioId,
        tecnicoId: tecnicoId,
        searchTerm: searchTerm,
      );

      if (loadMore && state is TicketsLoaded) {
        // Combinar resultados existentes con nuevos
        final currentState = state as TicketsLoaded;
        final updatedItems = [...currentState.tickets.items, ...result.items];
        final updatedResult = PagedResult<TicketModel>(
          items: updatedItems,
          totalRecords: result.totalRecords,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        );
        emit(TicketsLoaded(updatedResult));
      } else {
        emit(TicketsLoaded(result));
      }
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Obtener detalle de un ticket
  Future<void> getTicketById(int id) async {
    try {
      emit(TicketLoading());
      final ticket = await _ticketRepository.getTicketById(id);
      emit(TicketDetailLoaded(ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Crear nuevo ticket
  Future<void> createTicket({
    required String asunto,
    required String descripcion,
    required PrioridadTicket prioridad,
    int? equipoId,
  }) async {
    try {
      emit(TicketActionLoading('Creando ticket...'));
      final ticket = await _ticketRepository.createTicket(
        asunto: asunto,
        descripcion: descripcion,
        prioridad: prioridad.toJson(), // Convierte enum a int (1-4)
        equipoId: equipoId,
      );
      emit(TicketCreated(ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Actualizar ticket
  Future<void> updateTicket({
    required int id,
    required String asunto,
    required String descripcion,
    required PrioridadTicket prioridad,
    int? equipoId,
  }) async {
    try {
      emit(TicketActionLoading('Actualizando ticket...'));
      final ticket = await _ticketRepository.updateTicket(
        id: id,
        asunto: asunto,
        descripcion: descripcion,
        prioridad: prioridad.toJson(), // Convierte enum a int (1-4)
        equipoId: equipoId,
      );
      emit(TicketUpdated(ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Asignar técnico a un ticket
  Future<void> asignarTecnico(int ticketId, int tecnicoId) async {
    try {
      emit(TicketActionLoading('Asignando técnico...'));
      await _ticketRepository.asignarTecnico(ticketId, tecnicoId);
      final ticket = await _ticketRepository.getTicketById(ticketId);
      emit(TicketActionSuccess('Técnico asignado correctamente', ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Iniciar proceso de resolución
  Future<void> iniciarProceso(int ticketId) async {
    try {
      emit(TicketActionLoading('Iniciando proceso...'));
      await _ticketRepository.iniciarProceso(ticketId);
      final ticket = await _ticketRepository.getTicketById(ticketId);
      emit(TicketActionSuccess('Proceso iniciado correctamente', ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Resolver ticket
  Future<void> resolverTicket({
    required int ticketId,
    required String solucion,
    required TipoSolucion tipoSolucion,
    int? minutosInvertidos,
  }) async {
    try {
      emit(TicketActionLoading('Resolviendo ticket...'));
      await _ticketRepository.resolverTicket(
        ticketId: ticketId,
        solucion: solucion,
        tipoSolucion: tipoSolucion.toJson(), // Convierte enum a int (0-3)
        minutosInvertidos: minutosInvertidos,
      );
      // Recargar el ticket para obtener estado actualizado
      await getTicketById(ticketId);
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Cerrar ticket
  Future<void> cerrarTicket(int ticketId) async {
    try {
      emit(TicketActionLoading('Cerrando ticket...'));
      await _ticketRepository.cerrarTicket(ticketId);
      final ticket = await _ticketRepository.getTicketById(ticketId);
      emit(TicketActionSuccess('Ticket cerrado correctamente', ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Reabrir ticket
  Future<void> reabrirTicket(int ticketId, String motivo) async {
    try {
      emit(TicketActionLoading('Reabriendo ticket...'));
      await _ticketRepository.reabrirTicket(ticketId, motivo);
      final ticket = await _ticketRepository.getTicketById(ticketId);
      emit(TicketActionSuccess('Ticket reabierto correctamente', ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Evaluar ticket
  Future<void> evaluarTicket(
    int ticketId,
    int calificacion,
    String? comentario,
  ) async {
    try {
      emit(TicketActionLoading('Evaluando ticket...'));
      await _ticketRepository.evaluarTicket(
        ticketId: ticketId,
        calificacion: calificacion,
        comentario: comentario,
      );
      final ticket = await _ticketRepository.getTicketById(ticketId);
      emit(TicketActionSuccess('Ticket evaluado correctamente', ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Obtener mis tickets (tickets creados por el usuario actual)
  Future<void> getMisTickets() async {
    try {
      emit(TicketLoading());
      final tickets = await _ticketRepository.getMisTickets();
      // Convertir List a PagedResult para mantener consistencia
      final result = PagedResult<TicketModel>(
        items: tickets,
        totalRecords: tickets.length,
        pageNumber: 1,
        pageSize: tickets.length,
      );
      emit(TicketsLoaded(result));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Obtener tickets asignados al técnico actual
  Future<void> getTicketsAsignados() async {
    try {
      emit(TicketLoading());
      final tickets = await _ticketRepository.getTicketsAsignados();
      // Convertir List a PagedResult para mantener consistencia
      final result = PagedResult<TicketModel>(
        items: tickets,
        totalRecords: tickets.length,
        pageNumber: 1,
        pageSize: tickets.length,
      );
      emit(TicketsLoaded(result));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Obtener tickets pendientes
  Future<void> getTicketsPendientes() async {
    try {
      emit(TicketLoading());
      final tickets = await _ticketRepository.getTicketsPendientes();
      // Convertir List a PagedResult para mantener consistencia
      final result = PagedResult<TicketModel>(
        items: tickets,
        totalRecords: tickets.length,
        pageNumber: 1,
        pageSize: tickets.length,
      );
      emit(TicketsLoaded(result));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Eliminar ticket
  Future<void> deleteTicket(int id) async {
    try {
      emit(TicketActionLoading('Eliminando ticket...'));
      await _ticketRepository.deleteTicket(id);
      emit(const TicketActionSuccess('Ticket eliminado correctamente', null));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(TicketInitial());
  }
}
