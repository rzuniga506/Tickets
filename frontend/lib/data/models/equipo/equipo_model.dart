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
  final TipoEquipo tipo;
  final String tipoNombre;
  final EstadoEquipo estado;
  final String estadoNombre;

  // Campos comunes - Información del fabricante
  final String? marca;
  final String? proveedor;
  final String? sku;
  final String? numeroOrdenCompra;
  final String? ubicacionFisica;

  // Hardware - Computadoras/Laptops
  final String? procesador;
  final int? ramGB;
  final int? discoDuroCapacidadGB;
  final String? tipoAlmacenamiento;

  // Red - Computadoras/Dispositivos
  final String? macAddress;
  final String? direccionIP;
  final String? hostname;

  // Sistema Operativo - Computadoras/Laptops
  final String? sistemaOperativo;
  final String? versionSO;
  final String? licenciaSO;

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
    required this.tipo,
    required this.tipoNombre,
    required this.estado,
    required this.estadoNombre,
    // Campos comunes
    this.marca,
    this.proveedor,
    this.sku,
    this.numeroOrdenCompra,
    this.ubicacionFisica,
    // Hardware
    this.procesador,
    this.ramGB,
    this.discoDuroCapacidadGB,
    this.tipoAlmacenamiento,
    // Red
    this.macAddress,
    this.direccionIP,
    this.hostname,
    // Sistema Operativo
    this.sistemaOperativo,
    this.versionSO,
    this.licenciaSO,
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
      tipo: _parseTipo(json['tipo']),
      tipoNombre: json['tipoNombre'] ?? '',
      estado: _parseEstado(json['estado']),
      estadoNombre: json['estadoNombre'] ?? '',
      // Campos comunes
      marca: json['marca'],
      proveedor: json['proveedor'],
      sku: json['sku'],
      numeroOrdenCompra: json['numeroOrdenCompra'],
      ubicacionFisica: json['ubicacionFisica'],
      // Hardware
      procesador: json['procesador'],
      ramGB: json['ramGB'],
      discoDuroCapacidadGB: json['discoDuroCapacidadGB'],
      tipoAlmacenamiento: json['tipoAlmacenamiento'],
      // Red
      macAddress: json['macAddress'],
      direccionIP: json['direccionIP'],
      hostname: json['hostname'],
      // Sistema Operativo
      sistemaOperativo: json['sistemaOperativo'],
      versionSO: json['versionSO'],
      licenciaSO: json['licenciaSO'],
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

  static TipoEquipo _parseTipo(int tipo) {
    return TipoEquipoExtension.fromJson(tipo);
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

  /// Indica si el equipo requiere información de red (computadora, laptop, switch, router, etc.)
  bool get requiereInfoRed {
    return tipo == TipoEquipo.computadora ||
        tipo == TipoEquipo.laptop ||
        tipo == TipoEquipo.servidor ||
        tipo == TipoEquipo.impresora ||
        tipo == TipoEquipo.router ||
        tipo == TipoEquipo.switch_ ||
        tipo == TipoEquipo.firewall ||
        tipo == TipoEquipo.telefono;
  }

  /// Indica si el equipo es un dispositivo de cómputo
  bool get esDispositivoComputo {
    return tipo == TipoEquipo.computadora ||
        tipo == TipoEquipo.laptop ||
        tipo == TipoEquipo.servidor;
  }

  /// Indica si el equipo es un dispositivo de red
  bool get esDispositivoRed {
    return tipo == TipoEquipo.router ||
        tipo == TipoEquipo.switch_ ||
        tipo == TipoEquipo.firewall;
  }

  /// Resumen de especificaciones principales para mostrar en tarjetas
  String get resumenEspecificaciones {
    final specs = <String>[];

    if (marca != null) specs.add(marca!);
    if (modelo != null) specs.add(modelo!);

    if (esDispositivoComputo) {
      if (procesador != null) specs.add(procesador!);
      if (ramGB != null) specs.add('$ramGB GB RAM');
      if (discoDuroCapacidadGB != null && tipoAlmacenamiento != null) {
        specs.add('$discoDuroCapacidadGB GB $tipoAlmacenamiento');
      } else if (discoDuroCapacidadGB != null) {
        specs.add('$discoDuroCapacidadGB GB');
      }
    }

    return specs.isEmpty ? 'Sin especificaciones' : specs.join(' • ');
  }
}
