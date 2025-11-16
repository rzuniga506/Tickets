using System.Text.Json.Serialization;

namespace Tickets.Domain.Models.Especificaciones
{
    /// <summary>
    /// Especificaciones técnicas para Monitores
    /// Se almacena en EspecificacionesJson
    /// </summary>
    public class EspecificacionesMonitor
    {
        [JsonPropertyName("tamanioPulgadas")]
        public decimal? TamanioPulgadas { get; set; }

        [JsonPropertyName("resolucion")]
        public string? Resolucion { get; set; } // 1920x1080, 2560x1440, 3840x2160

        [JsonPropertyName("tipoPanel")]
        public string? TipoPanel { get; set; } // IPS, TN, VA, OLED

        [JsonPropertyName("frecuenciaHz")]
        public int? FrecuenciaHz { get; set; }

        [JsonPropertyName("tiempoRespuestaMs")]
        public int? TiempoRespuestaMs { get; set; }

        [JsonPropertyName("relacionAspecto")]
        public string? RelacionAspecto { get; set; } // 16:9, 21:9, 16:10

        [JsonPropertyName("curvo")]
        public bool? Curvo { get; set; }

        [JsonPropertyName("touchscreen")]
        public bool? Touchscreen { get; set; }

        // Puertos
        [JsonPropertyName("puertoHDMI")]
        public int? PuertoHDMI { get; set; }

        [JsonPropertyName("puertoDisplayPort")]
        public int? PuertoDisplayPort { get; set; }

        [JsonPropertyName("puertoVGA")]
        public bool? PuertoVGA { get; set; }

        [JsonPropertyName("puertoDVI")]
        public bool? PuertoDVI { get; set; }

        [JsonPropertyName("puertoUSBC")]
        public bool? PuertoUSBC { get; set; }

        // Características
        [JsonPropertyName("bocinas")]
        public bool? Bocinas { get; set; }

        [JsonPropertyName("ajusteAltura")]
        public bool? AjusteAltura { get; set; }

        [JsonPropertyName("rotacion")]
        public bool? Rotacion { get; set; } // Pivot

        [JsonPropertyName("hdr")]
        public bool? HDR { get; set; }

        [JsonPropertyName("gSync")]
        public bool? GSync { get; set; }

        [JsonPropertyName("freeSync")]
        public bool? FreeSync { get; set; }

        [JsonPropertyName("consumoWatts")]
        public int? ConsumoWatts { get; set; }
    }
}
