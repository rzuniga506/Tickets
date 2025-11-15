using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.AsignacionTicket;

/// <summary>
/// DTO para crear una nueva Asignación de Ticket
/// </summary>
public class CreateAsignacionTicketDto
{
    [Required(ErrorMessage = "El ID del ticket es requerido")]
    public int TicketId { get; set; }

    public int? TecnicoAnteriorId { get; set; }

    [Required(ErrorMessage = "El ID del técnico nuevo es requerido")]
    public int TecnicoNuevoId { get; set; }

    [StringLength(500, ErrorMessage = "El motivo no puede exceder 500 caracteres")]
    public string? Motivo { get; set; }

    public bool EsAsignacionAutomatica { get; set; } = false;

    public int? MinutosConTecnicoAnterior { get; set; }
}
