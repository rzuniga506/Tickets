import '../../../config/constants.dart';
import '../categoria/categoria_ticket_model.dart';

class TicketModel {
  final int id;
  final String numeroTicket;
  final String asunto;
  final String descripcion;
  final PrioridadTicket prioridad;
  final String prioridadNombre;
  final EstadoTicket estado;
  final String estadoNombre;
  final int? categoriaId;
  final CategoriaTicketModel? categoria;
  final DateTime fechaApertura;
  final DateTime? fechaAsignacion;
  final DateTime? fechaInicioProceso;
  final DateTime? fechaResolucion;
  final DateTime? fechaCierre;
  final int? minutosInvertidos;
  final DateTime? fechaLimiteSLA;
  final bool slaCumplido;
  final int? minutosRestantesSLA;
  final int? calificacionServicio;
  final String? comentarioEvaluacion;
  final DateTime? fechaEvaluacion;
  final String? solucion;
  final TipoSolucion? tipoSolucion;
  final String? tipoSolucionNombre;
  final bool fueReabierto;
  final int cantidadReaberturas;
  final int solicitanteId;
  final String solicitanteNombre;
  final String solicitanteEmail;
  final int? tecnicoAsignadoId;
  final String? tecnicoAsignadoNombre;
  final int? equipoId;
  final String? equipoNombre;
  final String? equipoCodigoInterno;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  TicketModel({
    required this.id,
    required this.numeroTicket,
    required this.asunto,
    required this.descripcion,
    required this.prioridad,
    required this.prioridadNombre,
    required this.estado,
    required this.estadoNombre,
    this.categoriaId,
    this.categoria,
    required this.fechaApertura,
    this.fechaAsignacion,
    this.fechaInicioProceso,
    this.fechaResolucion,
    this.fechaCierre,
    this.minutosInvertidos,
    this.fechaLimiteSLA,
    required this.slaCumplido,
    this.minutosRestantesSLA,
    this.calificacionServicio,
    this.comentarioEvaluacion,
    this.fechaEvaluacion,
    this.solucion,
    this.tipoSolucion,
    this.tipoSolucionNombre,
    required this.fueReabierto,
    required this.cantidadReaberturas,
    required this.solicitanteId,
    required this.solicitanteNombre,
    required this.solicitanteEmail,
    this.tecnicoAsignadoId,
    this.tecnicoAsignadoNombre,
    this.equipoId,
    this.equipoNombre,
    this.equipoCodigoInterno,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      numeroTicket: json['numeroTicket'] ?? '',
      asunto: json['asunto'] ?? '',
      descripcion: json['descripcion'] ?? '',
      prioridad: _parsePrioridad(json['prioridad']),
      prioridadNombre: json['prioridadNombre'] ?? '',
      estado: _parseEstado(json['estado']),
      estadoNombre: json['estadoNombre'] ?? '',
      categoriaId: json['categoriaTicketId'] ?? json['categoriaId'],
      categoria: json['categoriaTicket'] != null || json['categoria'] != null
          ? CategoriaTicketModel.fromJson(json['categoriaTicket'] ?? json['categoria'])
          : null,
      fechaApertura: DateTime.parse(json['fechaApertura']),
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.parse(json['fechaAsignacion'])
          : null,
      fechaInicioProceso: json['fechaInicioProceso'] != null
          ? DateTime.parse(json['fechaInicioProceso'])
          : null,
      fechaResolucion: json['fechaResolucion'] != null
          ? DateTime.parse(json['fechaResolucion'])
          : null,
      fechaCierre: json['fechaCierre'] != null
          ? DateTime.parse(json['fechaCierre'])
          : null,
      minutosInvertidos: json['minutosInvertidos'],
      fechaLimiteSLA: json['fechaLimiteSLA'] != null
          ? DateTime.parse(json['fechaLimiteSLA'])
          : null,
      slaCumplido: json['slaCumplido'] ?? false,
      minutosRestantesSLA: json['minutosRestantesSLA'],
      calificacionServicio: json['calificacionServicio'],
      comentarioEvaluacion: json['comentarioEvaluacion'],
      fechaEvaluacion: json['fechaEvaluacion'] != null
          ? DateTime.parse(json['fechaEvaluacion'])
          : null,
      solucion: json['solucion'],
      tipoSolucion: json['tipoSolucion'] != null
          ? _parseTipoSolucion(json['tipoSolucion'])
          : null,
      tipoSolucionNombre: json['tipoSolucionNombre'],
      fueReabierto: json['fueReabierto'] ?? false,
      cantidadReaberturas: json['cantidadReaberturas'] ?? 0,
      solicitanteId: json['solicitanteId'],
      solicitanteNombre: json['solicitanteNombre'] ?? '',
      solicitanteEmail: json['solicitanteEmail'] ?? '',
      tecnicoAsignadoId: json['tecnicoAsignadoId'],
      tecnicoAsignadoNombre: json['tecnicoAsignadoNombre'],
      equipoId: json['equipoId'],
      equipoNombre: json['equipoNombre'],
      equipoCodigoInterno: json['equipoCodigoInterno'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'])
          : null,
    );
  }

  static PrioridadTicket _parsePrioridad(int prioridad) {
    // Backend envía valores 1-4, no 0-3
    return PrioridadTicketExtension.fromJson(prioridad);
  }

  static EstadoTicket _parseEstado(int estado) {
    return EstadoTicketExtension.fromJson(estado);
  }

  static TipoSolucion _parseTipoSolucion(int tipo) {
    return TipoSolucionExtension.fromJson(tipo);
  }

  bool get slaProximoVencer {
    if (minutosRestantesSLA == null || minutosRestantesSLA! <= 0) return false;
    return minutosRestantesSLA! <= 60; // Menos de 1 hora
  }

  bool get puedeEvaluar {
    return estado == EstadoTicket.resuelto && calificacionServicio == null;
  }

  bool get estaAsignado => tecnicoAsignadoId != null;
}
