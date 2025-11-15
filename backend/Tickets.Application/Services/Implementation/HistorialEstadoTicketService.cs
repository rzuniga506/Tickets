using Microsoft.EntityFrameworkCore;
using Tickets.Application.DTOs.HistorialEstadoTicket;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation;

/// <summary>
/// Implementación del servicio de Historial de Estados de Tickets
/// </summary>
public class HistorialEstadoTicketService : IHistorialEstadoTicketService
{
    private readonly IUnitOfWork _unitOfWork;

    public HistorialEstadoTicketService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<HistorialEstadoTicketDto>> GetByTicketIdAsync(int ticketId)
    {
        var historiales = await _unitOfWork.Repository<HistorialEstadoTicket>()
            .GetAllAsync(
                filter: h => h.TicketId == ticketId,
                orderBy: q => q.OrderByDescending(h => h.FechaCreacion),
                includeProperties: "Ticket,Usuario"
            );

        return historiales.Select(MapToDto);
    }

    public async Task<HistorialEstadoTicketDto> GetByIdAsync(int id)
    {
        var historial = await _unitOfWork.Repository<HistorialEstadoTicket>()
            .GetAllAsync(
                filter: h => h.Id == id,
                includeProperties: "Ticket,Usuario"
            );

        var entity = historial.FirstOrDefault();

        if (entity == null)
        {
            throw new KeyNotFoundException($"Historial con ID {id} no encontrado");
        }

        return MapToDto(entity);
    }

    public async Task<HistorialEstadoTicketDto> CreateAsync(CreateHistorialEstadoTicketDto dto, int usuarioId)
    {
        // Validar que el ticket existe
        var ticket = await _unitOfWork.Repository<Ticket>().GetByIdAsync(dto.TicketId);
        if (ticket == null)
        {
            throw new KeyNotFoundException($"Ticket con ID {dto.TicketId} no encontrado");
        }

        // Validar que el cambio de estado es válido
        if (dto.EstadoAnterior == dto.EstadoNuevo)
        {
            throw new InvalidOperationException("El estado anterior y el nuevo no pueden ser iguales");
        }

        var historial = new HistorialEstadoTicket
        {
            TicketId = dto.TicketId,
            EstadoAnterior = dto.EstadoAnterior,
            EstadoNuevo = dto.EstadoNuevo,
            Comentario = dto.Comentario,
            MinutosEnEstadoAnterior = dto.MinutosEnEstadoAnterior,
            UsuarioId = usuarioId,
            CreadoPor = usuarioId.ToString()
        };

        await _unitOfWork.Repository<HistorialEstadoTicket>().AddAsync(historial);
        await _unitOfWork.SaveChangesAsync();

        return await GetByIdAsync(historial.Id);
    }

    public async Task<Dictionary<string, int>> GetEstadisticasCambiosPorTicketAsync(int ticketId)
    {
        var historiales = await _unitOfWork.Repository<HistorialEstadoTicket>()
            .GetAllAsync(filter: h => h.TicketId == ticketId);

        var estadisticas = historiales
            .GroupBy(h => h.EstadoNuevoDescripcion)
            .ToDictionary(
                g => g.Key,
                g => g.Count()
            );

        return estadisticas;
    }

    public async Task<Dictionary<string, double>> GetTiempoPromedioEstadosAsync(int ticketId)
    {
        var historiales = await _unitOfWork.Repository<HistorialEstadoTicket>()
            .GetAllAsync(
                filter: h => h.TicketId == ticketId && h.MinutosEnEstadoAnterior.HasValue,
                orderBy: q => q.OrderBy(h => h.FechaCreacion)
            );

        var tiempos = historiales
            .GroupBy(h => h.EstadoAnteriorDescripcion)
            .ToDictionary(
                g => g.Key,
                g => g.Average(h => h.MinutosEnEstadoAnterior ?? 0)
            );

        return tiempos;
    }

    private static HistorialEstadoTicketDto MapToDto(HistorialEstadoTicket historial)
    {
        return new HistorialEstadoTicketDto
        {
            Id = historial.Id,
            TicketId = historial.TicketId,
            NumeroTicket = historial.Ticket?.NumeroTicket ?? "",
            EstadoAnterior = historial.EstadoAnterior,
            EstadoAnteriorDescripcion = historial.EstadoAnteriorDescripcion,
            EstadoNuevo = historial.EstadoNuevo,
            EstadoNuevoDescripcion = historial.EstadoNuevoDescripcion,
            Comentario = historial.Comentario,
            MinutosEnEstadoAnterior = historial.MinutosEnEstadoAnterior,
            UsuarioId = historial.UsuarioId,
            UsuarioNombre = historial.Usuario != null
                ? $"{historial.Usuario.Nombre} {historial.Usuario.Apellido}"
                : "",
            FechaCreacion = historial.FechaCreacion
        };
    }
}
