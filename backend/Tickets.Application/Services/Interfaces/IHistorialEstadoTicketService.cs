using Tickets.Application.DTOs.HistorialEstadoTicket;

namespace Tickets.Application.Services.Interfaces;

/// <summary>
/// Servicio para gestión del Historial de Estados de Tickets
/// </summary>
public interface IHistorialEstadoTicketService
{
    /// <summary>
    /// Obtener historial de un ticket específico
    /// </summary>
    Task<IEnumerable<HistorialEstadoTicketDto>> GetByTicketIdAsync(int ticketId);

    /// <summary>
    /// Obtener un registro de historial por ID
    /// </summary>
    Task<HistorialEstadoTicketDto> GetByIdAsync(int id);

    /// <summary>
    /// Crear un nuevo registro de historial
    /// </summary>
    Task<HistorialEstadoTicketDto> CreateAsync(CreateHistorialEstadoTicketDto dto, int usuarioId);

    /// <summary>
    /// Obtener estadísticas de cambios de estado de un ticket
    /// </summary>
    Task<Dictionary<string, int>> GetEstadisticasCambiosPorTicketAsync(int ticketId);

    /// <summary>
    /// Obtener tiempo promedio en cada estado para un ticket
    /// </summary>
    Task<Dictionary<string, double>> GetTiempoPromedioEstadosAsync(int ticketId);
}
