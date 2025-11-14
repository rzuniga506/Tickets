using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Notificaciones;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers
{
    /// <summary>
    /// Controlador de gestión de notificaciones
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class NotificacionesController : ControllerBase
    {
        private readonly INotificacionService _notificacionService;

        public NotificacionesController(INotificacionService notificacionService)
        {
            _notificacionService = notificacionService;
        }

        /// <summary>
        /// Obtiene todas las notificaciones del usuario autenticado
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse<PagedResult<NotificacionDto>>>> GetByUsuario(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 20,
            [FromQuery] bool? leida = null)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _notificacionService.GetByUsuarioAsync(usuarioId, pageNumber, pageSize, leida);

            return Ok(ApiResponse<PagedResult<NotificacionDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene una notificación por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<NotificacionDto>>> GetById(int id)
        {
            var result = await _notificacionService.GetByIdAsync(id);
            return Ok(ApiResponse<NotificacionDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Crea una nueva notificación
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<NotificacionDto>>> Create(
            [FromBody] NotificacionCreateDto createDto)
        {
            var result = await _notificacionService.CreateAsync(createDto);

            return CreatedAtAction(
                nameof(GetById),
                new { id = result.Id },
                ApiResponse<NotificacionDto>.SuccessResponse(result, "Notificación creada exitosamente"));
        }

        /// <summary>
        /// Marca una notificación como leída
        /// </summary>
        [HttpPatch("{id}/marcar-leida")]
        public async Task<ActionResult<ApiResponse<bool>>> MarcarComoLeida(int id)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _notificacionService.MarcarComoLeidaAsync(id, usuarioId);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Notificación marcada como leída"));
        }

        /// <summary>
        /// Marca todas las notificaciones del usuario como leídas
        /// </summary>
        [HttpPatch("marcar-todas-leidas")]
        public async Task<ActionResult<ApiResponse<bool>>> MarcarTodasComoLeidas()
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _notificacionService.MarcarTodasComoLeidasAsync(usuarioId);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Todas las notificaciones han sido marcadas como leídas"));
        }

        /// <summary>
        /// Elimina una notificación
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> Delete(int id)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _notificacionService.DeleteAsync(id, usuarioId);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Notificación eliminada exitosamente"));
        }

        /// <summary>
        /// Obtiene el conteo de notificaciones no leídas
        /// </summary>
        [HttpGet("no-leidas/count")]
        public async Task<ActionResult<ApiResponse<int>>> GetConteoNoLeidas()
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _notificacionService.GetConteoNoLeidasAsync(usuarioId);

            return Ok(ApiResponse<int>.SuccessResponse(result));
        }
    }
}
