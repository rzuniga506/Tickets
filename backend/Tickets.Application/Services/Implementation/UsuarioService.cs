using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Usuarios;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Exceptions;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Implementación del servicio de gestión de usuarios
    /// </summary>
    public class UsuarioService : IUsuarioService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public UsuarioService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<PagedResult<UsuarioDto>> GetAllAsync(int pageNumber = 1, int pageSize = 10, string? searchTerm = null, bool? activo = null)
        {
            var query = _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                .Include(u => u.Departamento)
                .AsQueryable();

            // Aplicar filtros
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.ToLower();
                query = query.Where(u =>
                    u.Nombre.ToLower().Contains(searchTerm) ||
                    u.Apellido.ToLower().Contains(searchTerm) ||
                    u.Email.ToLower().Contains(searchTerm));
            }

            if (activo.HasValue)
            {
                query = query.Where(u => u.Activo == activo.Value);
            }

            // Total de registros
            var totalRecords = await query.CountAsync();

            // Aplicar paginación
            var usuarios = await query
                .OrderByDescending(u => u.FechaCreacion)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var usuariosDto = _mapper.Map<List<UsuarioDto>>(usuarios);

            return new PagedResult<UsuarioDto>
            {
                Items = usuariosDto,
                TotalRecords = totalRecords,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<UsuarioDto> GetByIdAsync(int id)
        {
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                .Include(u => u.Departamento)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (usuario == null)
            {
                throw new NotFoundException("Usuario", id);
            }

            return _mapper.Map<UsuarioDto>(usuario);
        }

        public async Task<UsuarioDto> CreateAsync(UsuarioCreateDto createDto, string createdBy)
        {
            // Validar que el email no exista
            var emailExists = await _unitOfWork.Repository<Usuario>()
                .AnyAsync(u => u.Email == createDto.Email);

            if (emailExists)
            {
                throw new ConflictException($"El email {createDto.Email} ya está registrado");
            }

            // Validar departamento si se especifica
            if (createDto.DepartamentoId.HasValue)
            {
                var departamentoExists = await _unitOfWork.Repository<Departamento>()
                    .AnyAsync(d => d.Id == createDto.DepartamentoId.Value);

                if (!departamentoExists)
                {
                    throw new NotFoundException("Departamento", createDto.DepartamentoId.Value);
                }
            }

            // Mapear a entidad
            var usuario = _mapper.Map<Usuario>(createDto);

            // Hash de la contraseña
            usuario.PasswordHash = BCrypt.Net.BCrypt.HashPassword(createDto.Password);
            usuario.CreadoPor = createdBy;
            usuario.FechaCreacion = DateTime.UtcNow;

            // Agregar usuario
            _unitOfWork.Repository<Usuario>().Add(usuario);
            await _unitOfWork.SaveChangesAsync();

            // Asignar roles si se especifican
            if (createDto.RolesIds != null && createDto.RolesIds.Any())
            {
                await AsignarRolesAsync(usuario.Id, createDto.RolesIds);
            }

            // Recargar usuario con relaciones
            return await GetByIdAsync(usuario.Id);
        }

        public async Task<UsuarioDto> UpdateAsync(int id, UsuarioUpdateDto updateDto, string modifiedBy)
        {
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(id);

            if (usuario == null)
            {
                throw new NotFoundException("Usuario", id);
            }

            // Validar departamento si se especifica
            if (updateDto.DepartamentoId.HasValue)
            {
                var departamentoExists = await _unitOfWork.Repository<Departamento>()
                    .AnyAsync(d => d.Id == updateDto.DepartamentoId.Value);

                if (!departamentoExists)
                {
                    throw new NotFoundException("Departamento", updateDto.DepartamentoId.Value);
                }
            }

            // Mapear cambios
            _mapper.Map(updateDto, usuario);
            usuario.ModificadoPor = modifiedBy;
            usuario.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Usuario>().Update(usuario);
            await _unitOfWork.SaveChangesAsync();

            // Actualizar roles si se especifican
            if (updateDto.RolesIds != null)
            {
                await AsignarRolesAsync(id, updateDto.RolesIds);
            }

            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(id);

            if (usuario == null)
            {
                throw new NotFoundException("Usuario", id);
            }

            _unitOfWork.Repository<Usuario>().Remove(usuario);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> ToggleActivoAsync(int id)
        {
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(id);

            if (usuario == null)
            {
                throw new NotFoundException("Usuario", id);
            }

            usuario.Activo = !usuario.Activo;
            usuario.FechaModificacion = DateTime.UtcNow;

            _unitOfWork.Repository<Usuario>().Update(usuario);
            await _unitOfWork.SaveChangesAsync();

            return usuario.Activo;
        }

        public async Task<bool> AsignarRolesAsync(int usuarioId, List<int> rolesIds)
        {
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                .FirstOrDefaultAsync(u => u.Id == usuarioId);

            if (usuario == null)
            {
                throw new NotFoundException("Usuario", usuarioId);
            }

            // Validar que todos los roles existan
            var rolesExistentes = await _unitOfWork.Repository<Rol>()
                .GetQueryable()
                .Where(r => rolesIds.Contains(r.Id))
                .Select(r => r.Id)
                .ToListAsync();

            var rolesInvalidos = rolesIds.Except(rolesExistentes).ToList();
            if (rolesInvalidos.Any())
            {
                throw new ValidationException($"Los siguientes roles no existen: {string.Join(", ", rolesInvalidos)}");
            }

            // Eliminar roles actuales
            var rolesActuales = await _unitOfWork.Repository<UsuarioRol>()
                .FindAsync(ur => ur.UsuarioId == usuarioId);

            foreach (var rolActual in rolesActuales)
            {
                _unitOfWork.Repository<UsuarioRol>().HardRemove(rolActual);
            }

            // Agregar nuevos roles
            foreach (var rolId in rolesIds)
            {
                var usuarioRol = new UsuarioRol
                {
                    UsuarioId = usuarioId,
                    RolId = rolId
                };
                _unitOfWork.Repository<UsuarioRol>().Add(usuarioRol);
            }

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<List<UsuarioDto>> GetByDepartamentoAsync(int departamentoId)
        {
            var usuarios = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                .Include(u => u.Departamento)
                .Where(u => u.DepartamentoId == departamentoId && u.Activo)
                .OrderBy(u => u.Nombre)
                .ToListAsync();

            return _mapper.Map<List<UsuarioDto>>(usuarios);
        }

        public async Task<List<UsuarioDto>> GetByRolAsync(int rolId)
        {
            var usuarios = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                .Include(u => u.Departamento)
                .Where(u => u.UsuarioRoles.Any(ur => ur.RolId == rolId) && u.Activo)
                .OrderBy(u => u.Nombre)
                .ToListAsync();

            return _mapper.Map<List<UsuarioDto>>(usuarios);
        }

        public async Task<List<UsuarioDto>> GetTecnicosActivosAsync()
        {
            // Buscar rol de técnico (asumimos que tiene "Tecnico" en el nombre)
            var usuarios = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                .Include(u => u.Departamento)
                .Where(u => u.Activo && u.UsuarioRoles.Any(ur =>
                    ur.Rol.Nombre.Contains("Técnico") ||
                    ur.Rol.Nombre.Contains("Admin")))
                .OrderBy(u => u.Nombre)
                .ToListAsync();

            return _mapper.Map<List<UsuarioDto>>(usuarios);
        }
    }
}
