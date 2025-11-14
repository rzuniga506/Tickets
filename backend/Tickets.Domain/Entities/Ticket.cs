using System;
using System.Collections.Generic;
using Tickets.Domain.Common;
using Tickets.Domain.Enums;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un ticket de soporte
    /// </summary>
    public class Ticket : BaseEntity
    {
        /// <summary>
        /// Número único del ticket (ej: TK-2024-00001)
        /// </summary>
        public string NumeroTicket { get; set; } = string.Empty;

        /// <summary>
        /// Asunto del ticket
        /// </summary>
        public string Asunto { get; set; } = string.Empty;

        /// <summary>
        /// Descripción detallada del problema
        /// </summary>
        public string Descripcion { get; set; } = string.Empty;

        /// <summary>
        /// Prioridad del ticket
        /// </summary>
        public PrioridadTicket Prioridad { get; set; }

        /// <summary>
        /// Estado actual del ticket
        /// </summary>
        public EstadoTicket Estado { get; set; }

        /// <summary>
        /// Fecha de apertura del ticket
        /// </summary>
        public DateTime FechaApertura { get; set; }

        /// <summary>
        /// Fecha de asignación a un técnico
        /// </summary>
        public DateTime? FechaAsignacion { get; set; }

        /// <summary>
        /// Fecha de inicio del proceso de resolución
        /// </summary>
        public DateTime? FechaInicioProceso { get; set; }

        /// <summary>
        /// Fecha de resolución del ticket
        /// </summary>
        public DateTime? FechaResolucion { get; set; }

        /// <summary>
        /// Fecha de cierre definitivo
        /// </summary>
        public DateTime? FechaCierre { get; set; }

        /// <summary>
        /// Minutos invertidos en la resolución
        /// </summary>
        public int? MinutosInvertidos { get; set; }

        /// <summary>
        /// Fecha límite según SLA
        /// </summary>
        public DateTime? FechaLimiteSLA { get; set; }

        /// <summary>
        /// Indica si se cumplió el SLA
        /// </summary>
        public bool SLACumplido { get; set; }

        /// <summary>
        /// Minutos restantes para cumplir SLA
        /// </summary>
        public int? MinutosRestantesSLA { get; set; }

        /// <summary>
        /// Calificación del servicio (1-5 estrellas)
        /// </summary>
        public int? CalificacionServicio { get; set; }

        /// <summary>
        /// Comentario de evaluación del usuario
        /// </summary>
        public string? ComentarioEvaluacion { get; set; }

        /// <summary>
        /// Fecha de evaluación
        /// </summary>
        public DateTime? FechaEvaluacion { get; set; }

        /// <summary>
        /// Solución aplicada al ticket
        /// </summary>
        public string? Solucion { get; set; }

        /// <summary>
        /// Tipo de solución
        /// </summary>
        public TipoSolucion? TipoSolucion { get; set; }

        /// <summary>
        /// Indica si el ticket fue reabierto
        /// </summary>
        public bool FueReabierto { get; set; }

        /// <summary>
        /// Cantidad de veces que se reabrió
        /// </summary>
        public int CantidadReaberturas { get; set; }

        // Relaciones
        /// <summary>
        /// Usuario que creó el ticket (solicitante)
        /// </summary>
        public int SolicitanteId { get; set; }
        public virtual Usuario Solicitante { get; set; } = null!;

        /// <summary>
        /// Técnico asignado al ticket
        /// </summary>
        public int? TecnicoAsignadoId { get; set; }
        public virtual Usuario? TecnicoAsignado { get; set; }

        /// <summary>
        /// Equipo relacionado con el ticket
        /// </summary>
        public int? EquipoId { get; set; }
        public virtual Equipo? Equipo { get; set; }

        /// <summary>
        /// Categoría del ticket
        /// </summary>
        public int? CategoriaTicketId { get; set; }
        public virtual CategoriaTicket? CategoriaTicket { get; set; }

        /// <summary>
        /// Comentarios del ticket
        /// </summary>
        public virtual ICollection<ComentarioTicket> Comentarios { get; set; }

        /// <summary>
        /// Archivos adjuntos del ticket
        /// </summary>
        public virtual ICollection<AdjuntoTicket> Adjuntos { get; set; }

        /// <summary>
        /// Historial de cambios de estado del ticket
        /// </summary>
        public virtual ICollection<HistorialEstadoTicket> HistorialEstados { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public Ticket()
        {
            Estado = EstadoTicket.Nuevo;
            Prioridad = PrioridadTicket.Media;
            FechaApertura = DateTime.UtcNow;
            FueReabierto = false;
            CantidadReaberturas = 0;
            SLACumplido = false;
            Comentarios = new HashSet<ComentarioTicket>();
            Adjuntos = new HashSet<AdjuntoTicket>();
            HistorialEstados = new HashSet<HistorialEstadoTicket>();
        }
    }
}
