import 'dart:convert';

/// Especificaciones técnicas para Router, Switch, Firewall
class EspecificacionesDispositivoRed {
  final int? numeroPuertos;
  final String? velocidadPuertos; // 1Gbps, 10Gbps, 100Mbps
  final int? puertosPoE;
  final int? potenciaPoEWatts;
  final int? puertosSFP;
  final int? puertosSFPPlus;
  final String? capacidadSwitching; // Gbps
  final int? tablaMACAddresses;

  // Características
  final bool? administrable;
  final bool? soporteVLAN;
  final int? numeroVLANsMax;
  final bool? qos;
  final bool? portMirroring;
  final bool? linkAggregation;
  final bool? spanningTree;

  // Router específico
  final bool? wifi;
  final String? bandasWifi; // 2.4GHz, 5GHz, 6GHz
  final String? estandarWifi; // WiFi 6, WiFi 6E, WiFi 7
  final String? velocidadWifiMax; // Mbps
  final String? vpnThroughput;
  final int? puertoWAN;

  // Firewall específico
  final String? throughputFirewall; // Gbps
  final int? vpnTunnelsMax;
  final bool? ips; // Intrusion Prevention System
  final bool? ids; // Intrusion Detection System
  final bool? antivirus;
  final bool? webFiltering;

  // Software
  final String? versionFirmware;
  final bool? interfazWeb;
  final bool? ssh;
  final bool? snmp;
  final bool? syslog;

  // Redundancia
  final bool? fuenteRedundante;
  final int? ventiladores;
  final bool? montableRack;
  final double? unidadesRack; // 1U, 2U, etc.

  const EspecificacionesDispositivoRed({
    this.numeroPuertos,
    this.velocidadPuertos,
    this.puertosPoE,
    this.potenciaPoEWatts,
    this.puertosSFP,
    this.puertosSFPPlus,
    this.capacidadSwitching,
    this.tablaMACAddresses,
    this.administrable,
    this.soporteVLAN,
    this.numeroVLANsMax,
    this.qos,
    this.portMirroring,
    this.linkAggregation,
    this.spanningTree,
    this.wifi,
    this.bandasWifi,
    this.estandarWifi,
    this.velocidadWifiMax,
    this.vpnThroughput,
    this.puertoWAN,
    this.throughputFirewall,
    this.vpnTunnelsMax,
    this.ips,
    this.ids,
    this.antivirus,
    this.webFiltering,
    this.versionFirmware,
    this.interfazWeb,
    this.ssh,
    this.snmp,
    this.syslog,
    this.fuenteRedundante,
    this.ventiladores,
    this.montableRack,
    this.unidadesRack,
  });

  factory EspecificacionesDispositivoRed.fromJson(Map<String, dynamic> json) {
    return EspecificacionesDispositivoRed(
      numeroPuertos: json['numeroPuertos'],
      velocidadPuertos: json['velocidadPuertos'],
      puertosPoE: json['puertosPoE'],
      potenciaPoEWatts: json['potenciaPoEWatts'],
      puertosSFP: json['puertosSFP'],
      puertosSFPPlus: json['puertosSFPPlus'],
      capacidadSwitching: json['capacidadSwitching'],
      tablaMACAddresses: json['tablaMACAddresses'],
      administrable: json['administrable'],
      soporteVLAN: json['soporteVLAN'],
      numeroVLANsMax: json['numeroVLANsMax'],
      qos: json['qos'],
      portMirroring: json['portMirroring'],
      linkAggregation: json['linkAggregation'],
      spanningTree: json['spanningTree'],
      wifi: json['wifi'],
      bandasWifi: json['bandasWifi'],
      estandarWifi: json['estandarWifi'],
      velocidadWifiMax: json['velocidadWifiMax'],
      vpnThroughput: json['vpnThroughput'],
      puertoWAN: json['puertoWAN'],
      throughputFirewall: json['throughputFirewall'],
      vpnTunnelsMax: json['vpnTunnelsMax'],
      ips: json['ips'],
      ids: json['ids'],
      antivirus: json['antivirus'],
      webFiltering: json['webFiltering'],
      versionFirmware: json['versionFirmware'],
      interfazWeb: json['interfazWeb'],
      ssh: json['ssh'],
      snmp: json['snmp'],
      syslog: json['syslog'],
      fuenteRedundante: json['fuenteRedundante'],
      ventiladores: json['ventiladores'],
      montableRack: json['montableRack'],
      unidadesRack: json['unidadesRack']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroPuertos': numeroPuertos,
      'velocidadPuertos': velocidadPuertos,
      'puertosPoE': puertosPoE,
      'potenciaPoEWatts': potenciaPoEWatts,
      'puertosSFP': puertosSFP,
      'puertosSFPPlus': puertosSFPPlus,
      'capacidadSwitching': capacidadSwitching,
      'tablaMACAddresses': tablaMACAddresses,
      'administrable': administrable,
      'soporteVLAN': soporteVLAN,
      'numeroVLANsMax': numeroVLANsMax,
      'qos': qos,
      'portMirroring': portMirroring,
      'linkAggregation': linkAggregation,
      'spanningTree': spanningTree,
      'wifi': wifi,
      'bandasWifi': bandasWifi,
      'estandarWifi': estandarWifi,
      'velocidadWifiMax': velocidadWifiMax,
      'vpnThroughput': vpnThroughput,
      'puertoWAN': puertoWAN,
      'throughputFirewall': throughputFirewall,
      'vpnTunnelsMax': vpnTunnelsMax,
      'ips': ips,
      'ids': ids,
      'antivirus': antivirus,
      'webFiltering': webFiltering,
      'versionFirmware': versionFirmware,
      'interfazWeb': interfazWeb,
      'ssh': ssh,
      'snmp': snmp,
      'syslog': syslog,
      'fuenteRedundante': fuenteRedundante,
      'ventiladores': ventiladores,
      'montableRack': montableRack,
      'unidadesRack': unidadesRack,
    };
  }

  static EspecificacionesDispositivoRed? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return EspecificacionesDispositivoRed.fromJson(json.decode(jsonString));
    } catch (e) {
      return null;
    }
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
