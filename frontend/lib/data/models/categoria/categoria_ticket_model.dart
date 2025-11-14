import 'package:equatable/equatable.dart';

/// Modelo para Categoría de Ticket
class CategoriaTicketModel extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final String color;
  final String? icono;
  final int orden;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  const CategoriaTicketModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.color,
    this.icono,
    required this.orden,
    required this.activo,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  /// Crear desde JSON
  factory CategoriaTicketModel.fromJson(Map<String, dynamic> json) {
    return CategoriaTicketModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      color: json['color'] as String,
      icono: json['icono'] as String?,
      orden: json['orden'] as int,
      activo: json['activo'] as bool,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
      'icono': icono,
      'orden': orden,
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
    };
  }

  /// Copiar con modificaciones
  CategoriaTicketModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? color,
    String? icono,
    int? orden,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  }) {
    return CategoriaTicketModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      color: color ?? this.color,
      icono: icono ?? this.icono,
      orden: orden ?? this.orden,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        color,
        icono,
        orden,
        activo,
        fechaCreacion,
        fechaModificacion,
      ];

  @override
  bool get stringify => true;
}

/// DTO para crear categoría
class CreateCategoriaTicketDto {
  final String nombre;
  final String? descripcion;
  final String color;
  final String? icono;
  final int orden;
  final bool activo;

  const CreateCategoriaTicketDto({
    required this.nombre,
    this.descripcion,
    this.color = '#6B7280',
    this.icono,
    this.orden = 0,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
      'icono': icono,
      'orden': orden,
      'activo': activo,
    };
  }
}

/// DTO para actualizar categoría
class UpdateCategoriaTicketDto {
  final String nombre;
  final String? descripcion;
  final String color;
  final String? icono;
  final int orden;
  final bool activo;

  const UpdateCategoriaTicketDto({
    required this.nombre,
    this.descripcion,
    required this.color,
    this.icono,
    required this.orden,
    required this.activo,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
      'icono': icono,
      'orden': orden,
      'activo': activo,
    };
  }
}
