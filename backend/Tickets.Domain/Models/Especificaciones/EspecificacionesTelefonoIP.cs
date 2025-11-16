using System.Text.Json.Serialization;

namespace Tickets.Domain.Models.Especificaciones
{
    /// <summary>
    /// Especificaciones técnicas para Teléfonos IP
    /// Se almacena en EspecificacionesJson
    /// </summary>
    public class EspecificacionesTelefonoIP
    {
        [JsonPropertyName("extension")]
        public string? Extension { get; set; }

        [JsonPropertyName("numeroLineas")]
        public int? NumeroLineas { get; set; }

        [JsonPropertyName("protocoloVoIP")]
        public string? ProtocoloVoIP { get; set; } // SIP, H.323, SCCP

        [JsonPropertyName("codecsAudio")]
        public string? CodecsAudio { get; set; } // G.711, G.729, Opus

        [JsonPropertyName("pantalla")]
        public bool? Pantalla { get; set; }

        [JsonPropertyName("pantallaTamanioPulgadas")]
        public decimal? PantallaTamanioPulgadas { get; set; }

        [JsonPropertyName("pantallaColor")]
        public bool? PantallaColor { get; set; }

        [JsonPropertyName("pantallaTactil")]
        public bool? PantallaTactil { get; set; }

        [JsonPropertyName("poe")]
        public bool? PoE { get; set; }

        [JsonPropertyName("wifi")]
        public bool? Wifi { get; set; }

        [JsonPropertyName("bluetooth")]
        public bool? Bluetooth { get; set; }

        [JsonPropertyName("manosLibres")]
        public bool? ManosLibres { get; set; }

        [JsonPropertyName("headset")]
        public bool? Headset { get; set; }

        [JsonPropertyName("teclasFuncion")]
        public int? TeclasFuncion { get; set; }

        [JsonPropertyName("moduloExpansion")]
        public bool? ModuloExpansion { get; set; }

        [JsonPropertyName("puertoUSB")]
        public bool? PuertoUSB { get; set; }

        [JsonPropertyName("grabacionLlamadas")]
        public bool? GrabacionLlamadas { get; set; }

        [JsonPropertyName("directorio")]
        public int? DirectorioContactos { get; set; } // Número de contactos

        [JsonPropertyName("versionFirmware")]
        public string? VersionFirmware { get; set; }

        [JsonPropertyName("servidorSIP")]
        public string? ServidorSIP { get; set; }
    }
}
