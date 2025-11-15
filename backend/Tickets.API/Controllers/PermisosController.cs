using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Permisos;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PermisosController : ControllerBase
{
    private readonly IPermisoService _permisoService;

    public PermisosController(IPermisoService permisoService)
    {
        _permisoService = permisoService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<IEnumerable<PermisoDto>>>> GetAll()
    {
        try
        {
            var permisos = await _permisoService.GetAllAsync();
            return Ok(ApiResponse<IEnumerable<PermisoDto>>.SuccessResponse(permisos));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<PermisoDto>>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("modulo/{modulo}")]
    public async Task<ActionResult<ApiResponse<IEnumerable<PermisoDto>>>> GetByModulo(string modulo)
    {
        try
        {
            var permisos = await _permisoService.GetByModuloAsync(modulo);
            return Ok(ApiResponse<IEnumerable<PermisoDto>>.SuccessResponse(permisos));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<IEnumerable<PermisoDto>>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ApiResponse<PermisoDto>>> GetById(int id)
    {
        try
        {
            var permiso = await _permisoService.GetByIdAsync(id);
            return Ok(ApiResponse<PermisoDto>.SuccessResponse(permiso));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse<PermisoDto>.ErrorResponse(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse<PermisoDto>.ErrorResponse(ex.Message));
        }
    }
}
