using System.Text.Json.Serialization;

namespace Tickets.Domain.Models.Especificaciones
{
    /// <summary>
    /// Especificaciones técnicas para Impresoras y Scanners
    /// Se almacena en EspecificacionesJson
    /// </summary>
    public class EspecificacionesImpresora
    {
        [JsonPropertyName("tipoImpresora")]
        public string? TipoImpresora { get; set; } // Laser, Tinta, Multifuncion, Matricial

        [JsonPropertyName("colorOMonocromo")]
        public string? ColorOMonocromo { get; set; } // Color, Monocromo

        [JsonPropertyName("velocidadPPM")]
        public int? VelocidadPPM { get; set; } // Páginas por minuto

        [JsonPropertyName("velocidadPPMColor")]
        public int? VelocidadPPMColor { get; set; }

        [JsonPropertyName("resolucionDPI")]
        public string? ResolucionDPI { get; set; } // 1200x1200, 2400x600

        [JsonPropertyName("cicloDeTrabajo")]
        public int? CicloDeTrabajo { get; set; } // Páginas por mes recomendadas

        [JsonPropertyName("contadorImpresiones")]
        public int? ContadorImpresiones { get; set; }

        // Funciones
        [JsonPropertyName("impresion")]
        public bool? Impresion { get; set; }

        [JsonPropertyName("escaneo")]
        public bool? Escaneo { get; set; }

        [JsonPropertyName("copiado")]
        public bool? Copiado { get; set; }

        [JsonPropertyName("fax")]
        public bool? Fax { get; set; }

        [JsonPropertyName("duplexAutomatico")]
        public bool? DuplexAutomatico { get; set; }

        [JsonPropertyName("alimentadorDocumentos")]
        public bool? AlimentadorDocumentos { get; set; } // ADF

        [JsonPropertyName("capacidadADF")]
        public int? CapacidadADF { get; set; } // Hojas

        // Conectividad
        [JsonPropertyName("wifi")]
        public bool? Wifi { get; set; }

        [JsonPropertyName("ethernet")]
        public bool? Ethernet { get; set; }

        [JsonPropertyName("usb")]
        public bool? USB { get; set; }

        [JsonPropertyName("impresionMovil")]
        public bool? ImpresionMovil { get; set; } // AirPrint, Google Cloud Print

        // Capacidad
        [JsonPropertyName("capacidadBandeja")]
        public int? CapacidadBandeja { get; set; } // Hojas

        [JsonPropertyName("capacidadBandejaSalida")]
        public int? CapacidadBandejaSalida { get; set; }

        [JsonPropertyName("formatosMaximos")]
        public string? FormatosMaximos { get; set; } // A4, Carta, Legal, A3

        // Consumibles
        [JsonPropertyName("modeloTonerTinta")]
        public string? ModeloTonerTinta { get; set; }

        [JsonPropertyName("rendimientoPaginasNegro")]
        public int? RendimientoPaginasNegro { get; set; }

        [JsonPropertyName("rendimientoPaginasColor")]
        public int? RendimientoPaginasColor { get; set; }
    }
}
