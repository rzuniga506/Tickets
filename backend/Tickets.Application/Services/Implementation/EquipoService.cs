using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Equipos;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Enums;
using Tickets.Domain.Exceptions;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Implementación del servicio de gestión de equipos
    /// </summary>
    public class EquipoService : IEquipoService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public EquipoService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<PagedResult<EquipoDto>> GetAllAsync(
            int pageNumber = 1,
            int pageSize = 10,
            string? searchTerm = null,
            EstadoEquipo? estado = null,
            CondicionEquipo? condicion = null,
            int? usuarioAsignadoId = null,
            int? departamentoId = null)
        {
            var query = _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .Include(e => e.UsuarioAsignado)
                .Include(e => e.DepartamentoAsignado)
                .AsQueryable();

            // Aplicar filtros
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.ToLower();
                query = query.Where(e =>
                    e.CodigoInterno.ToLower().Contains(searchTerm) ||
                    e.Nombre.ToLower().Contains(searchTerm) ||
                    (e.NumeroSerie != null && e.NumeroSerie.ToLower().Contains(searchTerm)) ||
                    (e.Modelo != null && e.Modelo.ToLower().Contains(searchTerm)));
            }

            if (estado.HasValue)
            {
                query = query.Where(e => e.Estado == estado.Value);
            }

            if (condicion.HasValue)
            {
                query = query.Where(e => e.Condicion == condicion.Value);
            }

            if (usuarioAsignadoId.HasValue)
            {
                query = query.Where(e => e.UsuarioAsignadoId == usuarioAsignadoId.Value);
            }

            if (departamentoId.HasValue)
            {
                query = query.Where(e => e.DepartamentoAsignadoId == departamentoId.Value);
            }

            // Total de registros
            var totalRecords = await query.CountAsync();

            // Aplicar paginación
            var equipos = await query
                .OrderByDescending(e => e.FechaCreacion)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var equiposDto = _mapper.Map<List<EquipoDto>>(equipos);

            return new PagedResult<EquipoDto>
            {
                Items = equiposDto,
                TotalRecords = totalRecords,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<EquipoDto> GetByIdAsync(int id)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .Include(e => e.UsuarioAsignado)
                .Include(e => e.DepartamentoAsignado)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (equipo == null)
            {
                throw new NotFoundException("Equipo", id);
            }

            return _mapper.Map<EquipoDto>(equipo);
        }

        public async Task<EquipoDto> GetByCodigoInternoAsync(string codigoInterno)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .Include(e => e.UsuarioAsignado)
                .Include(e => e.DepartamentoAsignado)
                .FirstOrDefaultAsync(e => e.CodigoInterno == codigoInterno);

            if (equipo == null)
            {
                throw new NotFoundException($"No se encontró un equipo con código interno: {codigoInterno}");
            }

            return _mapper.Map<EquipoDto>(equipo);
        }

        public async Task<EquipoDto> GetByCodigoQRAsync(string codigoQR)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .Include(e => e.UsuarioAsignado)
                .Include(e => e.DepartamentoAsignado)
                .FirstOrDefaultAsync(e => e.CodigoQR == codigoQR);

            if (equipo == null)
            {
                throw new NotFoundException($"No se encontró un equipo con código QR: {codigoQR}");
            }

            return _mapper.Map<EquipoDto>(equipo);
        }

        public async Task<EquipoDto> CreateAsync(EquipoCreateDto createDto, string createdBy)
        {
            // Validar que el código interno no exista
            var codigoExists = await _unitOfWork.Repository<Equipo>()
                .AnyAsync(e => e.CodigoInterno == createDto.CodigoInterno);

            if (codigoExists)
            {
                throw new ConflictException($"Ya existe un equipo con el código interno: {createDto.CodigoInterno}");
            }

            // Validar usuario asignado si se especifica
            if (createDto.UsuarioAsignadoId.HasValue)
            {
                var usuarioExists = await _unitOfWork.Repository<Usuario>()
                    .AnyAsync(u => u.Id == createDto.UsuarioAsignadoId.Value && u.Activo);

                if (!usuarioExists)
                {
                    throw new NotFoundException("Usuario", createDto.UsuarioAsignadoId.Value);
                }
            }

            // Validar departamento asignado si se especifica
            if (createDto.DepartamentoAsignadoId.HasValue)
            {
                var departamentoExists = await _unitOfWork.Repository<Departamento>()
                    .AnyAsync(d => d.Id == createDto.DepartamentoAsignadoId.Value && d.Activo);

                if (!departamentoExists)
                {
                    throw new NotFoundException("Departamento", createDto.DepartamentoAsignadoId.Value);
                }
            }

            // Mapear a entidad
            var equipo = _mapper.Map<Equipo>(createDto);
            equipo.CreadoPor = createdBy;
            equipo.FechaCreacion = DateTime.UtcNow;

            // Generar código QR
            equipo.CodigoQR = GenerarCodigoQR(createDto.CodigoInterno);

            // Si se asigna a un usuario, establecer fecha de asignación
            if (createDto.UsuarioAsignadoId.HasValue)
            {
                equipo.FechaAsignacion = DateTime.UtcNow;
                equipo.Estado = EstadoEquipo.Asignado;
            }

            // Agregar equipo
            _unitOfWork.Repository<Equipo>().Add(equipo);
            await _unitOfWork.SaveChangesAsync();

            return await GetByIdAsync(equipo.Id);
        }

        public async Task<EquipoDto> UpdateAsync(int id, EquipoUpdateDto updateDto, string modifiedBy)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetByIdAsync(id);

            if (equipo == null)
            {
                throw new NotFoundException("Equipo", id);
            }

            // Validar usuario asignado si se especifica
            if (updateDto.UsuarioAsignadoId.HasValue)
            {
                var usuarioExists = await _unitOfWork.Repository<Usuario>()
                    .AnyAsync(u => u.Id == updateDto.UsuarioAsignadoId.Value && u.Activo);

                if (!usuarioExists)
                {
                    throw new NotFoundException("Usuario", updateDto.UsuarioAsignadoId.Value);
                }

                // Si cambia el usuario asignado, actualizar fecha de asignación
                if (equipo.UsuarioAsignadoId != updateDto.UsuarioAsignadoId)
                {
                    equipo.FechaAsignacion = DateTime.UtcNow;
                }
            }

            // Validar departamento asignado si se especifica
            if (updateDto.DepartamentoAsignadoId.HasValue)
            {
                var departamentoExists = await _unitOfWork.Repository<Departamento>()
                    .AnyAsync(d => d.Id == updateDto.DepartamentoAsignadoId.Value && d.Activo);

                if (!departamentoExists)
                {
                    throw new NotFoundException("Departamento", updateDto.DepartamentoAsignadoId.Value);
                }
            }

            // Mapear cambios
            _mapper.Map(updateDto, equipo);
            equipo.ModificadoPor = modifiedBy;
            equipo.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Equipo>().Update(equipo);
            await _unitOfWork.SaveChangesAsync();

            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetByIdAsync(id);

            if (equipo == null)
            {
                throw new NotFoundException("Equipo", id);
            }

            // Validar que no tenga tickets activos
            var tieneTicketsActivos = await _unitOfWork.Repository<Ticket>()
                .AnyAsync(t => t.EquipoId == id && t.Estado != EstadoTicket.Cerrado);

            if (tieneTicketsActivos)
            {
                throw new ValidationException("No se puede eliminar el equipo porque tiene tickets activos asociados");
            }

            _unitOfWork.Repository<Equipo>().Remove(equipo);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> AsignarUsuarioAsync(int equipoId, int usuarioId, string modifiedBy)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetByIdAsync(equipoId);

            if (equipo == null)
            {
                throw new NotFoundException("Equipo", equipoId);
            }

            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(usuarioId);

            if (usuario == null || !usuario.Activo)
            {
                throw new NotFoundException("Usuario", usuarioId);
            }

            equipo.UsuarioAsignadoId = usuarioId;
            equipo.DepartamentoAsignadoId = usuario.DepartamentoId;
            equipo.FechaAsignacion = DateTime.UtcNow;
            equipo.Estado = EstadoEquipo.Asignado;
            equipo.ModificadoPor = modifiedBy;
            equipo.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Equipo>().Update(equipo);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> DesasignarUsuarioAsync(int equipoId, string modifiedBy)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetByIdAsync(equipoId);

            if (equipo == null)
            {
                throw new NotFoundException("Equipo", equipoId);
            }

            equipo.UsuarioAsignadoId = null;
            equipo.DepartamentoAsignadoId = null;
            equipo.FechaAsignacion = null;
            equipo.Estado = EstadoEquipo.Disponible;
            equipo.ModificadoPor = modifiedBy;
            equipo.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Equipo>().Update(equipo);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<string> GenerarCodigoQRAsync(int equipoId)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetByIdAsync(equipoId);

            if (equipo == null)
            {
                throw new NotFoundException("Equipo", equipoId);
            }

            if (string.IsNullOrEmpty(equipo.CodigoQR))
            {
                equipo.CodigoQR = GenerarCodigoQR(equipo.CodigoInterno);
                _unitOfWork.Repository<Equipo>().Update(equipo);
                await _unitOfWork.SaveChangesAsync();
            }

            return equipo.CodigoQR;
        }

        public async Task<List<EquipoDto>> GetDisponiblesAsync()
        {
            var equipos = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .Include(e => e.DepartamentoAsignado)
                .Where(e => e.Estado == EstadoEquipo.Disponible)
                .OrderBy(e => e.Nombre)
                .ToListAsync();

            return _mapper.Map<List<EquipoDto>>(equipos);
        }

        public async Task<List<EquipoDto>> GetByUsuarioAsync(int usuarioId)
        {
            var equipos = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .Include(e => e.UsuarioAsignado)
                .Include(e => e.DepartamentoAsignado)
                .Where(e => e.UsuarioAsignadoId == usuarioId)
                .OrderBy(e => e.Nombre)
                .ToListAsync();

            return _mapper.Map<List<EquipoDto>>(equipos);
        }

        public async Task<List<EquipoDto>> GetByDepartamentoAsync(int departamentoId)
        {
            var equipos = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .Include(e => e.UsuarioAsignado)
                .Include(e => e.DepartamentoAsignado)
                .Where(e => e.DepartamentoAsignadoId == departamentoId)
                .OrderBy(e => e.Nombre)
                .ToListAsync();

            return _mapper.Map<List<EquipoDto>>(equipos);
        }

        public async Task<List<EquipoDto>> GetGarantiaProximaVencerAsync(int dias = 30)
        {
            var fechaLimite = DateTime.UtcNow.AddDays(dias);

            var equipos = await _unitOfWork.Repository<Equipo>()
                .GetQueryable()
                .Include(e => e.UsuarioAsignado)
                .Include(e => e.DepartamentoAsignado)
                .Where(e => e.FechaFinGarantia.HasValue &&
                           e.FechaFinGarantia.Value > DateTime.UtcNow &&
                           e.FechaFinGarantia.Value <= fechaLimite)
                .OrderBy(e => e.FechaFinGarantia)
                .ToListAsync();

            return _mapper.Map<List<EquipoDto>>(equipos);
        }

        public async Task<bool> CambiarEstadoAsync(int equipoId, EstadoEquipo nuevoEstado, string modifiedBy)
        {
            var equipo = await _unitOfWork.Repository<Equipo>()
                .GetByIdAsync(equipoId);

            if (equipo == null)
            {
                throw new NotFoundException("Equipo", equipoId);
            }

            equipo.Estado = nuevoEstado;
            equipo.ModificadoPor = modifiedBy;
            equipo.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Equipo>().Update(equipo);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        // Métodos privados auxiliares
        private string GenerarCodigoQR(string codigoInterno)
        {
            // Generar un código QR basado en el código interno + timestamp
            // En producción, esto podría generar un QR real usando una librería
            return $"QR-{codigoInterno}-{DateTime.UtcNow.Ticks}";
        }
    }
}
