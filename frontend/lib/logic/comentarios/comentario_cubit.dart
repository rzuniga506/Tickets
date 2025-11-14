import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/comentario_repository.dart';
import '../../data/models/comentario/comentario_ticket_model.dart';
import '../../core/api/api_response.dart';
import 'comentario_state.dart';

class ComentarioCubit extends Cubit<ComentarioState> {
  final ComentarioRepository _comentarioRepository;

  ComentarioCubit(this._comentarioRepository) : super(ComentarioInitial());

  /// Obtener comentarios de un ticket
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
        emit(const ComentarioLoading('Cargando comentarios...'));
      }

      final result = await _comentarioRepository.getByTicketId(
        ticketId: ticketId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      if (loadMore && state is ComentariosLoaded) {
        final currentState = state as ComentariosLoaded;
        final updatedItems = [
          ...currentState.comentarios.items,
          ...result.items,
        ];
        final updatedResult = PagedResult<ComentarioTicketModel>(
          items: updatedItems,
          totalItems: result.totalItems,
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

  /// Crear nuevo comentario
  Future<void> createComentario({
    required String contenido,
    required int ticketId,
    bool esInterno = false,
  }) async {
    try {
      emit(const ComentarioLoading('Creando comentario...'));

      final comentario = await _comentarioRepository.create(
        contenido: contenido,
        ticketId: ticketId,
        esInterno: esInterno,
      );

      emit(ComentarioCreated(comentario));
    } catch (e) {
      emit(ComentarioError(e.toString()));
    }
  }

  /// Actualizar comentario
  Future<void> updateComentario({
    required int id,
    required String contenido,
    required bool esInterno,
  }) async {
    try {
      emit(const ComentarioLoading('Actualizando comentario...'));

      final comentario = await _comentarioRepository.update(
        id: id,
        contenido: contenido,
        esInterno: esInterno,
      );

      emit(ComentarioUpdated(comentario));
    } catch (e) {
      emit(ComentarioError(e.toString()));
    }
  }

  /// Eliminar comentario
  Future<void> deleteComentario(int id) async {
    try {
      emit(const ComentarioLoading('Eliminando comentario...'));

      await _comentarioRepository.delete(id);

      emit(ComentarioDeleted());
    } catch (e) {
      emit(ComentarioError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(ComentarioInitial());
  }
}
