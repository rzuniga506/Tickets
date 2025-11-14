using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.HistorialEstadoTicket;

/// <summary>
/// DTO para Historial de Estado de Ticket
/// </summary>
public class HistorialEstadoTicketDto
{
    public int Id { get; set; }
    public int TicketId { get; set; }
    public string NumeroTicket { get; set; } = string.Empty;
    public EstadoTicket EstadoAnterior { get; set; }
    public string EstadoAnteriorDescripcion { get; set; } = string.Empty;
    public EstadoTicket EstadoNuevo { get; set; }
    public string EstadoNuevoDescripcion { get; set; } = string.Empty;
    public string? Comentario { get; set; }
    public int? MinutosEnEstadoAnterior { get; set; }
    public int UsuarioId { get; set; }
    public string UsuarioNombre { get; set; } = string.Empty;
    public DateTime FechaCreacion { get; set; }
}
