using System.Text.Json.Serialization;

namespace Tickets.Domain.Models.Especificaciones
{
    /// <summary>
    /// Especificaciones técnicas detalladas para Computadoras y Laptops
    /// Se almacena en EspecificacionesJson
    /// </summary>
    public class EspecificacionesComputadora
    {
        // Hardware - CPU
        [JsonPropertyName("nucleosProcesador")]
        public int? NucleosProcesador { get; set; }

        [JsonPropertyName("velocidadProcesadorGHz")]
        public decimal? VelocidadProcesadorGHz { get; set; }

        // Hardware - RAM
        [JsonPropertyName("tipoRam")]
        public string? TipoRam { get; set; } // DDR4, DDR5

        [JsonPropertyName("ranuraRamDisponibles")]
        public int? RanuraRamDisponibles { get; set; }

        // Hardware - Almacenamiento
        [JsonPropertyName("almacenamientoSecundario")]
        public string? AlmacenamientoSecundario { get; set; } // Segundo disco si existe

        [JsonPropertyName("capacidadSecundariaGB")]
        public int? CapacidadSecundariaGB { get; set; }

        // Hardware - Gráficos
        [JsonPropertyName("tarjetaGrafica")]
        public string? TarjetaGrafica { get; set; }

        [JsonPropertyName("memoriaGraficaGB")]
        public int? MemoriaGraficaGB { get; set; }

        [JsonPropertyName("graficaIntegrada")]
        public bool? GraficaIntegrada { get; set; }

        // Red
        [JsonPropertyName("tarjetaRedVelocidad")]
        public string? TarjetaRedVelocidad { get; set; } // 1Gbps, 10Gbps

        [JsonPropertyName("wifi")]
        public bool? Wifi { get; set; }

        [JsonPropertyName("bluetooth")]
        public bool? Bluetooth { get; set; }

        [JsonPropertyName("dominioRed")]
        public string? DominioRed { get; set; }

        // Sistema
        [JsonPropertyName("arquitecturaSO")]
        public string? ArquitecturaSO { get; set; } // x64, x86, ARM

        [JsonPropertyName("tipoLicenciaSO")]
        public string? TipoLicenciaSO { get; set; } // OEM, Retail, Volume

        // Laptop específico
        [JsonPropertyName("tamanioPantallaLaptop")]
        public decimal? TamanioPantallaLaptop { get; set; }

        [JsonPropertyName("resolucionPantallaLaptop")]
        public string? ResolucionPantallaLaptop { get; set; }

        [JsonPropertyName("duracionBateriaHoras")]
        public decimal? DuracionBateriaHoras { get; set; }

        [JsonPropertyName("webcam")]
        public bool? Webcam { get; set; }

        // Puertos
        [JsonPropertyName("puertosUSB")]
        public int? PuertosUSB { get; set; }

        [JsonPropertyName("puertosUSBC")]
        public int? PuertosUSBC { get; set; }

        [JsonPropertyName("puertoHDMI")]
        public bool? PuertoHDMI { get; set; }

        [JsonPropertyName("puertoDisplayPort")]
        public bool? PuertoDisplayPort { get; set; }

        [JsonPropertyName("puertoEthernet")]
        public bool? PuertoEthernet { get; set; }

        // Otros
        [JsonPropertyName("lectorCD")]
        public bool? LectorCD { get; set; }

        [JsonPropertyName("formFactor")]
        public string? FormFactor { get; set; } // Desktop, Tower, Mini PC, Laptop
    }
}
