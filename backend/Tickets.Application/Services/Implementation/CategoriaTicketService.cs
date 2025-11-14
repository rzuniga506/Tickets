using Microsoft.EntityFrameworkCore;
using Tickets.Application.DTOs.CategoriaTicket;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Infrastructure.Data;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation;

/// <summary>
/// Implementación del servicio de Categorías de Tickets
/// </summary>
public class CategoriaTicketService : ICategoriaTicketService
{
    private readonly IUnitOfWork _unitOfWork;

    public CategoriaTicketService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<CategoriaTicketDto>> GetAllAsync()
    {
        var categorias = await _unitOfWork.Repository<CategoriaTicket>()
            .GetAllAsync(
                orderBy: q => q.OrderBy(c => c.Orden).ThenBy(c => c.Nombre)
            );

        return categorias.Select(MapToDto);
    }

    public async Task<IEnumerable<CategoriaTicketDto>> GetActivosAsync()
    {
        var categorias = await _unitOfWork.Repository<CategoriaTicket>()
            .GetAllAsync(
                filter: c => c.Activo,
                orderBy: q => q.OrderBy(c => c.Orden).ThenBy(c => c.Nombre)
            );

        return categorias.Select(MapToDto);
    }

    public async Task<CategoriaTicketDto> GetByIdAsync(int id)
    {
        var categoria = await _unitOfWork.Repository<CategoriaTicket>().GetByIdAsync(id);

        if (categoria == null)
        {
            throw new KeyNotFoundException($"Categoría con ID {id} no encontrada");
        }

        return MapToDto(categoria);
    }

    public async Task<CategoriaTicketDto> CreateAsync(CreateCategoriaTicketDto dto, int usuarioId)
    {
        // Validar que no exista otra categoría con el mismo nombre
        var existente = await _unitOfWork.Repository<CategoriaTicket>()
            .GetAllAsync(filter: c => c.Nombre.ToLower() == dto.Nombre.ToLower());

        if (existente.Any())
        {
            throw new InvalidOperationException($"Ya existe una categoría con el nombre '{dto.Nombre}'");
        }

        var categoria = new CategoriaTicket
        {
            Nombre = dto.Nombre,
            Descripcion = dto.Descripcion,
            Color = dto.Color,
            Icono = dto.Icono,
            Orden = dto.Orden,
            Activo = dto.Activo,
            CreadoPor = usuarioId
        };

        await _unitOfWork.Repository<CategoriaTicket>().AddAsync(categoria);
        await _unitOfWork.SaveChangesAsync();

        return MapToDto(categoria);
    }

    public async Task<CategoriaTicketDto> UpdateAsync(int id, UpdateCategoriaTicketDto dto, int usuarioId)
    {
        var categoria = await _unitOfWork.Repository<CategoriaTicket>().GetByIdAsync(id);

        if (categoria == null)
        {
            throw new KeyNotFoundException($"Categoría con ID {id} no encontrada");
        }

        // Validar que no exista otra categoría con el mismo nombre
        var existente = await _unitOfWork.Repository<CategoriaTicket>()
            .GetAllAsync(filter: c => c.Nombre.ToLower() == dto.Nombre.ToLower() && c.Id != id);

        if (existente.Any())
        {
            throw new InvalidOperationException($"Ya existe otra categoría con el nombre '{dto.Nombre}'");
        }

        categoria.Nombre = dto.Nombre;
        categoria.Descripcion = dto.Descripcion;
        categoria.Color = dto.Color;
        categoria.Icono = dto.Icono;
        categoria.Orden = dto.Orden;
        categoria.Activo = dto.Activo;
        categoria.ModificadoPor = usuarioId;

        _unitOfWork.Repository<CategoriaTicket>().Update(categoria);
        await _unitOfWork.SaveChangesAsync();

        return MapToDto(categoria);
    }

    public async Task DeleteAsync(int id)
    {
        var categoria = await _unitOfWork.Repository<CategoriaTicket>().GetByIdAsync(id);

        if (categoria == null)
        {
            throw new KeyNotFoundException($"Categoría con ID {id} no encontrada");
        }

        // Verificar si hay tickets asociados
        var ticketsCount = await _unitOfWork.Repository<Ticket>()
            .CountAsync(t => t.CategoriaTicketId == id);

        if (ticketsCount > 0)
        {
            throw new InvalidOperationException(
                $"No se puede eliminar la categoría porque tiene {ticketsCount} ticket(s) asociado(s). " +
                "Desactive la categoría en lugar de eliminarla.");
        }

        _unitOfWork.Repository<CategoriaTicket>().Delete(categoria);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task<CategoriaTicketDto> ToggleActivoAsync(int id, int usuarioId)
    {
        var categoria = await _unitOfWork.Repository<CategoriaTicket>().GetByIdAsync(id);

        if (categoria == null)
        {
            throw new KeyNotFoundException($"Categoría con ID {id} no encontrada");
        }

        categoria.Activo = !categoria.Activo;
        categoria.ModificadoPor = usuarioId;

        _unitOfWork.Repository<CategoriaTicket>().Update(categoria);
        await _unitOfWork.SaveChangesAsync();

        return MapToDto(categoria);
    }

    public async Task ReorderAsync(Dictionary<int, int> ordenPorId, int usuarioId)
    {
        foreach (var kvp in ordenPorId)
        {
            var categoria = await _unitOfWork.Repository<CategoriaTicket>().GetByIdAsync(kvp.Key);

            if (categoria != null)
            {
                categoria.Orden = kvp.Value;
                categoria.ModificadoPor = usuarioId;
                _unitOfWork.Repository<CategoriaTicket>().Update(categoria);
            }
        }

        await _unitOfWork.SaveChangesAsync();
    }

    private static CategoriaTicketDto MapToDto(CategoriaTicket categoria)
    {
        return new CategoriaTicketDto
        {
            Id = categoria.Id,
            Nombre = categoria.Nombre,
            Descripcion = categoria.Descripcion,
            Color = categoria.Color,
            Icono = categoria.Icono,
            Orden = categoria.Orden,
            Activo = categoria.Activo,
            FechaCreacion = categoria.FechaCreacion,
            FechaModificacion = categoria.FechaModificacion
        };
    }
}
