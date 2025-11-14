import 'package:equatable/equatable.dart';

/// Estados de ticket disponibles (debe coincidir con backend)
enum EstadoTicket {
  nuevo,
  asignado,
  enProceso,
  enEspera,
  resuelto,
  cerrado,
  cancelado,
  reabierto,
}

/// Extension para manejar conversión de EstadoTicket
extension EstadoTicketExtension on EstadoTicket {
  String get descripcion {
    switch (this) {
      case EstadoTicket.nuevo:
        return 'Nuevo';
      case EstadoTicket.asignado:
        return 'Asignado';
      case EstadoTicket.enProceso:
        return 'En Proceso';
      case EstadoTicket.enEspera:
        return 'En Espera';
      case EstadoTicket.resuelto:
        return 'Resuelto';
      case EstadoTicket.cerrado:
        return 'Cerrado';
      case EstadoTicket.cancelado:
        return 'Cancelado';
      case EstadoTicket.reabierto:
        return 'Reabierto';
    }
  }

  int get valor {
    switch (this) {
      case EstadoTicket.nuevo:
        return 0;
      case EstadoTicket.asignado:
        return 1;
      case EstadoTicket.enProceso:
        return 2;
      case EstadoTicket.enEspera:
        return 3;
      case EstadoTicket.resuelto:
        return 4;
      case EstadoTicket.cerrado:
        return 5;
      case EstadoTicket.cancelado:
        return 6;
      case EstadoTicket.reabierto:
        return 7;
    }
  }

  static EstadoTicket fromInt(int valor) {
    switch (valor) {
      case 0:
        return EstadoTicket.nuevo;
      case 1:
        return EstadoTicket.asignado;
      case 2:
        return EstadoTicket.enProceso;
      case 3:
        return EstadoTicket.enEspera;
      case 4:
        return EstadoTicket.resuelto;
      case 5:
        return EstadoTicket.cerrado;
      case 6:
        return EstadoTicket.cancelado;
      case 7:
        return EstadoTicket.reabierto;
      default:
        return EstadoTicket.nuevo;
    }
  }
}

/// Modelo para Historial de Estado de Ticket
class HistorialEstadoTicketModel extends Equatable {
  final int id;
  final int ticketId;
  final String numeroTicket;
  final EstadoTicket estadoAnterior;
  final String estadoAnteriorDescripcion;
  final EstadoTicket estadoNuevo;
  final String estadoNuevoDescripcion;
  final String? comentario;
  final int? minutosEnEstadoAnterior;
  final int usuarioId;
  final String usuarioNombre;
  final DateTime fechaCreacion;

  const HistorialEstadoTicketModel({
    required this.id,
    required this.ticketId,
    required this.numeroTicket,
    required this.estadoAnterior,
    required this.estadoAnteriorDescripcion,
    required this.estadoNuevo,
    required this.estadoNuevoDescripcion,
    this.comentario,
    this.minutosEnEstadoAnterior,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.fechaCreacion,
  });

  /// Crear desde JSON
  factory HistorialEstadoTicketModel.fromJson(Map<String, dynamic> json) {
    return HistorialEstadoTicketModel(
      id: json['id'] as int,
      ticketId: json['ticketId'] as int,
      numeroTicket: json['numeroTicket'] as String,
      estadoAnterior: EstadoTicketExtension.fromInt(json['estadoAnterior'] as int),
      estadoAnteriorDescripcion: json['estadoAnteriorDescripcion'] as String,
      estadoNuevo: EstadoTicketExtension.fromInt(json['estadoNuevo'] as int),
      estadoNuevoDescripcion: json['estadoNuevoDescripcion'] as String,
      comentario: json['comentario'] as String?,
      minutosEnEstadoAnterior: json['minutosEnEstadoAnterior'] as int?,
      usuarioId: json['usuarioId'] as int,
      usuarioNombre: json['usuarioNombre'] as String,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'numeroTicket': numeroTicket,
      'estadoAnterior': estadoAnterior.valor,
      'estadoAnteriorDescripcion': estadoAnteriorDescripcion,
      'estadoNuevo': estadoNuevo.valor,
      'estadoNuevoDescripcion': estadoNuevoDescripcion,
      'comentario': comentario,
      'minutosEnEstadoAnterior': minutosEnEstadoAnterior,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Duración formateada en el estado anterior
  String get tiempoEnEstadoAnterior {
    if (minutosEnEstadoAnterior == null) return 'No disponible';

    final minutos = minutosEnEstadoAnterior!;
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

  @override
  List<Object?> get props => [
        id,
        ticketId,
        numeroTicket,
        estadoAnterior,
        estadoAnteriorDescripcion,
        estadoNuevo,
        estadoNuevoDescripcion,
        comentario,
        minutosEnEstadoAnterior,
        usuarioId,
        usuarioNombre,
        fechaCreacion,
      ];

  @override
  bool get stringify => true;
}

/// DTO para crear historial de estado
class CreateHistorialEstadoTicketDto {
  final int ticketId;
  final EstadoTicket estadoAnterior;
  final EstadoTicket estadoNuevo;
  final String? comentario;
  final int? minutosEnEstadoAnterior;

  const CreateHistorialEstadoTicketDto({
    required this.ticketId,
    required this.estadoAnterior,
    required this.estadoNuevo,
    this.comentario,
    this.minutosEnEstadoAnterior,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'estadoAnterior': estadoAnterior.valor,
      'estadoNuevo': estadoNuevo.valor,
      'comentario': comentario,
      'minutosEnEstadoAnterior': minutosEnEstadoAnterior,
    };
  }
}
