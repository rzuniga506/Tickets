import '../../core/errors/exceptions.dart';
import '../models/departamento/departamento_model.dart';
import '../services/departamento_service.dart';

class DepartamentoRepository {
  final DepartamentoService _departamentoService;

  DepartamentoRepository(this._departamentoService);

  /// Obtener todos los departamentos
  Future<List<DepartamentoModel>> getAll() async {
    try {
      return await _departamentoService.getAll();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener departamentos activos
  Future<List<DepartamentoModel>> getActivos() async {
    try {
      return await _departamentoService.getActivos();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener departamento por ID
  Future<DepartamentoModel> getById(int id) async {
    try {
      return await _departamentoService.getById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear nuevo departamento
  Future<DepartamentoModel> create(CreateDepartamentoDto dto) async {
    try {
      // Validaciones del lado del cliente
      if (dto.nombre.trim().isEmpty) {
        throw ServerException('El nombre es requerido');
      }

      if (dto.nombre.length > 100) {
        throw ServerException('El nombre no puede exceder 100 caracteres');
      }

      if (dto.codigo != null && dto.codigo!.length > 20) {
        throw ServerException('El código no puede exceder 20 caracteres');
      }

      return await _departamentoService.create(dto);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar departamento
  Future<DepartamentoModel> update(int id, UpdateDepartamentoDto dto) async {
    try {
      // Validaciones del lado del cliente
      if (dto.nombre.trim().isEmpty) {
        throw ServerException('El nombre es requerido');
      }

      if (dto.nombre.length > 100) {
        throw ServerException('El nombre no puede exceder 100 caracteres');
      }

      if (dto.codigo != null && dto.codigo!.length > 20) {
        throw ServerException('El código no puede exceder 20 caracteres');
      }

      return await _departamentoService.update(id, dto);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar departamento
  Future<void> delete(int id) async {
    try {
      await _departamentoService.delete(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Activar/Desactivar departamento
  Future<DepartamentoModel> toggleActivo(int id) async {
    try {
      return await _departamentoService.toggleActivo(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener estadísticas del departamento
  Future<Map<String, int>> getEstadisticas(int id) async {
    try {
      return await _departamentoService.getEstadisticas(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
