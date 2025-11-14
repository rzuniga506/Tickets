# 🎫 FASE 3: Sistema de Tickets de Soporte

**Duración estimada:** 3-4 semanas
**Prioridad:** ALTA
**Dependencias:** Fase 1 y Fase 2 completadas
**Estado:** Pendiente

---

## 🎯 Objetivos

1. Sistema completo de tickets de soporte técnico
2. Asignación automática y manual de técnicos
3. Seguimiento de estados y prioridades
4. Sistema de comentarios y adjuntos
5. SLA (Service Level Agreement) con alertas
6. Dashboard para técnicos y usuarios
7. Evaluación del servicio
8. Integración con inventarios
9. Notificaciones en tiempo real

---

## 📋 Funcionalidades

### Para Usuarios Finales
- Crear tickets de soporte
- Ver estado de sus tickets
- Agregar comentarios
- Adjuntar archivos/capturas
- Evaluar el servicio recibido
- Ver historial de tickets

### Para Técnicos
- Ver tickets asignados
- Dashboard de tickets pendientes
- Actualizar estado de tickets
- Agregar comentarios y soluciones
- Cambiar prioridad
- Reasignar tickets
- Registrar tiempo invertido
- Marcar como resuelto

### Para Administradores
- Asignar/reasignar tickets
- Ver todos los tickets
- Configurar categorías y prioridades
- Definir SLAs
- Reportes y métricas
- Dashboard completo

---

## 🗃️ Modelo de Datos

### Ticket.cs (Domain/Entities/)
```csharp
public class Ticket : BaseEntity
{
    // Identificación
    public string NumeroTicket { get; set; }        // AUTO: TK-2024-00001
    public string Asunto { get; set; }
    public string Descripcion { get; set; }

    // Clasificación
    public int CategoriaId { get; set; }
    public CategoriaTicket Categoria { get; set; }

    public PrioridadTicket Prioridad { get; set; }  // Baja, Media, Alta, Crítica
    public EstadoTicket Estado { get; set; }        // Nuevo, EnProceso, EnEspera, Resuelto, Cerrado

    // Solicitante
    public int SolicitanteId { get; set; }
    public Usuario Solicitante { get; set; }

    // Asignación
    public int? TecnicoAsignadoId { get; set; }
    public Usuario TecnicoAsignado { get; set; }
    public DateTime? FechaAsignacion { get; set; }

    // Fechas y tiempos
    public DateTime FechaApertura { get; set; }
    public DateTime? FechaInicioProceso { get; set; }
    public DateTime? FechaResolucion { get; set; }
    public DateTime? FechaCierre { get; set; }
    public int? MinutosInvertidos { get; set; }

    // SLA
    public DateTime? FechaLimiteSLA { get; set; }
    public bool SLACumplido { get; set; }
    public int? MinutosRestantesSLA { get; set; }

    // Equipo relacionado (opcional)
    public int? EquipoId { get; set; }
    public Equipo Equipo { get; set; }

    // Ubicación del problema
    public int? UbicacionId { get; set; }
    public Ubicacion Ubicacion { get; set; }

    // Evaluación
    public int? CalificacionServicio { get; set; }   // 1-5
    public string ComentarioEvaluacion { get; set; }
    public DateTime? FechaEvaluacion { get; set; }

    // Solución
    public string Solucion { get; set; }
    public TipoSolucion? TipoSolucion { get; set; }  // Resuelto, Workaround, NoResuelto

    // Reaperturas
    public bool FueReabierto { get; set; }
    public int CantidadReaberturas { get; set; }

    // Relaciones
    public ICollection<ComentarioTicket> Comentarios { get; set; }
    public ICollection<AdjuntoTicket> Adjuntos { get; set; }
    public ICollection<HistorialEstadoTicket> HistorialEstados { get; set; }
}

public enum PrioridadTicket
{
    Baja = 1,
    Media = 2,
    Alta = 3,
    Critica = 4
}

public enum EstadoTicket
{
    Nuevo,
    Asignado,
    EnProceso,
    EnEspera,
    Resuelto,
    Cerrado,
    Cancelado
}

public enum TipoSolucion
{
    Resuelto,
    Workaround,
    NoResuelto,
    Derivado
}
```

