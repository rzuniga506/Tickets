using System.Collections.Generic;

namespace Tickets.Application.DTOs.Dashboard
{
    /// <summary>
    /// DTO para estadísticas completas del dashboard
    /// </summary>
    public class DashboardStatsDto
    {
        // Estadísticas de Tickets
        public int TotalTickets { get; set; }
        public int TicketsAbiertos { get; set; }
        public int TicketsCerrados { get; set; }
        public int TicketsPendientes { get; set; }
        public int TicketsAsignados { get; set; }
        public int TicketsEnProceso { get; set; }
        public int TicketsResueltos { get; set; }
        public int MisTickets { get; set; }
        public int TicketsAsignadosAMi { get; set; }

        // Estadísticas de Equipos
        public int TotalEquipos { get; set; }
        public int EquiposDisponibles { get; set; }
        public int EquiposAsignados { get; set; }
        public int EquiposEnMantenimiento { get; set; }
        public int MisEquipos { get; set; }

        // Estadísticas de Notificaciones
        public int NotificacionesNoLeidas { get; set; }

        // Métricas de calidad
        public decimal PromedioCalificacion { get; set; }
        public int TicketsAltaPrioridad { get; set; }

        // Distribuciones
        public List<TicketPorCategoriaDto>? TicketsPorCategoria { get; set; }
        public List<TicketPorEstadoDto>? TicketsPorEstado { get; set; }
        public List<EquipoPorTipoDto>? EquiposPorTipo { get; set; }
    }

    /// <summary>
    /// DTO para tickets agrupados por categoría
    /// </summary>
    public class TicketPorCategoriaDto
    {
        public string Categoria { get; set; } = string.Empty;
        public int Cantidad { get; set; }
    }

    /// <summary>
    /// DTO para tickets agrupados por estado
    /// </summary>
    public class TicketPorEstadoDto
    {
        public string Estado { get; set; } = string.Empty;
        public int Cantidad { get; set; }
    }

    /// <summary>
    /// DTO para equipos agrupados por tipo
    /// </summary>
    public class EquipoPorTipoDto
    {
        public string Tipo { get; set; } = string.Empty;
        public int Cantidad { get; set; }
    }
}
