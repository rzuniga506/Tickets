import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/adjunto_repository.dart';
import 'adjunto_state.dart';

class AdjuntoCubit extends Cubit<AdjuntoState> {
  final AdjuntoRepository _adjuntoRepository;

  AdjuntoCubit(this._adjuntoRepository) : super(AdjuntoInitial());

  /// Obtener adjuntos de un ticket
  Future<void> getAdjuntosByTicketId(int ticketId) async {
    try {
      emit(const AdjuntoLoading('Cargando adjuntos...'));

      final adjuntos = await _adjuntoRepository.getByTicketId(ticketId);

      emit(AdjuntosLoaded(adjuntos));
    } catch (e) {
      emit(AdjuntoError(e.toString()));
    }
  }

  /// Subir archivo
  Future<void> uploadAdjunto(File file, int ticketId) async {
    try {
      emit(const AdjuntoUploading(0.0));

      final adjunto = await _adjuntoRepository.upload(file, ticketId);

      emit(const AdjuntoUploading(1.0));
      emit(AdjuntoUploaded(adjunto));
    } catch (e) {
      emit(AdjuntoError(e.toString()));
    }
  }

  /// Descargar archivo
  Future<void> downloadAdjunto(int id, String nombreArchivo) async {
    try {
      emit(AdjuntoDownloading(id));

      final bytes = await _adjuntoRepository.download(id);

      emit(AdjuntoDownloaded(bytes, nombreArchivo));
    } catch (e) {
      emit(AdjuntoError(e.toString()));
    }
  }

  /// Eliminar adjunto
  Future<void> deleteAdjunto(int id) async {
    try {
      emit(const AdjuntoLoading('Eliminando adjunto...'));

      await _adjuntoRepository.delete(id);

      emit(AdjuntoDeleted());
    } catch (e) {
      emit(AdjuntoError(e.toString()));
    }
  }

  /// Resetear estado
  void reset() {
    emit(AdjuntoInitial());
  }
}