### CategoriaTicket.cs (Domain/Entities/)
```csharp
public class CategoriaTicket : BaseEntity
{
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public string Icono { get; set; }
    public string Color { get; set; }

    // SLA por defecto
    public int TiempoRespuestaMinutos { get; set; }  // Tiempo para asignar
    public int TiempoResolucionMinutos { get; set; }  // Tiempo para resolver

    // Asignación automática
    public bool AsignacionAutomatica { get; set; }
    public int? GrupoTecnicosId { get; set; }        // Grupo asignado a esta categoría

    public bool Activa { get; set; }

    // Relaciones
    public ICollection<Ticket> Tickets { get; set; }
    public ICollection<SubcategoriaTicket> Subcategorias { get; set; }
}

// Ejemplos de categorías:
// - Hardware (PC, Impresora, Red)
// - Software (Instalación, Licencias, Errores)
// - Accesos (Permisos, Contraseñas, Cuentas)
// - Red (Conectividad, VPN, WiFi)
// - Telefonía
// - Otros
```

### SubcategoriaTicket.cs (Domain/Entities/)
```csharp
public class SubcategoriaTicket : BaseEntity
{
    public string Nombre { get; set; }
    public string Descripcion { get; set; }

    public int CategoriaId { get; set; }
    public CategoriaTicket Categoria { get; set; }
}
```

### ComentarioTicket.cs (Domain/Entities/)
```csharp
public class ComentarioTicket : BaseEntity
{
    public int TicketId { get; set; }
    public Ticket Ticket { get; set; }

    public int AutorId { get; set; }
    public Usuario Autor { get; set; }

    public string Contenido { get; set; }
    public bool EsInterno { get; set; }              // Solo visible para técnicos
    public DateTime FechaComentario { get; set; }

    // Tipo de comentario
    public TipoComentario Tipo { get; set; }         // Normal, CambioEstado, Reasignacion, etc.
}

public enum TipoComentario
{
    Normal,
    CambioEstado,
    Reasignacion,
    CambioPrioridad,
    Solucion,
    Seguimiento
}
```

### AdjuntoTicket.cs (Domain/Entities/)
```csharp
public class AdjuntoTicket : BaseEntity
{
    public int TicketId { get; set; }
    public Ticket Ticket { get; set; }

    public string NombreArchivo { get; set; }
    public string RutaArchivo { get; set; }
    public string Extension { get; set; }
    public long TamanoBytes { get; set; }
    public string TipoMime { get; set; }

    public int SubidoPorId { get; set; }
    public Usuario SubidoPor { get; set; }
}
```

### HistorialEstadoTicket.cs (Domain/Entities/)
```csharp
public class HistorialEstadoTicket : BaseEntity
{
    public int TicketId { get; set; }
    public Ticket Ticket { get; set; }

    public EstadoTicket EstadoAnterior { get; set; }
    public EstadoTicket EstadoNuevo { get; set; }
    public PrioridadTicket? PrioridadAnterior { get; set; }
    public PrioridadTicket? PrioridadNueva { get; set; }
    public int? TecnicoAnteriorId { get; set; }
    public int? TecnicoNuevoId { get; set; }

    public string Motivo { get; set; }
    public DateTime FechaCambio { get; set; }

    public int ModificadoPorId { get; set; }
    public Usuario ModificadoPor { get; set; }
}
```

### ConfiguracionSLA.cs (Domain/Entities/)
```csharp
public class ConfiguracionSLA : BaseEntity
{
    public string Nombre { get; set; }
    public string Descripcion { get; set; }

    public int? CategoriaId { get; set; }
    public CategoriaTicket Categoria { get; set; }

    public PrioridadTicket Prioridad { get; set; }

    // Tiempos en minutos
    public int TiempoRespuesta { get; set; }         // Tiempo para asignar/responder
    public int TiempoResolucion { get; set; }        // Tiempo para resolver

    // Horario laboral
    public bool Solo24x7 { get; set; }
    public TimeSpan HoraInicio { get; set; }
    public TimeSpan HoraFin { get; set; }

    public bool Activa { get; set; }
}
```

---

## 🔌 API Endpoints

### Tickets

