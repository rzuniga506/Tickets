class UserModel {
  final int id;
  final String nombre;
  final String apellido;
  final String nombreCompleto;
  final String email;
  final String? telefono;
  final bool activo;
  final int? departamentoId;
  final String? departamentoNombre;
  final List<String> roles;
  final DateTime? ultimoAcceso;
  final DateTime fechaCreacion;

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    required this.activo,
    this.departamentoId,
    this.departamentoNombre,
    required this.roles,
    this.ultimoAcceso,
    required this.fechaCreacion,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      activo: json['activo'] ?? false,
      departamentoId: json['departamentoId'],
      departamentoNombre: json['departamentoNombre'],
      roles: List<String>.from(json['roles'] ?? []),
      ultimoAcceso: json['ultimoAcceso'] != null
          ? DateTime.parse(json['ultimoAcceso'])
          : null,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'activo': activo,
      'departamentoId': departamentoId,
      'departamentoNombre': departamentoNombre,
      'roles': roles,
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool isAdmin() {
    return roles.any((r) => r.contains('Admin'));
  }

  bool isTechnician() {
    return roles.any((r) => r.contains('Técnico'));
  }
}
