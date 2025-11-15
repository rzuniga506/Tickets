using Microsoft.EntityFrameworkCore;
using Tickets.Application.DTOs.Departamento;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation;

/// <summary>
/// Implementación del servicio de Departamentos
/// </summary>
public class DepartamentoService : IDepartamentoService
{
    private readonly IUnitOfWork _unitOfWork;

    public DepartamentoService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<DepartamentoDto>> GetAllAsync()
    {
        var departamentos = await _unitOfWork.Repository<Departamento>()
            .GetAllAsync(
                includeProperties: "Usuarios,Equipos",
                orderBy: q => q.OrderBy(d => d.Nombre)
            );

        return departamentos.Select(MapToDto);
    }

    public async Task<IEnumerable<DepartamentoDto>> GetActivosAsync()
    {
        var departamentos = await _unitOfWork.Repository<Departamento>()
            .GetAllAsync(
                filter: d => d.Activo,
                includeProperties: "Usuarios,Equipos",
                orderBy: q => q.OrderBy(d => d.Nombre)
            );

        return departamentos.Select(MapToDto);
    }

    public async Task<DepartamentoDto> GetByIdAsync(int id)
    {
        var departamentos = await _unitOfWork.Repository<Departamento>()
            .GetAllAsync(
                filter: d => d.Id == id,
                includeProperties: "Usuarios,Equipos"
            );

        var departamento = departamentos.FirstOrDefault();

        if (departamento == null)
        {
            throw new KeyNotFoundException($"Departamento con ID {id} no encontrado");
        }

        return MapToDto(departamento);
    }

    public async Task<DepartamentoDto> CreateAsync(CreateDepartamentoDto dto, int usuarioId)
    {
        // Validar que no exista otro departamento con el mismo nombre
        var existente = await _unitOfWork.Repository<Departamento>()
            .GetAllAsync(filter: d => d.Nombre.ToLower() == dto.Nombre.ToLower());

        if (existente.Any())
        {
            throw new InvalidOperationException($"Ya existe un departamento con el nombre '{dto.Nombre}'");
        }

        // Validar código único si se proporciona
        if (!string.IsNullOrEmpty(dto.Codigo))
        {
            var existenteCodigo = await _unitOfWork.Repository<Departamento>()
                .GetAllAsync(filter: d => d.Codigo == dto.Codigo);

            if (existenteCodigo.Any())
            {
                throw new InvalidOperationException($"Ya existe un departamento con el código '{dto.Codigo}'");
            }
        }

        var departamento = new Departamento
        {
            Nombre = dto.Nombre,
            Descripcion = dto.Descripcion,
            Codigo = dto.Codigo,
            Activo = dto.Activo,
            CreadoPor = usuarioId
        };

        await _unitOfWork.Repository<Departamento>().AddAsync(departamento);
        await _unitOfWork.SaveChangesAsync();

        return await GetByIdAsync(departamento.Id);
    }

    public async Task<DepartamentoDto> UpdateAsync(int id, UpdateDepartamentoDto dto, int usuarioId)
    {
        var departamento = await _unitOfWork.Repository<Departamento>().GetByIdAsync(id);

        if (departamento == null)
        {
            throw new KeyNotFoundException($"Departamento con ID {id} no encontrado");
        }

        // Validar que no exista otro departamento con el mismo nombre
        var existente = await _unitOfWork.Repository<Departamento>()
            .GetAllAsync(filter: d => d.Nombre.ToLower() == dto.Nombre.ToLower() && d.Id != id);

        if (existente.Any())
        {
            throw new InvalidOperationException($"Ya existe otro departamento con el nombre '{dto.Nombre}'");
        }

        // Validar código único si se proporciona
        if (!string.IsNullOrEmpty(dto.Codigo))
        {
            var existenteCodigo = await _unitOfWork.Repository<Departamento>()
                .GetAllAsync(filter: d => d.Codigo == dto.Codigo && d.Id != id);

            if (existenteCodigo.Any())
            {
                throw new InvalidOperationException($"Ya existe otro departamento con el código '{dto.Codigo}'");
            }
        }

        departamento.Nombre = dto.Nombre;
        departamento.Descripcion = dto.Descripcion;
        departamento.Codigo = dto.Codigo;
        departamento.Activo = dto.Activo;
        departamento.ModificadoPor = usuarioId;

        _unitOfWork.Repository<Departamento>().Update(departamento);
        await _unitOfWork.SaveChangesAsync();

        return await GetByIdAsync(departamento.Id);
    }

