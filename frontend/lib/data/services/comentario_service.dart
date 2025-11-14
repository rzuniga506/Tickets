import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/errors/exceptions.dart';
import '../models/comentario/comentario_ticket_model.dart';

class ComentarioService {
  final ApiClient _apiClient;

  ComentarioService(this._apiClient);

  /// Obtener comentarios de un ticket
  Future<PagedResult<ComentarioTicketModel>> getByTicketId({
    required int ticketId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/comentariosticket/ticket/$ticketId',
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          json.decode(response.body),
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return PagedResult<ComentarioTicketModel>.fromJson(
            apiResponse.data!,
            (json) => ComentarioTicketModel.fromJson(json as Map<String, dynamic>),
          );
        } else {
          throw ServerException(apiResponse.error ?? 'Error al obtener comentarios');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Obtener un comentario por ID
  Future<ComentarioTicketModel> getById(int id) async {
    try {
      final response = await _apiClient.get('/comentariosticket/$id');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          json.decode(response.body),
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return ComentarioTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error ?? 'Error al obtener comentario');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Crear un nuevo comentario
  Future<ComentarioTicketModel> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/comentariosticket',
        body: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          json.decode(response.body),
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return ComentarioTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error ?? 'Error al crear comentario');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Actualizar un comentario
  Future<ComentarioTicketModel> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '/comentariosticket/$id',
        body: data,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          json.decode(response.body),
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return ComentarioTicketModel.fromJson(apiResponse.data!);
        } else {
          throw ServerException(apiResponse.error ?? 'Error al actualizar comentario');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Eliminar un comentario
  Future<void> delete(int id) async {
    try {
      final response = await _apiClient.delete('/comentariosticket/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final apiResponse = ApiResponse<dynamic>.fromJson(
          json.decode(response.body),
          (json) => json,
        );
        throw ServerException(apiResponse.error ?? 'Error al eliminar comentario');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
