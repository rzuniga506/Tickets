using System;
using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.Equipos
{
    /// <summary>
    /// DTO para respuesta de equipo
    /// </summary>
    public class EquipoDto
    {
        public int Id { get; set; }
        public string CodigoInterno { get; set; } = string.Empty;
        public string? NumeroSerie { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string? CodigoQR { get; set; }
        public string? Modelo { get; set; }
        public string? EspecificacionesJson { get; set; }
        public EstadoEquipo Estado { get; set; }
        public string EstadoNombre { get; set; } = string.Empty;
        public CondicionEquipo Condicion { get; set; }
        public string CondicionNombre { get; set; } = string.Empty;
        public decimal? CostoAdquisicion { get; set; }
        public DateTime? FechaAdquisicion { get; set; }
        public int VidaUtilMeses { get; set; }
        public decimal? ValorResidual { get; set; }
        public DateTime? FechaInicioGarantia { get; set; }
        public DateTime? FechaFinGarantia { get; set; }
        public bool EnGarantia { get; set; }
        public DateTime? FechaAsignacion { get; set; }
        public string? Observaciones { get; set; }

        // Relaciones
        public int? UsuarioAsignadoId { get; set; }
        public string? UsuarioAsignadoNombre { get; set; }
        public int? DepartamentoAsignadoId { get; set; }
        public string? DepartamentoAsignadoNombre { get; set; }

        // Auditoria
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public string? CreadoPor { get; set; }
        public string? ModificadoPor { get; set; }
    }
}
