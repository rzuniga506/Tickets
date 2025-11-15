import 'package:equatable/equatable.dart';
import '../../data/models/notificacion/notificacion_model.dart';
import '../../data/models/paged_result.dart';

/// Estados para la gestión de notificaciones
abstract class NotificacionState extends Equatable {
  const NotificacionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class NotificacionInitial extends NotificacionState {}

/// Cargando notificaciones
class NotificacionLoading extends NotificacionState {}

/// Lista de notificaciones cargada exitosamente
class NotificacionesLoaded extends NotificacionState {
  final PagedResult<NotificacionModel> notificaciones;
  final bool isLoadingMore;
  final int conteoNoLeidas;

  const NotificacionesLoaded(
    this.notificaciones, {
    this.isLoadingMore = false,
    this.conteoNoLeidas = 0,
  });

  @override
  List<Object?> get props => [notificaciones, isLoadingMore, conteoNoLeidas];

  NotificacionesLoaded copyWith({
    PagedResult<NotificacionModel>? notificaciones,
    bool? isLoadingMore,
    int? conteoNoLeidas,
  }) {
    return NotificacionesLoaded(
      notificaciones ?? this.notificaciones,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      conteoNoLeidas: conteoNoLeidas ?? this.conteoNoLeidas,
    );
  }
}

/// Contador de notificaciones no leídas
class ConteoNoLeidasLoaded extends NotificacionState {
  final int conteo;

  const ConteoNoLeidasLoaded(this.conteo);

  @override
  List<Object?> get props => [conteo];
}

/// Notificación marcada como leída
class NotificacionMarcadaLeida extends NotificacionState {
  final NotificacionModel notificacion;

  const NotificacionMarcadaLeida(this.notificacion);

  @override
  List<Object?> get props => [notificacion];
}

/// Todas las notificaciones marcadas como leídas
class TodasNotificacionesMarcadasLeidas extends NotificacionState {
  const TodasNotificacionesMarcadasLeidas();
}

/// Acción de notificación ejecutada exitosamente
class NotificacionActionSuccess extends NotificacionState {
  final String message;

  const NotificacionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error en operación de notificaciones
class NotificacionError extends NotificacionState {
  final String message;

  const NotificacionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estados para operaciones en progreso
class NotificacionActionLoading extends NotificacionState {
  final String action;

  const NotificacionActionLoading(this.action);

  @override
  List<Object?> get props => [action];
}
