import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../services/equipo_service.dart';
import '../models/equipo/equipo_model.dart';

/// Repositorio de equipos
class EquipoRepository {
  final EquipoService _equipoService;

  EquipoRepository(this._equipoService);

  /// Obtener equipos con filtros
  Future<PagedResult<EquipoModel>> getEquipos({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    int? estado,
    int? condicion,
    int? usuarioAsignadoId,
    int? departamentoId,
  }) async {
    try {
      return await _equipoService.getEquipos(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchTerm: searchTerm,
        estado: estado,
        condicion: condicion,
        usuarioAsignadoId: usuarioAsignadoId,
        departamentoId: departamentoId,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener equipo por ID
  Future<EquipoModel> getEquipoById(int id) async {
    try {
      return await _equipoService.getEquipoById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener equipo por código QR
  Future<EquipoModel> getEquipoByQR(String codigoQR) async {
    try {
      return await _equipoService.getEquipoByQR(codigoQR);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear equipo
  Future<EquipoModel> createEquipo(Map<String, dynamic> data) async {
    try {
      return await _equipoService.createEquipo(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar equipo
  Future<EquipoModel> updateEquipo(int id, Map<String, dynamic> data) async {
    try {
      return await _equipoService.updateEquipo(id, data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Asignar equipo a usuario
  Future<void> asignarEquipo(int equipoId, int usuarioId) async {
    try {
      await _equipoService.asignarEquipo(equipoId, usuarioId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Desasignar equipo
  Future<void> desasignarEquipo(int equipoId) async {
    try {
      await _equipoService.desasignarEquipo(equipoId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Generar código QR
  Future<String> generarQR(int equipoId) async {
    try {
      return await _equipoService.generarQR(equipoId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener equipos disponibles
  Future<List<EquipoModel>> getEquiposDisponibles() async {
    try {
      return await _equipoService.getEquiposDisponibles();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener mis equipos asignados
  Future<List<EquipoModel>> getMisEquipos() async {
    try {
      return await _equipoService.getMisEquipos();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar equipo
  Future<void> deleteEquipo(int id) async {
    try {
      await _equipoService.deleteEquipo(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
