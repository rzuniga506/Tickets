import '../../core/errors/exceptions.dart';
import '../models/permiso/permiso_model.dart';
import '../services/permiso_service.dart';

class PermisoRepository {
  final PermisoService _permisoService;

  PermisoRepository(this._permisoService);

  /// Obtener todos los permisos
  Future<List<PermisoModel>> getAll() async {
    try {
      return await _permisoService.getAll();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener permisos por módulo
  Future<List<PermisoModel>> getByModulo(String modulo) async {
    try {
      if (modulo.trim().isEmpty) {
        throw ServerException('El módulo es requerido');
      }

      return await _permisoService.getByModulo(modulo);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener permiso por ID
  Future<PermisoModel> getById(int id) async {
    try {
      return await _permisoService.getById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
