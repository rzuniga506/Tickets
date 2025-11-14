using System.ComponentModel.DataAnnotations;
using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.HistorialEstadoTicket;

/// <summary>
/// DTO para crear un nuevo registro de Historial de Estado de Ticket
/// </summary>
public class CreateHistorialEstadoTicketDto
{
    [Required(ErrorMessage = "El ID del ticket es requerido")]
    public int TicketId { get; set; }

    [Required(ErrorMessage = "El estado anterior es requerido")]
    public EstadoTicket EstadoAnterior { get; set; }

    [Required(ErrorMessage = "El estado nuevo es requerido")]
    public EstadoTicket EstadoNuevo { get; set; }

    [StringLength(1000, ErrorMessage = "El comentario no puede exceder 1000 caracteres")]
    public string? Comentario { get; set; }

    public int? MinutosEnEstadoAnterior { get; set; }
}
