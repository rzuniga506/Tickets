import 'mencion_model.dart';

/// Modelo de comentario de ticket
class ComentarioTicketModel {
  final int id;
  final String contenido;
  final bool esInterno;
  final bool esSistema;

  // Relaciones
  final int ticketId;
  final String numeroTicket;
  final int usuarioId;
  final String usuarioNombre;
  final String usuarioEmail;

  // Menciones
  final List<MencionModel> menciones;

  // Auditoría
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  ComentarioTicketModel({
    required this.id,
    required this.contenido,
    required this.esInterno,
    required this.esSistema,
    required this.ticketId,
    required this.numeroTicket,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.usuarioEmail,
    required this.menciones,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  factory ComentarioTicketModel.fromJson(Map<String, dynamic> json) {
    return ComentarioTicketModel(
      id: json['id'],
      contenido: json['contenido'] ?? '',
      esInterno: json['esInterno'] ?? false,
      esSistema: json['esSistema'] ?? false,
      ticketId: json['ticketId'],
      numeroTicket: json['numeroTicket'] ?? '',
      usuarioId: json['usuarioId'],
      usuarioNombre: json['usuarioNombre'] ?? '',
      usuarioEmail: json['usuarioEmail'] ?? '',
      menciones: (json['menciones'] as List<dynamic>?)
              ?.map((m) => MencionModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenido': contenido,
      'esInterno': esInterno,
      'esSistema': esSistema,
      'ticketId': ticketId,
      'numeroTicket': numeroTicket,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'usuarioEmail': usuarioEmail,
      'menciones': menciones.map((m) => m.toJson()).toList(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      if (fechaModificacion != null)
        'fechaModificacion': fechaModificacion!.toIso8601String(),
    };
  }

  /// Verifica si el comentario menciona a un usuario específico
  bool mencionaA(int usuarioId) {
    return menciones.any((m) => m.usuarioMencionadoId == usuarioId);
  }

  /// Obtiene los nombres de usuarios mencionados
  List<String> get nombresMencionados {
    return menciones.map((m) => m.usuarioMencionadoNombre).toList();
  }
}
