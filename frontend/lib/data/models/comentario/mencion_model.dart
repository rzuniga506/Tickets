/// Modelo de mención de usuario en comentario
class MencionModel {
  final int id;
  final int usuarioMencionadoId;
  final String usuarioMencionadoNombre;
  final String usuarioMencionadoEmail;
  final bool leida;
  final DateTime? fechaLeida;

  MencionModel({
    required this.id,
    required this.usuarioMencionadoId,
    required this.usuarioMencionadoNombre,
    required this.usuarioMencionadoEmail,
    required this.leida,
    this.fechaLeida,
  });

  factory MencionModel.fromJson(Map<String, dynamic> json) {
    return MencionModel(
      id: json['id'],
      usuarioMencionadoId: json['usuarioMencionadoId'],
      usuarioMencionadoNombre: json['usuarioMencionadoNombre'] ?? '',
      usuarioMencionadoEmail: json['usuarioMencionadoEmail'] ?? '',
      leida: json['leida'] ?? false,
      fechaLeida: json['fechaLeida'] != null
          ? DateTime.parse(json['fechaLeida'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioMencionadoId': usuarioMencionadoId,
      'usuarioMencionadoNombre': usuarioMencionadoNombre,
      'usuarioMencionadoEmail': usuarioMencionadoEmail,
      'leida': leida,
      if (fechaLeida != null) 'fechaLeida': fechaLeida!.toIso8601String(),
    };
  }
}
