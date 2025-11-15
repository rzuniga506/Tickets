using Tickets.Domain.Common;

namespace Tickets.Domain.Entities;

/// <summary>
/// Representa el historial de asignaciones de un ticket
/// </summary>
public class AsignacionTicket : BaseEntity
{
    /// <summary>
    /// Técnico anterior (null si es la primera asignación)
    /// </summary>
    public int? TecnicoAnteriorId { get; set; }

    /// <summary>
    /// Técnico anterior
    /// </summary>
    public virtual Usuario? TecnicoAnterior { get; set; }

    /// <summary>
    /// Técnico nuevo al que se asigna
    /// </summary>
    public int TecnicoNuevoId { get; set; }

    /// <summary>
    /// Técnico nuevo
    /// </summary>
    public virtual Usuario TecnicoNuevo { get; set; } = null!;

    /// <summary>
    /// Motivo de la asignación/reasignación
    /// </summary>
    public string? Motivo { get; set; }

    /// <summary>
    /// Indica si fue una asignación automática o manual
    /// </summary>
    public bool EsAsignacionAutomatica { get; set; } = false;

    /// <summary>
    /// Tiempo que el ticket estuvo con el técnico anterior (en minutos)
    /// </summary>
    public int? MinutosConTecnicoAnterior { get; set; }

    // Relaciones
    /// <summary>
    /// ID del ticket asociado
    /// </summary>
    public int TicketId { get; set; }

    /// <summary>
    /// Ticket asociado
    /// </summary>
    public virtual Ticket Ticket { get; set; } = null!;

    /// <summary>
    /// ID del usuario que realizó la asignación
    /// </summary>
    public int AsignadoPorId { get; set; }

    /// <summary>
    /// Usuario que realizó la asignación
    /// </summary>
    public virtual Usuario AsignadoPor { get; set; } = null!;

    /// <summary>
    /// Propiedades calculadas
    /// </summary>
    public bool EsPrimeraAsignacion => TecnicoAnteriorId == null;
    public bool EsReasignacion => TecnicoAnteriorId != null;
}
