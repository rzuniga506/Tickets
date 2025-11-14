using Tickets.Domain.Enums;

namespace Tickets.Domain.Entities;

/// <summary>
/// Representa el historial de cambios de estado de un ticket
/// </summary>
public class HistorialEstadoTicket : BaseEntity
{
    /// <summary>
    /// Estado anterior del ticket
    /// </summary>
    public EstadoTicket EstadoAnterior { get; set; }

    /// <summary>
    /// Estado nuevo del ticket
    /// </summary>
    public EstadoTicket EstadoNuevo { get; set; }

    /// <summary>
    /// Comentario opcional sobre el cambio de estado
    /// </summary>
    public string? Comentario { get; set; }

    /// <summary>
    /// Tiempo transcurrido en el estado anterior (en minutos)
    /// </summary>
    public int? MinutosEnEstadoAnterior { get; set; }

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
    /// ID del usuario que realizó el cambio
    /// </summary>
    public int UsuarioId { get; set; }

    /// <summary>
    /// Usuario que realizó el cambio
    /// </summary>
    public virtual Usuario Usuario { get; set; } = null!;

    /// <summary>
    /// Propiedades calculadas
    /// </summary>
    public string EstadoAnteriorDescripcion => ObtenerDescripcionEstado(EstadoAnterior);
    public string EstadoNuevoDescripcion => ObtenerDescripcionEstado(EstadoNuevo);

    private static string ObtenerDescripcionEstado(EstadoTicket estado)
    {
        return estado switch
        {
            EstadoTicket.Nuevo => "Nuevo",
            EstadoTicket.Asignado => "Asignado",
            EstadoTicket.EnProceso => "En Proceso",
            EstadoTicket.EnEspera => "En Espera",
            EstadoTicket.Resuelto => "Resuelto",
            EstadoTicket.Cerrado => "Cerrado",
            EstadoTicket.Cancelado => "Cancelado",
            EstadoTicket.Reabierto => "Reabierto",
            _ => "Desconocido"
        };
    }
}
