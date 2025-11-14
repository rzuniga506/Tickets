import 'package:equatable/equatable.dart';
import '../../data/models/comentario/comentario_ticket_model.dart';
import '../../core/api/api_response.dart';

abstract class ComentarioState extends Equatable {
  const ComentarioState();

  @override
  List<Object?> get props => [];
}

class ComentarioInitial extends ComentarioState {}

class ComentarioLoading extends ComentarioState {
  final String? message;

  const ComentarioLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

class ComentariosLoaded extends ComentarioState {
  final PagedResult<ComentarioTicketModel> comentarios;
  final bool isLoadingMore;

  const ComentariosLoaded(
    this.comentarios, {
    this.isLoadingMore = false,
  });

  ComentariosLoaded copyWith({
    PagedResult<ComentarioTicketModel>? comentarios,
    bool? isLoadingMore,
  }) {
    return ComentariosLoaded(
      comentarios ?? this.comentarios,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [comentarios, isLoadingMore];
}

class ComentarioCreated extends ComentarioState {
  final ComentarioTicketModel comentario;

  const ComentarioCreated(this.comentario);

  @override
  List<Object?> get props => [comentario];
}

class ComentarioUpdated extends ComentarioState {
  final ComentarioTicketModel comentario;

  const ComentarioUpdated(this.comentario);

  @override
  List<Object?> get props => [comentario];
}

class ComentarioDeleted extends ComentarioState {}

class ComentarioError extends ComentarioState {
  final String message;

  const ComentarioError(this.message);

  @override
  List<Object?> get props => [message];
}
