using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Notificaciones;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Enums;
using Tickets.Domain.Exceptions;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Implementación del servicio de gestión de notificaciones
    /// </summary>
    public class NotificacionService : INotificacionService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IEmailService _emailService;

        public NotificacionService(
            IUnitOfWork unitOfWork,
            IMapper mapper,
            IEmailService emailService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _emailService = emailService;
        }

        public async Task<PagedResult<NotificacionDto>> GetByUsuarioAsync(
            int usuarioId,
            int pageNumber = 1,
            int pageSize = 20,
            bool? leida = null)
        {
            var query = _unitOfWork.Repository<Notificacion>()
                .GetQueryable()
                .Where(n => n.UsuarioId == usuarioId);

            // Aplicar filtro de leída/no leída
            if (leida.HasValue)
            {
                query = query.Where(n => n.Leida == leida.Value);
            }

            // Total de registros
            var totalRecords = await query.CountAsync();

            // Aplicar paginación
            var notificaciones = await query
                .OrderByDescending(n => n.FechaCreacion)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var notificacionesDto = _mapper.Map<List<NotificacionDto>>(notificaciones);

            return new PagedResult<NotificacionDto>
            {
                Items = notificacionesDto,
                TotalRecords = totalRecords,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<NotificacionDto> GetByIdAsync(int id)
        {
            var notificacion = await _unitOfWork.Repository<Notificacion>()
                .GetByIdAsync(id);

            if (notificacion == null)
            {
                throw new NotFoundException("Notificación", id);
            }

            return _mapper.Map<NotificacionDto>(notificacion);
        }

        public async Task<NotificacionDto> CreateAsync(NotificacionCreateDto createDto)
        {
            // Validar que el usuario existe
            var usuarioExists = await _unitOfWork.Repository<Usuario>()
                .AnyAsync(u => u.Id == createDto.UsuarioId && u.Activo);

            if (!usuarioExists)
            {
                throw new NotFoundException("Usuario", createDto.UsuarioId);
            }

            // Mapear a entidad
            var notificacion = _mapper.Map<Notificacion>(createDto);
            notificacion.FechaCreacion = DateTime.UtcNow;

            // Agregar notificación
            _unitOfWork.Repository<Notificacion>().Add(notificacion);
            await _unitOfWork.SaveChangesAsync();

            // TODO: Aquí se podría integrar con servicios de push notifications (Firebase, SignalR, etc.)
            if (notificacion.EnviarPush)
            {
                await EnviarPushNotificationAsync(notificacion);
            }

            if (notificacion.EnviarEmail)
            {
                await EnviarEmailNotificationAsync(notificacion);
            }

            return await GetByIdAsync(notificacion.Id);
        }

        public async Task<bool> MarcarComoLeidaAsync(int id, int usuarioId)
        {
            var notificacion = await _unitOfWork.Repository<Notificacion>()
                .FirstOrDefaultAsync(n => n.Id == id && n.UsuarioId == usuarioId);

            if (notificacion == null)
            {
                throw new NotFoundException("Notificación", id);
            }

            if (!notificacion.Leida)
            {
                notificacion.Leida = true;
                notificacion.FechaLeida = DateTime.UtcNow;
                notificacion.FechaModificacion = DateTime.UtcNow;

                _unitOfWork.Repository<Notificacion>().Update(notificacion);
                await _unitOfWork.SaveChangesAsync();
            }

            return true;
        }

        public async Task<bool> MarcarTodasComoLeidasAsync(int usuarioId)
        {
            var notificaciones = await _unitOfWork.Repository<Notificacion>()
                .FindAsync(n => n.UsuarioId == usuarioId && !n.Leida);

            foreach (var notificacion in notificaciones)
            {
                notificacion.Leida = true;
                notificacion.FechaLeida = DateTime.UtcNow;
                notificacion.FechaModificacion = DateTime.UtcNow;
            }

            if (notificaciones.Any())
            {
                _unitOfWork.Repository<Notificacion>().UpdateRange(notificaciones);
                await _unitOfWork.SaveChangesAsync();
            }

            return true;
        }

        public async Task<bool> DeleteAsync(int id, int usuarioId)
        {
            var notificacion = await _unitOfWork.Repository<Notificacion>()
                .FirstOrDefaultAsync(n => n.Id == id && n.UsuarioId == usuarioId);

            if (notificacion == null)
            {
                throw new NotFoundException("Notificación", id);
            }

            _unitOfWork.Repository<Notificacion>().Remove(notificacion);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<int> GetConteoNoLeidasAsync(int usuarioId)
        {
            return await _unitOfWork.Repository<Notificacion>()
                .GetQueryable()
                .CountAsync(n => n.UsuarioId == usuarioId && !n.Leida);
        }

        public async Task NotificarNuevoTicketAsync(int ticketId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.Solicitante)
                .FirstOrDefaultAsync(t => t.Id == ticketId);

            if (ticket == null) return;

            // Obtener administradores y técnicos
            var usuariosNotificar = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                .Where(u => u.Activo && u.UsuarioRoles.Any(ur =>
                    ur.Rol.Nombre.Contains("Admin") || ur.Rol.Nombre.Contains("Técnico")))
                .ToListAsync();

            foreach (var usuario in usuariosNotificar)
            {
                var notificacion = new NotificacionCreateDto
                {
                    Titulo = "Nuevo Ticket Creado",
                    Mensaje = $"Se ha creado el ticket {ticket.NumeroTicket}: {ticket.Asunto}",
                    Tipo = TipoNotificacion.TicketNuevo,
                    Prioridad = MapearPrioridadTicketANotificacion(ticket.Prioridad),
                    UsuarioId = usuario.Id,
                    EntidadTipo = "Ticket",
                    EntidadId = ticketId,
                    Accion = "Ver",
                    UrlAccion = $"/tickets/{ticketId}",
                    EnviarPush = true,
                    EnviarEmail = ticket.Prioridad >= PrioridadTicket.Alta,
                    MostrarInApp = true
                };

                await CreateAsync(notificacion);
            }
        }

        public async Task NotificarTicketAsignadoAsync(int ticketId, int tecnicoId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null) return;

            var notificacion = new NotificacionCreateDto
            {
                Titulo = "Ticket Asignado",
                Mensaje = $"Se te ha asignado el ticket {ticket.NumeroTicket}: {ticket.Asunto}",
                Tipo = TipoNotificacion.TicketAsignado,
                Prioridad = MapearPrioridadTicketANotificacion(ticket.Prioridad),
                UsuarioId = tecnicoId,
                EntidadTipo = "Ticket",
                EntidadId = ticketId,
                Accion = "Ver",
                UrlAccion = $"/tickets/{ticketId}",
                EnviarPush = true,
                EnviarEmail = ticket.Prioridad >= PrioridadTicket.Alta,
                MostrarInApp = true
            };

            await CreateAsync(notificacion);
        }

        public async Task NotificarTicketEnProcesoAsync(int ticketId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetQueryable()
                .Include(t => t.TecnicoAsignado)
                .FirstOrDefaultAsync(t => t.Id == ticketId);

            if (ticket == null) return;

            var tecnicoNombre = ticket.TecnicoAsignado != null
                ? $"{ticket.TecnicoAsignado.Nombre} {ticket.TecnicoAsignado.Apellido}"
                : "un técnico";

            var notificacion = new NotificacionCreateDto
            {
                Titulo = "Ticket en Proceso",
                Mensaje = $"Tu ticket {ticket.NumeroTicket} está siendo atendido por {tecnicoNombre}",
                Tipo = TipoNotificacion.TicketEnProceso,
                Prioridad = PrioridadNotificacion.Normal,
                UsuarioId = ticket.SolicitanteId,
                EntidadTipo = "Ticket",
                EntidadId = ticketId,
                Accion = "Ver",
                UrlAccion = $"/tickets/{ticketId}",
                EnviarPush = true,
                EnviarEmail = false,
                MostrarInApp = true
            };

            await CreateAsync(notificacion);
        }

        public async Task NotificarTicketResueltoAsync(int ticketId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null) return;

            var notificacion = new NotificacionCreateDto
            {
                Titulo = "Ticket Resuelto",
                Mensaje = $"Tu ticket {ticket.NumeroTicket} ha sido resuelto. Por favor evalúa el servicio.",
                Tipo = TipoNotificacion.TicketResuelto,
                Prioridad = PrioridadNotificacion.Alta,
                UsuarioId = ticket.SolicitanteId,
                EntidadTipo = "Ticket",
                EntidadId = ticketId,
                Accion = "Evaluar",
                UrlAccion = $"/tickets/{ticketId}/evaluar",
                EnviarPush = true,
                EnviarEmail = true,
                MostrarInApp = true
            };

            await CreateAsync(notificacion);
        }

        public async Task NotificarTicketReabiertoAsync(int ticketId, int tecnicoId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null) return;

            var notificacion = new NotificacionCreateDto
            {
                Titulo = "Ticket Reabierto",
                Mensaje = $"El ticket {ticket.NumeroTicket} ha sido reabierto y requiere tu atención",
                Tipo = TipoNotificacion.TicketActualizado,
                Prioridad = PrioridadNotificacion.Alta,
                UsuarioId = tecnicoId,
                EntidadTipo = "Ticket",
                EntidadId = ticketId,
                Accion = "Ver",
                UrlAccion = $"/tickets/{ticketId}",
                EnviarPush = true,
                EnviarEmail = true,
                MostrarInApp = true
            };

            await CreateAsync(notificacion);
        }

        public async Task NotificarSLAProximoVencerAsync(int ticketId, int tecnicoId)
        {
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null) return;

            var notificacion = new NotificacionCreateDto
            {
                Titulo = "SLA Próximo a Vencer",
                Mensaje = $"El SLA del ticket {ticket.NumeroTicket} está próximo a vencer",
                Tipo = TipoNotificacion.SLAProximoVencer,
                Prioridad = PrioridadNotificacion.Urgente,
                UsuarioId = tecnicoId,
                EntidadTipo = "Ticket",
                EntidadId = ticketId,
                Accion = "Ver",
                UrlAccion = $"/tickets/{ticketId}",
                EnviarPush = true,
                EnviarEmail = true,
                MostrarInApp = true
            };

            await CreateAsync(notificacion);
        }

        public async Task NotificarEquipoAsignadoAsync(int equipoId, int usuarioId)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetByIdAsync(equipoId);

            if (equipo == null) return;

            var notificacion = new NotificacionCreateDto
            {
                Titulo = "Equipo Asignado",
                Mensaje = $"Se te ha asignado el equipo {equipo.Nombre} ({equipo.CodigoInterno})",
                Tipo = TipoNotificacion.EquipoAsignado,
                Prioridad = PrioridadNotificacion.Normal,
                UsuarioId = usuarioId,
                EntidadTipo = "Equipo",
                EntidadId = equipoId,
                Accion = "Ver",
                UrlAccion = $"/equipos/{equipoId}",
                EnviarPush = true,
                EnviarEmail = true,
                MostrarInApp = true
            };

            await CreateAsync(notificacion);
        }

        // Métodos privados auxiliares

        private PrioridadNotificacion MapearPrioridadTicketANotificacion(PrioridadTicket prioridad)
        {
            return prioridad switch
            {
                PrioridadTicket.Baja => PrioridadNotificacion.Baja,
                PrioridadTicket.Media => PrioridadNotificacion.Normal,
                PrioridadTicket.Alta => PrioridadNotificacion.Alta,
                PrioridadTicket.Critica or PrioridadTicket.Urgente => PrioridadNotificacion.Urgente,
                _ => PrioridadNotificacion.Normal
            };
        }

        private async Task EnviarPushNotificationAsync(Notificacion notificacion)
        {
            // TODO: Implementar integración con Firebase Cloud Messaging o similar
            // Por ahora solo marcamos como enviada
            notificacion.Enviada = true;
            notificacion.FechaEnvio = DateTime.UtcNow;
            await Task.CompletedTask;
        }

        private async Task EnviarEmailNotificationAsync(Notificacion notificacion)
        {
            try
            {
                // Obtener datos del usuario destinatario
                var usuario = await _unitOfWork.Repository<Usuario>()
                    .GetByIdAsync(notificacion.UsuarioId);

                if (usuario == null || string.IsNullOrEmpty(usuario.Email))
                {
                    return; // No se puede enviar email sin usuario o email
                }

                bool emailSent = false;

                // Enviar email según el tipo de notificación
                switch (notificacion.Tipo)
                {
                    case TipoNotificacion.Mencion:
                        // Para menciones, obtener información del ticket
                        if (notificacion.EntidadId.HasValue)
                        {
                            var ticket = await _unitOfWork.Repository<Ticket>()
                                .GetByIdAsync(notificacion.EntidadId.Value);

                            if (ticket != null)
                            {
                                emailSent = await _emailService.SendMentionNotificationAsync(
                                    toEmail: usuario.Email,
                                    toName: usuario.NombreCompleto,
                                    ticketNumber: ticket.NumeroTicket,
                                    ticketSubject: ticket.Asunto,
                                    ticketId: ticket.Id
                                );
                            }
                        }
                        break;

                    case TipoNotificacion.TicketAsignado:
                    case TipoNotificacion.TicketNuevo:
                    case TipoNotificacion.TicketActualizado:
                    case TipoNotificacion.TicketResuelto:
                    case TipoNotificacion.TicketComentario:
                    case TipoNotificacion.SLAProximoVencer:
                        // Para otros tipos de notificaciones de tickets
                        var subject = notificacion.Titulo;
                        var body = GenerarEmailGenerico(
                            usuario.NombreCompleto,
                            notificacion.Titulo,
                            notificacion.Mensaje,
                            notificacion.UrlAccion
                        );

                        emailSent = await _emailService.SendEmailAsync(
                            to: usuario.Email,
                            subject: subject,
                            body: body,
                            isHtml: true
                        );
                        break;

                    default:
                        // Para otros tipos, solo enviar si es de alta prioridad
                        if (notificacion.Prioridad == PrioridadNotificacion.Alta ||
                            notificacion.Prioridad == PrioridadNotificacion.Urgente)
                        {
                            var subjectDefault = notificacion.Titulo;
                            var bodyDefault = GenerarEmailGenerico(
                                usuario.NombreCompleto,
                                notificacion.Titulo,
                                notificacion.Mensaje,
                                notificacion.UrlAccion
                            );

                            emailSent = await _emailService.SendEmailAsync(
                                to: usuario.Email,
                                subject: subjectDefault,
                                body: bodyDefault,
                                isHtml: true
                            );
                        }
                        break;
                }

                // Marcar como enviada si fue exitoso
                if (emailSent)
                {
                    notificacion.Enviada = true;
                    notificacion.FechaEnvio = DateTime.UtcNow;
                }
            }
            catch (Exception)
            {
                // Log del error pero no fallar el proceso de notificación
                // El error ya está logueado en EmailService
                await Task.CompletedTask;
            }
        }

        private string GenerarEmailGenerico(string userName, string titulo, string mensaje, string? urlAccion)
        {
            var actionButton = string.IsNullOrEmpty(urlAccion)
                ? string.Empty
                : $@"
                    <div style='text-align: center; margin: 30px 0;'>
                        <a href='{urlAccion}' class='button'>Ver Detalles</a>
                    </div>";

            return $@"
<!DOCTYPE html>
<html lang='es'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>{titulo}</title>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        .container {{
            background-color: #ffffff;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }}
        .header {{
            background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
            color: #ffffff;
            padding: 25px;
            border-radius: 12px 12px 0 0;
            text-align: center;
            margin: -30px -30px 30px -30px;
        }}
        .header h1 {{
            margin: 0;
            font-size: 24px;
            fontweight: 600;
        }}
        .content {{
            margin: 20px 0;
        }}
        .message-box {{
            background-color: #f8f9fa;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }}
        .button {{
            display: inline-block;
            padding: 12px 30px;
            background-color: #2196F3;
            color: #ffffff !important;
            text-decoration: none;
            border-radius: 6px;
            margin: 20px 0;
            font-weight: 600;
        }}
        .button:hover {{
            background-color: #1976D2;
        }}
        .footer {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
            text-align: center;
            color: #757575;
            font-size: 12px;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>{titulo}</h1>
        </div>

        <div class='content'>
            <p>Hola <strong>{userName}</strong>,</p>

            <div class='message-box'>
                <p>{mensaje}</p>
            </div>

            {actionButton}
        </div>

        <div class='footer'>
            <p>Este es un correo automático del Sistema de Tickets TI.</p>
            <p>Por favor, no respondas a este correo.</p>
        </div>
    </div>
</body>
</html>";
        }
    }
}
