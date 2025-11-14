using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Adjuntos;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers
{
    /// <summary>
    /// Controlador de gestión de archivos adjuntos de tickets
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AdjuntosTicketController : ControllerBase
    {
        private readonly IAdjuntoTicketService _adjuntoService;

        public AdjuntosTicketController(IAdjuntoTicketService adjuntoService)
        {
            _adjuntoService = adjuntoService;
        }

        /// <summary>
        /// Obtiene todos los adjuntos de un ticket
        /// </summary>
        [HttpGet("ticket/{ticketId}")]
        public async Task<ActionResult<ApiResponse<List<AdjuntoTicketDto>>>> GetByTicketId(int ticketId)
        {
            var result = await _adjuntoService.GetByTicketIdAsync(ticketId);
            return Ok(ApiResponse<List<AdjuntoTicketDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene un adjunto por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<AdjuntoTicketDto>>> GetById(int id)
        {
            var result = await _adjuntoService.GetByIdAsync(id);
            return Ok(ApiResponse<AdjuntoTicketDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Sube un archivo adjunto a un ticket
        /// </summary>
        [HttpPost("upload")]
        public async Task<ActionResult<ApiResponse<AdjuntoTicketDto>>> Upload(
            [FromForm] IFormFile file,
            [FromForm] int ticketId)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _adjuntoService.UploadAsync(file, ticketId, usuarioId);

            return CreatedAtAction(
                nameof(GetById),
                new { id = result.Id },
                ApiResponse<AdjuntoTicketDto>.SuccessResponse(result, "Archivo subido exitosamente"));
        }

        /// <summary>
        /// Descarga un archivo adjunto
        /// </summary>
        [HttpGet("download/{id}")]
        public async Task<IActionResult> Download(int id)
        {
            var (contenido, nombreArchivo, tipoMime) = await _adjuntoService.DownloadAsync(id);
            return File(contenido, tipoMime, nombreArchivo);
        }

        /// <summary>
        /// Elimina un adjunto
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> Delete(int id)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            await _adjuntoService.DeleteAsync(id, usuarioId);

            return Ok(ApiResponse<object>.SuccessResponse(null, "Archivo eliminado exitosamente"));
        }
    }
}
