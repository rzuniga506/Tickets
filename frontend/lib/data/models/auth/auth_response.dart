import '../user/user_model.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final UserModel usuario;
  final List<String> roles;
  final List<String> permisos;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.usuario,
    required this.roles,
    required this.permisos,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresAt: DateTime.parse(json['expiresAt']),
      usuario: UserModel.fromJson(json['usuario']),
      roles: List<String>.from(json['roles'] ?? []),
      permisos: List<String>.from(json['permisos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'usuario': usuario.toJson(),
      'roles': roles,
      'permisos': permisos,
    };
  }
}
