using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Departamento;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers;

/// <summary>
/// Controlador para gestión de Departamentos
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DepartamentosController : ControllerBase
{
    private readonly IDepartamentoService _departamentoService;

    public DepartamentosController(IDepartamentoService departamentoService)
    {
        _departamentoService = departamentoService;
    }

    /// <summary>
    /// Obtener todos los departamentos
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IEnumerable<DepartamentoDto>>>> GetAll()
    {
        try
        {
            var departamentos = await _departamentoService.GetAllAsync();
            return Ok(ApiResponse<IEnumerable<DepartamentoDto>>.SuccessResponse(departamentos));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<DepartamentoDto>>.ErrorResponse(
                $"Error al obtener departamentos: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener departamentos activos
    /// </summary>
    [HttpGet("activos")]
    public async Task<ActionResult<ApiResponse<IEnumerable<DepartamentoDto>>>> GetActivos()
    {
        try
        {
            var departamentos = await _departamentoService.GetActivosAsync();
            return Ok(ApiResponse<IEnumerable<DepartamentoDto>>.SuccessResponse(departamentos));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<DepartamentoDto>>.ErrorResponse(
                $"Error al obtener departamentos activos: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener departamento por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<DepartamentoDto>>> GetById(int id)
    {
        try
        {
            var departamento = await _departamentoService.GetByIdAsync(id);
            return Ok(ApiResponse<DepartamentoDto>.SuccessResponse(departamento));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<DepartamentoDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<DepartamentoDto>.ErrorResponse(
                $"Error al obtener departamento: {ex.Message}"));
        }
    }

    /// <summary>
    /// Crear nuevo departamento
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ApiResponse<DepartamentoDto>>> Create(
        [FromBody] CreateDepartamentoDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<DepartamentoDto>.ErrorResponse(
                    "Datos inválidos", null, ModelState));
            }

            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var departamento = await _departamentoService.CreateAsync(dto, usuarioId);

            return CreatedAtAction(
                nameof(GetById),
                new { id = departamento.Id },
                ApiResponse<DepartamentoDto>.SuccessResponse(departamento, "Departamento creado exitosamente"));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<DepartamentoDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<DepartamentoDto>.ErrorResponse(
                $"Error al crear departamento: {ex.Message}"));
        }
    }

    /// <summary>
    /// Actualizar departamento
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<ApiResponse<DepartamentoDto>>> Update(
        int id,
        [FromBody] UpdateDepartamentoDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<DepartamentoDto>.ErrorResponse(
                    "Datos inválidos", null, ModelState));
            }

            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var departamento = await _departamentoService.UpdateAsync(id, dto, usuarioId);

            return Ok(ApiResponse<DepartamentoDto>.SuccessResponse(
                departamento, "Departamento actualizado exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<DepartamentoDto>.ErrorResponse(ex.Message));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<DepartamentoDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<DepartamentoDto>.ErrorResponse(
                $"Error al actualizar departamento: {ex.Message}"));
        }
    }

    /// <summary>
    /// Eliminar departamento
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<ActionResult<ApiResponse<object>>> Delete(int id)
    {
        try
        {
            await _departamentoService.DeleteAsync(id);
            return Ok(ApiResponse<object>.SuccessResponse(null, "Departamento eliminado exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<object>.ErrorResponse(ex.Message));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<object>.ErrorResponse(
                $"Error al eliminar departamento: {ex.Message}"));
        }
    }

    /// <summary>
    /// Activar/Desactivar departamento
    /// </summary>
    [HttpPatch("{id}/toggle-activo")]
    public async Task<ActionResult<ApiResponse<DepartamentoDto>>> ToggleActivo(int id)
    {
        try
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var departamento = await _departamentoService.ToggleActivoAsync(id, usuarioId);

            return Ok(ApiResponse<DepartamentoDto>.SuccessResponse(
                departamento, "Estado de departamento actualizado exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<DepartamentoDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<DepartamentoDto>.ErrorResponse(
                $"Error al cambiar estado de departamento: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener estadísticas del departamento
    /// </summary>
    [HttpGet("{id}/estadisticas")]
    public async Task<ActionResult<ApiResponse<Dictionary<string, int>>>> GetEstadisticas(int id)
    {
        try
        {
            var estadisticas = await _departamentoService.GetEstadisticasAsync(id);
            return Ok(ApiResponse<Dictionary<string, int>>.SuccessResponse(estadisticas));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<Dictionary<string, int>>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<Dictionary<string, int>>.ErrorResponse(
                $"Error al obtener estadísticas: {ex.Message}"));
        }
    }
}