    public async Task DeleteAsync(int id)
    {
        var departamento = await _unitOfWork.Repository<Departamento>().GetByIdAsync(id);

        if (departamento == null)
        {
            throw new KeyNotFoundException($"Departamento con ID {id} no encontrado");
        }

        // Verificar si hay usuarios asociados
        var usuariosCount = await _unitOfWork.Repository<Usuario>()
            .CountAsync(u => u.DepartamentoId == id);

        if (usuariosCount > 0)
        {
            throw new InvalidOperationException(
                $"No se puede eliminar el departamento porque tiene {usuariosCount} usuario(s) asociado(s). " +
                "Desactive el departamento en lugar de eliminarlo.");
        }

        // Verificar si hay equipos asociados
        var equiposCount = await _unitOfWork.Repository<Equipo>()
            .CountAsync(e => e.DepartamentoId == id);

        if (equiposCount > 0)
        {
            throw new InvalidOperationException(
                $"No se puede eliminar el departamento porque tiene {equiposCount} equipo(s) asociado(s). " +
                "Desactive el departamento en lugar de eliminarlo.");
        }

        _unitOfWork.Repository<Departamento>().Delete(departamento);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task<DepartamentoDto> ToggleActivoAsync(int id, int usuarioId)
    {
        var departamento = await _unitOfWork.Repository<Departamento>().GetByIdAsync(id);

        if (departamento == null)
        {
            throw new KeyNotFoundException($"Departamento con ID {id} no encontrado");
        }

        departamento.Activo = !departamento.Activo;
        departamento.ModificadoPor = usuarioId;

        _unitOfWork.Repository<Departamento>().Update(departamento);
        await _unitOfWork.SaveChangesAsync();

        return await GetByIdAsync(id);
    }

    public async Task<Dictionary<string, int>> GetEstadisticasAsync(int id)
    {
        var departamento = await _unitOfWork.Repository<Departamento>().GetByIdAsync(id);

        if (departamento == null)
        {
            throw new KeyNotFoundException($"Departamento con ID {id} no encontrado");
        }

        var usuariosCount = await _unitOfWork.Repository<Usuario>()
            .CountAsync(u => u.DepartamentoId == id);

        var equiposCount = await _unitOfWork.Repository<Equipo>()
            .CountAsync(e => e.DepartamentoId == id);

        var ticketsCount = await _unitOfWork.Repository<Ticket>()
            .CountAsync(t => t.Solicitante.DepartamentoId == id);

        return new Dictionary<string, int>
        {
            { "TotalUsuarios", usuariosCount },
            { "TotalEquipos", equiposCount },
            { "TotalTickets", ticketsCount }
        };
    }

    private static DepartamentoDto MapToDto(Departamento departamento)
    {
        return new DepartamentoDto
        {
            Id = departamento.Id,
            Nombre = departamento.Nombre,
            Descripcion = departamento.Descripcion,
            Codigo = departamento.Codigo,
            Activo = departamento.Activo,
            CantidadUsuarios = departamento.Usuarios?.Count ?? 0,
            CantidadEquipos = departamento.Equipos?.Count ?? 0,
            FechaCreacion = departamento.FechaCreacion,
            FechaModificacion = departamento.FechaModificacion
        };
    }
}
