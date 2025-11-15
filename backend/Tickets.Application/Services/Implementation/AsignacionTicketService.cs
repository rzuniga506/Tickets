using Microsoft.EntityFrameworkCore;
using Tickets.Application.DTOs.AsignacionTicket;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Enums;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Application.Services.Implementation;

/// <summary>
/// Implementación del servicio de Asignaciones de Tickets
/// </summary>
public class AsignacionTicketService : IAsignacionTicketService
{
    private readonly IUnitOfWork _unitOfWork;

    public AsignacionTicketService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<AsignacionTicketDto>> GetByTicketIdAsync(int ticketId)
    {
        var asignaciones = await _unitOfWork.Repository<AsignacionTicket>()
            .GetAllAsync(
                filter: a => a.TicketId == ticketId,
                orderBy: q => q.OrderByDescending(a => a.FechaCreacion),
                includeProperties: "Ticket,TecnicoAnterior,TecnicoNuevo,AsignadoPor"
            );

        return asignaciones.Select(MapToDto);
    }

    public async Task<AsignacionTicketDto> GetByIdAsync(int id)
    {
        var asignaciones = await _unitOfWork.Repository<AsignacionTicket>()
            .GetAllAsync(
                filter: a => a.Id == id,
                includeProperties: "Ticket,TecnicoAnterior,TecnicoNuevo,AsignadoPor"
            );

        var asignacion = asignaciones.FirstOrDefault();

        if (asignacion == null)
        {
            throw new KeyNotFoundException($"Asignación con ID {id} no encontrada");
        }

        return MapToDto(asignacion);
    }

    public async Task<AsignacionTicketDto> CreateAsync(CreateAsignacionTicketDto dto, int asignadoPorId)
    {
        // Validar que el ticket existe
        var ticket = await _unitOfWork.Repository<Ticket>().GetByIdAsync(dto.TicketId);
        if (ticket == null)
        {
            throw new KeyNotFoundException($"Ticket con ID {dto.TicketId} no encontrado");
        }

        // Validar que el técnico nuevo existe
        var tecnicoNuevo = await _unitOfWork.Repository<Usuario>().GetByIdAsync(dto.TecnicoNuevoId);
        if (tecnicoNuevo == null)
        {
            throw new KeyNotFoundException($"Técnico con ID {dto.TecnicoNuevoId} no encontrado");
        }

        // Validar que el técnico anterior existe (si se especifica)
        if (dto.TecnicoAnteriorId.HasValue)
        {
            var tecnicoAnterior = await _unitOfWork.Repository<Usuario>().GetByIdAsync(dto.TecnicoAnteriorId.Value);
            if (tecnicoAnterior == null)
            {
                throw new KeyNotFoundException($"Técnico anterior con ID {dto.TecnicoAnteriorId.Value} no encontrado");
            }

            // Validar que no se asigne al mismo técnico
            if (dto.TecnicoAnteriorId.Value == dto.TecnicoNuevoId)
            {
                throw new InvalidOperationException("No se puede asignar el ticket al mismo técnico");
            }
        }

        var asignacion = new AsignacionTicket
        {
            TicketId = dto.TicketId,
            TecnicoAnteriorId = dto.TecnicoAnteriorId,
            TecnicoNuevoId = dto.TecnicoNuevoId,
            Motivo = dto.Motivo,
            EsAsignacionAutomatica = dto.EsAsignacionAutomatica,
            MinutosConTecnicoAnterior = dto.MinutosConTecnicoAnterior,
            AsignadoPorId = asignadoPorId,
            CreadoPor = asignadoPorId
        };

        await _unitOfWork.Repository<AsignacionTicket>().AddAsync(asignacion);
        await _unitOfWork.SaveChangesAsync();

        return await GetByIdAsync(asignacion.Id);
    }

    public async Task<Dictionary<string, int>> GetEstadisticasAsignacionesPorTecnicoAsync()
    {
        var asignaciones = await _unitOfWork.Repository<AsignacionTicket>()
            .GetAllAsync(includeProperties: "TecnicoNuevo");

        var estadisticas = asignaciones
            .GroupBy(a => a.TecnicoNuevo != null
                ? $"{a.TecnicoNuevo.Nombre} {a.TecnicoNuevo.Apellido}"
                : "Sin asignar")
            .ToDictionary(
                g => g.Key,
                g => g.Count()
            );

        return estadisticas;
    }

    public async Task<Dictionary<string, int>> GetCargaActualPorTecnicoAsync()
    {
        // Obtener tickets activos (no cerrados ni cancelados)
        var ticketsActivos = await _unitOfWork.Repository<Ticket>()
            .GetAllAsync(
                filter: t => t.Estado != EstadoTicket.Cerrado && t.Estado != EstadoTicket.Cancelado,
                includeProperties: "TecnicoAsignado"
            );

        var cargaTrabajo = ticketsActivos
            .Where(t => t.TecnicoAsignado != null)
            .GroupBy(t => $"{t.TecnicoAsignado!.Nombre} {t.TecnicoAsignado.Apellido}")
            .ToDictionary(
                g => g.Key,
                g => g.Count()
            );

        return cargaTrabajo;
    }

    public async Task<Dictionary<string, double>> GetTiempoPromedioAsignacionPorTecnicoAsync()
    {
        var asignaciones = await _unitOfWork.Repository<AsignacionTicket>()
            .GetAllAsync(
                filter: a => a.MinutosConTecnicoAnterior.HasValue,
                includeProperties: "TecnicoAnterior"
            );

        var tiemposPromedio = asignaciones
            .Where(a => a.TecnicoAnterior != null)
            .GroupBy(a => $"{a.TecnicoAnterior!.Nombre} {a.TecnicoAnterior.Apellido}")
            .ToDictionary(
                g => g.Key,
                g => g.Average(a => a.MinutosConTecnicoAnterior ?? 0)
            );

        return tiemposPromedio;
    }

    private static AsignacionTicketDto MapToDto(AsignacionTicket asignacion)
    {
        return new AsignacionTicketDto
        {
            Id = asignacion.Id,
            TicketId = asignacion.TicketId,
            NumeroTicket = asignacion.Ticket?.NumeroTicket ?? "",
            TecnicoAnteriorId = asignacion.TecnicoAnteriorId,
            TecnicoAnteriorNombre = asignacion.TecnicoAnterior != null
                ? $"{asignacion.TecnicoAnterior.Nombre} {asignacion.TecnicoAnterior.Apellido}"
                : null,
            TecnicoNuevoId = asignacion.TecnicoNuevoId,
            TecnicoNuevoNombre = asignacion.TecnicoNuevo != null
                ? $"{asignacion.TecnicoNuevo.Nombre} {asignacion.TecnicoNuevo.Apellido}"
                : "",
            Motivo = asignacion.Motivo,
            EsAsignacionAutomatica = asignacion.EsAsignacionAutomatica,
            MinutosConTecnicoAnterior = asignacion.MinutosConTecnicoAnterior,
            AsignadoPorId = asignacion.AsignadoPorId,
            AsignadoPorNombre = asignacion.AsignadoPor != null
                ? $"{asignacion.AsignadoPor.Nombre} {asignacion.AsignadoPor.Apellido}"
                : "",
            FechaCreacion = asignacion.FechaCreacion,
            EsPrimeraAsignacion = asignacion.EsPrimeraAsignacion,
            EsReasignacion = asignacion.EsReasignacion
        };
    }
}
