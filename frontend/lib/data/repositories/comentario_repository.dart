import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../services/comentario_service.dart';
import '../models/comentario/comentario_ticket_model.dart';

class ComentarioRepository {
  final ComentarioService _comentarioService;

  ComentarioRepository(this._comentarioService);

  /// Obtener comentarios de un ticket
  Future<PagedResult<ComentarioTicketModel>> getByTicketId({
    required int ticketId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      return await _comentarioService.getByTicketId(
        ticketId: ticketId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener comentario por ID
  Future<ComentarioTicketModel> getById(int id) async {
    try {
      return await _comentarioService.getById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear comentario
  Future<ComentarioTicketModel> create({
    required String contenido,
    required int ticketId,
    bool esInterno = false,
  }) async {
    try {
      final data = {
        'contenido': contenido,
        'ticketId': ticketId,
        'esInterno': esInterno,
      };

      return await _comentarioService.create(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar comentario
  Future<ComentarioTicketModel> update({
    required int id,
    required String contenido,
    required bool esInterno,
  }) async {
    try {
      final data = {
        'contenido': contenido,
        'esInterno': esInterno,
      };

      return await _comentarioService.update(id, data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar comentario
  Future<void> delete(int id) async {
    try {
      await _comentarioService.delete(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
