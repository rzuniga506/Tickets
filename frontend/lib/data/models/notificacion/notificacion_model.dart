import '../../../config/constants.dart';

class NotificacionModel {
  final int id;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final String tipoNombre;
  final PrioridadNotificacion prioridad;
  final String prioridadNombre;
  final bool leida;
  final DateTime? fechaLeida;
  final bool enviada;
  final DateTime? fechaEnvio;
  final String? entidadTipo;
  final int? entidadId;
  final String? accion;
  final String? datosJson;
  final String? urlAccion;
  final String? iconoUrl;
  final bool enviarPush;
  final bool enviarEmail;
  final bool mostrarInApp;
  final int usuarioId;
  final DateTime fechaCreacion;

  NotificacionModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.tipoNombre,
    required this.prioridad,
    required this.prioridadNombre,
    required this.leida,
    this.fechaLeida,
    required this.enviada,
    this.fechaEnvio,
    this.entidadTipo,
    this.entidadId,
    this.accion,
    this.datosJson,
    this.urlAccion,
    this.iconoUrl,
    required this.enviarPush,
    required this.enviarEmail,
    required this.mostrarInApp,
    required this.usuarioId,
    required this.fechaCreacion,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: _parseTipo(json['tipo']),
      tipoNombre: json['tipoNombre'] ?? '',
      prioridad: _parsePrioridad(json['prioridad']),
      prioridadNombre: json['prioridadNombre'] ?? '',
      leida: json['leida'] ?? false,
      fechaLeida: json['fechaLeida'] != null
          ? DateTime.parse(json['fechaLeida'])
          : null,
      enviada: json['enviada'] ?? false,
      fechaEnvio: json['fechaEnvio'] != null
          ? DateTime.parse(json['fechaEnvio'])
          : null,
      entidadTipo: json['entidadTipo'],
      entidadId: json['entidadId'],
      accion: json['accion'],
      datosJson: json['datosJson'],
      urlAccion: json['urlAccion'],
      iconoUrl: json['iconoUrl'],
      enviarPush: json['enviarPush'] ?? false,
      enviarEmail: json['enviarEmail'] ?? false,
      mostrarInApp: json['mostrarInApp'] ?? true,
      usuarioId: json['usuarioId'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  static TipoNotificacion _parseTipo(int tipo) {
    return TipoNotificacion.values[tipo];
  }

  static PrioridadNotificacion _parsePrioridad(int prioridad) {
    return PrioridadNotificacion.values[prioridad];
  }

  String get tiempoTranscurrido {
    final diferencia = DateTime.now().difference(fechaCreacion);

    if (diferencia.inMinutes < 1) {
      return 'Justo ahora';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    } else {
      return 'Hace ${diferencia.inDays} d';
    }
  }
}
