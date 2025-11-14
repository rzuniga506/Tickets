using System.Collections.Generic;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Usuarios;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de gestión de usuarios
    /// </summary>
    public interface IUsuarioService
    {
        /// <summary>
        /// Obtiene todos los usuarios con paginación
        /// </summary>
        Task<PagedResult<UsuarioDto>> GetAllAsync(int pageNumber = 1, int pageSize = 10, string? searchTerm = null, bool? activo = null);

        /// <summary>
        /// Obtiene un usuario por ID
        /// </summary>
        Task<UsuarioDto> GetByIdAsync(int id);

        /// <summary>
        /// Crea un nuevo usuario
        /// </summary>
        Task<UsuarioDto> CreateAsync(UsuarioCreateDto createDto, string createdBy);

        /// <summary>
        /// Actualiza un usuario existente
        /// </summary>
        Task<UsuarioDto> UpdateAsync(int id, UsuarioUpdateDto updateDto, string modifiedBy);

        /// <summary>
        /// Elimina (soft delete) un usuario
        /// </summary>
        Task<bool> DeleteAsync(int id);

        /// <summary>
        /// Activa o desactiva un usuario
        /// </summary>
        Task<bool> ToggleActivoAsync(int id);

        /// <summary>
        /// Asigna roles a un usuario
        /// </summary>
        Task<bool> AsignarRolesAsync(int usuarioId, List<int> rolesIds);

        /// <summary>
        /// Obtiene usuarios por departamento
        /// </summary>
        Task<List<UsuarioDto>> GetByDepartamentoAsync(int departamentoId);

        /// <summary>
        /// Obtiene usuarios por rol
        /// </summary>
        Task<List<UsuarioDto>> GetByRolAsync(int rolId);

        /// <summary>
        /// Obtiene técnicos activos (para asignación de tickets)
        /// </summary>
        Task<List<UsuarioDto>> GetTecnicosActivosAsync();
    }
}
