import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../services/notificacion_service.dart';
import '../models/notificacion/notificacion_model.dart';

/// Repositorio de notificaciones
class NotificacionRepository {
  final NotificacionService _notificacionService;

  NotificacionRepository(this._notificacionService);

  /// Obtener notificaciones
  Future<PagedResult<NotificacionModel>> getNotificaciones({
    int pageNumber = 1,
    int pageSize = 20,
    bool? leida,
  }) async {
    try {
      return await _notificacionService.getNotificaciones(
        pageNumber: pageNumber,
        pageSize: pageSize,
        leida: leida,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Marcar notificación como leída
  Future<void> marcarLeida(int id) async {
    try {
      await _notificacionService.marcarLeida(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Marcar todas como leídas
  Future<void> marcarTodasLeidas() async {
    try {
      await _notificacionService.marcarTodasLeidas();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener conteo de no leídas
  Future<int> getConteoNoLeidas() async {
    try {
      return await _notificacionService.getConteoNoLeidas();
    } catch (e) {
      return 0;
    }
  }

  /// Eliminar notificación
  Future<void> deleteNotificacion(int id) async {
    try {
      await _notificacionService.deleteNotificacion(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
