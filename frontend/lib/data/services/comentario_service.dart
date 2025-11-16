import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';
import '../models/comentario/comentario_ticket_model.dart';

/// Servicio de comentarios de tickets
class ComentarioService {
  final ApiClient _apiClient;

  ComentarioService(this._apiClient);

  /// Obtener comentarios de un ticket con paginación
  Future<PagedResult<ComentarioTicketModel>> getComentariosByTicketId({
    required int ticketId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.comentariosTicket}/ticket/$ticketId',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final apiResponse = ApiResponse<PagedResult<ComentarioTicketModel>>.fromJson(
      response.data,
      (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        (item) => ComentarioTicketModel.fromJson(item),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener comentarios');
    }

    return apiResponse.data!;
  }

  /// Obtener un comentario por ID
  Future<ComentarioTicketModel> getComentarioById(int id) async {
    final response = await _apiClient.get('${ApiEndpoints.comentariosTicket}/$id');

    final apiResponse = ApiResponse<ComentarioTicketModel>.fromJson(
      response.data,
      (json) => ComentarioTicketModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener comentario');
    }

    return apiResponse.data!;
  }

  /// Crear un nuevo comentario
  Future<ComentarioTicketModel> createComentario({
    required int ticketId,
    required String contenido,
    required List<int> usuariosIdMencionados,
    bool esInterno = false,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.comentariosTicket,
      data: {
        'ticketId': ticketId,
        'contenido': contenido,
        'esInterno': esInterno,
        'usuariosIdMencionados': usuariosIdMencionados,
      },
    );

    final apiResponse = ApiResponse<ComentarioTicketModel>.fromJson(
      response.data,
      (json) => ComentarioTicketModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al crear comentario');
    }

    return apiResponse.data!;
  }

  /// Actualizar un comentario existente
  Future<ComentarioTicketModel> updateComentario({
    required int id,
    required String contenido,
  }) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.comentariosTicket}/$id',
      data: {
        'contenido': contenido,
      },
    );

    final apiResponse = ApiResponse<ComentarioTicketModel>.fromJson(
      response.data,
      (json) => ComentarioTicketModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al actualizar comentario');
    }

    return apiResponse.data!;
  }

  /// Eliminar un comentario
  Future<void> deleteComentario(int id) async {
    await _apiClient.delete('${ApiEndpoints.comentariosTicket}/$id');
  }
}