```
GET    /api/tickets
       - Parámetros: page, pageSize, estado, prioridad, categoriaId,
                     tecnicoId, solicitanteId, search, fechaDesde, fechaHasta
       - Autorización: tickets.read
       - Response: Lista paginada de tickets

GET    /api/tickets/{id}
       - Autorización: tickets.read
       - Response: Detalle completo del ticket

POST   /api/tickets
       - Autorización: tickets.write
       - Body: TicketCreateDto
       - Response: Ticket creado con número generado

PUT    /api/tickets/{id}
       - Autorización: tickets.write
       - Body: TicketUpdateDto
       - Response: Ticket actualizado

DELETE /api/tickets/{id}
       - Autorización: tickets.delete
       - Response: 204 No Content (soft delete)

POST   /api/tickets/{id}/asignar
       - Autorización: tickets.assign
       - Body: AsignarTicketDto
       - Response: Ticket asignado

POST   /api/tickets/{id}/cambiar-estado
       - Autorización: tickets.write
       - Body: CambiarEstadoTicketDto
       - Response: Estado actualizado

POST   /api/tickets/{id}/cambiar-prioridad
       - Autorización: tickets.write
       - Body: CambiarPrioridadDto
       - Response: Prioridad actualizada

POST   /api/tickets/{id}/resolver
       - Autorización: tickets.write
       - Body: ResolverTicketDto
       - Response: Ticket resuelto

POST   /api/tickets/{id}/cerrar
       - Autorización: tickets.write
       - Response: Ticket cerrado

POST   /api/tickets/{id}/reabrir
       - Autorización: tickets.write
       - Body: ReabrirTicketDto
       - Response: Ticket reabierto

POST   /api/tickets/{id}/evaluar
       - Autorización: tickets.read (propio ticket)
       - Body: EvaluarTicketDto
       - Response: Evaluación guardada

GET    /api/tickets/{id}/historial
       - Autorización: tickets.read
       - Response: Historial de cambios

GET    /api/tickets/mis-tickets
       - Autorización: Authenticated
       - Response: Tickets del usuario autenticado

GET    /api/tickets/asignados-a-mi
       - Autorización: Authenticated
       - Response: Tickets asignados al técnico autenticado

GET    /api/tickets/estadisticas
       - Autorización: tickets.read
       - Response: Estadísticas dashboard
```

### Comentarios

```
GET    /api/tickets/{ticketId}/comentarios
       - Autorización: tickets.read
       - Response: Lista de comentarios

POST   /api/tickets/{ticketId}/comentarios
       - Autorización: tickets.write
       - Body: ComentarioCreateDto
       - Response: Comentario creado

PUT    /api/tickets/{ticketId}/comentarios/{id}
       - Autorización: tickets.write (propio comentario)
       - Body: ComentarioUpdateDto
       - Response: Comentario actualizado

DELETE /api/tickets/{ticketId}/comentarios/{id}
       - Autorización: tickets.write (propio comentario)
       - Response: 204 No Content
```

### Adjuntos

```
GET    /api/tickets/{ticketId}/adjuntos
POST   /api/tickets/{ticketId}/adjuntos
       - Multipart file upload
       - Max size: 10MB
DELETE /api/tickets/{ticketId}/adjuntos/{id}

GET    /api/tickets/{ticketId}/adjuntos/{id}/download
       - Response: File download
```

### Categorías

```
GET    /api/tickets/categorias
POST   /api/tickets/categorias
PUT    /api/tickets/categorias/{id}
DELETE /api/tickets/categorias/{id}
```

---

## 💻 Implementación Backend

### TicketService.cs (Application/Services/)

