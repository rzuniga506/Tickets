class AdjuntoTicketModel {
  final int id;
  final String nombreArchivo;
  final String nombreArchivoServidor;
  final String rutaArchivo;
  final String tipoMime;
  final int tamanoBytes;
  final String tamanoFormateado;
  final String extension;
  final bool esImagen;
  final bool esPdf;
  final int ticketId;
  final String numeroTicket;
  final int usuarioId;
  final String usuarioNombre;
  final String usuarioEmail;
  final DateTime fechaCreacion;

  AdjuntoTicketModel({
    required this.id,
    required this.nombreArchivo,
    required this.nombreArchivoServidor,
    required this.rutaArchivo,
    required this.tipoMime,
    required this.tamanoBytes,
    required this.tamanoFormateado,
    required this.extension,
    required this.esImagen,
    required this.esPdf,
    required this.ticketId,
    required this.numeroTicket,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.usuarioEmail,
    required this.fechaCreacion,
  });

  factory AdjuntoTicketModel.fromJson(Map<String, dynamic> json) {
    return AdjuntoTicketModel(
      id: json['id'],
      nombreArchivo: json['nombreArchivo'] ?? '',
      nombreArchivoServidor: json['nombreArchivoServidor'] ?? '',
      rutaArchivo: json['rutaArchivo'] ?? '',
      tipoMime: json['tipoMime'] ?? '',
      tamanoBytes: json['tamanoBytes'] ?? 0,
      tamanoFormateado: json['tamanoFormateado'] ?? '',
      extension: json['extension'] ?? '',
      esImagen: json['esImagen'] ?? false,
      esPdf: json['esPdf'] ?? false,
      ticketId: json['ticketId'],
      numeroTicket: json['numeroTicket'] ?? '',
      usuarioId: json['usuarioId'],
      usuarioNombre: json['usuarioNombre'] ?? '',
      usuarioEmail: json['usuarioEmail'] ?? '',
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreArchivo': nombreArchivo,
      'nombreArchivoServidor': nombreArchivoServidor,
      'rutaArchivo': rutaArchivo,
      'tipoMime': tipoMime,
      'tamanoBytes': tamanoBytes,
      'tamanoFormateado': tamanoFormateado,
      'extension': extension,
      'esImagen': esImagen,
      'esPdf': esPdf,
      'ticketId': ticketId,
      'numeroTicket': numeroTicket,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'usuarioEmail': usuarioEmail,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Determinar icono según tipo de archivo
  String get iconoArchivo {
    if (esImagen) return '🖼️';
    if (esPdf) return '📄';
    if (extension.toLowerCase() == '.zip' || extension.toLowerCase() == '.rar') return '📦';
    if (extension.toLowerCase() == '.doc' || extension.toLowerCase() == '.docx') return '📝';
    if (extension.toLowerCase() == '.xls' || extension.toLowerCase() == '.xlsx') return '📊';
    if (extension.toLowerCase() == '.txt') return '📃';
    return '📎';
  }

  /// Verificar si es un tipo previsualizable
  bool get esPrevisualizeable => esImagen || esPdf;
}
