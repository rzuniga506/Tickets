using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Comentarios;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers
{
    /// <summary>
    /// Controlador de gestión de comentarios de tickets
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ComentariosTicketController : ControllerBase
    {
        private readonly IComentarioTicketService _comentarioService;

        public ComentariosTicketController(IComentarioTicketService comentarioService)
        {
            _comentarioService = comentarioService;
        }

        /// <summary>
        /// Obtiene todos los comentarios de un ticket
        /// </summary>
        [HttpGet("ticket/{ticketId}")]
        public async Task<ActionResult<ApiResponse<PagedResult<ComentarioTicketDto>>>> GetByTicketId(
            int ticketId,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 50)
        {
            var result = await _comentarioService.GetByTicketIdAsync(ticketId, pageNumber, pageSize);
            return Ok(ApiResponse<PagedResult<ComentarioTicketDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene un comentario por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<ComentarioTicketDto>>> GetById(int id)
        {
            var result = await _comentarioService.GetByIdAsync(id);
            return Ok(ApiResponse<ComentarioTicketDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Crea un nuevo comentario
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<ComentarioTicketDto>>> Create(
            [FromBody] ComentarioTicketCreateDto createDto)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _comentarioService.CreateAsync(createDto, usuarioId);

            return CreatedAtAction(
                nameof(GetById),
                new { id = result.Id },
                ApiResponse<ComentarioTicketDto>.SuccessResponse(result, "Comentario creado exitosamente"));
        }

        /// <summary>
        /// Actualiza un comentario existente
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<ComentarioTicketDto>>> Update(
            int id,
            [FromBody] ComentarioTicketUpdateDto updateDto)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _comentarioService.UpdateAsync(id, updateDto, usuarioId);

            return Ok(ApiResponse<ComentarioTicketDto>.SuccessResponse(result, "Comentario actualizado exitosamente"));
        }

        /// <summary>
        /// Elimina un comentario
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> Delete(int id)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            await _comentarioService.DeleteAsync(id, usuarioId);

            return Ok(ApiResponse<object>.SuccessResponse(null, "Comentario eliminado exitosamente"));
        }
    }
}
