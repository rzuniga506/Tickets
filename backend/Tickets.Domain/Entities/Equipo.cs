using System;
using System.Collections.Generic;
using Tickets.Domain.Common;
using Tickets.Domain.Enums;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un equipo del inventario
    /// </summary>
    public class Equipo : BaseEntity
    {
        /// <summary>
        /// Código interno único del equipo
        /// </summary>
        public string CodigoInterno { get; set; } = string.Empty;

        /// <summary>
        /// Número de serie del fabricante
        /// </summary>
        public string? NumeroSerie { get; set; }

        /// <summary>
        /// Nombre descriptivo del equipo
        /// </summary>
        public string Nombre { get; set; } = string.Empty;

        /// <summary>
        /// Descripción detallada del equipo
        /// </summary>
        public string? Descripcion { get; set; }

        /// <summary>
        /// Código QR único para identificación
        /// </summary>
        public string? CodigoQR { get; set; }

        /// <summary>
        /// Modelo del equipo
        /// </summary>
        public string? Modelo { get; set; }

        /// <summary>
        /// Especificaciones técnicas en formato JSON
        /// </summary>
        public string? EspecificacionesJson { get; set; }

        /// <summary>
        /// Tipo de equipo
        /// </summary>
        public TipoEquipo Tipo { get; set; }

        // =============================================
        // CAMPOS COMUNES - Información del Fabricante
        // =============================================

        /// <summary>
        /// Marca o fabricante del equipo (Dell, HP, Lenovo, etc.)
        /// </summary>
        public string? Marca { get; set; }

        /// <summary>
        /// Proveedor que suministró el equipo
        /// </summary>
        public string? Proveedor { get; set; }

        /// <summary>
        /// Stock Keeping Unit - Código SKU del producto
        /// </summary>
        public string? SKU { get; set; }

        /// <summary>
        /// Número de orden de compra
        /// </summary>
        public string? NumeroOrdenCompra { get; set; }

        /// <summary>
        /// Ubicación física (Edificio, Piso, Área)
        /// </summary>
        public string? UbicacionFisica { get; set; }

        // =============================================
        // COMPUTADORAS/LAPTOPS - Hardware
        // =============================================

        /// <summary>
        /// Procesador/CPU (ej: Intel Core i7-12700K)
        /// </summary>
        public string? Procesador { get; set; }

        /// <summary>
        /// Memoria RAM en GB
        /// </summary>
        public int? RamGB { get; set; }

        /// <summary>
        /// Capacidad del disco duro/SSD en GB
        /// </summary>
        public int? DiscoDuroCapacidadGB { get; set; }

        /// <summary>
        /// Tipo de almacenamiento (SSD, HDD, NVMe)
        /// </summary>
        public string? TipoAlmacenamiento { get; set; }

        // =============================================
        // COMPUTADORAS/LAPTOPS/DISPOSITIVOS RED - Red
        // =============================================

        /// <summary>
        /// Dirección MAC de la tarjeta de red
        /// </summary>
        public string? MacAddress { get; set; }

        /// <summary>
        /// Dirección IP asignada (IPv4 o IPv6)
        /// </summary>
        public string? DireccionIP { get; set; }

        /// <summary>
        /// Nombre del host en la red
        /// </summary>
        public string? Hostname { get; set; }

        // =============================================
        // COMPUTADORAS/LAPTOPS - Sistema Operativo
        // =============================================

        /// <summary>
        /// Sistema operativo instalado
        /// </summary>
        public string? SistemaOperativo { get; set; }

        /// <summary>
        /// Versión del sistema operativo
        /// </summary>
        public string? VersionSO { get; set; }

        /// <summary>
        /// Clave de licencia del sistema operativo
        /// </summary>
        public string? LicenciaSO { get; set; }

        /// <summary>
        /// Estado actual del equipo
        /// </summary>
        public EstadoEquipo Estado { get; set; }

        /// <summary>
        /// Condición física del equipo
        /// </summary>
        public CondicionEquipo Condicion { get; set; }

        /// <summary>
        /// Costo de adquisición
        /// </summary>
        public decimal? CostoAdquisicion { get; set; }

        /// <summary>
        /// Fecha de adquisición
        /// </summary>
        public DateTime? FechaAdquisicion { get; set; }

        /// <summary>
        /// Vida útil en meses para cálculo de depreciación
        /// </summary>
        public int VidaUtilMeses { get; set; }

        /// <summary>
        /// Valor residual después de depreciación
        /// </summary>
        public decimal? ValorResidual { get; set; }

        /// <summary>
        /// Fecha de inicio de garantía
        /// </summary>
        public DateTime? FechaInicioGarantia { get; set; }

        /// <summary>
        /// Fecha de fin de garantía
        /// </summary>
        public DateTime? FechaFinGarantia { get; set; }

        /// <summary>
        /// Fecha de asignación al usuario actual
        /// </summary>
        public DateTime? FechaAsignacion { get; set; }

        /// <summary>
        /// Observaciones adicionales
        /// </summary>
        public string? Observaciones { get; set; }

        // Relaciones
        /// <summary>
        /// Usuario al que está asignado el equipo
        /// </summary>
        public int? UsuarioAsignadoId { get; set; }
        public virtual Usuario? UsuarioAsignado { get; set; }

        /// <summary>
        /// Departamento al que está asignado el equipo
        /// </summary>
        public int? DepartamentoAsignadoId { get; set; }
        public virtual Departamento? DepartamentoAsignado { get; set; }

        /// <summary>
        /// Tickets relacionados con este equipo
        /// </summary>
        public virtual ICollection<Ticket> Tickets { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public Equipo()
        {
            Estado = EstadoEquipo.Disponible;
            Condicion = CondicionEquipo.Bueno;
            VidaUtilMeses = 36; // 3 años por defecto
            Tickets = new HashSet<Ticket>();
        }
    }
}
