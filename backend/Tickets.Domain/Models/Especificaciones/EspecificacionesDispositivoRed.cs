using System.Text.Json.Serialization;

namespace Tickets.Domain.Models.Especificaciones
{
    /// <summary>
    /// Especificaciones técnicas para Router, Switch, Firewall
    /// Se almacena en EspecificacionesJson
    /// </summary>
    public class EspecificacionesDispositivoRed
    {
        [JsonPropertyName("numeroPuertos")]
        public int? NumeroPuertos { get; set; }

        [JsonPropertyName("velocidadPuertos")]
        public string? VelocidadPuertos { get; set; } // 1Gbps, 10Gbps, 100Mbps

        [JsonPropertyName("puertosPoE")]
        public int? PuertosPoE { get; set; }

        [JsonPropertyName("potenciaPoEWatts")]
        public int? PotenciaPoEWatts { get; set; }

        [JsonPropertyName("puertosSFP")]
        public int? PuertosSFP { get; set; }

        [JsonPropertyName("puertosSFPPlus")]
        public int? PuertosSFPPlus { get; set; }

        [JsonPropertyName("capacidadSwitching")]
        public string? CapacidadSwitching { get; set; } // Gbps

        [JsonPropertyName("tablaMACAddresses")]
        public int? TablaMACAddresses { get; set; }

        // Características
        [JsonPropertyName("administrable")]
        public bool? Administrable { get; set; }

        [JsonPropertyName("soporteVLAN")]
        public bool? SoporteVLAN { get; set; }

        [JsonPropertyName("numeroVLANsMax")]
        public int? NumeroVLANsMax { get; set; }

        [JsonPropertyName("qos")]
        public bool? QoS { get; set; }

        [JsonPropertyName("portMirroring")]
        public bool? PortMirroring { get; set; }

        [JsonPropertyName("linkAggregation")]
        public bool? LinkAggregation { get; set; }

        [JsonPropertyName("spanningTree")]
        public bool? SpanningTree { get; set; }

        // Router específico
        [JsonPropertyName("wifi")]
        public bool? Wifi { get; set; }

        [JsonPropertyName("bandasWifi")]
        public string? BandasWifi { get; set; } // 2.4GHz, 5GHz, 6GHz

        [JsonPropertyName("estandarWifi")]
        public string? EstandarWifi { get; set; } // WiFi 6, WiFi 6E, WiFi 7

        [JsonPropertyName("velocidadWifiMax")]
        public string? VelocidadWifiMax { get; set; } // Mbps

        [JsonPropertyName("vpnThroughput")]
        public string? VPNThroughput { get; set; }

        [JsonPropertyName("puertoWAN")]
        public int? PuertoWAN { get; set; }

        // Firewall específico
        [JsonPropertyName("throughputFirewall")]
        public string? ThroughputFirewall { get; set; } // Gbps

        [JsonPropertyName("vpnTunnelsMax")]
        public int? VPNTunnelsMax { get; set; }

        [JsonPropertyName("ips")]
        public bool? IPS { get; set; } // Intrusion Prevention System

        [JsonPropertyName("ids")]
        public bool? IDS { get; set; } // Intrusion Detection System

        [JsonPropertyName("antivirus")]
        public bool? Antivirus { get; set; }

        [JsonPropertyName("webFiltering")]
        public bool? WebFiltering { get; set; }

        // Software
        [JsonPropertyName("versionFirmware")]
        public string? VersionFirmware { get; set; }

        [JsonPropertyName("interfazWeb")]
        public bool? InterfazWeb { get; set; }

        [JsonPropertyName("ssh")]
        public bool? SSH { get; set; }

        [JsonPropertyName("snmp")]
        public bool? SNMP { get; set; }

        [JsonPropertyName("syslog")]
        public bool? Syslog { get; set; }

        // Redundancia
        [JsonPropertyName("fuenteRedundante")]
        public bool? FuenteRedundante { get; set; }

        [JsonPropertyName("ventiladores")]
        public int? Ventiladores { get; set; }

        [JsonPropertyName("montableRack")]
        public bool? MontableRack { get; set; }

        [JsonPropertyName("unidadesRack")]
        public decimal? UnidadesRack { get; set; } // 1U, 2U, etc.
    }
}
