using System;
using System.ComponentModel.DataAnnotations;
using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.Equipos
{
    /// <summary>
    /// DTO para actualizar un equipo existente
    /// </summary>
    public class EquipoUpdateDto
    {
        [MaxLength(100, ErrorMessage = "El número de serie no puede exceder 100 caracteres")]
        public string? NumeroSerie { get; set; }

        [Required(ErrorMessage = "El nombre es requerido")]
        [MaxLength(200, ErrorMessage = "El nombre no puede exceder 200 caracteres")]
        public string Nombre { get; set; } = string.Empty;

        [MaxLength(1000, ErrorMessage = "La descripción no puede exceder 1000 caracteres")]
        public string? Descripcion { get; set; }

        [MaxLength(100, ErrorMessage = "El modelo no puede exceder 100 caracteres")]
        public string? Modelo { get; set; }

        public string? EspecificacionesJson { get; set; }

        [Required(ErrorMessage = "El tipo de equipo es requerido")]
        public TipoEquipo Tipo { get; set; }

        [Required(ErrorMessage = "El estado es requerido")]
        public EstadoEquipo Estado { get; set; }

        // Campos comunes - Información del fabricante
        [MaxLength(100, ErrorMessage = "La marca no puede exceder 100 caracteres")]
        public string? Marca { get; set; }

        [MaxLength(100, ErrorMessage = "El proveedor no puede exceder 100 caracteres")]
        public string? Proveedor { get; set; }

        [MaxLength(50, ErrorMessage = "El SKU no puede exceder 50 caracteres")]
        public string? SKU { get; set; }

        [MaxLength(50, ErrorMessage = "El número de orden no puede exceder 50 caracteres")]
        public string? NumeroOrdenCompra { get; set; }

        [MaxLength(200, ErrorMessage = "La ubicación física no puede exceder 200 caracteres")]
        public string? UbicacionFisica { get; set; }

        // Hardware - Computadoras/Laptops
        [MaxLength(150, ErrorMessage = "El procesador no puede exceder 150 caracteres")]
        public string? Procesador { get; set; }

        [Range(1, 1024, ErrorMessage = "La RAM debe estar entre 1 y 1024 GB")]
        public int? RamGB { get; set; }

        [Range(1, 100000, ErrorMessage = "La capacidad de almacenamiento debe estar entre 1 y 100000 GB")]
        public int? DiscoDuroCapacidadGB { get; set; }

        [MaxLength(50, ErrorMessage = "El tipo de almacenamiento no puede exceder 50 caracteres")]
        public string? TipoAlmacenamiento { get; set; }

        // Red - Computadoras/Dispositivos
        [MaxLength(17, ErrorMessage = "La dirección MAC no puede exceder 17 caracteres")]
        [RegularExpression(@"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$", ErrorMessage = "Formato de MAC inválido (ej: AA:BB:CC:DD:EE:FF)")]
        public string? MacAddress { get; set; }

        [MaxLength(45, ErrorMessage = "La dirección IP no puede exceder 45 caracteres")]
        public string? DireccionIP { get; set; }

        [MaxLength(100, ErrorMessage = "El hostname no puede exceder 100 caracteres")]
        public string? Hostname { get; set; }

        // Sistema Operativo - Computadoras/Laptops
        [MaxLength(100, ErrorMessage = "El sistema operativo no puede exceder 100 caracteres")]
        public string? SistemaOperativo { get; set; }

        [MaxLength(50, ErrorMessage = "La versión del SO no puede exceder 50 caracteres")]
        public string? VersionSO { get; set; }

        [MaxLength(200, ErrorMessage = "La licencia del SO no puede exceder 200 caracteres")]
        public string? LicenciaSO { get; set; }

        [Required(ErrorMessage = "La condición es requerida")]
        public CondicionEquipo Condicion { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "El costo debe ser mayor o igual a 0")]
        public decimal? CostoAdquisicion { get; set; }

        public DateTime? FechaAdquisicion { get; set; }

        [Range(1, 600, ErrorMessage = "La vida útil debe estar entre 1 y 600 meses")]
        public int VidaUtilMeses { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "El valor residual debe ser mayor o igual a 0")]
        public decimal? ValorResidual { get; set; }

        public DateTime? FechaInicioGarantia { get; set; }

        public DateTime? FechaFinGarantia { get; set; }

        [MaxLength(2000, ErrorMessage = "Las observaciones no pueden exceder 2000 caracteres")]
        public string? Observaciones { get; set; }

        public int? UsuarioAsignadoId { get; set; }
        public int? DepartamentoAsignadoId { get; set; }
    }
}
