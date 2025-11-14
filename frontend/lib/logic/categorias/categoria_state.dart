import 'package:equatable/equatable.dart';
import '../../data/models/categoria/categoria_ticket_model.dart';

abstract class CategoriaState extends Equatable {
  const CategoriaState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CategoriaInitial extends CategoriaState {}

/// Estado de carga
class CategoriaLoading extends CategoriaState {
  final String? message;

  const CategoriaLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Categorías cargadas
class CategoriasLoaded extends CategoriaState {
  final List<CategoriaTicketModel> categorias;

  const CategoriasLoaded(this.categorias);

  @override
  List<Object?> get props => [categorias];
}

/// Categoría individual cargada
class CategoriaLoaded extends CategoriaState {
  final CategoriaTicketModel categoria;

  const CategoriaLoaded(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

/// Categoría creada
class CategoriaCreated extends CategoriaState {
  final CategoriaTicketModel categoria;

  const CategoriaCreated(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

/// Categoría actualizada
class CategoriaUpdated extends CategoriaState {
  final CategoriaTicketModel categoria;

  const CategoriaUpdated(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

/// Categoría eliminada
class CategoriaDeleted extends CategoriaState {}

/// Categoría reordenada
class CategoriasReordered extends CategoriaState {}

/// Estado de error
class CategoriaError extends CategoriaState {
  final String message;

  const CategoriaError(this.message);

  @override
  List<Object?> get props => [message];
}
