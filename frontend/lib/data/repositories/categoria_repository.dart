import '../../core/errors/exceptions.dart';
import '../models/categoria/categoria_ticket_model.dart';
import '../services/categoria_service.dart';

class CategoriaRepository {
  final CategoriaService _categoriaService;

  CategoriaRepository(this._categoriaService);

  /// Obtener todas las categorías
  Future<List<CategoriaTicketModel>> getAll() async {
    try {
      return await _categoriaService.getAll();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener categorías activas
  Future<List<CategoriaTicketModel>> getActivos() async {
    try {
      return await _categoriaService.getActivos();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener categoría por ID
  Future<CategoriaTicketModel> getById(int id) async {
    try {
      return await _categoriaService.getById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear nueva categoría
  Future<CategoriaTicketModel> create(CreateCategoriaTicketDto dto) async {
    try {
      // Validaciones del lado del cliente
      if (dto.nombre.trim().isEmpty) {
        throw ServerException('El nombre es requerido');
      }

      if (dto.nombre.length > 100) {
        throw ServerException('El nombre no puede exceder 100 caracteres');
      }

      // Validar formato de color hexadecimal
      final colorRegex = RegExp(r'^#([A-Fa-f0-9]{6})$');
      if (!colorRegex.hasMatch(dto.color)) {
        throw ServerException('El color debe ser un código hexadecimal válido (ej: #FF5733)');
      }

      return await _categoriaService.create(dto);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar categoría
  Future<CategoriaTicketModel> update(int id, UpdateCategoriaTicketDto dto) async {
    try {
      // Validaciones del lado del cliente
      if (dto.nombre.trim().isEmpty) {
        throw ServerException('El nombre es requerido');
      }

      if (dto.nombre.length > 100) {
        throw ServerException('El nombre no puede exceder 100 caracteres');
      }

      // Validar formato de color hexadecimal
      final colorRegex = RegExp(r'^#([A-Fa-f0-9]{6})$');
      if (!colorRegex.hasMatch(dto.color)) {
        throw ServerException('El color debe ser un código hexadecimal válido (ej: #FF5733)');
      }

      return await _categoriaService.update(id, dto);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar categoría
  Future<void> delete(int id) async {
    try {
      await _categoriaService.delete(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Activar/Desactivar categoría
  Future<CategoriaTicketModel> toggleActivo(int id) async {
    try {
      return await _categoriaService.toggleActivo(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Reordenar categorías
  Future<void> reorder(Map<int, int> ordenPorId) async {
    try {
      await _categoriaService.reorder(ordenPorId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
