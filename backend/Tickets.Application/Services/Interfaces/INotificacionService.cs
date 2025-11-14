using System.Collections.Generic;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Notificaciones;
using Tickets.Domain.Enums;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de gestión de notificaciones
    /// </summary>
    public interface INotificacionService
    {
        /// <summary>
        /// Obtiene todas las notificaciones de un usuario con paginación
        /// </summary>
        Task<PagedResult<NotificacionDto>> GetByUsuarioAsync(
            int usuarioId,
            int pageNumber = 1,
            int pageSize = 20,
            bool? leida = null);

        /// <summary>
        /// Obtiene una notificación por ID
        /// </summary>
        Task<NotificacionDto> GetByIdAsync(int id);

        /// <summary>
        /// Crea una nueva notificación
        /// </summary>
        Task<NotificacionDto> CreateAsync(NotificacionCreateDto createDto);

        /// <summary>
        /// Marca una notificación como leída
        /// </summary>
        Task<bool> MarcarComoLeidaAsync(int id, int usuarioId);

        /// <summary>
        /// Marca todas las notificaciones de un usuario como leídas
        /// </summary>
        Task<bool> MarcarTodasComoLeidasAsync(int usuarioId);

        /// <summary>
        /// Elimina una notificación
        /// </summary>
        Task<bool> DeleteAsync(int id, int usuarioId);

        /// <summary>
        /// Obtiene el conteo de notificaciones no leídas de un usuario
        /// </summary>
        Task<int> GetConteoNoLeidasAsync(int usuarioId);

        /// <summary>
        /// Envía notificación de nuevo ticket a administradores
        /// </summary>
        Task NotificarNuevoTicketAsync(int ticketId);

        /// <summary>
        /// Envía notificación de ticket asignado al técnico
        /// </summary>
        Task NotificarTicketAsignadoAsync(int ticketId, int tecnicoId);

        /// <summary>
        /// Envía notificación de ticket en proceso al solicitante
        /// </summary>
        Task NotificarTicketEnProcesoAsync(int ticketId);

        /// <summary>
        /// Envía notificación de ticket resuelto al solicitante
        /// </summary>
        Task NotificarTicketResueltoAsync(int ticketId);

        /// <summary>
        /// Envía notificación de ticket reabierto al técnico
        /// </summary>
        Task NotificarTicketReabiertoAsync(int ticketId, int tecnicoId);

        /// <summary>
        /// Envía notificación de SLA próximo a vencer
        /// </summary>
        Task NotificarSLAProximoVencerAsync(int ticketId, int tecnicoId);

        /// <summary>
        /// Envía notificación de equipo asignado al usuario
        /// </summary>
        Task NotificarEquipoAsignadoAsync(int equipoId, int usuarioId);
    }
}
