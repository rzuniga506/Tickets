import '../../core/errors/exceptions.dart';
import '../models/rol/rol_model.dart';
import '../services/rol_service.dart';

class RolRepository {
  final RolService _rolService;

  RolRepository(this._rolService);

  /// Obtener todos los roles
  Future<List<RolModel>> getAll() async {
    try {
      return await _rolService.getAll();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener rol por ID
  Future<RolModel> getById(int id) async {
    try {
      return await _rolService.getById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear nuevo rol
  Future<RolModel> create(CreateRolDto dto) async {
    try {
      // Validaciones del lado del cliente
      if (dto.nombre.trim().isEmpty) {
        throw ServerException('El nombre es requerido');
      }

      if (dto.nombre.length > 50) {
        throw ServerException('El nombre no puede exceder 50 caracteres');
      }

      return await _rolService.create(dto);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar rol
  Future<RolModel> update(int id, UpdateRolDto dto) async {
    try {
      // Validaciones del lado del cliente
      if (dto.nombre.trim().isEmpty) {
        throw ServerException('El nombre es requerido');
      }

      if (dto.nombre.length > 50) {
        throw ServerException('El nombre no puede exceder 50 caracteres');
      }

      return await _rolService.update(id, dto);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar rol
  Future<void> delete(int id) async {
    try {
      await _rolService.delete(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Asignar permisos a un rol
  Future<RolModel> asignarPermisos(int id, List<int> permisosIds) async {
    try {
      if (permisosIds.isEmpty) {
        throw ServerException('Debe seleccionar al menos un permiso');
      }

      return await _rolService.asignarPermisos(id, permisosIds);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
