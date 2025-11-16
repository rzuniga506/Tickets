import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/comentario_repository.dart';
import '../../data/models/comentario/comentario_ticket_model.dart';
import '../../core/api/api_response.dart';
import 'comentario_state.dart';

/// Cubit para gestionar comentarios de tickets
class ComentarioCubit extends Cubit<ComentarioState> {
  final ComentarioRepository _comentarioRepository;

  ComentarioCubit(this._comentarioRepository) : super(ComentarioInitial());

  /// Obtener comentarios de un ticket con paginación
  Future<void> getComentariosByTicketId({
    required int ticketId,
    int pageNumber = 1,
    int pageSize = 50,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore && state is ComentariosLoaded) {
        final currentState = state as ComentariosLoaded;
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(ComentariosLoading());
      }

      final result = await _comentarioRepository.getComentariosByTicketId(
        ticketId: ticketId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      if (loadMore && state is ComentariosLoaded) {
        final currentState = state as ComentariosLoaded;
        final updatedItems = [
          ...currentState.comentarios.items,
          ...result.items
        ];
        final updatedResult = PagedResult<ComentarioTicketModel>(
          items: updatedItems,
          totalRecords: result.totalRecords,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        );
        emit(ComentariosLoaded(updatedResult));
      } else {
        emit(ComentariosLoaded(result));
      }
    } catch (e) {
      emit(ComentarioError(e.toString()));
    }
  }

  /// Obtener un comentario por ID
  Future<void> getComentarioById(int id) async {
    try {
      emit(ComentariosLoading());
      final comentario = await _comentarioRepository.getComentarioById(id);
      emit(ComentarioLoaded(comentario));
    } catch (e) {
      emit(ComentarioError(e.toString()));
    }
  }

  /// Crear un nuevo comentario
  Future<void> createComentario({
    required int ticketId,
    required String contenido,
    required List<int> usuariosIdMencionados,
    bool esInterno = false,
  }) async {
    try {
      emit(const ComentarioActionLoading('Creando comentario...'));
      
      final comentario = await _comentarioRepository.createComentario(
        ticketId: ticketId,
        contenido: contenido,
        usuariosIdMencionados: usuariosIdMencionados,
        esInterno: esInterno,
      );
      
      emit(ComentarioCreated(comentario));
      
      // Recargar la lista de comentarios después de crear uno nuevo
      await getComentariosByTicketId(ticketId: ticketId);
    } catch (e) {
      emit(ComentarioError(e.toString()));
    }
  }

  /// Actualizar un comentario existente
  Future<void> updateComentario({
    required int id,
    required int ticketId,
    required String contenido,
  }) async {
    try {
      emit(const ComentarioActionLoading('Actualizando comentario...'));
      
      final comentario = await _comentarioRepository.updateComentario(
        id: id,
        contenido: contenido,
      );
      
      emit(ComentarioUpdated(comentario));
      
      // Recargar la lista después de actualizar
      await getComentariosByTicketId(ticketId: ticketId);
    } catch (e) {
      emit(ComentarioError(e.toString()));
    }
  }

  /// Eliminar un comentario
  Future<void> deleteComentario({
    required int id,
    required int ticketId,
  }) async {
    try {
      emit(const ComentarioActionLoading('Eliminando comentario...'));
      
      await _comentarioRepository.deleteComentario(id);
      
      emit(ComentarioDeleted(id));
      
      // Recargar la lista después de eliminar
      await getComentariosByTicketId(ticketId: ticketId);
    } catch (e) {
      emit(ComentarioError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(ComentarioInitial());
  }

  /// Extraer IDs de usuarios mencionados del contenido
  List<int> extractMentionedUserIds(
    String contenido,
    Map<String, int> usuariosDisponibles,
  ) {
    final mentionedIds = <int>[];
    final mentionPattern = RegExp(r'@(\w+)');
    final matches = mentionPattern.allMatches(contenido);

    for (final match in matches) {
      final username = match.group(1);
      if (username != null && usuariosDisponibles.containsKey(username)) {
        final userId = usuariosDisponibles[username]!;
        if (!mentionedIds.contains(userId)) {
          mentionedIds.add(userId);
        }
      }
    }

    return mentionedIds;
  }

  /// Procesar contenido y resaltar menciones
  String highlightMentions(String contenido) {
    return contenido.replaceAllMapped(
      RegExp(r'@(\w+)'),
      (match) => '**${match.group(0)}**',
    );
  }
}
