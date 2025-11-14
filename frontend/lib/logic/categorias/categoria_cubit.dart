import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/categoria/categoria_ticket_model.dart';
import '../../data/repositories/categoria_repository.dart';
import 'categoria_state.dart';

class CategoriaCubit extends Cubit<CategoriaState> {
  final CategoriaRepository _categoriaRepository;

  CategoriaCubit(this._categoriaRepository) : super(CategoriaInitial());

  /// Obtener todas las categorías
  Future<void> getCategorias() async {
    try {
      emit(const CategoriaLoading('Cargando categorías...'));

      final categorias = await _categoriaRepository.getAll();

      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(CategoriaError(e.toString()));
    }
  }

  /// Obtener categorías activas
  Future<void> getCategoriasActivas() async {
    try {
      emit(const CategoriaLoading('Cargando categorías activas...'));

      final categorias = await _categoriaRepository.getActivos();

      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(CategoriaError(e.toString()));
    }
  }

  /// Obtener categoría por ID
  Future<void> getCategoriaById(int id) async {
    try {
      emit(const CategoriaLoading('Cargando categoría...'));

      final categoria = await _categoriaRepository.getById(id);

      emit(CategoriaLoaded(categoria));
    } catch (e) {
      emit(CategoriaError(e.toString()));
    }
  }

  /// Crear nueva categoría
  Future<void> createCategoria(CreateCategoriaTicketDto dto) async {
    try {
      emit(const CategoriaLoading('Creando categoría...'));

      final categoria = await _categoriaRepository.create(dto);

      emit(CategoriaCreated(categoria));
    } catch (e) {
      emit(CategoriaError(e.toString()));
    }
  }

  /// Actualizar categoría
  Future<void> updateCategoria(int id, UpdateCategoriaTicketDto dto) async {
    try {
      emit(const CategoriaLoading('Actualizando categoría...'));

      final categoria = await _categoriaRepository.update(id, dto);

      emit(CategoriaUpdated(categoria));
    } catch (e) {
      emit(CategoriaError(e.toString()));
    }
  }

  /// Eliminar categoría
  Future<void> deleteCategoria(int id) async {
    try {
      emit(const CategoriaLoading('Eliminando categoría...'));

      await _categoriaRepository.delete(id);

      emit(CategoriaDeleted());
    } catch (e) {
      emit(CategoriaError(e.toString()));
    }
  }

  /// Activar/Desactivar categoría
  Future<void> toggleActivo(int id) async {
    try {
      emit(const CategoriaLoading('Cambiando estado de categoría...'));

      final categoria = await _categoriaRepository.toggleActivo(id);

      emit(CategoriaUpdated(categoria));
    } catch (e) {
      emit(CategoriaError(e.toString()));
    }
  }

  /// Reordenar categorías
  Future<void> reorderCategorias(Map<int, int> ordenPorId) async {
    try {
      emit(const CategoriaLoading('Reordenando categorías...'));

      await _categoriaRepository.reorder(ordenPorId);

      emit(CategoriasReordered());
    } catch (e) {
      emit(CategoriaError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(CategoriaInitial());
  }
}
