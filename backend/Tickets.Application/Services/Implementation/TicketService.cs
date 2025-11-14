using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Tickets;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Enums;
using Tickets.Domain.Exceptions;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Implementación del servicio de gestión de tickets
    /// </summary>
    public class TicketService : ITicketService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly INotificacionService _notificacionService;

        // SLA en minutos por prioridad
        private readonly Dictionary<PrioridadTicket, int> _slaMinutosPorPrioridad = new()
        {
            { PrioridadTicket.Baja, 480 },      // 8 horas
            { PrioridadTicket.Media, 240 },     // 4 horas
            { PrioridadTicket.Alta, 120 },      // 2 horas
            { PrioridadTicket.Urgente, 60 },    // 1 hora
            { PrioridadTicket.Critica, 30 }     // 30 minutos
        };

        public TicketService(
            IUnitOfWork unitOfWork,
            IMapper mapper,
            INotificacionService notificacionService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _notificacionService = notificacionService;
        }

        public async Task<PagedResult<TicketDto>> GetAllAsync(
            int pageNumber = 1,
            int pageSize = 10,
            string? searchTerm = null,
            EstadoTicket? estado = null,
            PrioridadTicket? prioridad = null,
            int? solicitanteId = null,
            int? tecnicoId = null,
            bool? slaCumplido = null)
        {
            var query = _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.Solicitante)
                .Include(t => t.TecnicoAsignado)
                .Include(t => t.Equipo)
                .AsQueryable();

            // Aplicar filtros
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.ToLower();
                query = query.Where(t =>
                    t.NumeroTicket.ToLower().Contains(searchTerm) ||
                    t.Asunto.ToLower().Contains(searchTerm) ||
                    t.Descripcion.ToLower().Contains(searchTerm));
            }

            if (estado.HasValue)
            {
                query = query.Where(t => t.Estado == estado.Value);
            }

            if (prioridad.HasValue)
            {
                query = query.Where(t => t.Prioridad == prioridad.Value);
            }

            if (solicitanteId.HasValue)
            {
                query = query.Where(t => t.SolicitanteId == solicitanteId.Value);
            }

            if (tecnicoId.HasValue)
            {
                query = query.Where(t => t.TecnicoAsignadoId == tecnicoId.Value);
            }

            if (slaCumplido.HasValue)
            {
                query = query.Where(t => t.SLACumplido == slaCumplido.Value);
            }

            // Total de registros
            var totalRecords = await query.CountAsync();

            // Aplicar paginación
            var tickets = await query
                .OrderByDescending(t => t.FechaCreacion)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            // Actualizar minutos restantes de SLA
            foreach (var ticket in tickets)
            {
                ActualizarMinutosRestantesSLA(ticket);
            }

            var ticketsDto = _mapper.Map<List<TicketDto>>(tickets);

            return new PagedResult<TicketDto>
            {
                Items = ticketsDto,
                TotalRecords = totalRecords,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<TicketDto> GetByIdAsync(int id)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.Solicitante)
                .Include(t => t.TecnicoAsignado)
                .Include(t => t.Equipo)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", id);
            }

            ActualizarMinutosRestantesSLA(ticket);

            return _mapper.Map<TicketDto>(ticket);
        }

        public async Task<TicketDto> GetByNumeroAsync(string numeroTicket)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.Solicitante)
                .Include(t => t.TecnicoAsignado)
                .Include(t => t.Equipo)
                .FirstOrDefaultAsync(t => t.NumeroTicket == numeroTicket);

            if (ticket == null)
            {
                throw new NotFoundException($"No se encontró un ticket con número: {numeroTicket}");
            }

            ActualizarMinutosRestantesSLA(ticket);

            return _mapper.Map<TicketDto>(ticket);
        }

        public async Task<TicketDto> CreateAsync(TicketCreateDto createDto, int solicitanteId)
        {
            // Validar solicitante
            var solicitante = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(solicitanteId);

            if (solicitante == null || !solicitante.Activo)
            {
                throw new NotFoundException("Usuario", solicitanteId);
            }

            // Validar equipo si se especifica
            if (createDto.EquipoId.HasValue)
            {
                var equipoExists = await _unitOfWork.Repository<Equipo>()
                    .AnyAsync(e => e.Id == createDto.EquipoId.Value);

                if (!equipoExists)
                {
                    throw new NotFoundException("Equipo", createDto.EquipoId.Value);
                }
            }

            // Mapear a entidad
            var ticket = _mapper.Map<Ticket>(createDto);
            ticket.SolicitanteId = solicitanteId;
            ticket.NumeroTicket = await GenerarNumeroTicketAsync();
            ticket.Estado = EstadoTicket.Nuevo;
            ticket.FechaApertura = DateTime.UtcNow;
            ticket.FechaCreacion = DateTime.UtcNow;

            // Calcular SLA
            CalcularSLA(ticket);

            // Agregar ticket
            _unitOfWork.Repository<Ticket>().Add(ticket);
            await _unitOfWork.SaveChangesAsync();

            // Enviar notificación a administradores
            await _notificacionService.NotificarNuevoTicketAsync(ticket.Id);

            return await GetByIdAsync(ticket.Id);
        }

        public async Task<TicketDto> UpdateAsync(int id, TicketUpdateDto updateDto)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(id);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", id);
            }

            // No permitir edición si está cerrado
            if (ticket.Estado == EstadoTicket.Cerrado)
            {
                throw new ValidationException("No se puede editar un ticket cerrado");
            }

            // Validar equipo si se especifica
            if (updateDto.EquipoId.HasValue)
            {
                var equipoExists = await _unitOfWork.Repository<Equipo>()
                    .AnyAsync(e => e.Id == updateDto.EquipoId.Value);

                if (!equipoExists)
                {
                    throw new NotFoundException("Equipo", updateDto.EquipoId.Value);
                }
            }

            var prioridadAnterior = ticket.Prioridad;

            // Mapear cambios
            _mapper.Map(updateDto, ticket);
            ticket.FechaModificacion = DateTime.UtcNow;

            // Recalcular SLA si cambió la prioridad
            if (prioridadAnterior != ticket.Prioridad)
            {
                CalcularSLA(ticket);
            }

            _unitOfWork.Repository<Ticket>().Update(ticket);
            await _unitOfWork.SaveChangesAsync();

            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(id);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", id);
            }

            // Solo permitir eliminar tickets nuevos o sin asignar
            if (ticket.Estado != EstadoTicket.Nuevo)
            {
                throw new ValidationException("Solo se pueden eliminar tickets en estado Nuevo");
            }

            _unitOfWork.Repository<Ticket>().Remove(ticket);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> AsignarTecnicoAsync(int ticketId, TicketAsignarDto asignarDto)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", ticketId);
            }

            // Validar técnico
            var tecnico = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                .FirstOrDefaultAsync(u => u.Id == asignarDto.TecnicoId && u.Activo);

            if (tecnico == null)
            {
                throw new NotFoundException("Técnico", asignarDto.TecnicoId);
            }

            // Validar que sea técnico o admin
            var esTecnico = tecnico.UsuarioRoles.Any(ur =>
                ur.Rol.Nombre.Contains("Técnico") || ur.Rol.Nombre.Contains("Admin"));

            if (!esTecnico)
            {
                throw new ValidationException("El usuario no tiene permisos de técnico");
            }

            ticket.TecnicoAsignadoId = asignarDto.TecnicoId;
            ticket.FechaAsignacion = DateTime.UtcNow;
            ticket.Estado = EstadoTicket.Asignado;
            ticket.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Ticket>().Update(ticket);
            await _unitOfWork.SaveChangesAsync();

            // Notificar al técnico
            await _notificacionService.NotificarTicketAsignadoAsync(ticketId, asignarDto.TecnicoId);

            return true;
        }

        public async Task<bool> IniciarProcesoAsync(int ticketId, int tecnicoId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", ticketId);
            }

            // Validar que esté asignado al técnico
            if (ticket.TecnicoAsignadoId != tecnicoId)
            {
                throw new ValidationException("El ticket no está asignado a este técnico");
            }

            if (ticket.Estado != EstadoTicket.Asignado)
            {
                throw new ValidationException("El ticket debe estar en estado Asignado");
            }

            ticket.FechaInicioProceso = DateTime.UtcNow;
            ticket.Estado = EstadoTicket.EnProceso;
            ticket.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Ticket>().Update(ticket);
            await _unitOfWork.SaveChangesAsync();

            // Notificar al solicitante
            await _notificacionService.NotificarTicketEnProcesoAsync(ticketId);

            return true;
        }

        public async Task<bool> ResolverAsync(int ticketId, TicketResolverDto resolverDto, int tecnicoId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", ticketId);
            }

            // Validar que esté asignado al técnico
            if (ticket.TecnicoAsignadoId != tecnicoId)
            {
                throw new ValidationException("El ticket no está asignado a este técnico");
            }

            if (ticket.Estado == EstadoTicket.Cerrado)
            {
                throw new ValidationException("El ticket ya está cerrado");
            }

            ticket.Solucion = resolverDto.Solucion;
            ticket.TipoSolucion = resolverDto.TipoSolucion;
            ticket.MinutosInvertidos = resolverDto.MinutosInvertidos;
            ticket.FechaResolucion = DateTime.UtcNow;
            ticket.Estado = EstadoTicket.Resuelto;
            ticket.FechaModificacion = DateTime.UtcNow;

            // Calcular cumplimiento de SLA
            if (ticket.FechaLimiteSLA.HasValue)
            {
                ticket.SLACumplido = ticket.FechaResolucion <= ticket.FechaLimiteSLA.Value;
            }

            _unitOfWork.Repository<Ticket>().Update(ticket);
            await _unitOfWork.SaveChangesAsync();

            // Notificar al solicitante
            await _notificacionService.NotificarTicketResueltoAsync(ticketId);

            return true;
        }

        public async Task<bool> CerrarAsync(int ticketId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", ticketId);
            }

            if (ticket.Estado != EstadoTicket.Resuelto)
            {
                throw new ValidationException("Solo se pueden cerrar tickets resueltos");
            }

            ticket.FechaCierre = DateTime.UtcNow;
            ticket.Estado = EstadoTicket.Cerrado;
            ticket.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Ticket>().Update(ticket);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> ReabrirAsync(int ticketId, string motivo)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", ticketId);
            }

            if (ticket.Estado != EstadoTicket.Cerrado && ticket.Estado != EstadoTicket.Resuelto)
            {
                throw new ValidationException("Solo se pueden reabrir tickets cerrados o resueltos");
            }

            ticket.Estado = EstadoTicket.Asignado;
            ticket.FueReabierto = true;
            ticket.CantidadReaberturas++;
            ticket.FechaModificacion = DateTime.UtcNow;

            // Limpiar fechas de resolución y cierre
            ticket.FechaResolucion = null;
            ticket.FechaCierre = null;
            ticket.Solucion = null;

            // Recalcular SLA
            CalcularSLA(ticket);

            _unitOfWork.Repository<Ticket>().Update(ticket);
            await _unitOfWork.SaveChangesAsync();

            // Notificar al técnico
            if (ticket.TecnicoAsignadoId.HasValue)
            {
                await _notificacionService.NotificarTicketReabiertoAsync(ticketId, ticket.TecnicoAsignadoId.Value);
            }

            return true;
        }

        public async Task<bool> EvaluarAsync(int ticketId, TicketEvaluarDto evaluarDto, int solicitanteId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", ticketId);
            }

            // Validar que sea el solicitante
            if (ticket.SolicitanteId != solicitanteId)
            {
                throw new ValidationException("Solo el solicitante puede evaluar el ticket");
            }

            if (ticket.Estado != EstadoTicket.Resuelto && ticket.Estado != EstadoTicket.Cerrado)
            {
                throw new ValidationException("Solo se pueden evaluar tickets resueltos o cerrados");
            }

            ticket.CalificacionServicio = evaluarDto.CalificacionServicio;
            ticket.ComentarioEvaluacion = evaluarDto.ComentarioEvaluacion;
            ticket.FechaEvaluacion = DateTime.UtcNow;
            ticket.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Ticket>().Update(ticket);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> CambiarPrioridadAsync(int ticketId, PrioridadTicket nuevaPrioridad)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException("Ticket", ticketId);
            }

            if (ticket.Estado == EstadoTicket.Cerrado)
            {
                throw new ValidationException("No se puede cambiar la prioridad de un ticket cerrado");
            }

            ticket.Prioridad = nuevaPrioridad;
            ticket.FechaModificacion = DateTime.UtcNow;

            // Recalcular SLA
            CalcularSLA(ticket);

            _unitOfWork.Repository<Ticket>().Update(ticket);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<List<TicketDto>> GetMisTicketsAsync(int usuarioId)
        {
            var tickets = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.Solicitante)
                .Include(t => t.TecnicoAsignado)
                .Include(t => t.Equipo)
                .Where(t => t.SolicitanteId == usuarioId)
                .OrderByDescending(t => t.FechaCreacion)
                .ToListAsync();

            foreach (var ticket in tickets)
            {
                ActualizarMinutosRestantesSLA(ticket);
            }

            return _mapper.Map<List<TicketDto>>(tickets);
        }

        public async Task<List<TicketDto>> GetTicketsAsignadosAsync(int tecnicoId)
        {
            var tickets = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.Solicitante)
                .Include(t => t.TecnicoAsignado)
                .Include(t => t.Equipo)
                .Where(t => t.TecnicoAsignadoId == tecnicoId &&
                           t.Estado != EstadoTicket.Cerrado)
                .OrderBy(t => t.FechaLimiteSLA)
                .ToListAsync();

            foreach (var ticket in tickets)
            {
                ActualizarMinutosRestantesSLA(ticket);
            }

            return _mapper.Map<List<TicketDto>>(tickets);
        }

        public async Task<List<TicketDto>> GetPendientesAsignacionAsync()
        {
            var tickets = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.Solicitante)
                .Include(t => t.Equipo)
                .Where(t => t.Estado == EstadoTicket.Nuevo)
                .OrderBy(t => t.Prioridad)
                .ThenBy(t => t.FechaCreacion)
                .ToListAsync();

            foreach (var ticket in tickets)
            {
                ActualizarMinutosRestantesSLA(ticket);
            }

            return _mapper.Map<List<TicketDto>>(tickets);
        }

        public async Task<List<TicketDto>> GetSLAProximoVencerAsync(int minutosRestantes = 60)
        {
            var tickets = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.Solicitante)
                .Include(t => t.TecnicoAsignado)
                .Include(t => t.Equipo)
                .Where(t => t.FechaLimiteSLA.HasValue &&
                           t.Estado != EstadoTicket.Cerrado &&
                           t.Estado != EstadoTicket.Resuelto)
                .ToListAsync();

            // Filtrar por minutos restantes en memoria
            var ticketsFiltrados = tickets
                .Where(t =>
                {
                    ActualizarMinutosRestantesSLA(t);
                    return t.MinutosRestantesSLA.HasValue &&
                           t.MinutosRestantesSLA.Value > 0 &&
                           t.MinutosRestantesSLA.Value <= minutosRestantes;
                })
                .OrderBy(t => t.MinutosRestantesSLA)
                .ToList();

            return _mapper.Map<List<TicketDto>>(ticketsFiltrados);
        }

        public async Task<TicketEstadisticasDto> GetEstadisticasAsync()
        {
            var tickets = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .ToListAsync();

            var estadisticas = new TicketEstadisticasDto
            {
                TotalTickets = tickets.Count,
                TicketsNuevos = tickets.Count(t => t.Estado == EstadoTicket.Nuevo),
                TicketsEnProceso = tickets.Count(t => t.Estado == EstadoTicket.EnProceso || t.Estado == EstadoTicket.Asignado),
                TicketsResueltos = tickets.Count(t => t.Estado == EstadoTicket.Resuelto),
                TicketsCerrados = tickets.Count(t => t.Estado == EstadoTicket.Cerrado),
                TicketsConSLACumplido = tickets.Count(t => t.SLACumplido),
                TicketsConSLAIncumplido = tickets.Count(t => !t.SLACumplido && (t.Estado == EstadoTicket.Resuelto || t.Estado == EstadoTicket.Cerrado))
            };

            var ticketsCalificados = tickets.Where(t => t.CalificacionServicio.HasValue).ToList();
            if (ticketsCalificados.Any())
            {
                estadisticas.PromedioCalificacion = (decimal)ticketsCalificados.Average(t => t.CalificacionServicio!.Value);
            }

            var ticketsConTiempo = tickets.Where(t => t.MinutosInvertidos.HasValue).ToList();
            if (ticketsConTiempo.Any())
            {
                estadisticas.PromedioTiempoResolucionMinutos = (int)ticketsConTiempo.Average(t => t.MinutosInvertidos!.Value);
            }

            return estadisticas;
        }

        // Métodos privados auxiliares

        private async Task<string> GenerarNumeroTicketAsync()
        {
            var anio = DateTime.UtcNow.Year;
            var ultimoTicket = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Where(t => t.NumeroTicket.StartsWith($"TK-{anio}-"))
                .OrderByDescending(t => t.Id)
                .FirstOrDefaultAsync();

            int consecutivo = 1;
            if (ultimoTicket != null)
            {
                var partes = ultimoTicket.NumeroTicket.Split('-');
                if (partes.Length == 3 && int.TryParse(partes[2], out int numero))
                {
                    consecutivo = numero + 1;
                }
            }

            return $"TK-{anio}-{consecutivo:D5}";
        }

        private void CalcularSLA(Ticket ticket)
        {
            if (_slaMinutosPorPrioridad.TryGetValue(ticket.Prioridad, out int minutosLimite))
            {
                var fechaBase = ticket.FechaInicioProceso ?? ticket.FechaAsignacion ?? ticket.FechaApertura;
                ticket.FechaLimiteSLA = fechaBase.AddMinutes(minutosLimite);
            }
        }

        private void ActualizarMinutosRestantesSLA(Ticket ticket)
        {
            if (ticket.FechaLimiteSLA.HasValue && ticket.Estado != EstadoTicket.Cerrado && ticket.Estado != EstadoTicket.Resuelto)
            {
                var minutosRestantes = (int)(ticket.FechaLimiteSLA.Value - DateTime.UtcNow).TotalMinutes;
                ticket.MinutosRestantesSLA = minutosRestantes > 0 ? minutosRestantes : 0;
            }
        }
    }
}
