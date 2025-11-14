class ComentarioTicketModel {
  final int id;
  final String contenido;
  final bool esInterno;
  final bool esSistema;
  final int ticketId;
  final String numeroTicket;
  final int usuarioId;
  final String usuarioNombre;
  final String usuarioEmail;
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
      'fechaCreacion': fechaCreacion.toIso8601String(),
      if (fechaModificacion != null)
        'fechaModificacion': fechaModificacion!.toIso8601String(),
    };
  }

  bool get puedeEditar => !esSistema;

  bool get esReciente {
    final diferencia = DateTime.now().difference(fechaCreacion);
    return diferencia.inMinutes < 5;
  }

  bool get fueEditado => fechaModificacion != null;
}
