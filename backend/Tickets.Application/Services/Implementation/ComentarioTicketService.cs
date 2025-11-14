using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Comentarios;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Exceptions;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Implementación del servicio de gestión de comentarios de tickets
    /// </summary>
    public class ComentarioTicketService : IComentarioTicketService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public ComentarioTicketService(
            IUnitOfWork unitOfWork,
            IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<PagedResult<ComentarioTicketDto>> GetByTicketIdAsync(
            int ticketId,
            int pageNumber = 1,
            int pageSize = 50)
        {
            // Verificar que el ticket existe
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException($"Ticket con ID {ticketId} no encontrado");
            }

            var query = _unitOfWork.Repository<ComentarioTicket>()
                .GetQueryable()
                .Include(c => c.Usuario)
                .Include(c => c.Ticket)
                .Where(c => c.TicketId == ticketId)
                .OrderBy(c => c.FechaCreacion);

            var totalRecords = await query.CountAsync();
            var items = await query
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var itemsDto = items.Select(c => new ComentarioTicketDto
            {
                Id = c.Id,
                Contenido = c.Contenido,
                EsInterno = c.EsInterno,
                EsSistema = c.EsSistema,
                TicketId = c.TicketId,
                NumeroTicket = c.Ticket.NumeroTicket,
                UsuarioId = c.UsuarioId,
                UsuarioNombre = $"{c.Usuario.Nombre} {c.Usuario.Apellido}",
                UsuarioEmail = c.Usuario.Email,
                FechaCreacion = c.FechaCreacion,
                FechaModificacion = c.FechaModificacion
            }).ToList();

            return new PagedResult<ComentarioTicketDto>
            {
                Items = itemsDto,
                TotalItems = totalRecords,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<ComentarioTicketDto> GetByIdAsync(int id)
        {
            var comentario = await _unitOfWork.Repository<ComentarioTicket>()
                .GetQueryable()
                .Include(c => c.Usuario)
                .Include(c => c.Ticket)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (comentario == null)
            {
                throw new NotFoundException($"Comentario con ID {id} no encontrado");
            }

            return new ComentarioTicketDto
            {
                Id = comentario.Id,
                Contenido = comentario.Contenido,
                EsInterno = comentario.EsInterno,
                EsSistema = comentario.EsSistema,
                TicketId = comentario.TicketId,
                NumeroTicket = comentario.Ticket.NumeroTicket,
                UsuarioId = comentario.UsuarioId,
                UsuarioNombre = $"{comentario.Usuario.Nombre} {comentario.Usuario.Apellido}",
                UsuarioEmail = comentario.Usuario.Email,
                FechaCreacion = comentario.FechaCreacion,
                FechaModificacion = comentario.FechaModificacion
            };
        }

        public async Task<ComentarioTicketDto> CreateAsync(
            ComentarioTicketCreateDto createDto,
            int usuarioId)
        {
            // Verificar que el ticket existe
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(createDto.TicketId);

            if (ticket == null)
            {
                throw new NotFoundException($"Ticket con ID {createDto.TicketId} no encontrado");
            }

            // Verificar que el usuario existe
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(usuarioId);

            if (usuario == null)
            {
                throw new NotFoundException($"Usuario con ID {usuarioId} no encontrado");
            }

            var comentario = new ComentarioTicket
            {
                Contenido = createDto.Contenido,
                EsInterno = createDto.EsInterno,
                EsSistema = false,
                TicketId = createDto.TicketId,
                UsuarioId = usuarioId,
                CreadoPor = usuario.Email
            };

            await _unitOfWork.Repository<ComentarioTicket>().AddAsync(comentario);
            await _unitOfWork.SaveChangesAsync();

            return await GetByIdAsync(comentario.Id);
        }

        public async Task<ComentarioTicketDto> UpdateAsync(
            int id,
            ComentarioTicketUpdateDto updateDto,
            int usuarioId)
        {
            var comentario = await _unitOfWork.Repository<ComentarioTicket>()
                .GetByIdAsync(id);

            if (comentario == null)
            {
                throw new NotFoundException($"Comentario con ID {id} no encontrado");
            }

            // Solo el creador puede editar el comentario (y no puede editar comentarios del sistema)
            if (comentario.UsuarioId != usuarioId)
            {
                throw new BusinessException("No tienes permiso para editar este comentario");
            }

            if (comentario.EsSistema)
            {
                throw new BusinessException("No se pueden editar comentarios del sistema");
            }

            // Actualizar campos
            comentario.Contenido = updateDto.Contenido;
            comentario.EsInterno = updateDto.EsInterno;

            var usuario = await _unitOfWork.Repository<Usuario>().GetByIdAsync(usuarioId);
            comentario.ModificadoPor = usuario?.Email;

            _unitOfWork.Repository<ComentarioTicket>().Update(comentario);
            await _unitOfWork.SaveChangesAsync();

            return await GetByIdAsync(comentario.Id);
        }

        public async Task DeleteAsync(int id, int usuarioId)
        {
            var comentario = await _unitOfWork.Repository<ComentarioTicket>()
                .GetByIdAsync(id);

            if (comentario == null)
            {
                throw new NotFoundException($"Comentario con ID {id} no encontrado");
            }

            // Solo el creador puede eliminar el comentario (y no puede eliminar comentarios del sistema)
            if (comentario.UsuarioId != usuarioId)
            {
                throw new BusinessException("No tienes permiso para eliminar este comentario");
            }

            if (comentario.EsSistema)
            {
                throw new BusinessException("No se pueden eliminar comentarios del sistema");
            }

            _unitOfWork.Repository<ComentarioTicket>().Delete(comentario);
            await _unitOfWork.SaveChangesAsync();
        }

        public async Task<ComentarioTicketDto> CreateSistemaCommentAsync(
            int ticketId,
            string contenido)
        {
            // Verificar que el ticket existe
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException($"Ticket con ID {ticketId} no encontrado");
            }

            // Obtener el usuario administrador del sistema (ID 1)
            var sistemaUsuario = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(1);

            if (sistemaUsuario == null)
            {
                throw new BusinessException("Usuario del sistema no encontrado");
            }

            var comentario = new ComentarioTicket
            {
                Contenido = contenido,
                EsInterno = false,
                EsSistema = true,
                TicketId = ticketId,
                UsuarioId = sistemaUsuario.Id,
                CreadoPor = "Sistema"
            };

            await _unitOfWork.Repository<ComentarioTicket>().AddAsync(comentario);
            await _unitOfWork.SaveChangesAsync();

            return await GetByIdAsync(comentario.Id);
        }
    }
}
