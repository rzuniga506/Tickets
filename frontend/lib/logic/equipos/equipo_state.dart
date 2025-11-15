import 'package:equatable/equatable.dart';
import '../../data/models/equipo/equipo_model.dart';
import '../../data/models/paged_result.dart';

/// Estados para la gestión de equipos/inventario
abstract class EquipoState extends Equatable {
  const EquipoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class EquipoInitial extends EquipoState {}

/// Cargando equipos
class EquipoLoading extends EquipoState {}

/// Lista de equipos cargada exitosamente
class EquiposLoaded extends EquipoState {
  final PagedResult<EquipoModel> equipos;
  final bool isLoadingMore;

  const EquiposLoaded(this.equipos, {this.isLoadingMore = false});

  @override
  List<Object?> get props => [equipos, isLoadingMore];

  EquiposLoaded copyWith({
    PagedResult<EquipoModel>? equipos,
    bool? isLoadingMore,
  }) {
    return EquiposLoaded(
      equipos ?? this.equipos,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Detalle de equipo cargado
class EquipoDetailLoaded extends EquipoState {
  final EquipoModel equipo;

  const EquipoDetailLoaded(this.equipo);

  @override
  List<Object?> get props => [equipo];
}

/// Equipo encontrado por QR
class EquipoFoundByQR extends EquipoState {
  final EquipoModel equipo;

  const EquipoFoundByQR(this.equipo);

  @override
  List<Object?> get props => [equipo];
}

/// Equipo creado exitosamente
class EquipoCreated extends EquipoState {
  final EquipoModel equipo;

  const EquipoCreated(this.equipo);

  @override
  List<Object?> get props => [equipo];
}

/// Equipo actualizado exitosamente
class EquipoUpdated extends EquipoState {
  final EquipoModel equipo;

  const EquipoUpdated(this.equipo);

  @override
  List<Object?> get props => [equipo];
}

/// Código QR generado exitosamente
class QRGenerated extends EquipoState {
  final String qrCode;
  final EquipoModel equipo;

  const QRGenerated(this.qrCode, this.equipo);

  @override
  List<Object?> get props => [qrCode, equipo];
}

/// Acción de equipo ejecutada exitosamente (asignar, desasignar, etc.)
class EquipoActionSuccess extends EquipoState {
  final String message;
  final EquipoModel equipo;

  const EquipoActionSuccess(this.message, this.equipo);

  @override
  List<Object?> get props => [message, equipo];
}

/// Error en operación de equipos
class EquipoError extends EquipoState {
  final String message;

  const EquipoError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estados para operaciones en progreso
class EquipoActionLoading extends EquipoState {
  final String action;

  const EquipoActionLoading(this.action);

  @override
  List<Object?> get props => [action];
}

/// Estado para escaneo de QR en progreso
class QRScanning extends EquipoState {}
