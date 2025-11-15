import 'package:equatable/equatable.dart';

/// Modelo para Asignación de Ticket
class AsignacionTicketModel extends Equatable {
  final int id;
  final int ticketId;
  final String numeroTicket;
  final int? tecnicoAnteriorId;
  final String? tecnicoAnteriorNombre;
  final int tecnicoNuevoId;
  final String tecnicoNuevoNombre;
  final String? motivo;
  final bool esAsignacionAutomatica;
  final int? minutosConTecnicoAnterior;
  final int asignadoPorId;
  final String asignadoPorNombre;
  final DateTime fechaCreacion;
  final bool esPrimeraAsignacion;
  final bool esReasignacion;

  const AsignacionTicketModel({
    required this.id,
    required this.ticketId,
    required this.numeroTicket,
    this.tecnicoAnteriorId,
    this.tecnicoAnteriorNombre,
    required this.tecnicoNuevoId,
    required this.tecnicoNuevoNombre,
    this.motivo,
    required this.esAsignacionAutomatica,
    this.minutosConTecnicoAnterior,
    required this.asignadoPorId,
    required this.asignadoPorNombre,
    required this.fechaCreacion,
    required this.esPrimeraAsignacion,
    required this.esReasignacion,
  });

  /// Crear desde JSON
  factory AsignacionTicketModel.fromJson(Map<String, dynamic> json) {
    return AsignacionTicketModel(
      id: json['id'] as int,
      ticketId: json['ticketId'] as int,
      numeroTicket: json['numeroTicket'] as String,
      tecnicoAnteriorId: json['tecnicoAnteriorId'] as int?,
      tecnicoAnteriorNombre: json['tecnicoAnteriorNombre'] as String?,
      tecnicoNuevoId: json['tecnicoNuevoId'] as int,
      tecnicoNuevoNombre: json['tecnicoNuevoNombre'] as String,
      motivo: json['motivo'] as String?,
      esAsignacionAutomatica: json['esAsignacionAutomatica'] as bool,
      minutosConTecnicoAnterior: json['minutosConTecnicoAnterior'] as int?,
      asignadoPorId: json['asignadoPorId'] as int,
      asignadoPorNombre: json['asignadoPorNombre'] as String,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      esPrimeraAsignacion: json['esPrimeraAsignacion'] as bool,
      esReasignacion: json['esReasignacion'] as bool,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'numeroTicket': numeroTicket,
      'tecnicoAnteriorId': tecnicoAnteriorId,
      'tecnicoAnteriorNombre': tecnicoAnteriorNombre,
      'tecnicoNuevoId': tecnicoNuevoId,
      'tecnicoNuevoNombre': tecnicoNuevoNombre,
      'motivo': motivo,
      'esAsignacionAutomatica': esAsignacionAutomatica,
      'minutosConTecnicoAnterior': minutosConTecnicoAnterior,
      'asignadoPorId': asignadoPorId,
      'asignadoPorNombre': asignadoPorNombre,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'esPrimeraAsignacion': esPrimeraAsignacion,
      'esReasignacion': esReasignacion,
    };
  }

  /// Tiempo formateado con técnico anterior
  String get tiempoConTecnicoAnterior {
    if (minutosConTecnicoAnterior == null) return 'No disponible';

    final minutos = minutosConTecnicoAnterior!;
    if (minutos < 60) {
      return '$minutos min';
    } else if (minutos < 1440) {
      final horas = minutos ~/ 60;
      final mins = minutos % 60;
      return '$horas h ${mins > 0 ? "$mins min" : ""}';
    } else {
      final dias = minutos ~/ 1440;
      final horas = (minutos % 1440) ~/ 60;
      return '$dias d ${horas > 0 ? "$horas h" : ""}';
    }
  }

  /// Tipo de asignación
  String get tipoAsignacion => esAsignacionAutomatica ? 'Automática' : 'Manual';

  @override
  List<Object?> get props => [
        id,
        ticketId,
        numeroTicket,
        tecnicoAnteriorId,
        tecnicoAnteriorNombre,
        tecnicoNuevoId,
        tecnicoNuevoNombre,
        motivo,
        esAsignacionAutomatica,
        minutosConTecnicoAnterior,
        asignadoPorId,
        asignadoPorNombre,
        fechaCreacion,
        esPrimeraAsignacion,
        esReasignacion,
      ];

  @override
  bool get stringify => true;
}

/// DTO para crear asignación
class CreateAsignacionTicketDto {
  final int ticketId;
  final int? tecnicoAnteriorId;
  final int tecnicoNuevoId;
  final String? motivo;
  final bool esAsignacionAutomatica;
  final int? minutosConTecnicoAnterior;

  const CreateAsignacionTicketDto({
    required this.ticketId,
    this.tecnicoAnteriorId,
    required this.tecnicoNuevoId,
    this.motivo,
    this.esAsignacionAutomatica = false,
    this.minutosConTecnicoAnterior,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'tecnicoAnteriorId': tecnicoAnteriorId,
      'tecnicoNuevoId': tecnicoNuevoId,
      'motivo': motivo,
      'esAsignacionAutomatica': esAsignacionAutomatica,
      'minutosConTecnicoAnterior': minutosConTecnicoAnterior,
    };
  }
}
