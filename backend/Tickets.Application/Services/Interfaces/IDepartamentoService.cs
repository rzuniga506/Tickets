using Tickets.Application.DTOs.Departamento;

namespace Tickets.Application.Services.Interfaces;

/// <summary>
/// Servicio para gestión de Departamentos
/// </summary>
public interface IDepartamentoService
{
    /// <summary>
    /// Obtener todos los departamentos
    /// </summary>
    Task<IEnumerable<DepartamentoDto>> GetAllAsync();

    /// <summary>
    /// Obtener departamentos activos
    /// </summary>
    Task<IEnumerable<DepartamentoDto>> GetActivosAsync();

    /// <summary>
    /// Obtener departamento por ID
    /// </summary>
    Task<DepartamentoDto> GetByIdAsync(int id);

    /// <summary>
    /// Crear nuevo departamento
    /// </summary>
    Task<DepartamentoDto> CreateAsync(CreateDepartamentoDto dto, int usuarioId);

    /// <summary>
    /// Actualizar departamento
    /// </summary>
    Task<DepartamentoDto> UpdateAsync(int id, UpdateDepartamentoDto dto, int usuarioId);

    /// <summary>
    /// Eliminar departamento (soft delete)
    /// </summary>
    Task DeleteAsync(int id);

    /// <summary>
    /// Activar/Desactivar departamento
    /// </summary>
    Task<DepartamentoDto> ToggleActivoAsync(int id, int usuarioId);

    /// <summary>
    /// Obtener estadísticas del departamento
    /// </summary>
    Task<Dictionary<string, int>> GetEstadisticasAsync(int id);
}
