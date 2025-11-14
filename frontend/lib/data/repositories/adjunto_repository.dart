import 'dart:io';
import '../../core/errors/exceptions.dart';
import '../services/adjunto_service.dart';
import '../models/adjunto/adjunto_ticket_model.dart';

class AdjuntoRepository {
  final AdjuntoService _adjuntoService;

  AdjuntoRepository(this._adjuntoService);

  /// Obtener adjuntos de un ticket
  Future<List<AdjuntoTicketModel>> getByTicketId(int ticketId) async {
    try {
      return await _adjuntoService.getByTicketId(ticketId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener adjunto por ID
  Future<AdjuntoTicketModel> getById(int id) async {
    try {
      return await _adjuntoService.getById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Subir archivo
  Future<AdjuntoTicketModel> upload(File file, int ticketId) async {
    try {
      // Validar tamaño (max 10MB)
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB

      if (fileSize > maxSize) {
        throw ServerException('El archivo excede el tamaño máximo permitido de 10MB');
      }

      return await _adjuntoService.upload(file, ticketId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Descargar archivo
  Future<List<int>> download(int id) async {
    try {
      return await _adjuntoService.download(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar adjunto
  Future<void> delete(int id) async {
    try {
      await _adjuntoService.delete(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
