using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Usuarios;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers
{
    /// <summary>
    /// Controlador de gestión de usuarios
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsuariosController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;

        public UsuariosController(IUsuarioService usuarioService)
        {
            _usuarioService = usuarioService;
        }

        /// <summary>
        /// Obtiene todos los usuarios con paginación
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse<PagedResult<UsuarioDto>>>> GetAll(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? searchTerm = null,
            [FromQuery] bool? activo = null)
        {
            var result = await _usuarioService.GetAllAsync(pageNumber, pageSize, searchTerm, activo);
            return Ok(ApiResponse<PagedResult<UsuarioDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene un usuario por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<UsuarioDto>>> GetById(int id)
        {
            var result = await _usuarioService.GetByIdAsync(id);
            return Ok(ApiResponse<UsuarioDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Crea un nuevo usuario
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<UsuarioDto>>> Create([FromBody] UsuarioCreateDto createDto)
        {
            var createdBy = User.FindFirst(ClaimTypes.Email)?.Value ?? "System";
            var result = await _usuarioService.CreateAsync(createDto, createdBy);

            return CreatedAtAction(
                nameof(GetById),
                new { id = result.Id },
                ApiResponse<UsuarioDto>.SuccessResponse(result, "Usuario creado exitosamente"));
        }

        /// <summary>
        /// Actualiza un usuario existente
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<UsuarioDto>>> Update(
            int id,
            [FromBody] UsuarioUpdateDto updateDto)
        {
            var modifiedBy = User.FindFirst(ClaimTypes.Email)?.Value ?? "System";
            var result = await _usuarioService.UpdateAsync(id, updateDto, modifiedBy);

            return Ok(ApiResponse<UsuarioDto>.SuccessResponse(result, "Usuario actualizado exitosamente"));
        }

        /// <summary>
        /// Elimina un usuario (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> Delete(int id)
        {
            var result = await _usuarioService.DeleteAsync(id);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Usuario eliminado exitosamente"));
        }

        /// <summary>
        /// Activa o desactiva un usuario
        /// </summary>
        [HttpPatch("{id}/toggle-activo")]
        public async Task<ActionResult<ApiResponse<bool>>> ToggleActivo(int id)
        {
            var result = await _usuarioService.ToggleActivoAsync(id);
            var mensaje = result ? "Usuario activado" : "Usuario desactivado";
            return Ok(ApiResponse<bool>.SuccessResponse(result, mensaje));
        }

        /// <summary>
        /// Asigna roles a un usuario
        /// </summary>
        [HttpPost("{id}/asignar-roles")]
        public async Task<ActionResult<ApiResponse<bool>>> AsignarRoles(
            int id,
            [FromBody] List<int> rolesIds)
        {
            var result = await _usuarioService.AsignarRolesAsync(id, rolesIds);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Roles asignados exitosamente"));
        }

        /// <summary>
        /// Obtiene usuarios por departamento
        /// </summary>
        [HttpGet("departamento/{departamentoId}")]
        public async Task<ActionResult<ApiResponse<List<UsuarioDto>>>> GetByDepartamento(int departamentoId)
        {
            var result = await _usuarioService.GetByDepartamentoAsync(departamentoId);
            return Ok(ApiResponse<List<UsuarioDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene usuarios por rol
        /// </summary>
        [HttpGet("rol/{rolId}")]
        public async Task<ActionResult<ApiResponse<List<UsuarioDto>>>> GetByRol(int rolId)
        {
            var result = await _usuarioService.GetByRolAsync(rolId);
            return Ok(ApiResponse<List<UsuarioDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene técnicos activos
        /// </summary>
        [HttpGet("tecnicos")]
        public async Task<ActionResult<ApiResponse<List<UsuarioDto>>>> GetTecnicos()
        {
            var result = await _usuarioService.GetTecnicosActivosAsync();
            return Ok(ApiResponse<List<UsuarioDto>>.SuccessResponse(result));
        }
    }
}
