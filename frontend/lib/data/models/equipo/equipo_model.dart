import '../../../config/constants.dart';

class EquipoModel {
  final int id;
  final String codigoInterno;
  final String? numeroSerie;
  final String nombre;
  final String? descripcion;
  final String? codigoQR;
  final String? modelo;
  final String? especificacionesJson;
  final EstadoEquipo estado;
  final String estadoNombre;
  final CondicionEquipo condicion;
  final String condicionNombre;
  final double? costoAdquisicion;
  final DateTime? fechaAdquisicion;
  final int vidaUtilMeses;
  final double? valorResidual;
  final DateTime? fechaInicioGarantia;
  final DateTime? fechaFinGarantia;
  final bool enGarantia;
  final DateTime? fechaAsignacion;
  final String? observaciones;
  final int? usuarioAsignadoId;
  final String? usuarioAsignadoNombre;
  final int? departamentoAsignadoId;
  final String? departamentoAsignadoNombre;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  EquipoModel({
    required this.id,
    required this.codigoInterno,
    this.numeroSerie,
    required this.nombre,
    this.descripcion,
    this.codigoQR,
    this.modelo,
    this.especificacionesJson,
    required this.estado,
    required this.estadoNombre,
    required this.condicion,
    required this.condicionNombre,
    this.costoAdquisicion,
    this.fechaAdquisicion,
    required this.vidaUtilMeses,
    this.valorResidual,
    this.fechaInicioGarantia,
    this.fechaFinGarantia,
    required this.enGarantia,
    this.fechaAsignacion,
    this.observaciones,
    this.usuarioAsignadoId,
    this.usuarioAsignadoNombre,
    this.departamentoAsignadoId,
    this.departamentoAsignadoNombre,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  factory EquipoModel.fromJson(Map<String, dynamic> json) {
    return EquipoModel(
      id: json['id'],
      codigoInterno: json['codigoInterno'] ?? '',
      numeroSerie: json['numeroSerie'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      codigoQR: json['codigoQR'],
      modelo: json['modelo'],
      especificacionesJson: json['especificacionesJson'],
      estado: _parseEstado(json['estado']),
      estadoNombre: json['estadoNombre'] ?? '',
      condicion: _parseCondicion(json['condicion']),
      condicionNombre: json['condicionNombre'] ?? '',
      costoAdquisicion: json['costoAdquisicion']?.toDouble(),
      fechaAdquisicion: json['fechaAdquisicion'] != null
          ? DateTime.parse(json['fechaAdquisicion'])
          : null,
      vidaUtilMeses: json['vidaUtilMeses'] ?? 36,
      valorResidual: json['valorResidual']?.toDouble(),
      fechaInicioGarantia: json['fechaInicioGarantia'] != null
          ? DateTime.parse(json['fechaInicioGarantia'])
          : null,
      fechaFinGarantia: json['fechaFinGarantia'] != null
          ? DateTime.parse(json['fechaFinGarantia'])
          : null,
      enGarantia: json['enGarantia'] ?? false,
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.parse(json['fechaAsignacion'])
          : null,
      observaciones: json['observaciones'],
      usuarioAsignadoId: json['usuarioAsignadoId'],
      usuarioAsignadoNombre: json['usuarioAsignadoNombre'],
      departamentoAsignadoId: json['departamentoAsignadoId'],
      departamentoAsignadoNombre: json['departamentoAsignadoNombre'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'])
          : null,
    );
  }

  static EstadoEquipo _parseEstado(int estado) {
    return EstadoEquipoExtension.fromJson(estado);
  }

  static CondicionEquipo _parseCondicion(int condicion) {
    return CondicionEquipoExtension.fromJson(condicion);
  }

  bool get estaAsignado => usuarioAsignadoId != null;

  bool get garantiaProximaVencer {
    if (fechaFinGarantia == null) return false;
    final diasRestantes = fechaFinGarantia!.difference(DateTime.now()).inDays;
    return diasRestantes <= 30 && diasRestantes > 0;
  }
}
