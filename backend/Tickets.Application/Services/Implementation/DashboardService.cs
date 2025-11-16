using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Tickets.Application.DTOs.Dashboard;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Enums;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Servicio de estadísticas del dashboard
    /// </summary>
    public class DashboardService : IDashboardService
    {
        private readonly IUnitOfWork _unitOfWork;

        public DashboardService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<DashboardStatsDto> GetEstadisticasAsync(int usuarioId)
        {
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(usuarioId);

            if (usuario == null)
            {
                throw new System.Exception("Usuario no encontrado");
            }

            // Obtener todos los tickets y equipos
            var tickets = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .ToListAsync();

            var equipos = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .ToListAsync();

            var notificaciones = await _unitOfWork.Repository<Notificacion>()
                .GetQueryable()
                .Where(n => n.UsuarioId == usuarioId)
                .ToListAsync();

            // Filtrar tickets según el rol del usuario
            var misTickets = tickets.Where(t => t.SolicitanteId == usuarioId).ToList();
            var ticketsAsignadosAMi = tickets.Where(t => t.TecnicoAsignadoId == usuarioId).ToList();

            // Calcular estadísticas de tickets
            var ticketsAbiertos = tickets.Count(t =>
                t.Estado == EstadoTicket.Nuevo ||
                t.Estado == EstadoTicket.Asignado ||
                t.Estado == EstadoTicket.EnProceso ||
                t.Estado == EstadoTicket.Resuelto);

            // Obtener equipos del usuario
            var misEquipos = equipos.Where(e => e.UsuarioAsignadoId == usuarioId).ToList();

            // Calcular promedio de calificación
            var ticketsCalificados = tickets
                .Where(t => t.Calificacion.HasValue)
                .ToList();

            decimal promedioCalificacion = ticketsCalificados.Any()
                ? (decimal)ticketsCalificados.Average(t => t.Calificacion!.Value)
                : 0;

            // Construir estadísticas
            var stats = new DashboardStatsDto
            {
                // Estadísticas de Tickets
                TotalTickets = tickets.Count,
                TicketsAbiertos = ticketsAbiertos,
                TicketsCerrados = tickets.Count(t => t.Estado == EstadoTicket.Cerrado),
                TicketsPendientes = tickets.Count(t => t.Estado == EstadoTicket.Nuevo),
                TicketsAsignados = tickets.Count(t => t.Estado == EstadoTicket.Asignado),
                TicketsEnProceso = tickets.Count(t => t.Estado == EstadoTicket.EnProceso),
                TicketsResueltos = tickets.Count(t => t.Estado == EstadoTicket.Resuelto),
                MisTickets = misTickets.Count,
                TicketsAsignadosAMi = ticketsAsignadosAMi.Count,

                // Estadísticas de Equipos
                TotalEquipos = equipos.Count,
                EquiposDisponibles = equipos.Count(e => e.Estado == EstadoEquipo.Disponible),
                EquiposAsignados = equipos.Count(e => e.Estado == EstadoEquipo.Asignado),
                EquiposEnMantenimiento = equipos.Count(e => e.Estado == EstadoEquipo.EnMantenimiento),
                MisEquipos = misEquipos.Count,

                // Estadísticas de Notificaciones
                NotificacionesNoLeidas = notificaciones.Count(n => !n.Leida),

                // Métricas de calidad
                PromedioCalificacion = promedioCalificacion,
                TicketsAltaPrioridad = tickets.Count(t =>
                    t.Prioridad == PrioridadTicket.Alta &&
                    t.Estado != EstadoTicket.Cerrado),

                // Distribuciones
                TicketsPorCategoria = tickets
                    .Where(t => t.Categoria != null)
                    .GroupBy(t => t.Categoria!.ToString())
                    .Select(g => new TicketPorCategoriaDto
                    {
                        Categoria = g.Key,
                        Cantidad = g.Count()
                    })
                    .OrderByDescending(x => x.Cantidad)
                    .ToList(),

                TicketsPorEstado = tickets
                    .GroupBy(t => t.Estado.ToString())
                    .Select(g => new TicketPorEstadoDto
                    {
                        Estado = g.Key,
                        Cantidad = g.Count()
                    })
                    .OrderByDescending(x => x.Cantidad)
                    .ToList(),

                EquiposPorTipo = equipos
                    .GroupBy(e => e.Tipo.ToString())
                    .Select(g => new EquipoPorTipoDto
                    {
                        Tipo = g.Key,
                        Cantidad = g.Count()
                    })
                    .OrderByDescending(x => x.Cantidad)
                    .ToList()
            };

            return stats;
        }

        public async Task<DashboardStatsDto> GetEstadisticasGlobalesAsync()
        {
            // Obtener todos los datos
            var tickets = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .ToListAsync();

            var equipos = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .ToListAsync();

            var notificaciones = await _unitOfWork.Repository<Notificacion>()
                .GetQueryable()
                .ToListAsync();

            // Calcular estadísticas globales
            var ticketsAbiertos = tickets.Count(t =>
                t.Estado == EstadoTicket.Nuevo ||
                t.Estado == EstadoTicket.Asignado ||
                t.Estado == EstadoTicket.EnProceso ||
                t.Estado == EstadoTicket.Resuelto);

            // Calcular promedio de calificación
            var ticketsCalificados = tickets
                .Where(t => t.Calificacion.HasValue)
                .ToList();

            decimal promedioCalificacion = ticketsCalificados.Any()
                ? (decimal)ticketsCalificados.Average(t => t.Calificacion!.Value)
                : 0;

            var stats = new DashboardStatsDto
            {
                // Estadísticas de Tickets
                TotalTickets = tickets.Count,
                TicketsAbiertos = ticketsAbiertos,
                TicketsCerrados = tickets.Count(t => t.Estado == EstadoTicket.Cerrado),
                TicketsPendientes = tickets.Count(t => t.Estado == EstadoTicket.Nuevo),
                TicketsAsignados = tickets.Count(t => t.Estado == EstadoTicket.Asignado),
                TicketsEnProceso = tickets.Count(t => t.Estado == EstadoTicket.EnProceso),
                TicketsResueltos = tickets.Count(t => t.Estado == EstadoTicket.Resuelto),
                MisTickets = 0, // No aplica para estadísticas globales
                TicketsAsignadosAMi = 0, // No aplica para estadísticas globales

                // Estadísticas de Equipos
                TotalEquipos = equipos.Count,
                EquiposDisponibles = equipos.Count(e => e.Estado == EstadoEquipo.Disponible),
                EquiposAsignados = equipos.Count(e => e.Estado == EstadoEquipo.Asignado),
                EquiposEnMantenimiento = equipos.Count(e => e.Estado == EstadoEquipo.EnMantenimiento),
                MisEquipos = 0, // No aplica para estadísticas globales

                // Estadísticas de Notificaciones
                NotificacionesNoLeidas = notificaciones.Count(n => !n.Leida),

                // Métricas de calidad
                PromedioCalificacion = promedioCalificacion,
                TicketsAltaPrioridad = tickets.Count(t =>
                    t.Prioridad == PrioridadTicket.Alta &&
                    t.Estado != EstadoTicket.Cerrado),

                // Distribuciones
                TicketsPorCategoria = tickets
                    .Where(t => t.Categoria != null)
                    .GroupBy(t => t.Categoria!.ToString())
                    .Select(g => new TicketPorCategoriaDto
                    {
                        Categoria = g.Key,
                        Cantidad = g.Count()
                    })
                    .OrderByDescending(x => x.Cantidad)
                    .ToList(),

                TicketsPorEstado = tickets
                    .GroupBy(t => t.Estado.ToString())
                    .Select(g => new TicketPorEstadoDto
                    {
                        Estado = g.Key,
                        Cantidad = g.Count()
                    })
                    .OrderByDescending(x => x.Cantidad)
                    .ToList(),

                EquiposPorTipo = equipos
                    .GroupBy(e => e.Tipo.ToString())
                    .Select(g => new EquipoPorTipoDto
                    {
                        Tipo = g.Key,
                        Cantidad = g.Count()
                    })
                    .OrderByDescending(x => x.Cantidad)
                    .ToList()
            };

            return stats;
        }
    }
}
