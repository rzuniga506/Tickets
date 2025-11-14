using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Dashboard;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers
{
    /// <summary>
    /// Controlador de estadísticas del dashboard
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        /// <summary>
        /// Obtiene estadísticas del dashboard para el usuario autenticado
        /// </summary>
        [HttpGet("estadisticas")]
        public async Task<ActionResult<ApiResponse<DashboardStatsDto>>> GetEstadisticas()
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _dashboardService.GetEstadisticasAsync(usuarioId);

            return Ok(ApiResponse<DashboardStatsDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Obtiene estadísticas globales del sistema (solo administradores)
        /// </summary>
        [HttpGet("estadisticas/globales")]
        [Authorize(Roles = "Administrador")]
        public async Task<ActionResult<ApiResponse<DashboardStatsDto>>> GetEstadisticasGlobales()
        {
            var result = await _dashboardService.GetEstadisticasGlobalesAsync();
            return Ok(ApiResponse<DashboardStatsDto>.SuccessResponse(result));
        }
    }
}
