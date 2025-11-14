using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.Threading.Tasks;
using Tickets.Application.DTOs.Adjuntos;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de gestión de adjuntos de tickets
    /// </summary>
    public interface IAdjuntoTicketService
    {
        /// <summary>
        /// Obtener todos los adjuntos de un ticket
        /// </summary>
        Task<List<AdjuntoTicketDto>> GetByTicketIdAsync(int ticketId);

        /// <summary>
        /// Obtener un adjunto por ID
        /// </summary>
        Task<AdjuntoTicketDto> GetByIdAsync(int id);

        /// <summary>
        /// Subir un archivo adjunto
        /// </summary>
        Task<AdjuntoTicketDto> UploadAsync(IFormFile file, int ticketId, int usuarioId);

        /// <summary>
        /// Descargar un adjunto
        /// </summary>
        Task<(byte[] contenido, string nombreArchivo, string tipoMime)> DownloadAsync(int id);

        /// <summary>
        /// Eliminar un adjunto
        /// </summary>
        Task DeleteAsync(int id, int usuarioId);
    }
}
