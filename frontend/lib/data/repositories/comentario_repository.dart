import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../services/comentario_service.dart';
import '../models/comentario/comentario_ticket_model.dart';

/// Repositorio de comentarios de tickets
class ComentarioRepository {
  final ComentarioService _comentarioService;

  ComentarioRepository(this._comentarioService);

  /// Obtener comentarios de un ticket
  Future<PagedResult<ComentarioTicketModel>> getComentariosByTicketId({
    required int ticketId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      return await _comentarioService.getComentariosByTicketId(
        ticketId: ticketId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener comentario por ID
  Future<ComentarioTicketModel> getComentarioById(int id) async {
    try {
      return await _comentarioService.getComentarioById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear comentario
  Future<ComentarioTicketModel> createComentario({
    required int ticketId,
    required String contenido,
    required List<int> usuariosIdMencionados,
    bool esInterno = false,
  }) async {
    try {
      return await _comentarioService.createComentario(
        ticketId: ticketId,
        contenido: contenido,
        usuariosIdMencionados: usuariosIdMencionados,
        esInterno: esInterno,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar comentario
  Future<ComentarioTicketModel> updateComentario({
    required int id,
    required String contenido,
  }) async {
    try {
      return await _comentarioService.updateComentario(
        id: id,
        contenido: contenido,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar comentario
  Future<void> deleteComentario(int id) async {
    try {
      await _comentarioService.deleteComentario(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
