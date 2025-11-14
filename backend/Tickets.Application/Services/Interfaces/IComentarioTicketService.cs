using System.Collections.Generic;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Comentarios;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de gestión de comentarios de tickets
    /// </summary>
    public interface IComentarioTicketService
    {
        /// <summary>
        /// Obtener todos los comentarios de un ticket
        /// </summary>
        Task<PagedResult<ComentarioTicketDto>> GetByTicketIdAsync(int ticketId, int pageNumber = 1, int pageSize = 50);

        /// <summary>
        /// Obtener un comentario por ID
        /// </summary>
        Task<ComentarioTicketDto> GetByIdAsync(int id);

        /// <summary>
        /// Crear un nuevo comentario
        /// </summary>
        Task<ComentarioTicketDto> CreateAsync(ComentarioTicketCreateDto createDto, int usuarioId);

        /// <summary>
        /// Actualizar un comentario existente
        /// </summary>
        Task<ComentarioTicketDto> UpdateAsync(int id, ComentarioTicketUpdateDto updateDto, int usuarioId);

        /// <summary>
        /// Eliminar un comentario
        /// </summary>
        Task DeleteAsync(int id, int usuarioId);

        /// <summary>
        /// Crear un comentario del sistema (automático)
        /// </summary>
        Task<ComentarioTicketDto> CreateSistemaCommentAsync(int ticketId, string contenido);
    }
}
