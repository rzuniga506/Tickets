using Tickets.Application.DTOs.Rol;

namespace Tickets.Application.Services.Interfaces;

public interface IRolService
{
    Task<IEnumerable<RolDto>> GetAllAsync();
    Task<RolDto> GetByIdAsync(int id);
    Task<RolDto> CreateAsync(CreateRolDto dto, int usuarioId);
    Task<RolDto> UpdateAsync(int id, UpdateRolDto dto, int usuarioId);
    Task DeleteAsync(int id);
    Task<RolDto> AsignarPermisosAsync(int rolId, List<int> permisosIds, int usuarioId);
}
