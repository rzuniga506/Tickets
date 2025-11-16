import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/adjunto/adjunto_ticket_model.dart';

class AdjuntoService {
  final ApiClient _apiClient;

  AdjuntoService(this._apiClient);

  /// Obtener adjuntos de un ticket
  Future<List<AdjuntoTicketModel>> getByTicketId(int ticketId) async {
    try {
      final response = await _apiClient.get('/adjuntosticket/ticket/$ticketId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => AdjuntoTicketModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener adjuntos');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener un adjunto por ID
  Future<AdjuntoTicketModel> getById(int id) async {
    try {
      final response = await _apiClient.get('/adjuntosticket/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return AdjuntoTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al obtener adjunto');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Subir un archivo
  Future<AdjuntoTicketModel> upload(File file, int ticketId) async {
    try {
      final token = await _apiClient.storage.getAccessToken();
      if (token == null) {
        throw ServerException('No hay token de autenticación');
      }

      final uri = Uri.parse('${_apiClient.baseUrl}/adjuntosticket/upload');
      final request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Archivo
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      // Datos
      request.fields['ticketId'] = ticketId.toString();

      // Enviar
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          json.decode(response.body),
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return AdjuntoTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al subir archivo');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          json.decode(response.body),
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al subir archivo: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Subir múltiples archivos
  Future<List<AdjuntoTicketModel>> uploadMultiple(List<File> files, int ticketId) async {
    try {
      final token = await _apiClient.storage.getAccessToken();
      if (token == null) {
        throw ServerException('No hay token de autenticación');
      }

      final uri = Uri.parse('${_apiClient.baseUrl}/adjuntosticket/upload-multiple');
      final request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Archivos
      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(
          'files',
          file.path,
        ));
      }

      // Datos
      request.fields['ticketId'] = ticketId.toString();

      // Enviar
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          json.decode(response.body),
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => AdjuntoTicketModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(apiResponse.error?.toString() ?? 'Error al subir archivos');
        }
      } else {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          json.decode(response.body),
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al subir archivos: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Descargar un archivo
  Future<List<int>> download(int id) async {
    try {
      final token = await _apiClient.storage.getAccessToken();
      if (token == null) {
        throw ServerException('No hay token de autenticación');
      }

      final uri = Uri.parse('${_apiClient.baseUrl}/adjuntosticket/download/$id');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw ServerException('Error al descargar archivo: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar un adjunto
  Future<void> delete(int id) async {
    try {
      final response = await _apiClient.delete('/adjuntosticket/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data,
          (json) => json,
        );
        throw ServerException(apiResponse.error?.toString() ?? 'Error al eliminar adjunto');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
