using System;
using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.Tickets
{
    /// <summary>
    /// DTO para respuesta de ticket
    /// </summary>
    public class TicketDto
    {
        public int Id { get; set; }
        public string NumeroTicket { get; set; } = string.Empty;
        public string Asunto { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public PrioridadTicket Prioridad { get; set; }
        public string PrioridadNombre { get; set; } = string.Empty;
        public EstadoTicket Estado { get; set; }
        public string EstadoNombre { get; set; } = string.Empty;
        public TipoSoporte TipoSoporte { get; set; }
        public string TipoSoporteNombre { get; set; } = string.Empty;
        public DateTime FechaApertura { get; set; }
        public DateTime? FechaAsignacion { get; set; }
        public DateTime? FechaInicioProceso { get; set; }
        public DateTime? FechaResolucion { get; set; }
        public DateTime? FechaCierre { get; set; }
        public int? MinutosInvertidos { get; set; }
        public DateTime? FechaLimiteSLA { get; set; }
        public bool SLACumplido { get; set; }
        public int? MinutosRestantesSLA { get; set; }
        public int? CalificacionServicio { get; set; }
        public string? ComentarioEvaluacion { get; set; }
        public DateTime? FechaEvaluacion { get; set; }
        public string? Solucion { get; set; }
        public TipoSolucion? TipoSolucion { get; set; }
        public string? TipoSolucionNombre { get; set; }
        public bool FueReabierto { get; set; }
        public int CantidadReaberturas { get; set; }

        // Relaciones
        public int SolicitanteId { get; set; }
        public string SolicitanteNombre { get; set; } = string.Empty;
        public string SolicitanteEmail { get; set; } = string.Empty;
        public int? TecnicoAsignadoId { get; set; }
        public string? TecnicoAsignadoNombre { get; set; }
        public int? EquipoId { get; set; }
        public string? EquipoNombre { get; set; }
        public string? EquipoCodigoInterno { get; set; }
        public int? CategoriaTicketId { get; set; }
        public string? CategoriaTicketNombre { get; set; }

        // Auditoria
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }
}
