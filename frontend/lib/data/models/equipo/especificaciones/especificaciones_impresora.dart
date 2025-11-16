import 'dart:convert';

/// Especificaciones técnicas para Impresoras y Scanners
class EspecificacionesImpresora {
  final String? tipoImpresora; // Laser, Tinta, Multifuncion, Matricial
  final String? colorOMonocromo; // Color, Monocromo
  final int? velocidadPPM; // Páginas por minuto
  final int? velocidadPPMColor;
  final String? resolucionDPI; // 1200x1200, 2400x600
  final int? cicloDeTrabajo; // Páginas por mes recomendadas
  final int? contadorImpresiones;

  // Funciones
  final bool? impresion;
  final bool? escaneo;
  final bool? copiado;
  final bool? fax;
  final bool? duplexAutomatico;
  final bool? alimentadorDocumentos; // ADF
  final int? capacidadADF; // Hojas

  // Conectividad
  final bool? wifi;
  final bool? ethernet;
  final bool? usb;
  final bool? impresionMovil; // AirPrint, Google Cloud Print

  // Capacidad
  final int? capacidadBandeja; // Hojas
  final int? capacidadBandejaSalida;
  final String? formatosMaximos; // A4, Carta, Legal, A3

  // Consumibles
  final String? modeloTonerTinta;
  final int? rendimientoPaginasNegro;
  final int? rendimientoPaginasColor;

  const EspecificacionesImpresora({
    this.tipoImpresora,
    this.colorOMonocromo,
    this.velocidadPPM,
    this.velocidadPPMColor,
    this.resolucionDPI,
    this.cicloDeTrabajo,
    this.contadorImpresiones,
    this.impresion,
    this.escaneo,
    this.copiado,
    this.fax,
    this.duplexAutomatico,
    this.alimentadorDocumentos,
    this.capacidadADF,
    this.wifi,
    this.ethernet,
    this.usb,
    this.impresionMovil,
    this.capacidadBandeja,
    this.capacidadBandejaSalida,
    this.formatosMaximos,
    this.modeloTonerTinta,
    this.rendimientoPaginasNegro,
    this.rendimientoPaginasColor,
  });

  factory EspecificacionesImpresora.fromJson(Map<String, dynamic> json) {
    return EspecificacionesImpresora(
      tipoImpresora: json['tipoImpresora'],
      colorOMonocromo: json['colorOMonocromo'],
      velocidadPPM: json['velocidadPPM'],
      velocidadPPMColor: json['velocidadPPMColor'],
      resolucionDPI: json['resolucionDPI'],
      cicloDeTrabajo: json['cicloDeTrabajo'],
      contadorImpresiones: json['contadorImpresiones'],
      impresion: json['impresion'],
      escaneo: json['escaneo'],
      copiado: json['copiado'],
      fax: json['fax'],
      duplexAutomatico: json['duplexAutomatico'],
      alimentadorDocumentos: json['alimentadorDocumentos'],
      capacidadADF: json['capacidadADF'],
      wifi: json['wifi'],
      ethernet: json['ethernet'],
      usb: json['usb'],
      impresionMovil: json['impresionMovil'],
      capacidadBandeja: json['capacidadBandeja'],
      capacidadBandejaSalida: json['capacidadBandejaSalida'],
      formatosMaximos: json['formatosMaximos'],
      modeloTonerTinta: json['modeloTonerTinta'],
      rendimientoPaginasNegro: json['rendimientoPaginasNegro'],
      rendimientoPaginasColor: json['rendimientoPaginasColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipoImpresora': tipoImpresora,
      'colorOMonocromo': colorOMonocromo,
      'velocidadPPM': velocidadPPM,
      'velocidadPPMColor': velocidadPPMColor,
      'resolucionDPI': resolucionDPI,
      'cicloDeTrabajo': cicloDeTrabajo,
      'contadorImpresiones': contadorImpresiones,
      'impresion': impresion,
      'escaneo': escaneo,
      'copiado': copiado,
      'fax': fax,
      'duplexAutomatico': duplexAutomatico,
      'alimentadorDocumentos': alimentadorDocumentos,
      'capacidadADF': capacidadADF,
      'wifi': wifi,
      'ethernet': ethernet,
      'usb': usb,
      'impresionMovil': impresionMovil,
      'capacidadBandeja': capacidadBandeja,
      'capacidadBandejaSalida': capacidadBandejaSalida,
      'formatosMaximos': formatosMaximos,
      'modeloTonerTinta': modeloTonerTinta,
      'rendimientoPaginasNegro': rendimientoPaginasNegro,
      'rendimientoPaginasColor': rendimientoPaginasColor,
    };
  }

  static EspecificacionesImpresora? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return EspecificacionesImpresora.fromJson(json.decode(jsonString));
    } catch (e) {
      return null;
    }
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
