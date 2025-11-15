import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/ticket_repository.dart';
import '../../data/models/ticket/ticket_model.dart';
import '../../data/models/paged_result.dart';
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
          totalItems: result.totalItems,
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
      final ticket = await _ticketRepository.asignarTecnico(ticketId, tecnicoId);
      emit(TicketActionSuccess('Técnico asignado correctamente', ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Iniciar proceso de resolución
  Future<void> iniciarProceso(int ticketId) async {
    try {
      emit(TicketActionLoading('Iniciando proceso...'));
      final ticket = await _ticketRepository.iniciarProceso(ticketId);
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
      final ticket = await _ticketRepository.cerrarTicket(ticketId);
      emit(TicketActionSuccess('Ticket cerrado correctamente', ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Reabrir ticket
  Future<void> reabrirTicket(int ticketId, String motivo) async {
    try {
      emit(TicketActionLoading('Reabriendo ticket...'));
      final ticket = await _ticketRepository.reabrirTicket(ticketId, motivo);
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
      final ticket = await _ticketRepository.evaluarTicket(
        ticketId,
        calificacion,
        comentario,
      );
      emit(TicketActionSuccess('Ticket evaluado correctamente', ticket));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Obtener mis tickets (tickets creados por el usuario actual)
  Future<void> getMisTickets({
    int pageNumber = 1,
    int pageSize = 10,
    EstadoTicket? estado,
  }) async {
    try {
      emit(TicketLoading());
      final result = await _ticketRepository.getMisTickets(
        pageNumber: pageNumber,
        pageSize: pageSize,
        estado: estado,
      );
      emit(TicketsLoaded(result));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Obtener tickets asignados al técnico actual
  Future<void> getTicketsAsignados({
    int pageNumber = 1,
    int pageSize = 10,
    EstadoTicket? estado,
  }) async {
    try {
      emit(TicketLoading());
      final result = await _ticketRepository.getTicketsAsignados(
        pageNumber: pageNumber,
        pageSize: pageSize,
        estado: estado,
      );
      emit(TicketsLoaded(result));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Obtener tickets pendientes
  Future<void> getTicketsPendientes({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      emit(TicketLoading());
      final result = await _ticketRepository.getTicketsPendientes(
        pageNumber: pageNumber,
        pageSize: pageSize,
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
      emit(const TicketActionSuccess('Ticket eliminado correctamente', null as TicketModel));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(TicketInitial());
  }
}
