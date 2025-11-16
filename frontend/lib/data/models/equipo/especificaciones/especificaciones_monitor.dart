import 'dart:convert';

/// Especificaciones técnicas para Monitores
class EspecificacionesMonitor {
  final double? tamanioPulgadas;
  final String? resolucion; // 1920x1080, 2560x1440, 3840x2160
  final String? tipoPanel; // IPS, TN, VA, OLED
  final int? frecuenciaHz;
  final int? tiempoRespuestaMs;
  final String? relacionAspecto; // 16:9, 21:9, 16:10
  final bool? curvo;
  final bool? touchscreen;

  // Puertos
  final int? puertoHDMI;
  final int? puertoDisplayPort;
  final bool? puertoVGA;
  final bool? puertoDVI;
  final bool? puertoUSBC;

  // Características
  final bool? bocinas;
  final bool? ajusteAltura;
  final bool? rotacion; // Pivot
  final bool? hdr;
  final bool? gSync;
  final bool? freeSync;
  final int? consumoWatts;

  const EspecificacionesMonitor({
    this.tamanioPulgadas,
    this.resolucion,
    this.tipoPanel,
    this.frecuenciaHz,
    this.tiempoRespuestaMs,
    this.relacionAspecto,
    this.curvo,
    this.touchscreen,
    this.puertoHDMI,
    this.puertoDisplayPort,
    this.puertoVGA,
    this.puertoDVI,
    this.puertoUSBC,
    this.bocinas,
    this.ajusteAltura,
    this.rotacion,
    this.hdr,
    this.gSync,
    this.freeSync,
    this.consumoWatts,
  });

  factory EspecificacionesMonitor.fromJson(Map<String, dynamic> json) {
    return EspecificacionesMonitor(
      tamanioPulgadas: json['tamanioPulgadas']?.toDouble(),
      resolucion: json['resolucion'],
      tipoPanel: json['tipoPanel'],
      frecuenciaHz: json['frecuenciaHz'],
      tiempoRespuestaMs: json['tiempoRespuestaMs'],
      relacionAspecto: json['relacionAspecto'],
      curvo: json['curvo'],
      touchscreen: json['touchscreen'],
      puertoHDMI: json['puertoHDMI'],
      puertoDisplayPort: json['puertoDisplayPort'],
      puertoVGA: json['puertoVGA'],
      puertoDVI: json['puertoDVI'],
      puertoUSBC: json['puertoUSBC'],
      bocinas: json['bocinas'],
      ajusteAltura: json['ajusteAltura'],
      rotacion: json['rotacion'],
      hdr: json['hdr'],
      gSync: json['gSync'],
      freeSync: json['freeSync'],
      consumoWatts: json['consumoWatts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tamanioPulgadas': tamanioPulgadas,
      'resolucion': resolucion,
      'tipoPanel': tipoPanel,
      'frecuenciaHz': frecuenciaHz,
      'tiempoRespuestaMs': tiempoRespuestaMs,
      'relacionAspecto': relacionAspecto,
      'curvo': curvo,
      'touchscreen': touchscreen,
      'puertoHDMI': puertoHDMI,
      'puertoDisplayPort': puertoDisplayPort,
      'puertoVGA': puertoVGA,
      'puertoDVI': puertoDVI,
      'puertoUSBC': puertoUSBC,
      'bocinas': bocinas,
      'ajusteAltura': ajusteAltura,
      'rotacion': rotacion,
      'hdr': hdr,
      'gSync': gSync,
      'freeSync': freeSync,
      'consumoWatts': consumoWatts,
    };
  }

  static EspecificacionesMonitor? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return EspecificacionesMonitor.fromJson(json.decode(jsonString));
    } catch (e) {
      return null;
    }
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
