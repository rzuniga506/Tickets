using Tickets.Application.DTOs.CategoriaTicket;

namespace Tickets.Application.Services.Interfaces;

/// <summary>
/// Servicio para gestión de Categorías de Tickets
/// </summary>
public interface ICategoriaTicketService
{
    /// <summary>
    /// Obtener todas las categorías
    /// </summary>
    Task<IEnumerable<CategoriaTicketDto>> GetAllAsync();

    /// <summary>
    /// Obtener todas las categorías activas
    /// </summary>
    Task<IEnumerable<CategoriaTicketDto>> GetActivosAsync();

    /// <summary>
    /// Obtener categoría por ID
    /// </summary>
    Task<CategoriaTicketDto> GetByIdAsync(int id);

    /// <summary>
    /// Crear nueva categoría
    /// </summary>
    Task<CategoriaTicketDto> CreateAsync(CreateCategoriaTicketDto dto, int usuarioId);

    /// <summary>
    /// Actualizar categoría
    /// </summary>
    Task<CategoriaTicketDto> UpdateAsync(int id, UpdateCategoriaTicketDto dto, int usuarioId);

    /// <summary>
    /// Eliminar categoría (soft delete)
    /// </summary>
    Task DeleteAsync(int id);

    /// <summary>
    /// Activar/Desactivar categoría
    /// </summary>
    Task<CategoriaTicketDto> ToggleActivoAsync(int id, int usuarioId);

    /// <summary>
    /// Reordenar categorías
    /// </summary>
    Task ReorderAsync(Dictionary<int, int> ordenPorId, int usuarioId);
}
