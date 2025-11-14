import 'package:equatable/equatable.dart';
import '../../data/models/adjunto/adjunto_ticket_model.dart';

abstract class AdjuntoState extends Equatable {
  const AdjuntoState();

  @override
  List<Object?> get props => [];
}

class AdjuntoInitial extends AdjuntoState {}

class AdjuntoLoading extends AdjuntoState {
  final String? message;

  const AdjuntoLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

class AdjuntosLoaded extends AdjuntoState {
  final List<AdjuntoTicketModel> adjuntos;

  const AdjuntosLoaded(this.adjuntos);

  @override
  List<Object?> get props => [adjuntos];
}

class AdjuntoUploading extends AdjuntoState {
  final double progress;

  const AdjuntoUploading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class AdjuntoUploaded extends AdjuntoState {
  final AdjuntoTicketModel adjunto;

  const AdjuntoUploaded(this.adjunto);

  @override
  List<Object?> get props => [adjunto];
}

class AdjuntoDownloading extends AdjuntoState {
  final int adjuntoId;

  const AdjuntoDownloading(this.adjuntoId);

  @override
  List<Object?> get props => [adjuntoId];
}

class AdjuntoDownloaded extends AdjuntoState {
  final List<int> bytes;
  final String nombreArchivo;

  const AdjuntoDownloaded(this.bytes, this.nombreArchivo);

  @override
  List<Object?> get props => [bytes, nombreArchivo];
}

class AdjuntoDeleted extends AdjuntoState {}

class AdjuntoError extends AdjuntoState {
  final String message;

  const AdjuntoError(this.message);

  @override
  List<Object?> get props => [message];
}
