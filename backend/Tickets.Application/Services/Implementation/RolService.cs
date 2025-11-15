using Microsoft.EntityFrameworkCore;
using Tickets.Application.DTOs.Rol;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation;

public class RolService : IRolService
{
    private readonly IUnitOfWork _unitOfWork;

    public RolService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<RolDto>> GetAllAsync()
    {
        var roles = await _unitOfWork.Repository<Rol>()
            .GetAllAsync(includeProperties: "RolPermisos.Permiso,UsuarioRoles");
        return roles.Select(MapToDto);
    }

    public async Task<RolDto> GetByIdAsync(int id)
    {
        var roles = await _unitOfWork.Repository<Rol>()
            .GetAllAsync(filter: r => r.Id == id, includeProperties: "RolPermisos.Permiso,UsuarioRoles");
        var rol = roles.FirstOrDefault();
        if (rol == null) throw new KeyNotFoundException($"Rol {id} no encontrado");
        return MapToDto(rol);
    }

    public async Task<RolDto> CreateAsync(CreateRolDto dto, int usuarioId)
    {
        var existente = await _unitOfWork.Repository<Rol>()
            .GetAllAsync(filter: r => r.Nombre.ToLower() == dto.Nombre.ToLower());
        if (existente.Any()) throw new InvalidOperationException($"Rol '{dto.Nombre}' ya existe");

        var rol = new Rol
        {
            Nombre = dto.Nombre,
            Descripcion = dto.Descripcion,
            EsSistema = false,
            CreadoPor = usuarioId.ToString()
        };

        await _unitOfWork.Repository<Rol>().AddAsync(rol);
        await _unitOfWork.SaveChangesAsync();

        if (dto.PermisosIds.Any())
        {
            foreach (var permisoId in dto.PermisosIds)
            {
                await _unitOfWork.Repository<RolPermiso>().AddAsync(new RolPermiso
                {
                    RolId = rol.Id,
                    PermisoId = permisoId
                });
            }
            await _unitOfWork.SaveChangesAsync();
        }

        return await GetByIdAsync(rol.Id);
    }

    public async Task<RolDto> UpdateAsync(int id, UpdateRolDto dto, int usuarioId)
    {
        var rol = await _unitOfWork.Repository<Rol>().GetByIdAsync(id);
        if (rol == null) throw new KeyNotFoundException($"Rol {id} no encontrado");
        if (rol.EsSistema) throw new InvalidOperationException("No se puede modificar un rol del sistema");

        var existente = await _unitOfWork.Repository<Rol>()
            .GetAllAsync(filter: r => r.Nombre.ToLower() == dto.Nombre.ToLower() && r.Id != id);
        if (existente.Any()) throw new InvalidOperationException($"Ya existe otro rol '{dto.Nombre}'");

        rol.Nombre = dto.Nombre;
        rol.Descripcion = dto.Descripcion;
        rol.ModificadoPor = usuarioId.ToString();

        _unitOfWork.Repository<Rol>().Update(rol);

        // Actualizar permisos
        var permisosActuales = await _unitOfWork.Repository<RolPermiso>()
            .GetAllAsync(filter: rp => rp.RolId == id);
        foreach (var rp in permisosActuales)
            _unitOfWork.Repository<RolPermiso>().Delete(rp);

        foreach (var permisoId in dto.PermisosIds)
        {
            await _unitOfWork.Repository<RolPermiso>().AddAsync(new RolPermiso
            {
                RolId = id,
                PermisoId = permisoId
            });
        }

        await _unitOfWork.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task DeleteAsync(int id)
    {
        var rol = await _unitOfWork.Repository<Rol>().GetByIdAsync(id);
        if (rol == null) throw new KeyNotFoundException($"Rol {id} no encontrado");
        if (rol.EsSistema) throw new InvalidOperationException("No se puede eliminar un rol del sistema");

        var usuariosCount = await _unitOfWork.Repository<UsuarioRol>().CountAsync(ur => ur.RolId == id);
        if (usuariosCount > 0)
            throw new InvalidOperationException($"No se puede eliminar el rol porque tiene {usuariosCount} usuario(s) asociado(s)");

        _unitOfWork.Repository<Rol>().Delete(rol);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task<RolDto> AsignarPermisosAsync(int rolId, List<int> permisosIds, int usuarioId)
    {
        var rol = await _unitOfWork.Repository<Rol>().GetByIdAsync(rolId);
        if (rol == null) throw new KeyNotFoundException($"Rol {rolId} no encontrado");

        var permisosActuales = await _unitOfWork.Repository<RolPermiso>()
            .GetAllAsync(filter: rp => rp.RolId == rolId);
        foreach (var rp in permisosActuales)
            _unitOfWork.Repository<RolPermiso>().Delete(rp);

        foreach (var permisoId in permisosIds)
        {
            await _unitOfWork.Repository<RolPermiso>().AddAsync(new RolPermiso
            {
                RolId = rolId,
                PermisoId = permisoId
            });
        }

        await _unitOfWork.SaveChangesAsync();
        return await GetByIdAsync(rolId);
    }

    private static RolDto MapToDto(Rol rol)
    {
        return new RolDto
        {
            Id = rol.Id,
            Nombre = rol.Nombre,
            Descripcion = rol.Descripcion,
            EsSistema = rol.EsSistema,
            PermisosIds = rol.RolPermisos?.Select(rp => rp.PermisoId).ToList() ?? new(),
            CantidadUsuarios = rol.UsuarioRoles?.Count ?? 0,
            FechaCreacion = rol.FechaCreacion
        };
    }
}
