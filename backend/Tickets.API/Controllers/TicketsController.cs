using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Tickets;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Enums;

namespace Tickets.API.Controllers
{
    /// <summary>
    /// Controlador de gestión de tickets de soporte
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class TicketsController : ControllerBase
    {
        private readonly ITicketService _ticketService;

        public TicketsController(ITicketService ticketService)
        {
            _ticketService = ticketService;
        }

        /// <summary>
        /// Obtiene todos los tickets con paginación y filtros
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse<PagedResult<TicketDto>>>> GetAll(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? searchTerm = null,
            [FromQuery] EstadoTicket? estado = null,
            [FromQuery] PrioridadTicket? prioridad = null,
            [FromQuery] int? solicitanteId = null,
            [FromQuery] int? tecnicoId = null,
            [FromQuery] bool? slaCumplido = null)
        {
            var result = await _ticketService.GetAllAsync(
                pageNumber, pageSize, searchTerm, estado, prioridad, solicitanteId, tecnicoId, slaCumplido);

            return Ok(ApiResponse<PagedResult<TicketDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene un ticket por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<TicketDto>>> GetById(int id)
        {
            var result = await _ticketService.GetByIdAsync(id);
            return Ok(ApiResponse<TicketDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene un ticket por número
        /// </summary>
        [HttpGet("numero/{numeroTicket}")]
        public async Task<ActionResult<ApiResponse<TicketDto>>> GetByNumero(string numeroTicket)
        {
            var result = await _ticketService.GetByNumeroAsync(numeroTicket);
            return Ok(ApiResponse<TicketDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Crea un nuevo ticket
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<TicketDto>>> Create([FromBody] TicketCreateDto createDto)
        {
            var solicitanteId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _ticketService.CreateAsync(createDto, solicitanteId);

            return CreatedAtAction(
                nameof(GetById),
                new { id = result.Id },
                ApiResponse<TicketDto>.SuccessResponse(result, "Ticket creado exitosamente"));
        }

        /// <summary>
        /// Actualiza un ticket existente
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<TicketDto>>> Update(
            int id,
            [FromBody] TicketUpdateDto updateDto)
        {
            var result = await _ticketService.UpdateAsync(id, updateDto);
            return Ok(ApiResponse<TicketDto>.SuccessResponse(result, "Ticket actualizado exitosamente"));
        }

        /// <summary>
        /// Elimina un ticket (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> Delete(int id)
        {
            var result = await _ticketService.DeleteAsync(id);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Ticket eliminado exitosamente"));
        }

        /// <summary>
        /// Asigna un técnico a un ticket
        /// </summary>
        [HttpPost("{id}/asignar")]
        public async Task<ActionResult<ApiResponse<bool>>> AsignarTecnico(
            int id,
            [FromBody] TicketAsignarDto asignarDto)
        {
            var result = await _ticketService.AsignarTecnicoAsync(id, asignarDto);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Técnico asignado exitosamente"));
        }

        /// <summary>
        /// Inicia el proceso de resolución de un ticket
        /// </summary>
        [HttpPost("{id}/iniciar-proceso")]
        public async Task<ActionResult<ApiResponse<bool>>> IniciarProceso(int id)
        {
            var tecnicoId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _ticketService.IniciarProcesoAsync(id, tecnicoId);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Proceso iniciado exitosamente"));
        }

        /// <summary>
        /// Resuelve un ticket
        /// </summary>
        [HttpPost("{id}/resolver")]
        public async Task<ActionResult<ApiResponse<bool>>> Resolver(
            int id,
            [FromBody] TicketResolverDto resolverDto)
        {
            var tecnicoId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _ticketService.ResolverAsync(id, resolverDto, tecnicoId);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Ticket resuelto exitosamente"));
        }

        /// <summary>
        /// Cierra un ticket
        /// </summary>
        [HttpPost("{id}/cerrar")]
        public async Task<ActionResult<ApiResponse<bool>>> Cerrar(int id)
        {
            var result = await _ticketService.CerrarAsync(id);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Ticket cerrado exitosamente"));
        }

        /// <summary>
        /// Reabre un ticket cerrado
        /// </summary>
        [HttpPost("{id}/reabrir")]
        public async Task<ActionResult<ApiResponse<bool>>> Reabrir(int id, [FromBody] string motivo)
        {
            var result = await _ticketService.ReabrirAsync(id, motivo);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Ticket reabierto exitosamente"));
        }

        /// <summary>
        /// Evalúa un ticket resuelto
        /// </summary>
        [HttpPost("{id}/evaluar")]
        public async Task<ActionResult<ApiResponse<bool>>> Evaluar(
            int id,
            [FromBody] TicketEvaluarDto evaluarDto)
        {
            var solicitanteId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _ticketService.EvaluarAsync(id, evaluarDto, solicitanteId);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Evaluación registrada exitosamente"));
        }

        /// <summary>
        /// Cambia la prioridad de un ticket
        /// </summary>
        [HttpPatch("{id}/cambiar-prioridad")]
        public async Task<ActionResult<ApiResponse<bool>>> CambiarPrioridad(
            int id,
            [FromBody] PrioridadTicket nuevaPrioridad)
        {
            var result = await _ticketService.CambiarPrioridadAsync(id, nuevaPrioridad);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Prioridad cambiada exitosamente"));
        }

        /// <summary>
        /// Obtiene mis tickets (como solicitante)
        /// </summary>
        [HttpGet("mis-tickets")]
        public async Task<ActionResult<ApiResponse<List<TicketDto>>>> GetMisTickets()
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _ticketService.GetMisTicketsAsync(usuarioId);

            return Ok(ApiResponse<List<TicketDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene tickets asignados al técnico autenticado
        /// </summary>
        [HttpGet("asignados")]
        public async Task<ActionResult<ApiResponse<List<TicketDto>>>> GetTicketsAsignados()
        {
            var tecnicoId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _ticketService.GetTicketsAsignadosAsync(tecnicoId);

            return Ok(ApiResponse<List<TicketDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene tickets pendientes de asignación
        /// </summary>
        [HttpGet("pendientes-asignacion")]
        public async Task<ActionResult<ApiResponse<List<TicketDto>>>> GetPendientesAsignacion()
        {
            var result = await _ticketService.GetPendientesAsignacionAsync();
            return Ok(ApiResponse<List<TicketDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene tickets con SLA próximo a vencer
        /// </summary>
        [HttpGet("sla-proximo-vencer")]
        public async Task<ActionResult<ApiResponse<List<TicketDto>>>> GetSLAProximoVencer(
            [FromQuery] int minutosRestantes = 60)
        {
            var result = await _ticketService.GetSLAProximoVencerAsync(minutosRestantes);
            return Ok(ApiResponse<List<TicketDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene estadísticas de tickets
        /// </summary>
        [HttpGet("estadisticas")]
        public async Task<ActionResult<ApiResponse<TicketEstadisticasDto>>> GetEstadisticas()
        {
            var result = await _ticketService.GetEstadisticasAsync();
            return Ok(ApiResponse<TicketEstadisticasDto>.SuccessResponse(result));
        }
    }
}
