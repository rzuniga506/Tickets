import 'dart:convert';

/// Especificaciones técnicas detalladas para Computadoras y Laptops
/// Se almacena/obtiene del campo especificacionesJson
class EspecificacionesComputadora {
  // Hardware - CPU
  final int? nucleosProcesador;
  final double? velocidadProcesadorGHz;

  // Hardware - RAM
  final String? tipoRam; // DDR4, DDR5
  final int? ranuraRamDisponibles;

  // Hardware - Almacenamiento
  final String? almacenamientoSecundario;
  final int? capacidadSecundariaGB;

  // Hardware - Gráficos
  final String? tarjetaGrafica;
  final int? memoriaGraficaGB;
  final bool? graficaIntegrada;

  // Red
  final String? tarjetaRedVelocidad; // 1Gbps, 10Gbps
  final bool? wifi;
  final bool? bluetooth;
  final String? dominioRed;

  // Sistema
  final String? arquitecturaSO; // x64, x86, ARM
  final String? tipoLicenciaSO; // OEM, Retail, Volume

  // Laptop específico
  final double? tamanioPantallaLaptop;
  final String? resolucionPantallaLaptop;
  final double? duracionBateriaHoras;
  final bool? webcam;

  // Puertos
  final int? puertosUSB;
  final int? puertosUSBC;
  final bool? puertoHDMI;
  final bool? puertoDisplayPort;
  final bool? puertoEthernet;

  // Otros
  final bool? lectorCD;
  final String? formFactor; // Desktop, Tower, Mini PC, Laptop

  const EspecificacionesComputadora({
    this.nucleosProcesador,
    this.velocidadProcesadorGHz,
    this.tipoRam,
    this.ranuraRamDisponibles,
    this.almacenamientoSecundario,
    this.capacidadSecundariaGB,
    this.tarjetaGrafica,
    this.memoriaGraficaGB,
    this.graficaIntegrada,
    this.tarjetaRedVelocidad,
    this.wifi,
    this.bluetooth,
    this.dominioRed,
    this.arquitecturaSO,
    this.tipoLicenciaSO,
    this.tamanioPantallaLaptop,
    this.resolucionPantallaLaptop,
    this.duracionBateriaHoras,
    this.webcam,
    this.puertosUSB,
    this.puertosUSBC,
    this.puertoHDMI,
    this.puertoDisplayPort,
    this.puertoEthernet,
    this.lectorCD,
    this.formFactor,
  });

  factory EspecificacionesComputadora.fromJson(Map<String, dynamic> json) {
    return EspecificacionesComputadora(
      nucleosProcesador: json['nucleosProcesador'],
      velocidadProcesadorGHz: json['velocidadProcesadorGHz']?.toDouble(),
      tipoRam: json['tipoRam'],
      ranuraRamDisponibles: json['ranuraRamDisponibles'],
      almacenamientoSecundario: json['almacenamientoSecundario'],
      capacidadSecundariaGB: json['capacidadSecundariaGB'],
      tarjetaGrafica: json['tarjetaGrafica'],
      memoriaGraficaGB: json['memoriaGraficaGB'],
      graficaIntegrada: json['graficaIntegrada'],
      tarjetaRedVelocidad: json['tarjetaRedVelocidad'],
      wifi: json['wifi'],
      bluetooth: json['bluetooth'],
      dominioRed: json['dominioRed'],
      arquitecturaSO: json['arquitecturaSO'],
      tipoLicenciaSO: json['tipoLicenciaSO'],
      tamanioPantallaLaptop: json['tamanioPantallaLaptop']?.toDouble(),
      resolucionPantallaLaptop: json['resolucionPantallaLaptop'],
      duracionBateriaHoras: json['duracionBateriaHoras']?.toDouble(),
      webcam: json['webcam'],
      puertosUSB: json['puertosUSB'],
      puertosUSBC: json['puertosUSBC'],
      puertoHDMI: json['puertoHDMI'],
      puertoDisplayPort: json['puertoDisplayPort'],
      puertoEthernet: json['puertoEthernet'],
      lectorCD: json['lectorCD'],
      formFactor: json['formFactor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nucleosProcesador': nucleosProcesador,
      'velocidadProcesadorGHz': velocidadProcesadorGHz,
      'tipoRam': tipoRam,
      'ranuraRamDisponibles': ranuraRamDisponibles,
      'almacenamientoSecundario': almacenamientoSecundario,
      'capacidadSecundariaGB': capacidadSecundariaGB,
      'tarjetaGrafica': tarjetaGrafica,
      'memoriaGraficaGB': memoriaGraficaGB,
      'graficaIntegrada': graficaIntegrada,
      'tarjetaRedVelocidad': tarjetaRedVelocidad,
      'wifi': wifi,
      'bluetooth': bluetooth,
      'dominioRed': dominioRed,
      'arquitecturaSO': arquitecturaSO,
      'tipoLicenciaSO': tipoLicenciaSO,
      'tamanioPantallaLaptop': tamanioPantallaLaptop,
      'resolucionPantallaLaptop': resolucionPantallaLaptop,
      'duracionBateriaHoras': duracionBateriaHoras,
      'webcam': webcam,
      'puertosUSB': puertosUSB,
      'puertosUSBC': puertosUSBC,
      'puertoHDMI': puertoHDMI,
      'puertoDisplayPort': puertoDisplayPort,
      'puertoEthernet': puertoEthernet,
      'lectorCD': lectorCD,
      'formFactor': formFactor,
    };
  }

  /// Parse desde string JSON
  static EspecificacionesComputadora? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return EspecificacionesComputadora.fromJson(json.decode(jsonString));
    } catch (e) {
      return null;
    }
  }

  /// Convertir a string JSON
  String toJsonString() {
    return json.encode(toJson());
  }
}
