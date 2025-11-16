import 'package:equatable/equatable.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/paged_result.dart';

/// Estados para la gestión de tickets
abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TicketInitial extends TicketState {}

/// Cargando tickets
class TicketLoading extends TicketState {}

/// Lista de tickets cargada exitosamente
class TicketsLoaded extends TicketState {
  final PagedResult<TicketModel> tickets;
  final bool isLoadingMore;

  const TicketsLoaded(this.tickets, {this.isLoadingMore = false});

  @override
  List<Object?> get props => [tickets, isLoadingMore];

  TicketsLoaded copyWith({
    PagedResult<TicketModel>? tickets,
    bool? isLoadingMore,
  }) {
    return TicketsLoaded(
      tickets ?? this.tickets,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Detalle de ticket cargado
class TicketDetailLoaded extends TicketState {
  final TicketModel ticket;

  const TicketDetailLoaded(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

/// Ticket creado exitosamente
class TicketCreated extends TicketState {
  final TicketModel ticket;

  const TicketCreated(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

/// Ticket actualizado exitosamente
class TicketUpdated extends TicketState {
  final TicketModel ticket;

  const TicketUpdated(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

/// Acción de ticket ejecutada exitosamente (asignar, resolver, cerrar, etc.)
class TicketActionSuccess extends TicketState {
  final String message;
  final TicketModel? ticket;

  const TicketActionSuccess(this.message, this.ticket);

  @override
  List<Object?> get props => [message, ticket];
}

/// Error en operación de tickets
class TicketError extends TicketState {
  final String message;

  const TicketError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estados para operaciones en progreso
class TicketActionLoading extends TicketState {
  final String action;

  const TicketActionLoading(this.action);

  @override
  List<Object?> get props => [action];
}
