import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';
import '../models/equipo/equipo_model.dart';

/// Servicio de equipos
class EquipoService {
  final ApiClient _apiClient;

  EquipoService(this._apiClient);

  /// Obtener todos los equipos con filtros
  Future<PagedResult<EquipoModel>> getEquipos({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    int? estado,
    int? condicion,
    int? usuarioAsignadoId,
    int? departamentoId,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.equipos,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (searchTerm != null) 'searchTerm': searchTerm,
        if (estado != null) 'estado': estado,
        if (condicion != null) 'condicion': condicion,
        if (usuarioAsignadoId != null) 'usuarioAsignadoId': usuarioAsignadoId,
        if (departamentoId != null) 'departamentoId': departamentoId,
      },
    );

    final apiResponse = ApiResponse<PagedResult<EquipoModel>>.fromJson(
      response.data,
      (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        (item) => EquipoModel.fromJson(item),
      ),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener equipos');
    }

    return apiResponse.data!;
  }

  /// Obtener equipo por ID
  Future<EquipoModel> getEquipoById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.equipoById(id));

    final apiResponse = ApiResponse<EquipoModel>.fromJson(
      response.data,
      (json) => EquipoModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener equipo');
    }

    return apiResponse.data!;
  }

  /// Obtener equipo por código QR
  Future<EquipoModel> getEquipoByQR(String codigoQR) async {
    final response = await _apiClient.get(ApiEndpoints.equipoByQR(codigoQR));

    final apiResponse = ApiResponse<EquipoModel>.fromJson(
      response.data,
      (json) => EquipoModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Equipo no encontrado');
    }

    return apiResponse.data!;
  }

  /// Crear equipo
  Future<EquipoModel> createEquipo(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiEndpoints.equipos,
      data: data,
    );

    final apiResponse = ApiResponse<EquipoModel>.fromJson(
      response.data,
      (json) => EquipoModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al crear equipo');
    }

    return apiResponse.data!;
  }

  /// Actualizar equipo
  Future<EquipoModel> updateEquipo(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiEndpoints.equipoById(id),
      data: data,
    );

    final apiResponse = ApiResponse<EquipoModel>.fromJson(
      response.data,
      (json) => EquipoModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al actualizar equipo');
    }

    return apiResponse.data!;
  }

  /// Asignar equipo a usuario
  Future<void> asignarEquipo(int equipoId, int usuarioId) async {
    await _apiClient.post(ApiEndpoints.asignarEquipo(equipoId, usuarioId));
  }

  /// Desasignar equipo
  Future<void> desasignarEquipo(int equipoId) async {
    await _apiClient.post(ApiEndpoints.desasignarEquipo(equipoId));
  }

  /// Generar código QR
  Future<String> generarQR(int equipoId) async {
    final response = await _apiClient.post(ApiEndpoints.generarQR(equipoId));

    final apiResponse = ApiResponse<String>.fromJson(
      response.data,
      (json) => json as String,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al generar QR');
    }

    return apiResponse.data!;
  }

  /// Obtener equipos disponibles
  Future<List<EquipoModel>> getEquiposDisponibles() async {
    final response = await _apiClient.get(ApiEndpoints.equiposDisponibles);

    final apiResponse = ApiResponse<List<EquipoModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => EquipoModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener equipos disponibles');
    }

    return apiResponse.data!;
  }

  /// Obtener mis equipos asignados
  Future<List<EquipoModel>> getMisEquipos() async {
    final response = await _apiClient.get(ApiEndpoints.misEquipos);

    final apiResponse = ApiResponse<List<EquipoModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => EquipoModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Error al obtener mis equipos');
    }

    return apiResponse.data!;
  }

  /// Eliminar equipo
  Future<void> deleteEquipo(int id) async {
    await _apiClient.delete(ApiEndpoints.equipoById(id));
  }
}
