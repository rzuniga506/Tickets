import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';
import '../models/notificacion/notificacion_model.dart';

/// Servicio de notificaciones
class NotificacionService {
  final ApiClient _apiClient;

  NotificacionService(this._apiClient);

  /// Obtener notificaciones del usuario
  Future<PagedResult<NotificacionModel>> getNotificaciones({
    int pageNumber = 1,
    int pageSize = 20,
    bool? leida,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.notificaciones,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (leida != null) 'leida': leida,
      },
    );

    final apiResponse = ApiResponse<PagedResult<NotificacionModel>>.fromJson(
      response.data,
      (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        (item) => NotificacionModel.fromJson(item),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener notificaciones');
    }

    return apiResponse.data!;
  }

  /// Marcar notificación como leída
  Future<void> marcarLeida(int id) async {
    await _apiClient.patch(ApiEndpoints.marcarLeida(id));
  }

  /// Marcar todas como leídas
  Future<void> marcarTodasLeidas() async {
    await _apiClient.patch(ApiEndpoints.marcarTodasLeidas);
  }

  /// Obtener conteo de no leídas
  Future<int> getConteoNoLeidas() async {
    final response = await _apiClient.get(ApiEndpoints.conteoNoLeidas);

    final apiResponse = ApiResponse<int>.fromJson(
      response.data,
      (json) => json as int,
    );

    return apiResponse.data ?? 0;
  }

  /// Eliminar notificación
  Future<void> deleteNotificacion(int id) async {
    await _apiClient.delete(ApiEndpoints.notificacionById(id));
  }
}
