using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Tickets.API.Models;
using Tickets.Application.DTOs.CategoriaTicket;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers;

/// <summary>
/// Controlador para gestión de Categorías de Tickets
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CategoriasTicketController : ControllerBase
{
    private readonly ICategoriaTicketService _categoriaService;

    public CategoriasTicketController(ICategoriaTicketService categoriaService)
    {
        _categoriaService = categoriaService;
    }

    /// <summary>
    /// Obtener todas las categorías
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IEnumerable<CategoriaTicketDto>>>> GetAll()
    {
        try
        {
            var categorias = await _categoriaService.GetAllAsync();
            return Ok(ApiResponse<IEnumerable<CategoriaTicketDto>>.SuccessResponse(categorias));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<CategoriaTicketDto>>.ErrorResponse(
                $"Error al obtener categorías: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener categorías activas
    /// </summary>
    [HttpGet("activos")]
    public async Task<ActionResult<ApiResponse<IEnumerable<CategoriaTicketDto>>>> GetActivos()
    {
        try
        {
            var categorias = await _categoriaService.GetActivosAsync();
            return Ok(ApiResponse<IEnumerable<CategoriaTicketDto>>.SuccessResponse(categorias));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<CategoriaTicketDto>>.ErrorResponse(
                $"Error al obtener categorías activas: {ex.Message}"));
        }
    }

    /// <summary>
    /// Obtener categoría por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<CategoriaTicketDto>>> GetById(int id)
    {
        try
        {
            var categoria = await _categoriaService.GetByIdAsync(id);
            return Ok(ApiResponse<CategoriaTicketDto>.SuccessResponse(categoria));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<CategoriaTicketDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<CategoriaTicketDto>.ErrorResponse(
                $"Error al obtener categoría: {ex.Message}"));
        }
    }

    /// <summary>
    /// Crear nueva categoría
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ApiResponse<CategoriaTicketDto>>> Create(
        [FromBody] CreateCategoriaTicketDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<CategoriaTicketDto>.ErrorResponse(
                    "Datos inválidos", ModelState));
            }

            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var categoria = await _categoriaService.CreateAsync(dto, usuarioId);

            return CreatedAtAction(
                nameof(GetById),
                new { id = categoria.Id },
                ApiResponse<CategoriaTicketDto>.SuccessResponse(categoria, "Categoría creada exitosamente"));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<CategoriaTicketDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<CategoriaTicketDto>.ErrorResponse(
                $"Error al crear categoría: {ex.Message}"));
        }
    }

    /// <summary>
    /// Actualizar categoría
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<ApiResponse<CategoriaTicketDto>>> Update(
        int id,
        [FromBody] UpdateCategoriaTicketDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<CategoriaTicketDto>.ErrorResponse(
                    "Datos inválidos", ModelState));
            }

            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var categoria = await _categoriaService.UpdateAsync(id, dto, usuarioId);

            return Ok(ApiResponse<CategoriaTicketDto>.SuccessResponse(
                categoria, "Categoría actualizada exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<CategoriaTicketDto>.ErrorResponse(ex.Message));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<CategoriaTicketDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<CategoriaTicketDto>.ErrorResponse(
                $"Error al actualizar categoría: {ex.Message}"));
        }
    }

    /// <summary>
    /// Eliminar categoría
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<ActionResult<ApiResponse<object>>> Delete(int id)
    {
        try
        {
            await _categoriaService.DeleteAsync(id);
            return Ok(ApiResponse<object>.SuccessResponse(null, "Categoría eliminada exitosamente"));
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
                $"Error al eliminar categoría: {ex.Message}"));
        }
    }

    /// <summary>
    /// Activar/Desactivar categoría
    /// </summary>
    [HttpPatch("{id}/toggle-activo")]
    public async Task<ActionResult<ApiResponse<CategoriaTicketDto>>> ToggleActivo(int id)
    {
        try
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var categoria = await _categoriaService.ToggleActivoAsync(id, usuarioId);

            return Ok(ApiResponse<CategoriaTicketDto>.SuccessResponse(
                categoria, "Estado de categoría actualizado exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<CategoriaTicketDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<CategoriaTicketDto>.ErrorResponse(
                $"Error al cambiar estado de categoría: {ex.Message}"));
        }
    }

    /// <summary>
    /// Reordenar categorías
    /// </summary>
    [HttpPut("reorder")]
    public async Task<ActionResult<ApiResponse<object>>> Reorder(
        [FromBody] Dictionary<int, int> ordenPorId)
    {
        try
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            await _categoriaService.ReorderAsync(ordenPorId, usuarioId);

            return Ok(ApiResponse<object>.SuccessResponse(null, "Categorías reordenadas exitosamente"));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<object>.ErrorResponse(
                $"Error al reordenar categorías: {ex.Message}"));
        }
    }
}