```csharp
public class TicketService : ITicketService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly INotificacionService _notificacionService;
    private readonly ISLAService _slaService;
    private readonly ICurrentUserService _currentUserService;

    public async Task<TicketDto> CrearTicketAsync(TicketCreateDto dto)
    {
        var ticket = _mapper.Map<Ticket>(dto);

        // Generar número de ticket
        ticket.NumeroTicket = await GenerarNumeroTicketAsync();

        // Establecer valores iniciales
        ticket.Estado = EstadoTicket.Nuevo;
        ticket.FechaApertura = DateTime.UtcNow;
        ticket.SolicitanteId = _currentUserService.UsuarioId;
        ticket.FueReabierto = false;
        ticket.CantidadReaberturas = 0;

        // Calcular SLA
        var sla = await _slaService.CalcularSLAAsync(
            dto.CategoriaId,
            dto.Prioridad
        );

        ticket.FechaLimiteSLA = sla.FechaLimite;

        _unitOfWork.Repository<Ticket>().Add(ticket);

        // Asignación automática si está configurada
        var categoria = await _unitOfWork.Repository<CategoriaTicket>()
            .GetByIdAsync(dto.CategoriaId);

        if (categoria.AsignacionAutomatica)
        {
            await AsignarAutomaticamenteAsync(ticket, categoria);
        }

        await _unitOfWork.SaveChangesAsync();

        // Notificar técnicos
        await _notificacionService.NotificarNuevoTicketAsync(ticket);

        return _mapper.Map<TicketDto>(ticket);
    }

    public async Task<TicketDto> AsignarTicketAsync(int ticketId, AsignarTicketDto dto)
    {
        var ticket = await _unitOfWork.Repository<Ticket>()
            .Include(t => t.Solicitante)
            .Include(t => t.TecnicoAsignado)
            .FirstOrDefaultAsync(t => t.Id == ticketId);

        if (ticket == null)
            throw new NotFoundException("Ticket no encontrado");

        // Validar que el técnico exista y tenga permisos
        var tecnico = await _unitOfWork.Repository<Usuario>()
            .GetByIdAsync(dto.TecnicoId);

        if (tecnico == null)
            throw new ValidationException("Técnico no encontrado");

        // Registrar historial
        var historial = new HistorialEstadoTicket
        {
            TicketId = ticketId,
            EstadoAnterior = ticket.Estado,
            EstadoNuevo = EstadoTicket.Asignado,
            TecnicoAnteriorId = ticket.TecnicoAsignadoId,
            TecnicoNuevoId = dto.TecnicoId,
            Motivo = dto.Motivo,
            FechaCambio = DateTime.UtcNow,
            ModificadoPorId = _currentUserService.UsuarioId
        };

        _unitOfWork.Repository<HistorialEstadoTicket>().Add(historial);

        // Actualizar ticket
        ticket.TecnicoAsignadoId = dto.TecnicoId;
        ticket.FechaAsignacion = DateTime.UtcNow;
        ticket.Estado = EstadoTicket.Asignado;

        await _unitOfWork.SaveChangesAsync();

        // Notificaciones
        await _notificacionService.NotificarAsignacionTicketAsync(
            ticket,
            tecnico,
            dto.Notificar
        );

        return _mapper.Map<TicketDto>(ticket);
    }

    public async Task<TicketDto> ResolverTicketAsync(int ticketId, ResolverTicketDto dto)
    {
        var ticket = await _unitOfWork.Repository<Ticket>()
            .Include(t => t.Solicitante)
            .Include(t => t.TecnicoAsignado)
            .FirstOrDefaultAsync(t => t.Id == ticketId);

        if (ticket == null)
            throw new NotFoundException("Ticket no encontrado");

        // Validar que el usuario sea el técnico asignado o admin
        if (ticket.TecnicoAsignadoId != _currentUserService.UsuarioId &&
            !_currentUserService.EsAdmin)
        {
            throw new UnauthorizedException("No autorizado para resolver este ticket");
        }

        // Registrar historial
        var historial = new HistorialEstadoTicket
        {
            TicketId = ticketId,
            EstadoAnterior = ticket.Estado,
            EstadoNuevo = EstadoTicket.Resuelto,
            FechaCambio = DateTime.UtcNow,
            Motivo = "Ticket resuelto",
            ModificadoPorId = _currentUserService.UsuarioId
        };

        _unitOfWork.Repository<HistorialEstadoTicket>().Add(historial);

        // Actualizar ticket
        ticket.Estado = EstadoTicket.Resuelto;
        ticket.FechaResolucion = DateTime.UtcNow;
        ticket.Solucion = dto.Solucion;
        ticket.TipoSolucion = dto.TipoSolucion;
        ticket.MinutosInvertidos = dto.MinutosInvertidos;

        // Calcular si cumplió SLA
        if (ticket.FechaLimiteSLA.HasValue)
        {
            ticket.SLACumplido = ticket.FechaResolucion <= ticket.FechaLimiteSLA;
        }

        // Agregar comentario de solución
        var comentario = new ComentarioTicket
        {
            TicketId = ticketId,
            AutorId = _currentUserService.UsuarioId,
            Contenido = $"Solución: {dto.Solucion}",
            Tipo = TipoComentario.Solucion,
            FechaComentario = DateTime.UtcNow,
            EsInterno = false
        };

        _unitOfWork.Repository<ComentarioTicket>().Add(comentario);

        await _unitOfWork.SaveChangesAsync();

        // Notificar solicitante
        await _notificacionService.NotificarTicketResueltoAsync(ticket);

        return _mapper.Map<TicketDto>(ticket);
    }

    public async Task<PagedResult<TicketDto>> ObtenerTicketsAsync(TicketFilterDto filtros)
    {
        var query = _unitOfWork.Repository<Ticket>()
            .Include(t => t.Categoria)
            .Include(t => t.Solicitante)
            .Include(t => t.TecnicoAsignado)
            .Include(t => t.Equipo)
            .Include(t => t.Ubicacion)
            .AsQueryable();

        // Aplicar filtros
        if (!string.IsNullOrEmpty(filtros.Search))
        {
            query = query.Where(t =>
                t.NumeroTicket.Contains(filtros.Search) ||
                t.Asunto.Contains(filtros.Search) ||
                t.Descripcion.Contains(filtros.Search)
            );
        }

        if (filtros.Estado.HasValue)
            query = query.Where(t => t.Estado == filtros.Estado);

        if (filtros.Prioridad.HasValue)
            query = query.Where(t => t.Prioridad == filtros.Prioridad);

        if (filtros.CategoriaId.HasValue)
            query = query.Where(t => t.CategoriaId == filtros.CategoriaId);

        if (filtros.TecnicoId.HasValue)
            query = query.Where(t => t.TecnicoAsignadoId == filtros.TecnicoId);

        if (filtros.SolicitanteId.HasValue)
            query = query.Where(t => t.SolicitanteId == filtros.SolicitanteId);

        if (filtros.FechaDesde.HasValue)
            query = query.Where(t => t.FechaApertura >= filtros.FechaDesde);

        if (filtros.FechaHasta.HasValue)
            query = query.Where(t => t.FechaApertura <= filtros.FechaHasta);

        if (filtros.SoloVencidos)
        {
            query = query.Where(t =>
                t.FechaLimiteSLA.HasValue &&
                t.FechaLimiteSLA < DateTime.UtcNow &&
                t.Estado != EstadoTicket.Resuelto &&
                t.Estado != EstadoTicket.Cerrado
            );
        }

        // Ordenamiento
        query = filtros.OrdenPor switch
        {
            "numero" => filtros.Descendente
                ? query.OrderByDescending(t => t.NumeroTicket)
                : query.OrderBy(t => t.NumeroTicket),
            "fecha" => filtros.Descendente
                ? query.OrderByDescending(t => t.FechaApertura)
                : query.OrderBy(t => t.FechaApertura),
            "prioridad" => filtros.Descendente
                ? query.OrderByDescending(t => t.Prioridad)
                : query.OrderBy(t => t.Prioridad),
            _ => query.OrderByDescending(t => t.Id)
        };

        var totalItems = await query.CountAsync();

        var tickets = await query
            .Skip((filtros.Page - 1) * filtros.PageSize)
            .Take(filtros.PageSize)
            .ToListAsync();

        var ticketsDto = _mapper.Map<List<TicketDto>>(tickets);

        return new PagedResult<TicketDto>
        {
            Items = ticketsDto,
            TotalItems = totalItems,
            Page = filtros.Page,
            PageSize = filtros.PageSize
        };
    }

    public async Task<EstadisticasTicketsDto> ObtenerEstadisticasAsync()
    {
        var hoy = DateTime.UtcNow;
        var inicioMes = new DateTime(hoy.Year, hoy.Month, 1);

        var stats = new EstadisticasTicketsDto
        {
            TotalTickets = await _unitOfWork.Repository<Ticket>().CountAsync(),

            TicketsAbiertos = await _unitOfWork.Repository<Ticket>()
                .CountAsync(t =>
                    t.Estado != EstadoTicket.Resuelto &&
                    t.Estado != EstadoTicket.Cerrado &&
                    t.Estado != EstadoTicket.Cancelado),

            TicketsNuevos = await _unitOfWork.Repository<Ticket>()
                .CountAsync(t => t.Estado == EstadoTicket.Nuevo),

            TicketsEnProceso = await _unitOfWork.Repository<Ticket>()
                .CountAsync(t => t.Estado == EstadoTicket.EnProceso),

            TicketsVencidosSLA = await _unitOfWork.Repository<Ticket>()
                .CountAsync(t =>
                    t.FechaLimiteSLA.HasValue &&
                    t.FechaLimiteSLA < hoy &&
                    t.Estado != EstadoTicket.Resuelto &&
                    t.Estado != EstadoTicket.Cerrado),

            TicketsResueltosHoy = await _unitOfWork.Repository<Ticket>()
                .CountAsync(t =>
                    t.FechaResolucion.HasValue &&
                    t.FechaResolucion.Value.Date == hoy.Date),

            TicketsResueltosEsteMes = await _unitOfWork.Repository<Ticket>()
                .CountAsync(t =>
                    t.FechaResolucion.HasValue &&
                    t.FechaResolucion >= inicioMes),

            PromedioResolucionHoras = await CalcularPromedioResolucionAsync(),

            TicketsPorCategoria = await _unitOfWork.Repository<Ticket>()
                .GroupBy(t => t.Categoria.Nombre)
                .Select(g => new { Categoria = g.Key, Cantidad = g.Count() })
                .ToListAsync(),

            TicketsPorPrioridad = await _unitOfWork.Repository<Ticket>()
                .Where(t =>
                    t.Estado != EstadoTicket.Resuelto &&
                    t.Estado != EstadoTicket.Cerrado)
                .GroupBy(t => t.Prioridad)
                .Select(g => new { Prioridad = g.Key, Cantidad = g.Count() })
                .ToListAsync(),

            TicketsPorEstado = await _unitOfWork.Repository<Ticket>()
                .GroupBy(t => t.Estado)
                .Select(g => new { Estado = g.Key, Cantidad = g.Count() })
                .ToListAsync(),

            CumplimientoSLA = await CalcularCumplimientoSLAAsync()
        };

        return stats;
    }

    private async Task<string> GenerarNumeroTicketAsync()
    {
        var año = DateTime.UtcNow.Year;
        var ultimoTicket = await _unitOfWork.Repository<Ticket>()
            .OrderByDescending(t => t.Id)
            .FirstOrDefaultAsync();

        var secuencia = 1;
        if (ultimoTicket != null)
        {
            // Extraer secuencia del último número
            var partes = ultimoTicket.NumeroTicket.Split('-');
            if (partes.Length == 3 && int.TryParse(partes[2], out int sec))
            {
                var añoUltimo = int.Parse(partes[1]);
                secuencia = añoUltimo == año ? sec + 1 : 1;
            }
        }

        return $"TK-{año}-{secuencia:D5}";
    }

    private async Task AsignarAutomaticamenteAsync(
        Ticket ticket,
        CategoriaTicket categoria)
    {
        // Lógica de asignación automática
        // Puede ser: round-robin, por carga de trabajo, por disponibilidad, etc.

        if (categoria.GrupoTecnicosId.HasValue)
        {
            var tecnicos = await _unitOfWork.Repository<UsuarioRol>()
                .Where(ur => ur.Rol.Nombre == "Técnico")
                .Select(ur => ur.Usuario)
                .ToListAsync();

            if (tecnicos.Any())
            {
                // Round-robin simple (puede mejorarse)
                var tecnicoConMenosCarga = await ObtenerTecnicoConMenorCargaAsync(tecnicos);
                ticket.TecnicoAsignadoId = tecnicoConMenosCarga.Id;
                ticket.FechaAsignacion = DateTime.UtcNow;
                ticket.Estado = EstadoTicket.Asignado;
            }
        }
    }

    private async Task<Usuario> ObtenerTecnicoConMenorCargaAsync(List<Usuario> tecnicos)
    {
        var cargaPorTecnico = new Dictionary<int, int>();

        foreach (var tecnico in tecnicos)
        {
            var ticketsActivos = await _unitOfWork.Repository<Ticket>()
                .CountAsync(t =>
                    t.TecnicoAsignadoId == tecnico.Id &&
                    t.Estado != EstadoTicket.Resuelto &&
                    t.Estado != EstadoTicket.Cerrado);

            cargaPorTecnico[tecnico.Id] = ticketsActivos;
        }

        var tecnicoIdConMenorCarga = cargaPorTecnico.OrderBy(x => x.Value).First().Key;
        return tecnicos.First(t => t.Id == tecnicoIdConMenorCarga);
    }

    private async Task<double> CalcularPromedioResolucionAsync()
    {
        var ticketsResueltos = await _unitOfWork.Repository<Ticket>()
            .Where(t => t.FechaResolucion.HasValue && t.FechaApertura != null)
            .Select(t => new
            {
                Horas = (t.FechaResolucion.Value - t.FechaApertura).TotalHours
            })
            .ToListAsync();

        return ticketsResueltos.Any()
            ? ticketsResueltos.Average(t => t.Horas)
            : 0;
    }

    private async Task<double> CalcularCumplimientoSLAAsync()
    {
        var ticketsConSLA = await _unitOfWork.Repository<Ticket>()
            .Where(t => t.FechaLimiteSLA.HasValue &&
                       (t.Estado == EstadoTicket.Resuelto || t.Estado == EstadoTicket.Cerrado))
            .ToListAsync();

        if (!ticketsConSLA.Any())
            return 100;

        var cumplidos = ticketsConSLA.Count(t => t.SLACumplido);
        return (double)cumplidos / ticketsConSLA.Count * 100;
    }
}
```

