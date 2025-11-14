import 'package:equatable/equatable.dart';

/// Modelo para estadísticas del dashboard
class DashboardStatsModel extends Equatable {
  final int totalTickets;
  final int ticketsAbiertos;
  final int ticketsCerrados;
  final int ticketsPendientes;
  final int ticketsAsignados;
  final int ticketsEnProceso;
  final int ticketsResueltos;
  final int misTickets;
  final int ticketsAsignadosAMi;
  final int totalEquipos;
  final int equiposDisponibles;
  final int equiposAsignados;
  final int equiposEnMantenimiento;
  final int misEquipos;
  final int notificacionesNoLeidas;
  final double promedioCalificacion;
  final int ticketsAltaPrioridad;
  final List<TicketPorCategoria>? ticketsPorCategoria;
  final List<TicketPorEstado>? ticketsPorEstado;
  final List<EquipoPorTipo>? equiposPorTipo;

  const DashboardStatsModel({
    required this.totalTickets,
    required this.ticketsAbiertos,
    required this.ticketsCerrados,
    required this.ticketsPendientes,
    required this.ticketsAsignados,
    required this.ticketsEnProceso,
    required this.ticketsResueltos,
    required this.misTickets,
    required this.ticketsAsignadosAMi,
    required this.totalEquipos,
    required this.equiposDisponibles,
    required this.equiposAsignados,
    required this.equiposEnMantenimiento,
    required this.misEquipos,
    required this.notificacionesNoLeidas,
    required this.promedioCalificacion,
    required this.ticketsAltaPrioridad,
    this.ticketsPorCategoria,
    this.ticketsPorEstado,
    this.equiposPorTipo,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalTickets: json['totalTickets'] ?? 0,
      ticketsAbiertos: json['ticketsAbiertos'] ?? 0,
      ticketsCerrados: json['ticketsCerrados'] ?? 0,
      ticketsPendientes: json['ticketsPendientes'] ?? 0,
      ticketsAsignados: json['ticketsAsignados'] ?? 0,
      ticketsEnProceso: json['ticketsEnProceso'] ?? 0,
      ticketsResueltos: json['ticketsResueltos'] ?? 0,
      misTickets: json['misTickets'] ?? 0,
      ticketsAsignadosAMi: json['ticketsAsignadosAMi'] ?? 0,
      totalEquipos: json['totalEquipos'] ?? 0,
      equiposDisponibles: json['equiposDisponibles'] ?? 0,
      equiposAsignados: json['equiposAsignados'] ?? 0,
      equiposEnMantenimiento: json['equiposEnMantenimiento'] ?? 0,
      misEquipos: json['misEquipos'] ?? 0,
      notificacionesNoLeidas: json['notificacionesNoLeidas'] ?? 0,
      promedioCalificacion:
          (json['promedioCalificacion'] ?? 0.0).toDouble(),
      ticketsAltaPrioridad: json['ticketsAltaPrioridad'] ?? 0,
      ticketsPorCategoria: json['ticketsPorCategoria'] != null
          ? (json['ticketsPorCategoria'] as List)
              .map((e) => TicketPorCategoria.fromJson(e))
              .toList()
          : null,
      ticketsPorEstado: json['ticketsPorEstado'] != null
          ? (json['ticketsPorEstado'] as List)
              .map((e) => TicketPorEstado.fromJson(e))
              .toList()
          : null,
      equiposPorTipo: json['equiposPorTipo'] != null
          ? (json['equiposPorTipo'] as List)
              .map((e) => EquipoPorTipo.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTickets': totalTickets,
      'ticketsAbiertos': ticketsAbiertos,
      'ticketsCerrados': ticketsCerrados,
      'ticketsPendientes': ticketsPendientes,
      'ticketsAsignados': ticketsAsignados,
      'ticketsEnProceso': ticketsEnProceso,
      'ticketsResueltos': ticketsResueltos,
      'misTickets': misTickets,
      'ticketsAsignadosAMi': ticketsAsignadosAMi,
      'totalEquipos': totalEquipos,
      'equiposDisponibles': equiposDisponibles,
      'equiposAsignados': equiposAsignados,
      'equiposEnMantenimiento': equiposEnMantenimiento,
      'misEquipos': misEquipos,
      'notificacionesNoLeidas': notificacionesNoLeidas,
      'promedioCalificacion': promedioCalificacion,
      'ticketsAltaPrioridad': ticketsAltaPrioridad,
      'ticketsPorCategoria':
          ticketsPorCategoria?.map((e) => e.toJson()).toList(),
      'ticketsPorEstado': ticketsPorEstado?.map((e) => e.toJson()).toList(),
      'equiposPorTipo': equiposPorTipo?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        totalTickets,
        ticketsAbiertos,
        ticketsCerrados,
        ticketsPendientes,
        ticketsAsignados,
        ticketsEnProceso,
        ticketsResueltos,
        misTickets,
        ticketsAsignadosAMi,
        totalEquipos,
        equiposDisponibles,
        equiposAsignados,
        equiposEnMantenimiento,
        misEquipos,
        notificacionesNoLeidas,
        promedioCalificacion,
        ticketsAltaPrioridad,
        ticketsPorCategoria,
        ticketsPorEstado,
        equiposPorTipo,
      ];
}

/// Tickets agrupados por categoría
class TicketPorCategoria extends Equatable {
  final String categoria;
  final int cantidad;

  const TicketPorCategoria({
    required this.categoria,
    required this.cantidad,
  });

  factory TicketPorCategoria.fromJson(Map<String, dynamic> json) {
    return TicketPorCategoria(
      categoria: json['categoria'] ?? '',
      cantidad: json['cantidad'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'cantidad': cantidad,
    };
  }

  @override
  List<Object?> get props => [categoria, cantidad];
}

/// Tickets agrupados por estado
class TicketPorEstado extends Equatable {
  final String estado;
  final int cantidad;

  const TicketPorEstado({
    required this.estado,
    required this.cantidad,
  });

  factory TicketPorEstado.fromJson(Map<String, dynamic> json) {
    return TicketPorEstado(
      estado: json['estado'] ?? '',
      cantidad: json['cantidad'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'cantidad': cantidad,
    };
  }

  @override
  List<Object?> get props => [estado, cantidad];
}

/// Equipos agrupados por tipo
class EquipoPorTipo extends Equatable {
  final String tipo;
  final int cantidad;

  const EquipoPorTipo({
    required this.tipo,
    required this.cantidad,
  });

  factory EquipoPorTipo.fromJson(Map<String, dynamic> json) {
    return EquipoPorTipo(
      tipo: json['tipo'] ?? '',
      cantidad: json['cantidad'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'cantidad': cantidad,
    };
  }

  @override
  List<Object?> get props => [tipo, cantidad];
}
