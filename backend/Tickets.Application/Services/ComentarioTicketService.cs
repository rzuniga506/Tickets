using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Comentarios;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Infrastructure.Persistence;

namespace Tickets.Application.Services
{
    /// <summary>
    /// Servicio de gestión de comentarios de tickets con soporte para menciones
    /// </summary>
    public class ComentarioTicketService : IComentarioTicketService
    {
        private readonly ApplicationDbContext _context;
        private readonly INotificacionService _notificacionService;

        public ComentarioTicketService(
            ApplicationDbContext context,
            INotificacionService notificacionService)
        {
            _context = context;
            _notificacionService = notificacionService;
        }

        public async Task<PagedResult<ComentarioTicketDto>> GetByTicketIdAsync(
            int ticketId,
            int pageNumber = 1,
            int pageSize = 50)
        {
            var query = _context.ComentariosTicket
                .Include(c => c.Usuario)
                .Include(c => c.Ticket)
                .Include(c => c.Menciones)
                    .ThenInclude(m => m.UsuarioMencionado)
                .Where(c => c.TicketId == ticketId)
                .OrderByDescending(c => c.FechaCreacion);

            var totalRecords = await query.CountAsync();
            var items = await query
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var dtos = items.Select(MapToDto).ToList();

            return new PagedResult<ComentarioTicketDto>
            {
                Items = dtos,
                TotalRecords = totalRecords,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<ComentarioTicketDto> GetByIdAsync(int id)
        {
            var comentario = await _context.ComentariosTicket
                .Include(c => c.Usuario)
                .Include(c => c.Ticket)
                .Include(c => c.Menciones)
                    .ThenInclude(m => m.UsuarioMencionado)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (comentario == null)
            {
                throw new KeyNotFoundException($"Comentario con ID {id} no encontrado");
            }

            return MapToDto(comentario);
        }

        public async Task<ComentarioTicketDto> CreateAsync(
            ComentarioTicketCreateDto createDto,
            int usuarioId)
        {
            // Verificar que el ticket existe
            var ticket = await _context.Tickets.FindAsync(createDto.TicketId);
            if (ticket == null)
            {
                throw new KeyNotFoundException($"Ticket con ID {createDto.TicketId} no encontrado");
            }

            // Crear el comentario
            var comentario = new ComentarioTicket
            {
                Contenido = createDto.Contenido,
                EsInterno = createDto.EsInterno,
                EsSistema = false,
                TicketId = createDto.TicketId,
                UsuarioId = usuarioId,
                FechaCreacion = DateTime.UtcNow
            };

            _context.ComentariosTicket.Add(comentario);
            await _context.SaveChangesAsync();

            // Procesar menciones si las hay
            if (createDto.UsuariosIdMencionados != null && createDto.UsuariosIdMencionados.Any())
            {
                await CrearMencionesAsync(comentario.Id, createDto.UsuariosIdMencionados, ticket.NumeroTicket);
            }

            // Recargar con includes para retornar datos completos
            await _context.Entry(comentario)
                .Reference(c => c.Usuario)
                .LoadAsync();
            await _context.Entry(comentario)
                .Reference(c => c.Ticket)
                .LoadAsync();
            await _context.Entry(comentario)
                .Collection(c => c.Menciones)
                .LoadAsync();

            foreach (var mencion in comentario.Menciones)
            {
                await _context.Entry(mencion)
                    .Reference(m => m.UsuarioMencionado)
                    .LoadAsync();
            }

            return MapToDto(comentario);
        }

        public async Task<ComentarioTicketDto> UpdateAsync(
            int id,
            ComentarioTicketUpdateDto updateDto,
            int usuarioId)
        {
            var comentario = await _context.ComentariosTicket
                .Include(c => c.Menciones)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (comentario == null)
            {
                throw new KeyNotFoundException($"Comentario con ID {id} no encontrado");
            }

            // Verificar permisos: solo el creador puede editar
            if (comentario.UsuarioId != usuarioId)
            {
                throw new UnauthorizedAccessException("No tiene permisos para editar este comentario");
            }

            // No permitir editar comentarios del sistema
            if (comentario.EsSistema)
            {
                throw new InvalidOperationException("No se pueden editar comentarios del sistema");
            }

            comentario.Contenido = updateDto.Contenido;
            comentario.FechaModificacion = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            // Recargar con includes
            await _context.Entry(comentario)
                .Reference(c => c.Usuario)
                .LoadAsync();
            await _context.Entry(comentario)
                .Reference(c => c.Ticket)
                .LoadAsync();

            foreach (var mencion in comentario.Menciones)
            {
                await _context.Entry(mencion)
                    .Reference(m => m.UsuarioMencionado)
                    .LoadAsync();
            }

            return MapToDto(comentario);
        }

        public async Task DeleteAsync(int id, int usuarioId)
        {
            var comentario = await _context.ComentariosTicket.FindAsync(id);

            if (comentario == null)
            {
                throw new KeyNotFoundException($"Comentario con ID {id} no encontrado");
            }

            // Verificar permisos
            if (comentario.UsuarioId != usuarioId)
            {
                throw new UnauthorizedAccessException("No tiene permisos para eliminar este comentario");
            }

            // No permitir eliminar comentarios del sistema
            if (comentario.EsSistema)
            {
                throw new InvalidOperationException("No se pueden eliminar comentarios del sistema");
            }

            _context.ComentariosTicket.Remove(comentario);
            await _context.SaveChangesAsync();
        }

        public async Task<ComentarioTicketDto> CreateSistemaCommentAsync(
            int ticketId,
            string contenido)
        {
            var comentario = new ComentarioTicket
            {
                Contenido = contenido,
                EsInterno = false,
                EsSistema = true,
                TicketId = ticketId,
                UsuarioId = 1, // Usuario del sistema
                FechaCreacion = DateTime.UtcNow
            };

            _context.ComentariosTicket.Add(comentario);
            await _context.SaveChangesAsync();

            await _context.Entry(comentario)
                .Reference(c => c.Usuario)
                .LoadAsync();
            await _context.Entry(comentario)
                .Reference(c => c.Ticket)
                .LoadAsync();

            return MapToDto(comentario);
        }

        private async Task CrearMencionesAsync(
            int comentarioId,
            List<int> usuariosIdMencionados,
            string numeroTicket)
        {
            // Eliminar duplicados
            var usuariosUnicos = usuariosIdMencionados.Distinct().ToList();

            // Verificar que los usuarios existen
            var usuariosExistentes = await _context.Usuarios
                .Where(u => usuariosUnicos.Contains(u.Id))
                .Select(u => u.Id)
                .ToListAsync();

            foreach (var usuarioId in usuariosExistentes)
            {
                var mencion = new MencionComentario
                {
                    ComentarioTicketId = comentarioId,
                    UsuarioMencionadoId = usuarioId,
                    Leida = false,
                    FechaCreacion = DateTime.UtcNow
                };

                _context.MencionComentarios.Add(mencion);

                // Crear notificación para el usuario mencionado
                try
                {
                    await _notificacionService.CreateAsync(new DTOs.Notificaciones.NotificacionCreateDto
                    {
                        UsuarioId = usuarioId,
                        Titulo = "Te mencionaron en un ticket",
                        Mensaje = $"Fuiste mencionado en un comentario del ticket #{numeroTicket}",
                        Tipo = Domain.Enums.TipoNotificacion.Mencion,
                        TicketId = null // Se puede agregar si es necesario
                    });
                }
                catch
                {
                    // Si falla la notificación, no detener el proceso
                    // Log the error in production
                }
            }

            await _context.SaveChangesAsync();
        }

        private ComentarioTicketDto MapToDto(ComentarioTicket comentario)
        {
            return new ComentarioTicketDto
            {
                Id = comentario.Id,
                Contenido = comentario.Contenido,
                EsInterno = comentario.EsInterno,
                EsSistema = comentario.EsSistema,
                TicketId = comentario.TicketId,
                NumeroTicket = comentario.Ticket?.NumeroTicket ?? "",
                UsuarioId = comentario.UsuarioId,
                UsuarioNombre = comentario.Usuario?.NombreCompleto ?? "",
                UsuarioEmail = comentario.Usuario?.Email ?? "",
                Menciones = comentario.Menciones?.Select(m => new MencionDto
                {
                    Id = m.Id,
                    UsuarioMencionadoId = m.UsuarioMencionadoId,
                    UsuarioMencionadoNombre = m.UsuarioMencionado?.NombreCompleto ?? "",
                    UsuarioMencionadoEmail = m.UsuarioMencionado?.Email ?? "",
                    Leida = m.Leida,
                    FechaLeida = m.FechaLeida
                }).ToList() ?? new List<MencionDto>(),
                FechaCreacion = comentario.FechaCreacion,
                FechaModificacion = comentario.FechaModificacion
            };
        }
    }
}