### SLAService.cs (Application/Services/)

```csharp
public class SLAService : ISLAService
{
    private readonly IUnitOfWork _unitOfWork;

    public async Task<SLACalculoDto> CalcularSLAAsync(
        int categoriaId,
        PrioridadTicket prioridad)
    {
        // Buscar configuración SLA
        var sla = await _unitOfWork.Repository<ConfiguracionSLA>()
            .FirstOrDefaultAsync(s =>
                s.Activa &&
                (s.CategoriaId == categoriaId || s.CategoriaId == null) &&
                s.Prioridad == prioridad);

        if (sla == null)
        {
            // Valores por defecto
            sla = ObtenerSLAPorDefecto(prioridad);
        }

        var fechaInicio = DateTime.UtcNow;
        var fechaLimite = CalcularFechaLimite(fechaInicio, sla);

        return new SLACalculoDto
        {
            FechaInicio = fechaInicio,
            FechaLimite = fechaLimite,
            MinutosResolucion = sla.TiempoResolucion,
            MinutosRespuesta = sla.TiempoRespuesta
        };
    }

    private DateTime CalcularFechaLimite(DateTime inicio, ConfiguracionSLA sla)
    {
        if (sla.Solo24x7)
        {
            // Calcular solo horario laboral
            var minutos = sla.TiempoResolucion;
            var fecha = inicio;

            while (minutos > 0)
            {
                // Saltar fines de semana
                if (fecha.DayOfWeek == DayOfWeek.Saturday ||
                    fecha.DayOfWeek == DayOfWeek.Sunday)
                {
                    fecha = fecha.AddDays(1).Date.Add(sla.HoraInicio);
                    continue;
                }

                // Calcular minutos en horario laboral
                var finJornada = fecha.Date.Add(sla.HoraFin);
                var minutosDisponibles = (finJornada - fecha).TotalMinutes;

                if (minutosDisponibles >= minutos)
                {
                    fecha = fecha.AddMinutes(minutos);
                    minutos = 0;
                }
                else
                {
                    minutos -= (int)minutosDisponibles;
                    fecha = fecha.AddDays(1).Date.Add(sla.HoraInicio);
                }
            }

            return fecha;
        }
        else
        {
            // 24/7
            return inicio.AddMinutes(sla.TiempoResolucion);
        }
    }

    private ConfiguracionSLA ObtenerSLAPorDefecto(PrioridadTicket prioridad)
    {
        return prioridad switch
        {
            PrioridadTicket.Critica => new ConfiguracionSLA
            {
                TiempoRespuesta = 30,      // 30 minutos
                TiempoResolucion = 240,    // 4 horas
                Solo24x7 = false
            },
            PrioridadTicket.Alta => new ConfiguracionSLA
            {
                TiempoRespuesta = 60,      // 1 hora
                TiempoResolucion = 480,    // 8 horas
                Solo24x7 = true,
                HoraInicio = new TimeSpan(8, 0, 0),
                HoraFin = new TimeSpan(18, 0, 0)
            },
            PrioridadTicket.Media => new ConfiguracionSLA
            {
                TiempoRespuesta = 240,     // 4 horas
                TiempoResolucion = 1440,   // 24 horas
                Solo24x7 = true,
                HoraInicio = new TimeSpan(8, 0, 0),
                HoraFin = new TimeSpan(18, 0, 0)
            },
            _ => new ConfiguracionSLA
            {
                TiempoRespuesta = 480,     // 8 horas
                TiempoResolucion = 2880,   // 48 horas
                Solo24x7 = true,
                HoraInicio = new TimeSpan(8, 0, 0),
                HoraFin = new TimeSpan(18, 0, 0)
            }
        };
    }
}
```

