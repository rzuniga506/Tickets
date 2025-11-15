import 'package:equatable/equatable.dart';

/// Modelo para Departamento
class DepartamentoModel extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? codigo;
  final bool activo;
  final int cantidadUsuarios;
  final int cantidadEquipos;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  const DepartamentoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.codigo,
    required this.activo,
    required this.cantidadUsuarios,
    required this.cantidadEquipos,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  /// Crear desde JSON
  factory DepartamentoModel.fromJson(Map<String, dynamic> json) {
    return DepartamentoModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      codigo: json['codigo'] as String?,
      activo: json['activo'] as bool,
      cantidadUsuarios: json['cantidadUsuarios'] as int,
      cantidadEquipos: json['cantidadEquipos'] as int,
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
      'codigo': codigo,
      'activo': activo,
      'cantidadUsuarios': cantidadUsuarios,
      'cantidadEquipos': cantidadEquipos,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
    };
  }

  /// Copiar con modificaciones
  DepartamentoModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? codigo,
    bool? activo,
    int? cantidadUsuarios,
    int? cantidadEquipos,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  }) {
    return DepartamentoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      codigo: codigo ?? this.codigo,
      activo: activo ?? this.activo,
      cantidadUsuarios: cantidadUsuarios ?? this.cantidadUsuarios,
      cantidadEquipos: cantidadEquipos ?? this.cantidadEquipos,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        codigo,
        activo,
        cantidadUsuarios,
        cantidadEquipos,
        fechaCreacion,
        fechaModificacion,
      ];

  @override
  bool get stringify => true;
}

/// DTO para crear departamento
class CreateDepartamentoDto {
  final String nombre;
  final String? descripcion;
  final String? codigo;
  final bool activo;

  const CreateDepartamentoDto({
    required this.nombre,
    this.descripcion,
    this.codigo,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo': codigo,
      'activo': activo,
    };
  }
}

/// DTO para actualizar departamento
class UpdateDepartamentoDto {
  final String nombre;
  final String? descripcion;
  final String? codigo;
  final bool activo;

  const UpdateDepartamentoDto({
    required this.nombre,
    this.descripcion,
    this.codigo,
    required this.activo,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo': codigo,
      'activo': activo,
    };
  }
}
