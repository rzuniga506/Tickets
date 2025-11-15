namespace Tickets.Application.DTOs.AsignacionTicket;

/// <summary>
/// DTO para Asignación de Ticket
/// </summary>
public class AsignacionTicketDto
{
    public int Id { get; set; }
    public int TicketId { get; set; }
    public string NumeroTicket { get; set; } = string.Empty;
    public int? TecnicoAnteriorId { get; set; }
    public string? TecnicoAnteriorNombre { get; set; }
    public int TecnicoNuevoId { get; set; }
    public string TecnicoNuevoNombre { get; set; } = string.Empty;
    public string? Motivo { get; set; }
    public bool EsAsignacionAutomatica { get; set; }
    public int? MinutosConTecnicoAnterior { get; set; }
    public int AsignadoPorId { get; set; }
    public string AsignadoPorNombre { get; set; } = string.Empty;
    public DateTime FechaCreacion { get; set; }
    public bool EsPrimeraAsignacion { get; set; }
    public bool EsReasignacion { get; set; }
}
