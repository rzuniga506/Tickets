using AutoMapper;
using Tickets.Application.DTOs.Permisos;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation;

public class PermisoService : IPermisoService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public PermisoService(IUnitOfWork unitOfWork, IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<IEnumerable<PermisoDto>> GetAllAsync()
    {
        var permisos = await _unitOfWork.Repository<Permiso>()
            .GetAllAsync(orderBy: q => q.OrderBy(p => p.Modulo).ThenBy(p => p.Nombre));

        return _mapper.Map<IEnumerable<PermisoDto>>(permisos);
    }

    public async Task<IEnumerable<PermisoDto>> GetByModuloAsync(string modulo)
    {
        var permisos = await _unitOfWork.Repository<Permiso>()
            .GetAllAsync(
                filter: p => p.Modulo.ToLower() == modulo.ToLower(),
                orderBy: q => q.OrderBy(p => p.Nombre));

        return _mapper.Map<IEnumerable<PermisoDto>>(permisos);
    }

    public async Task<PermisoDto> GetByIdAsync(int id)
    {
        var permiso = await _unitOfWork.Repository<Permiso>().GetByIdAsync(id);

        if (permiso == null)
        {
            throw new KeyNotFoundException($"Permiso con ID {id} no encontrado");
        }

        return _mapper.Map<PermisoDto>(permiso);
    }
}
