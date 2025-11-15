using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Rol;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class RolesController : ControllerBase
{
    private readonly IRolService _rolService;

    public RolesController(IRolService rolService)
    {
        _rolService = rolService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<IEnumerable<RolDto>>>> GetAll()
    {
        try
        {
            var roles = await _rolService.GetAllAsync();
            return Ok(ApiResponse<IEnumerable<RolDto>>.SuccessResponse(roles));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<RolDto>>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<RolDto>>> GetById(int id)
    {
        try
        {
            var rol = await _rolService.GetByIdAsync(id);
            return Ok(ApiResponse<RolDto>.SuccessResponse(rol));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<RolDto>>> Create([FromBody] CreateRolDto dto)
    {
        try
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var rol = await _rolService.CreateAsync(dto, usuarioId);
            return CreatedAtAction(nameof(GetById), new { id = rol.Id },
                ApiResponse<RolDto>.SuccessResponse(rol, "Rol creado exitosamente"));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<ApiResponse<RolDto>>> Update(int id, [FromBody] UpdateRolDto dto)
    {
        try
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var rol = await _rolService.UpdateAsync(id, dto, usuarioId);
            return Ok(ApiResponse<RolDto>.SuccessResponse(rol, "Rol actualizado exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<ApiResponse<object>>> Delete(int id)
    {
        try
        {
            await _rolService.DeleteAsync(id);
            return Ok(ApiResponse<object>.SuccessResponse(null, "Rol eliminado exitosamente"));
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
            return StatusCode(500, ApiResponse<object>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("{id}/permisos")]
    public async Task<ActionResult<ApiResponse<RolDto>>> AsignarPermisos(int id, [FromBody] List<int> permisosIds)
    {
        try
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var rol = await _rolService.AsignarPermisosAsync(id, permisosIds, usuarioId);
            return Ok(ApiResponse<RolDto>.SuccessResponse(rol, "Permisos asignados exitosamente"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<RolDto>.ErrorResponse(ex.Message));
        }
    }
}
