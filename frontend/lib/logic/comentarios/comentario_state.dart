import 'package:equatable/equatable.dart';
import '../../data/models/comentario/comentario_ticket_model.dart';
import '../../core/api/api_response.dart';

/// Estado base de comentarios
abstract class ComentarioState extends Equatable {
  const ComentarioState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ComentarioInitial extends ComentarioState {}

/// Cargando comentarios
class ComentariosLoading extends ComentarioState {}

/// Comentarios cargados exitosamente
class ComentariosLoaded extends ComentarioState {
  final PagedResult<ComentarioTicketModel> comentarios;
  final bool isLoadingMore;

  const ComentariosLoaded(
    this.comentarios, {
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [comentarios, isLoadingMore];

  ComentariosLoaded copyWith({
    PagedResult<ComentarioTicketModel>? comentarios,
    bool? isLoadingMore,
  }) {
    return ComentariosLoaded(
      comentarios ?? this.comentarios,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Comentario individual cargado
class ComentarioLoaded extends ComentarioState {
  final ComentarioTicketModel comentario;

  const ComentarioLoaded(this.comentario);

  @override
  List<Object?> get props => [comentario];
}

/// Procesando acción (crear, actualizar, eliminar)
class ComentarioActionLoading extends ComentarioState {
  final String message;

  const ComentarioActionLoading(this.message);

  @override
  List<Object?> get props => [message];
}

/// Comentario creado exitosamente
class ComentarioCreated extends ComentarioState {
  final ComentarioTicketModel comentario;

  const ComentarioCreated(this.comentario);

  @override
  List<Object?> get props => [comentario];
}

/// Comentario actualizado exitosamente
class ComentarioUpdated extends ComentarioState {
  final ComentarioTicketModel comentario;

  const ComentarioUpdated(this.comentario);

  @override
  List<Object?> get props => [comentario];
}

/// Comentario eliminado exitosamente
class ComentarioDeleted extends ComentarioState {
  final int comentarioId;

  const ComentarioDeleted(this.comentarioId);

  @override
  List<Object?> get props => [comentarioId];
}

/// Error en operación
class ComentarioError extends ComentarioState {
  final String message;

  const ComentarioError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Acción exitosa con mensaje
class ComentarioSuccess extends ComentarioState {
  final String message;
  final ComentarioTicketModel? comentario;

  const ComentarioSuccess(this.message, [this.comentario]);

  @override
  List<Object?> get props => [message, comentario];
}
