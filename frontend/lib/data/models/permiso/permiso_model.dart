import 'package:equatable/equatable.dart';

/// Modelo para Permiso
class PermisoModel extends Equatable {
  final int id;
  final String codigo;
  final String nombre;
  final String modulo;
  final String? descripcion;

  const PermisoModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.modulo,
    this.descripcion,
  });

  factory PermisoModel.fromJson(Map<String, dynamic> json) {
    return PermisoModel(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      modulo: json['modulo'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'modulo': modulo,
      'descripcion': descripcion,
    };
  }

  PermisoModel copyWith({
    int? id,
    String? codigo,
    String? nombre,
    String? modulo,
    String? descripcion,
  }) {
    return PermisoModel(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      modulo: modulo ?? this.modulo,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  @override
  List<Object?> get props => [id, codigo, nombre, modulo, descripcion];
}
