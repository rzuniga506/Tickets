using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Tickets.API.Models;
using Tickets.Application.DTOs.AsignacionTicket;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers;

/// <summary>
/// Controlador para gestión de Asignaciones de Tickets
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AsignacionesTicketController : ControllerBase
{
    private readonly IAsignacionTicketService _asignacionService;

    public AsignacionesTicketController(IAsignacionTicketService asignacionService)
    {
        _asignacionService = asignacionService;
    }

    /// <summary>
    /// Obtener historial de asignaciones de un ticket específico
    /// </summary>
    [HttpGet("ticket/{ticketId}")]
    public async Task<ActionResult<ApiResponse<IEnumerable<AsignacionTicketDto>>>> GetByTicketId(int ticketId)
    {
        try
        {
            var asignaciones = await _asignacionService.GetByTicketIdAsync(ticketId);
            return Ok(ApiResponse<IEnumerable<AsignacionTicketDto>>.SuccessResponse(asignaciones));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<AsignacionTicketDto>>.ErrorResponse(
                $"Error al obtener historial de asignaciones: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener asignación por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<AsignacionTicketDto>>> GetById(int id)
    {
        try
        {
            var asignacion = await _asignacionService.GetByIdAsync(id);
            return Ok(ApiResponse<AsignacionTicketDto>.SuccessResponse(asignacion));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<AsignacionTicketDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<AsignacionTicketDto>.ErrorResponse(
                $"Error al obtener asignación: {ex.Message}"));
        }
    }

    /// <summary>
    /// Crear una nueva asignación
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ApiResponse<AsignacionTicketDto>>> Create(
        [FromBody] CreateAsignacionTicketDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<AsignacionTicketDto>.ErrorResponse(
                    "Datos inválidos", ModelState));
            }

            var asignadoPorId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var asignacion = await _asignacionService.CreateAsync(dto, asignadoPorId);

            return CreatedAtAction(
                nameof(GetById),
                new { id = asignacion.Id },
                ApiResponse<AsignacionTicketDto>.SuccessResponse(
                    asignacion, "Asignación creada exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<AsignacionTicketDto>.ErrorResponse(ex.Message));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<AsignacionTicketDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<AsignacionTicketDto>.ErrorResponse(
                $"Error al crear asignación: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener estadísticas de asignaciones por técnico
    /// </summary>
    [HttpGet("estadisticas/por-tecnico")]
    public async Task<ActionResult<ApiResponse<Dictionary<string, int>>>> GetEstadisticasPorTecnico()
    {
        try
        {
            var estadisticas = await _asignacionService.GetEstadisticasAsignacionesPorTecnicoAsync();
            return Ok(ApiResponse<Dictionary<string, int>>.SuccessResponse(estadisticas));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<Dictionary<string, int>>.ErrorResponse(
                $"Error al obtener estadísticas: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener carga de trabajo actual por técnico
    /// </summary>
    [HttpGet("carga-actual")]
    public async Task<ActionResult<ApiResponse<Dictionary<string, int>>>> GetCargaActual()
    {
        try
        {
            var cargaTrabajo = await _asignacionService.GetCargaActualPorTecnicoAsync();
            return Ok(ApiResponse<Dictionary<string, int>>.SuccessResponse(cargaTrabajo));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<Dictionary<string, int>>.ErrorResponse(
                $"Error al obtener carga de trabajo: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener tiempo promedio de asignación por técnico
    /// </summary>
    [HttpGet("tiempos-promedio")]
    public async Task<ActionResult<ApiResponse<Dictionary<string, double>>>> GetTiemposPromedio()
    {
        try
        {
            var tiempos = await _asignacionService.GetTiempoPromedioAsignacionPorTecnicoAsync();
            return Ok(ApiResponse<Dictionary<string, double>>.SuccessResponse(tiempos));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<Dictionary<string, double>>.ErrorResponse(
                $"Error al obtener tiempos promedio: {ex.Message}"));
        }
    }
}
