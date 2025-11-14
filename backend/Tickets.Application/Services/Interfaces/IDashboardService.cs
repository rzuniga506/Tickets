using System.Threading.Tasks;
using Tickets.Application.DTOs.Dashboard;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de estadísticas del dashboard
    /// </summary>
    public interface IDashboardService
    {
        /// <summary>
        /// Obtiene estadísticas completas del dashboard para el usuario autenticado
        /// </summary>
        /// <param name="usuarioId">ID del usuario autenticado</param>
        /// <returns>Estadísticas completas del dashboard</returns>
        Task<DashboardStatsDto> GetEstadisticasAsync(int usuarioId);

        /// <summary>
        /// Obtiene estadísticas globales del sistema (solo admin)
        /// </summary>
        /// <returns>Estadísticas globales</returns>
        Task<DashboardStatsDto> GetEstadisticasGlobalesAsync();
    }
}