---

## 📱 Implementación Frontend

### Estructura de Pantallas

```
presentation/screens/tickets/
├── tickets_list_screen.dart
├── ticket_detail_screen.dart
├── ticket_create_screen.dart
├── ticket_comentarios_screen.dart
├── tickets_dashboard_screen.dart
├── mis_tickets_screen.dart
└── tickets_asignados_screen.dart
```

### tickets_list_screen.dart

```dart
class TicketsListScreen extends StatefulWidget {
  const TicketsListScreen({Key? key}) : super(key: key);

  @override
  State<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends State<TicketsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthBloc>().state.usuario?.esAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets de Soporte'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Todos', icon: Icon(Icons.list)),
            const Tab(text: 'Nuevos', icon: Icon(Icons.fiber_new)),
            if (isAdmin) ...[
              const Tab(text: 'En proceso', icon: Icon(Icons.pending_actions)),
              const Tab(text: 'Resueltos', icon: Icon(Icons.check_circle)),
            ] else ...[
              const Tab(text: 'Mis tickets', icon: Icon(Icons.person)),
              const Tab(text: 'Cerrados', icon: Icon(Icons.done_all)),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TicketsTab(estado: null),
          _TicketsTab(estado: EstadoTicket.nuevo),
          if (isAdmin) ...[
            _TicketsTab(estado: EstadoTicket.enProceso),
            _TicketsTab(estado: EstadoTicket.resuelto),
          ] else ...[
            _MisTicketsTab(),
            _TicketsTab(estado: EstadoTicket.cerrado),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tickets/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Ticket'),
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FiltrosTicketsSheet(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
```

