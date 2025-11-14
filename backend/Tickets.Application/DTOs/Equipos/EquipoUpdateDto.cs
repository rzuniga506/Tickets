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

        [Required(ErrorMessage = "El estado es requerido")]
        public EstadoEquipo Estado { get; set; }

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
