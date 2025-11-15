using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.HistorialEstadoTicket;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers;

/// <summary>
/// Controlador para gestión del Historial de Estados de Tickets
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class HistorialEstadosTicketController : ControllerBase
{
    private readonly IHistorialEstadoTicketService _historialService;

    public HistorialEstadosTicketController(IHistorialEstadoTicketService historialService)
    {
        _historialService = historialService;
    }

    /// <summary>
    /// Obtener historial de un ticket específico
    /// </summary>
    [HttpGet("ticket/{ticketId}")]
    public async Task<ActionResult<ApiResponse<IEnumerable<HistorialEstadoTicketDto>>>> GetByTicketId(int ticketId)
    {
        try
        {
            var historial = await _historialService.GetByTicketIdAsync(ticketId);
            return Ok(ApiResponse<IEnumerable<HistorialEstadoTicketDto>>.SuccessResponse(historial));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<HistorialEstadoTicketDto>>.ErrorResponse(
                $"Error al obtener historial del ticket: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener un registro de historial por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<HistorialEstadoTicketDto>>> GetById(int id)
    {
        try
        {
            var historial = await _historialService.GetByIdAsync(id);
            return Ok(ApiResponse<HistorialEstadoTicketDto>.SuccessResponse(historial));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<HistorialEstadoTicketDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<HistorialEstadoTicketDto>.ErrorResponse(
                $"Error al obtener registro de historial: {ex.Message}"));
        }
    }

    /// <summary>
    /// Crear un nuevo registro de historial
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ApiResponse<HistorialEstadoTicketDto>>> Create(
        [FromBody] CreateHistorialEstadoTicketDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<HistorialEstadoTicketDto>.ErrorResponse(
                    "Datos inválidos", null, ModelState));
            }

            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var historial = await _historialService.CreateAsync(dto, usuarioId);

            return CreatedAtAction(
                nameof(GetById),
                new { id = historial.Id },
                ApiResponse<HistorialEstadoTicketDto>.SuccessResponse(
                    historial, "Registro de historial creado exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<HistorialEstadoTicketDto>.ErrorResponse(ex.Message));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<HistorialEstadoTicketDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<HistorialEstadoTicketDto>.ErrorResponse(
                $"Error al crear registro de historial: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener estadísticas de cambios de estado de un ticket
    /// </summary>
    [HttpGet("ticket/{ticketId}/estadisticas")]
    public async Task<ActionResult<ApiResponse<Dictionary<string, int>>>> GetEstadisticas(int ticketId)
    {
        try
        {
            var estadisticas = await _historialService.GetEstadisticasCambiosPorTicketAsync(ticketId);
            return Ok(ApiResponse<Dictionary<string, int>>.SuccessResponse(estadisticas));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<Dictionary<string, int>>.ErrorResponse(
                $"Error al obtener estadísticas: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener tiempo promedio en cada estado para un ticket
    /// </summary>
    [HttpGet("ticket/{ticketId}/tiempos-promedio")]
    public async Task<ActionResult<ApiResponse<Dictionary<string, double>>>> GetTiemposPromedio(int ticketId)
    {
        try
        {
            var tiempos = await _historialService.GetTiempoPromedioEstadosAsync(ticketId);
            return Ok(ApiResponse<Dictionary<string, double>>.SuccessResponse(tiempos));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<Dictionary<string, double>>.ErrorResponse(
                $"Error al obtener tiempos promedio: {ex.Message}"));
        }
    }
}
