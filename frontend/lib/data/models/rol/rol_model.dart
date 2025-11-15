import 'package:equatable/equatable.dart';

/// Modelo para Rol
class RolModel extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool esSistema;
  final List<int> permisosIds;
  final int cantidadUsuarios;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;

  const RolModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.esSistema,
    required this.permisosIds,
    required this.cantidadUsuarios,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  factory RolModel.fromJson(Map<String, dynamic> json) {
    return RolModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      esSistema: json['esSistema'] as bool,
      permisosIds: (json['permisosIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      cantidadUsuarios: json['cantidadUsuarios'] as int? ?? 0,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : null,
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'esSistema': esSistema,
      'permisosIds': permisosIds,
      'cantidadUsuarios': cantidadUsuarios,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
    };
  }

  RolModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    bool? esSistema,
    List<int>? permisosIds,
    int? cantidadUsuarios,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  }) {
    return RolModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      esSistema: esSistema ?? this.esSistema,
      permisosIds: permisosIds ?? this.permisosIds,
      cantidadUsuarios: cantidadUsuarios ?? this.cantidadUsuarios,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        esSistema,
        permisosIds,
        cantidadUsuarios,
        fechaCreacion,
        fechaModificacion,
      ];
}

/// DTO para crear un nuevo rol
class CreateRolDto {
  final String nombre;
  final String? descripcion;
  final List<int> permisosIds;

  const CreateRolDto({
    required this.nombre,
    this.descripcion,
    this.permisosIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'permisosIds': permisosIds,
    };
  }
}

/// DTO para actualizar un rol
class UpdateRolDto {
  final String nombre;
  final String? descripcion;
  final List<int> permisosIds;

  const UpdateRolDto({
    required this.nombre,
    this.descripcion,
    this.permisosIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'permisosIds': permisosIds,
    };
  }
}
