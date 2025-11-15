using Tickets.Application.DTOs.AsignacionTicket;

namespace Tickets.Application.Services.Interfaces;

/// <summary>
/// Servicio para gestión de Asignaciones de Tickets
/// </summary>
public interface IAsignacionTicketService
{
    /// <summary>
    /// Obtener historial de asignaciones de un ticket específico
    /// </summary>
    Task<IEnumerable<AsignacionTicketDto>> GetByTicketIdAsync(int ticketId);

    /// <summary>
    /// Obtener asignación por ID
    /// </summary>
    Task<AsignacionTicketDto> GetByIdAsync(int id);

    /// <summary>
    /// Crear una nueva asignación
    /// </summary>
    Task<AsignacionTicketDto> CreateAsync(CreateAsignacionTicketDto dto, int asignadoPorId);

    /// <summary>
    /// Obtener estadísticas de asignaciones por técnico
    /// </summary>
    Task<Dictionary<string, int>> GetEstadisticasAsignacionesPorTecnicoAsync();

    /// <summary>
    /// Obtener carga de trabajo actual por técnico (tickets asignados activos)
    /// </summary>
    Task<Dictionary<string, int>> GetCargaActualPorTecnicoAsync();

    /// <summary>
    /// Obtener tiempo promedio de asignación por técnico
    /// </summary>
    Task<Dictionary<string, double>> GetTiempoPromedioAsignacionPorTecnicoAsync();
}
