using System.Collections.Generic;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Equipos;
using Tickets.Domain.Enums;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de gestión de equipos
    /// </summary>
    public interface IEquipoService
    {
        /// <summary>
        /// Obtiene todos los equipos con paginación y filtros
        /// </summary>
        Task<PagedResult<EquipoDto>> GetAllAsync(
            int pageNumber = 1,
            int pageSize = 10,
            string? searchTerm = null,
            EstadoEquipo? estado = null,
            CondicionEquipo? condicion = null,
            int? usuarioAsignadoId = null,
            int? departamentoId = null);

        /// <summary>
        /// Obtiene un equipo por ID
        /// </summary>
        Task<EquipoDto> GetByIdAsync(int id);

        /// <summary>
        /// Obtiene un equipo por código interno
        /// </summary>
        Task<EquipoDto> GetByCodigoInternoAsync(string codigoInterno);

        /// <summary>
        /// Obtiene un equipo por código QR
        /// </summary>
        Task<EquipoDto> GetByCodigoQRAsync(string codigoQR);

        /// <summary>
        /// Crea un nuevo equipo
        /// </summary>
        Task<EquipoDto> CreateAsync(EquipoCreateDto createDto, string createdBy);

        /// <summary>
        /// Actualiza un equipo existente
        /// </summary>
        Task<EquipoDto> UpdateAsync(int id, EquipoUpdateDto updateDto, string modifiedBy);

        /// <summary>
        /// Elimina (soft delete) un equipo
        /// </summary>
        Task<bool> DeleteAsync(int id);

        /// <summary>
        /// Asigna un equipo a un usuario
        /// </summary>
        Task<bool> AsignarUsuarioAsync(int equipoId, int usuarioId, string modifiedBy);

        /// <summary>
        /// Desasigna un equipo de un usuario
        /// </summary>
        Task<bool> DesasignarUsuarioAsync(int equipoId, string modifiedBy);

        /// <summary>
        /// Genera un código QR único para un equipo
        /// </summary>
        Task<string> GenerarCodigoQRAsync(int equipoId);

        /// <summary>
        /// Obtiene equipos disponibles (no asignados)
        /// </summary>
        Task<List<EquipoDto>> GetDisponiblesAsync();

        /// <summary>
        /// Obtiene equipos asignados a un usuario
        /// </summary>
        Task<List<EquipoDto>> GetByUsuarioAsync(int usuarioId);

        /// <summary>
        /// Obtiene equipos por departamento
        /// </summary>
        Task<List<EquipoDto>> GetByDepartamentoAsync(int departamentoId);

        /// <summary>
        /// Obtiene equipos con garantía próxima a vencer (dentro de N días)
        /// </summary>
        Task<List<EquipoDto>> GetGarantiaProximaVencerAsync(int dias = 30);

        /// <summary>
        /// Cambia el estado de un equipo
        /// </summary>
        Task<bool> CambiarEstadoAsync(int equipoId, EstadoEquipo nuevoEstado, string modifiedBy);
    }
}
