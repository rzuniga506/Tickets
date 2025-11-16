using System.Collections.Generic;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Tickets;
using Tickets.Domain.Enums;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de gestión de tickets
    /// </summary>
    public interface ITicketService
    {
        /// <summary>
        /// Obtiene todos los tickets con paginación y filtros
        /// </summary>
        Task<PagedResult<TicketDto>> GetAllAsync(
            int pageNumber = 1,
            int pageSize = 10,
            string? searchTerm = null,
            EstadoTicket? estado = null,
            PrioridadTicket? prioridad = null,
            int? solicitanteId = null,
            int? tecnicoId = null,
            bool? slaCumplido = null);

        /// <summary>
        /// Obtiene un ticket por ID
        /// </summary>
        Task<TicketDto> GetByIdAsync(int id);

        /// <summary>
        /// Obtiene un ticket por número
        /// </summary>
        Task<TicketDto> GetByNumeroAsync(string numeroTicket);

        /// <summary>
        /// Crea un nuevo ticket
        /// </summary>
        Task<TicketDto> CreateAsync(TicketCreateDto createDto, int solicitanteId);

        /// <summary>
        /// Actualiza un ticket existente
        /// </summary>
        Task<TicketDto> UpdateAsync(int id, TicketUpdateDto updateDto);

        /// <summary>
        /// Elimina (soft delete) un ticket
        /// </summary>
        Task<bool> DeleteAsync(int id);

        /// <summary>
        /// Asigna un técnico a un ticket
        /// </summary>
        Task<bool> AsignarTecnicoAsync(int ticketId, TicketAsignarDto asignarDto);

        /// <summary>
        /// Inicia el proceso de resolución de un ticket
        /// </summary>
        Task<bool> IniciarProcesoAsync(int ticketId, int tecnicoId);

        /// <summary>
        /// Resuelve un ticket
        /// </summary>
        Task<bool> ResolverAsync(int ticketId, TicketResolverDto resolverDto, int tecnicoId);

        /// <summary>
        /// Cierra un ticket
        /// </summary>
        Task<bool> CerrarAsync(int ticketId);

        /// <summary>
        /// Reabre un ticket cerrado
        /// </summary>
        Task<bool> ReabrirAsync(int ticketId, string motivo);

        /// <summary>
        /// Evalúa un ticket resuelto
        /// </summary>
        Task<bool> EvaluarAsync(int ticketId, TicketEvaluarDto evaluarDto, int solicitanteId);

        /// <summary>
        /// Cambia la prioridad de un ticket
        /// </summary>
        Task<bool> CambiarPrioridadAsync(int ticketId, PrioridadTicket nuevaPrioridad);

        /// <summary>
        /// Obtiene tickets del usuario (como solicitante)
        /// </summary>
        Task<List<TicketDto>> GetMisTicketsAsync(int usuarioId);

        /// <summary>
        /// Obtiene tickets asignados al técnico
        /// </summary>
        Task<List<TicketDto>> GetTicketsAsignadosAsync(int tecnicoId);

        /// <summary>
        /// Obtiene tickets pendientes de asignación
        /// </summary>
        Task<List<TicketDto>> GetPendientesAsignacionAsync();

        /// <summary>
        /// Obtiene tickets con SLA próximo a vencer
        /// </summary>
        Task<List<TicketDto>> GetSLAProximoVencerAsync(int minutosRestantes = 60);

        /// <summary>
        /// Obtiene tickets donde el usuario ha sido mencionado en comentarios
        /// </summary>
        Task<List<TicketDto>> GetTicketsMencionadosAsync(int usuarioId);

        /// <summary>
        /// Obtiene todos los tickets accesibles para un usuario
        /// (creados por él, asignados a él, o donde ha sido mencionado)
        /// </summary>
        Task<PagedResult<TicketDto>> GetTicketsAccesiblesAsync(
            int usuarioId,
            int pageNumber = 1,
            int pageSize = 10,
            string? searchTerm = null,
            EstadoTicket? estado = null,
            PrioridadTicket? prioridad = null);

        /// <summary>
        /// Verifica si un usuario tiene acceso para ver un ticket
        /// </summary>
        Task<bool> TieneAccesoAsync(int ticketId, int usuarioId, bool esAdmin = false);

        /// <summary>
        /// Obtiene estadísticas de tickets
        /// </summary>
        Task<TicketEstadisticasDto> GetEstadisticasAsync();
    }

    /// <summary>
    /// DTO para estadísticas de tickets
    /// </summary>
    public class TicketEstadisticasDto
    {
        public int TotalTickets { get; set; }
        public int TicketsNuevos { get; set; }
        public int TicketsEnProceso { get; set; }
        public int TicketsResueltos { get; set; }
        public int TicketsCerrados { get; set; }
        public int TicketsConSLACumplido { get; set; }
        public int TicketsConSLAIncumplido { get; set; }
        public decimal PromedioCalificacion { get; set; }
        public int PromedioTiempoResolucionMinutos { get; set; }
    }
}