### Widgets

**ticket_card.dart**
```dart
class TicketCard extends StatelessWidget {
  final TicketDto ticket;

  const TicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/tickets/${ticket.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Número de ticket
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.numeroTicket,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Prioridad
                  _PrioridadChip(prioridad: ticket.prioridad),
                  const SizedBox(width: 8),

                  // Estado
                  _EstadoChip(estado: ticket.estado),
                ],
              ),
              const SizedBox(height: 12),

              // Asunto
              Text(
                ticket.asunto,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                ticket.descripcion,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Info adicional
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.category,
                    label: ticket.categoria.nombre,
                  ),
                  if (ticket.tecnicoAsignado != null)
                    _InfoChip(
                      icon: Icons.person,
                      label: ticket.tecnicoAsignado!.nombre,
                    ),
                  _InfoChip(
                    icon: Icons.access_time,
                    label: _formatearFecha(ticket.fechaApertura),
                  ),
                  if (ticket.fechaLimiteSLA != null)
                    _SLAIndicator(
                      fechaLimite: ticket.fechaLimiteSLA!,
                      estado: ticket.estado,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy').format(fecha);
    }
  }
}

class _PrioridadChip extends StatelessWidget {
  final PrioridadTicket prioridad;

  const _PrioridadChip({required this.prioridad});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (prioridad) {
      case PrioridadTicket.critica:
        color = Colors.red;
        icon = Icons.error;
        break;
      case PrioridadTicket.alta:
        color = Colors.orange;
        icon = Icons.arrow_upward;
        break;
      case PrioridadTicket.media:
        color = Colors.yellow[700]!;
        icon = Icons.remove;
        break;
      case PrioridadTicket.baja:
        color = Colors.blue;
        icon = Icons.arrow_downward;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        prioridad.displayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final EstadoTicket estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (estado) {
      case EstadoTicket.nuevo:
        color = Colors.blue;
        break;
      case EstadoTicket.asignado:
      case EstadoTicket.enProceso:
        color = Colors.orange;
        break;
      case EstadoTicket.resuelto:
        color = Colors.green;
        break;
      case EstadoTicket.cerrado:
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        estado.displayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SLAIndicator extends StatelessWidget {
  final DateTime fechaLimite;
  final EstadoTicket estado;

  const _SLAIndicator({
    required this.fechaLimite,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    if (estado == EstadoTicket.resuelto || estado == EstadoTicket.cerrado) {
      return const SizedBox();
    }

    final ahora = DateTime.now();
    final vencido = ahora.isAfter(fechaLimite);
    final diferencia = fechaLimite.difference(ahora);

    String texto;
    Color color;

    if (vencido) {
      texto = 'SLA vencido';
      color = Colors.red;
    } else if (diferencia.inHours < 2) {
      texto = 'SLA: ${diferencia.inMinutes} min';
      color = Colors.red;
    } else if (diferencia.inHours < 24) {
      texto = 'SLA: ${diferencia.inHours} h';
      color = Colors.orange;
    } else {
      texto = 'SLA: ${diferencia.inDays} días';
      color = Colors.green;
    }

    return Chip(
      avatar: Icon(
        vencido ? Icons.warning : Icons.timer,
        size: 16,
        color: Colors.white,
      ),
      label: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
```

---

## ✅ Entregables de la Fase 3

- [ ] Modelo de datos completo de tickets
- [ ] API endpoints de tickets implementados
- [ ] Sistema de comentarios y adjuntos
- [ ] Cálculo y seguimiento de SLA
- [ ] Pantallas de gestión de tickets (CRUD)
- [ ] Pantalla de detalle de ticket
- [ ] Sistema de asignación (manual y automática)
- [ ] Dashboard de tickets
- [ ] Notificaciones en tiempo real (SignalR)
- [ ] Sistema de evaluación de servicio
- [ ] Reportes y estadísticas
- [ ] Filtros avanzados
- [ ] Pruebas unitarias e integración

---

## 🧪 Casos de Prueba

1. Crear ticket como usuario final
2. Asignación automática de tickets
3. Asignación manual por administrador
4. Actualizar estado de ticket
5. Agregar comentarios y adjuntos
6. Resolver ticket con solución
7. Evaluar servicio
8. Reapertura de ticket
9. Cálculo de SLA
10. Notificaciones en tiempo real
11. Filtrado y búsqueda de tickets
12. Dashboard y estadísticas

---

**Siguiente Fase:** [FASE 4: Módulos Adicionales Prioritarios](FASE-4.md)
