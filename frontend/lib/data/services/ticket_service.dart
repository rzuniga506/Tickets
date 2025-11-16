import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';
import '../models/ticket/ticket_model.dart';

/// Servicio de tickets
class TicketService {
  final ApiClient _apiClient;

  TicketService(this._apiClient);

  /// Obtener todos los tickets con filtros
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
    final response = await _apiClient.get(
      ApiEndpoints.tickets,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (searchTerm != null) 'searchTerm': searchTerm,
        if (estado != null) 'estado': estado,
        if (prioridad != null) 'prioridad': prioridad,
        if (solicitanteId != null) 'solicitanteId': solicitanteId,
        if (tecnicoId != null) 'tecnicoId': tecnicoId,
        if (slaCumplido != null) 'slaCumplido': slaCumplido,
      },
    );

    final apiResponse = ApiResponse<PagedResult<TicketModel>>.fromJson(
      response.data,
      (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        (item) => TicketModel.fromJson(item),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener tickets');
    }

    return apiResponse.data!;
  }

  /// Obtener ticket por ID
  Future<TicketModel> getTicketById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.ticketById(id));

    final apiResponse = ApiResponse<TicketModel>.fromJson(
      response.data,
      (json) => TicketModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener ticket');
    }

    return apiResponse.data!;
  }

  /// Crear ticket
  Future<TicketModel> createTicket({
    required String asunto,
    required String descripcion,
    required int prioridad,
    required int tipoSoporte,
    int? equipoId,
    int? categoriaTicketId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.tickets,
      data: {
        'asunto': asunto,
        'descripcion': descripcion,
        'prioridad': prioridad,
        'tipoSoporte': tipoSoporte,
        if (equipoId != null) 'equipoId': equipoId,
        if (categoriaTicketId != null) 'categoriaTicketId': categoriaTicketId,
      },
    );

    final apiResponse = ApiResponse<TicketModel>.fromJson(
      response.data,
      (json) => TicketModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al crear ticket');
    }

    return apiResponse.data!;
  }

  /// Actualizar ticket
  Future<TicketModel> updateTicket({
    required int id,
    required String asunto,
    required String descripcion,
    required int prioridad,
    required int tipoSoporte,
    int? equipoId,
    int? categoriaTicketId,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.ticketById(id),
      data: {
        'asunto': asunto,
        'descripcion': descripcion,
        'prioridad': prioridad,
        'tipoSoporte': tipoSoporte,
        if (equipoId != null) 'equipoId': equipoId,
        if (categoriaTicketId != null) 'categoriaTicketId': categoriaTicketId,
      },
    );

    final apiResponse = ApiResponse<TicketModel>.fromJson(
      response.data,
      (json) => TicketModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al actualizar ticket');
    }

    return apiResponse.data!;
  }

  /// Asignar técnico
  Future<void> asignarTecnico(int ticketId, int tecnicoId) async {
    await _apiClient.post(
      ApiEndpoints.asignarTicket(ticketId),
      data: {'TecnicoId': tecnicoId},
    );
  }

  /// Iniciar proceso
  Future<void> iniciarProceso(int ticketId) async {
    await _apiClient.post(ApiEndpoints.iniciarProceso(ticketId));
  }

  /// Resolver ticket
  Future<void> resolverTicket({
    required int ticketId,
    required String solucion,
    required int tipoSolucion,
    int? minutosInvertidos,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resolverTicket(ticketId),
      data: {
        'solucion': solucion,
        'tipoSolucion': tipoSolucion,
        if (minutosInvertidos != null) 'minutosInvertidos': minutosInvertidos,
      },
    );
  }

  /// Cerrar ticket
  Future<void> cerrarTicket(int ticketId) async {
    await _apiClient.post(ApiEndpoints.cerrarTicket(ticketId));
  }

  /// Reabrir ticket
  Future<void> reabrirTicket(int ticketId, String motivo) async {
    await _apiClient.post(
      ApiEndpoints.reabrirTicket(ticketId),
      data: motivo,
    );
  }

  /// Evaluar ticket
  Future<void> evaluarTicket({
    required int ticketId,
    required int calificacion,
    String? comentario,
  }) async {
    await _apiClient.post(
      ApiEndpoints.evaluarTicket(ticketId),
      data: {
        'calificacionServicio': calificacion,
        if (comentario != null) 'comentarioEvaluacion': comentario,
      },
    );
  }

  /// Mis tickets
  Future<List<TicketModel>> getMisTickets() async {
    final response = await _apiClient.get(ApiEndpoints.misTickets);

    final apiResponse = ApiResponse<List<TicketModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => TicketModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener mis tickets');
    }

    return apiResponse.data!;
  }

  /// Tickets asignados
  Future<List<TicketModel>> getTicketsAsignados() async {
    final response = await _apiClient.get(ApiEndpoints.ticketsAsignados);

    final apiResponse = ApiResponse<List<TicketModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => TicketModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener tickets asignados');
    }

    return apiResponse.data!;
  }

  /// Tickets pendientes de asignación
  Future<List<TicketModel>> getTicketsPendientes() async {
    final response = await _apiClient.get(ApiEndpoints.ticketsPendientes);

    final apiResponse = ApiResponse<List<TicketModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => TicketModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener tickets pendientes');
    }

    return apiResponse.data!;
  }

  /// Eliminar ticket
  Future<void> deleteTicket(int id) async {
    await _apiClient.delete(ApiEndpoints.ticketById(id));
  }
}
