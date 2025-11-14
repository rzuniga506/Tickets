import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../services/usuario_service.dart';
import '../models/user/user_model.dart';

/// Repositorio de usuarios
class UsuarioRepository {
  final UsuarioService _usuarioService;

  UsuarioRepository(this._usuarioService);

  /// Obtener usuarios con filtros
  Future<PagedResult<UserModel>> getUsuarios({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    bool? activo,
  }) async {
    try {
      return await _usuarioService.getUsuarios(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchTerm: searchTerm,
        activo: activo,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener usuario por ID
  Future<UserModel> getUsuarioById(int id) async {
    try {
      return await _usuarioService.getUsuarioById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener técnicos
  Future<List<UserModel>> getTecnicos() async {
    try {
      return await _usuarioService.getTecnicos();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear usuario
  Future<UserModel> createUsuario(Map<String, dynamic> data) async {
    try {
      return await _usuarioService.createUsuario(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar usuario
  Future<UserModel> updateUsuario(int id, Map<String, dynamic> data) async {
    try {
      return await _usuarioService.updateUsuario(id, data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar usuario
  Future<void> deleteUsuario(int id) async {
    try {
      await _usuarioService.deleteUsuario(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Toggle activo/inactivo
  Future<void> toggleActivo(int id) async {
    try {
      await _usuarioService.toggleActivo(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
