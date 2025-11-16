import 'dart:convert';

/// Especificaciones técnicas para Teléfonos IP
class EspecificacionesTelefonoIP {
  final String? extension;
  final int? numeroLineas;
  final String? protocoloVoIP; // SIP, H.323, SCCP
  final String? codecsAudio; // G.711, G.729, Opus

  final bool? pantalla;
  final double? pantallaTamanioPulgadas;
  final bool? pantallaColor;
  final bool? pantallaTactil;

  final bool? poe;
  final bool? wifi;
  final bool? bluetooth;
  final bool? manosLibres;
  final bool? headset;

  final int? teclasFuncion;
  final bool? moduloExpansion;
  final bool? puertoUSB;
  final bool? grabacionLlamadas;
  final int? directorioContactos; // Número de contactos

  final String? versionFirmware;
  final String? servidorSIP;

  const EspecificacionesTelefonoIP({
    this.extension,
    this.numeroLineas,
    this.protocoloVoIP,
    this.codecsAudio,
    this.pantalla,
    this.pantallaTamanioPulgadas,
    this.pantallaColor,
    this.pantallaTactil,
    this.poe,
    this.wifi,
    this.bluetooth,
    this.manosLibres,
    this.headset,
    this.teclasFuncion,
    this.moduloExpansion,
    this.puertoUSB,
    this.grabacionLlamadas,
    this.directorioContactos,
    this.versionFirmware,
    this.servidorSIP,
  });

  factory EspecificacionesTelefonoIP.fromJson(Map<String, dynamic> json) {
    return EspecificacionesTelefonoIP(
      extension: json['extension'],
      numeroLineas: json['numeroLineas'],
      protocoloVoIP: json['protocoloVoIP'],
      codecsAudio: json['codecsAudio'],
      pantalla: json['pantalla'],
      pantallaTamanioPulgadas: json['pantallaTamanioPulgadas']?.toDouble(),
      pantallaColor: json['pantallaColor'],
      pantallaTactil: json['pantallaTactil'],
      poe: json['poe'],
      wifi: json['wifi'],
      bluetooth: json['bluetooth'],
      manosLibres: json['manosLibres'],
      headset: json['headset'],
      teclasFuncion: json['teclasFuncion'],
      moduloExpansion: json['moduloExpansion'],
      puertoUSB: json['puertoUSB'],
      grabacionLlamadas: json['grabacionLlamadas'],
      directorioContactos: json['directorioContactos'],
      versionFirmware: json['versionFirmware'],
      servidorSIP: json['servidorSIP'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extension': extension,
      'numeroLineas': numeroLineas,
      'protocoloVoIP': protocoloVoIP,
      'codecsAudio': codecsAudio,
      'pantalla': pantalla,
      'pantallaTamanioPulgadas': pantallaTamanioPulgadas,
      'pantallaColor': pantallaColor,
      'pantallaTactil': pantallaTactil,
      'poe': poe,
      'wifi': wifi,
      'bluetooth': bluetooth,
      'manosLibres': manosLibres,
      'headset': headset,
      'teclasFuncion': teclasFuncion,
      'moduloExpansion': moduloExpansion,
      'puertoUSB': puertoUSB,
      'grabacionLlamadas': grabacionLlamadas,
      'directorioContactos': directorioContactos,
      'versionFirmware': versionFirmware,
      'servidorSIP': servidorSIP,
    };
  }

  static EspecificacionesTelefonoIP? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return EspecificacionesTelefonoIP.fromJson(json.decode(jsonString));
    } catch (e) {
      return null;
    }
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
