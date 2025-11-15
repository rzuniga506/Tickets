using Tickets.Application.DTOs.Permisos;

namespace Tickets.Application.Services.Interfaces;

public interface IPermisoService
{
    /// <summary>
    /// Obtener todos los permisos
    /// </summary>
    Task<IEnumerable<PermisoDto>> GetAllAsync();

    /// <summary>
    /// Obtener permisos por módulo
    /// </summary>
    Task<IEnumerable<PermisoDto>> GetByModuloAsync(string modulo);

    /// <summary>
    /// Obtener permiso por ID
    /// </summary>
    Task<PermisoDto> GetByIdAsync(int id);
}
