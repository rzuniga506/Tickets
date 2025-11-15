import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notificacion_repository.dart';
import '../../data/models/notificacion/notificacion_model.dart';
import '../../data/models/paged_result.dart';
import 'notificacion_state.dart';

/// Cubit para gestionar notificaciones
class NotificacionCubit extends Cubit<NotificacionState> {
  final NotificacionRepository _notificacionRepository;

  NotificacionCubit(this._notificacionRepository) : super(NotificacionInitial());

  /// Obtener lista de notificaciones con paginación
  Future<void> getNotificaciones({
    int pageNumber = 1,
    int pageSize = 20,
    bool soloNoLeidas = false,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore && state is NotificacionesLoaded) {
        // Mostrar indicador de carga adicional
        final currentState = state as NotificacionesLoaded;
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(NotificacionLoading());
      }

      final result = await _notificacionRepository.getNotificaciones(
        pageNumber: pageNumber,
        pageSize: pageSize,
        soloNoLeidas: soloNoLeidas,
      );

      // Obtener conteo de no leídas
      final conteo = await _notificacionRepository.getConteoNoLeidas();

      if (loadMore && state is NotificacionesLoaded) {
        // Combinar resultados existentes con nuevos
        final currentState = state as NotificacionesLoaded;
        final updatedItems = [
          ...currentState.notificaciones.items,
          ...result.items
        ];
        final updatedResult = PagedResult<NotificacionModel>(
          items: updatedItems,
          totalItems: result.totalItems,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        );
        emit(NotificacionesLoaded(
          updatedResult,
          conteoNoLeidas: conteo,
        ));
      } else {
        emit(NotificacionesLoaded(result, conteoNoLeidas: conteo));
      }
    } catch (e) {
      emit(NotificacionError(e.toString()));
    }
  }

  /// Marcar una notificación como leída
  Future<void> marcarLeida(int notificacionId) async {
    try {
      await _notificacionRepository.marcarLeida(notificacionId);

      // Recargar notificaciones para actualizar el estado
      if (state is NotificacionesLoaded) {
        final currentState = state as NotificacionesLoaded;
        final updatedItems = currentState.notificaciones.items.map((notif) {
          if (notif.id == notificacionId) {
            return NotificacionModel(
              id: notif.id,
              tipo: notif.tipo,
              titulo: notif.titulo,
              mensaje: notif.mensaje,
              leida: true,
              fechaCreacion: notif.fechaCreacion,
              fechaLeida: DateTime.now(),
              usuarioId: notif.usuarioId,
              ticketId: notif.ticketId,
              equipoId: notif.equipoId,
            );
          }
          return notif;
        }).toList();

        final updatedResult = PagedResult<NotificacionModel>(
          items: updatedItems,
          totalItems: currentState.notificaciones.totalItems,
          pageNumber: currentState.notificaciones.pageNumber,
          pageSize: currentState.notificaciones.pageSize,
        );

        final nuevoConteo = updatedItems.where((n) => !n.leida).length;

        emit(NotificacionesLoaded(
          updatedResult,
          conteoNoLeidas: nuevoConteo,
        ));
      }
    } catch (e) {
      emit(NotificacionError(e.toString()));
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> marcarTodasLeidas() async {
    try {
      emit(const NotificacionActionLoading('Marcando todas como leídas...'));
      await _notificacionRepository.marcarTodasLeidas();

      // Recargar notificaciones
      await getNotificaciones(pageNumber: 1);

      emit(const NotificacionActionSuccess('Todas las notificaciones marcadas como leídas'));
    } catch (e) {
      emit(NotificacionError(e.toString()));
    }
  }

  /// Obtener solo el conteo de notificaciones no leídas
  Future<void> getConteoNoLeidas() async {
    try {
      final conteo = await _notificacionRepository.getConteoNoLeidas();
      emit(ConteoNoLeidasLoaded(conteo));
    } catch (e) {
      emit(NotificacionError(e.toString()));
    }
  }

  /// Eliminar notificación
  Future<void> deleteNotificacion(int id) async {
    try {
      emit(const NotificacionActionLoading('Eliminando notificación...'));
      await _notificacionRepository.deleteNotificacion(id);

      // Recargar notificaciones
      await getNotificaciones(pageNumber: 1);

      emit(const NotificacionActionSuccess('Notificación eliminada correctamente'));
    } catch (e) {
      emit(NotificacionError(e.toString()));
    }
  }

  /// Actualizar contador en tiempo real
  Future<void> actualizarContador() async {
    try {
      final conteo = await _notificacionRepository.getConteoNoLeidas();

      if (state is NotificacionesLoaded) {
        final currentState = state as NotificacionesLoaded;
        emit(currentState.copyWith(conteoNoLeidas: conteo));
      } else {
        emit(ConteoNoLeidasLoaded(conteo));
      }
    } catch (e) {
      // Silenciar error en actualización de contador
    }
  }

  /// Resetear estado
  void reset() {
    emit(NotificacionInitial());
  }
}
