using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Equipos;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Enums;

namespace Tickets.API.Controllers
{
    /// <summary>
    /// Controlador de gestión de equipos
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EquiposController : ControllerBase
    {
        private readonly IEquipoService _equipoService;

        public EquiposController(IEquipoService equipoService)
        {
            _equipoService = equipoService;
        }

        /// <summary>
        /// Obtiene todos los equipos con paginación y filtros
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse<PagedResult<EquipoDto>>>> GetAll(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? searchTerm = null,
            [FromQuery] EstadoEquipo? estado = null,
            [FromQuery] CondicionEquipo? condicion = null,
            [FromQuery] int? usuarioAsignadoId = null,
            [FromQuery] int? departamentoId = null)
        {
            var result = await _equipoService.GetAllAsync(
                pageNumber, pageSize, searchTerm, estado, condicion, usuarioAsignadoId, departamentoId);

            return Ok(ApiResponse<PagedResult<EquipoDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene un equipo por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<EquipoDto>>> GetById(int id)
        {
            var result = await _equipoService.GetByIdAsync(id);
            return Ok(ApiResponse<EquipoDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene un equipo por código interno
        /// </summary>
        [HttpGet("codigo/{codigoInterno}")]
        public async Task<ActionResult<ApiResponse<EquipoDto>>> GetByCodigoInterno(string codigoInterno)
        {
            var result = await _equipoService.GetByCodigoInternoAsync(codigoInterno);
            return Ok(ApiResponse<EquipoDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene un equipo por código QR
        /// </summary>
        [HttpGet("qr/{codigoQR}")]
        public async Task<ActionResult<ApiResponse<EquipoDto>>> GetByCodigoQR(string codigoQR)
        {
            var result = await _equipoService.GetByCodigoQRAsync(codigoQR);
            return Ok(ApiResponse<EquipoDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Crea un nuevo equipo
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<EquipoDto>>> Create([FromBody] EquipoCreateDto createDto)
        {
            var createdBy = User.FindFirst(ClaimTypes.Email)?.Value ?? "System";
            var result = await _equipoService.CreateAsync(createDto, createdBy);

            return CreatedAtAction(
                nameof(GetById),
                new { id = result.Id },
                ApiResponse<EquipoDto>.SuccessResponse(result, "Equipo creado exitosamente"));
        }

        /// <summary>
        /// Actualiza un equipo existente
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<EquipoDto>>> Update(
            int id,
            [FromBody] EquipoUpdateDto updateDto)
        {
            var modifiedBy = User.FindFirst(ClaimTypes.Email)?.Value ?? "System";
            var result = await _equipoService.UpdateAsync(id, updateDto, modifiedBy);

            return Ok(ApiResponse<EquipoDto>.SuccessResponse(result, "Equipo actualizado exitosamente"));
        }

        /// <summary>
        /// Elimina un equipo (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> Delete(int id)
        {
            var result = await _equipoService.DeleteAsync(id);
            return Ok(ApiResponse<bool>.SuccessResponse(result, "Equipo eliminado exitosamente"));
        }

        /// <summary>
        /// Asigna un equipo a un usuario
        /// </summary>
        [HttpPost("{equipoId}/asignar/{usuarioId}")]
        public async Task<ActionResult<ApiResponse<bool>>> AsignarUsuario(int equipoId, int usuarioId)
        {
            var modifiedBy = User.FindFirst(ClaimTypes.Email)?.Value ?? "System";
            var result = await _equipoService.AsignarUsuarioAsync(equipoId, usuarioId, modifiedBy);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Equipo asignado exitosamente"));
        }

        /// <summary>
        /// Desasigna un equipo de su usuario actual
        /// </summary>
        [HttpPost("{equipoId}/desasignar")]
        public async Task<ActionResult<ApiResponse<bool>>> DesasignarUsuario(int equipoId)
        {
            var modifiedBy = User.FindFirst(ClaimTypes.Email)?.Value ?? "System";
            var result = await _equipoService.DesasignarUsuarioAsync(equipoId, modifiedBy);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Equipo desasignado exitosamente"));
        }

        /// <summary>
        /// Genera un código QR para un equipo
        /// </summary>
        [HttpPost("{equipoId}/generar-qr")]
        public async Task<ActionResult<ApiResponse<string>>> GenerarCodigoQR(int equipoId)
        {
            var result = await _equipoService.GenerarCodigoQRAsync(equipoId);
            return Ok(ApiResponse<string>.SuccessResponse(result, "Código QR generado exitosamente"));
        }

        /// <summary>
        /// Obtiene equipos disponibles
        /// </summary>
        [HttpGet("disponibles")]
        public async Task<ActionResult<ApiResponse<List<EquipoDto>>>> GetDisponibles()
        {
            var result = await _equipoService.GetDisponiblesAsync();
            return Ok(ApiResponse<List<EquipoDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene equipos asignados a un usuario
        /// </summary>
        [HttpGet("usuario/{usuarioId}")]
        public async Task<ActionResult<ApiResponse<List<EquipoDto>>>> GetByUsuario(int usuarioId)
        {
            var result = await _equipoService.GetByUsuarioAsync(usuarioId);
            return Ok(ApiResponse<List<EquipoDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene mis equipos asignados
        /// </summary>
        [HttpGet("mis-equipos")]
        public async Task<ActionResult<ApiResponse<List<EquipoDto>>>> GetMisEquipos()
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _equipoService.GetByUsuarioAsync(usuarioId);
            return Ok(ApiResponse<List<EquipoDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene equipos por departamento
        /// </summary>
        [HttpGet("departamento/{departamentoId}")]
        public async Task<ActionResult<ApiResponse<List<EquipoDto>>>> GetByDepartamento(int departamentoId)
        {
            var result = await _equipoService.GetByDepartamentoAsync(departamentoId);
            return Ok(ApiResponse<List<EquipoDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene equipos con garantía próxima a vencer
        /// </summary>
        [HttpGet("garantia-proxima-vencer")]
        public async Task<ActionResult<ApiResponse<List<EquipoDto>>>> GetGarantiaProximaVencer(
            [FromQuery] int dias = 30)
        {
            var result = await _equipoService.GetGarantiaProximaVencerAsync(dias);
            return Ok(ApiResponse<List<EquipoDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Cambia el estado de un equipo
        /// </summary>
        [HttpPatch("{equipoId}/cambiar-estado")]
        public async Task<ActionResult<ApiResponse<bool>>> CambiarEstado(
            int equipoId,
            [FromBody] EstadoEquipo nuevoEstado)
        {
            var modifiedBy = User.FindFirst(ClaimTypes.Email)?.Value ?? "System";
            var result = await _equipoService.CambiarEstadoAsync(equipoId, nuevoEstado, modifiedBy);

            return Ok(ApiResponse<bool>.SuccessResponse(result, "Estado cambiado exitosamente"));
        }
    }
}
