# 🎯 FASE 4: Módulos Adicionales Prioritarios

**Duración estimada:** 4-5 semanas
**Prioridad:** ALTA
**Dependencias:** Fases 1, 2 y 3 completadas
**Estado:** Pendiente

---

## 🎯 Objetivos

Esta fase integra los módulos adicionales que son críticos para la operación completa del sistema:

1. **Sistema de Notificaciones** (Push, Email, In-App)
2. **Gestión de Ubicaciones** (Oficinas, pisos, áreas)
3. **Gestión de Proveedores** (Catálogo, garantías, contratos)
4. **Control de Accesos Avanzado** (Permisos granulares, auditoría)

---

# 📢 MÓDULO 1: Sistema de Notificaciones

## Objetivos
- Notificaciones push multiplataforma
- Notificaciones por correo electrónico
- Notificaciones in-app en tiempo real
- Centro de notificaciones
- Configuración de preferencias

## Modelo de Datos

### Notificacion.cs (Domain/Entities/)
```csharp
public class Notificacion : BaseEntity
{
    public string Titulo { get; set; }
    public string Mensaje { get; set; }
    public TipoNotificacion Tipo { get; set; }
    public PrioridadNotificacion Prioridad { get; set; }

    // Destinatario
    public int UsuarioId { get; set; }
    public Usuario Usuario { get; set; }

    // Estado
    public bool Leida { get; set; }
    public DateTime? FechaLeida { get; set; }
    public bool Enviada { get; set; }
    public DateTime? FechaEnvio { get; set; }

    // Metadata
    public string EntidadTipo { get; set; }      // "Ticket", "Equipo", etc.
    public int? EntidadId { get; set; }
    public string Accion { get; set; }           // "creado", "asignado", etc.
    public string DatosJson { get; set; }        // Datos adicionales en JSON

    // Link de acción
    public string UrlAccion { get; set; }
    public string IconoUrl { get; set; }

    // Canales
    public bool EnviarPush { get; set; }
    public bool EnviarEmail { get; set; }
    public bool MostrarInApp { get; set; }
}

public enum TipoNotificacion
{
    Sistema,
    TicketNuevo,
    TicketAsignado,
    TicketActualizado,
    TicketResuelto,
    TicketComentario,
    EquipoAsignado,
    EquipoLiberado,
    SoftwarePorVencer,
    GarantiaPorVencer,
    AlertaSLA,
    Otro
}

public enum PrioridadNotificacion
{
    Baja,
    Normal,
    Alta,
    Urgente
}
```

### PreferenciaNotificacion.cs (Domain/Entities/)
```csharp
public class PreferenciaNotificacion : BaseEntity
{
    public int UsuarioId { get; set; }
    public Usuario Usuario { get; set; }

    public TipoNotificacion TipoNotificacion { get; set; }

    // Canales habilitados
    public bool PushHabilitado { get; set; }
    public bool EmailHabilitado { get; set; }
    public bool InAppHabilitado { get; set; }

    // Horarios
    public bool SoloHorarioLaboral { get; set; }
    public TimeSpan? HoraInicio { get; set; }
    public TimeSpan? HoraFin { get; set; }

    // Agrupación
    public bool AgruparNotificaciones { get; set; }
    public int MinutosAgrupacion { get; set; }
}
```

### DispositivoUsuario.cs (Domain/Entities/)
```csharp
public class DispositivoUsuario : BaseEntity
{
    public int UsuarioId { get; set; }
    public Usuario Usuario { get; set; }

    public string TokenPush { get; set; }
    public PlataformaDispositivo Plataforma { get; set; }
    public string NombreDispositivo { get; set; }
    public string VersionApp { get; set; }

    public bool Activo { get; set; }
    public DateTime UltimoAcceso { get; set; }
}

public enum PlataformaDispositivo
{
    Android,
    iOS,
    Web,
    Windows,
    macOS,
    Linux
}
```

## API Endpoints

```
GET    /api/notificaciones
       - Parámetros: leidas, tipo, page, pageSize
       - Response: Lista paginada de notificaciones del usuario

GET    /api/notificaciones/no-leidas/count
       - Response: Cantidad de notificaciones no leídas

PUT    /api/notificaciones/{id}/marcar-leida
       - Response: Notificación marcada como leída

PUT    /api/notificaciones/marcar-todas-leidas
       - Response: Todas las notificaciones marcadas

DELETE /api/notificaciones/{id}
       - Response: 204 No Content

POST   /api/notificaciones/registrar-dispositivo
       - Body: { tokenPush, plataforma, nombreDispositivo }
       - Response: Dispositivo registrado

GET    /api/notificaciones/preferencias
       - Response: Preferencias de notificación del usuario

PUT    /api/notificaciones/preferencias
       - Body: PreferenciasNotificacionDto
       - Response: Preferencias actualizadas

POST   /api/notificaciones/test
       - Admin only
       - Body: { usuarioId, tipo }
       - Response: Notificación de prueba enviada
```

## Implementación Backend

### NotificacionService.cs
```csharp
public class NotificacionService : INotificacionService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IHubContext<NotificacionesHub> _hubContext;
    private readonly IPushNotificationService _pushService;
    private readonly IEmailService _emailService;

    public async Task EnviarNotificacionAsync(NotificacionDto dto)
    {
        var notificacion = _mapper.Map<Notificacion>(dto);

        // Verificar preferencias del usuario
        var preferencias = await ObtenerPreferenciasAsync(dto.UsuarioId, dto.Tipo);

        notificacion.EnviarPush = preferencias.PushHabilitado;
        notificacion.EnviarEmail = preferencias.EmailHabilitado;
        notificacion.MostrarInApp = preferencias.InAppHabilitado;

        _unitOfWork.Repository<Notificacion>().Add(notificacion);
        await _unitOfWork.SaveChangesAsync();

        // Enviar por diferentes canales
        var tasks = new List<Task>();

        // In-App (SignalR)
        if (notificacion.MostrarInApp)
        {
            tasks.Add(_hubContext.Clients
                .User(dto.UsuarioId.ToString())
                .SendAsync("NuevaNotificacion", notificacion));
        }

        // Push Notification
        if (notificacion.EnviarPush)
        {
            tasks.Add(EnviarPushAsync(notificacion));
        }

        // Email
        if (notificacion.EnviarEmail)
        {
            tasks.Add(EnviarEmailAsync(notificacion));
        }

        await Task.WhenAll(tasks);

        notificacion.Enviada = true;
        notificacion.FechaEnvio = DateTime.UtcNow;
        await _unitOfWork.SaveChangesAsync();
    }

    private async Task EnviarPushAsync(Notificacion notificacion)
    {
        var dispositivos = await _unitOfWork.Repository<DispositivoUsuario>()
            .Where(d => d.UsuarioId == notificacion.UsuarioId && d.Activo)
            .ToListAsync();

        foreach (var dispositivo in dispositivos)
        {
            try
            {
                await _pushService.EnviarAsync(
                    dispositivo.TokenPush,
                    dispositivo.Plataforma,
                    notificacion.Titulo,
                    notificacion.Mensaje,
                    new { notificacionId = notificacion.Id }
                );
            }
            catch (Exception ex)
            {
                // Log error pero no fallar
                _logger.LogError(ex, "Error enviando push a dispositivo {DispositivoId}",
                    dispositivo.Id);
            }
        }
    }

    private async Task EnviarEmailAsync(Notificacion notificacion)
    {
        var usuario = await _unitOfWork.Repository<Usuario>()
            .GetByIdAsync(notificacion.UsuarioId);

        await _emailService.EnviarAsync(new EmailDto
        {
            Para = usuario.Email,
            Asunto = notificacion.Titulo,
            Cuerpo = GenerarCuerpoEmail(notificacion),
            EsHtml = true
        });
    }

    public async Task NotificarNuevoTicketAsync(Ticket ticket)
    {
        // Notificar a administradores y técnicos
        var adminYTecnicos = await ObtenerAdministradoresYTecnicosAsync();

        foreach (var usuario in adminYTecnicos)
        {
            await EnviarNotificacionAsync(new NotificacionDto
            {
                UsuarioId = usuario.Id,
                Tipo = TipoNotificacion.TicketNuevo,
                Prioridad = MapearPrioridad(ticket.Prioridad),
                Titulo = $"Nuevo ticket: {ticket.NumeroTicket}",
                Mensaje = $"{ticket.Solicitante.Nombre} creó un ticket: {ticket.Asunto}",
                EntidadTipo = "Ticket",
                EntidadId = ticket.Id,
                Accion = "creado",
                UrlAccion = $"/tickets/{ticket.Id}"
            });
        }
    }

    public async Task NotificarAsignacionTicketAsync(
        Ticket ticket,
        Usuario tecnico,
        bool notificarSolicitante = true)
    {
        // Notificar al técnico asignado
        await EnviarNotificacionAsync(new NotificacionDto
        {
            UsuarioId = tecnico.Id,
            Tipo = TipoNotificacion.TicketAsignado,
            Prioridad = MapearPrioridad(ticket.Prioridad),
            Titulo = $"Ticket asignado: {ticket.NumeroTicket}",
            Mensaje = $"Se te asignó el ticket: {ticket.Asunto}",
            EntidadTipo = "Ticket",
            EntidadId = ticket.Id,
            Accion = "asignado",
            UrlAccion = $"/tickets/{ticket.Id}"
        });

        // Notificar al solicitante
        if (notificarSolicitante)
        {
            await EnviarNotificacionAsync(new NotificacionDto
            {
                UsuarioId = ticket.SolicitanteId,
                Tipo = TipoNotificacion.TicketActualizado,
                Prioridad = PrioridadNotificacion.Normal,
                Titulo = $"Ticket actualizado: {ticket.NumeroTicket}",
                Mensaje = $"Tu ticket fue asignado a {tecnico.Nombre}",
                EntidadTipo = "Ticket",
                EntidadId = ticket.Id,
                Accion = "actualizado",
                UrlAccion = $"/tickets/{ticket.Id}"
            });
        }
    }

    public async Task NotificarTicketResueltoAsync(Ticket ticket)
    {
        await EnviarNotificacionAsync(new NotificacionDto
        {
            UsuarioId = ticket.SolicitanteId,
            Tipo = TipoNotificacion.TicketResuelto,
            Prioridad = PrioridadNotificacion.Normal,
            Titulo = $"Ticket resuelto: {ticket.NumeroTicket}",
            Mensaje = $"Tu ticket ha sido resuelto. Por favor, evalúa el servicio.",
            EntidadTipo = "Ticket",
            EntidadId = ticket.Id,
            Accion = "resuelto",
            UrlAccion = $"/tickets/{ticket.Id}/evaluar"
        });
    }

    public async Task NotificarAsignacionEquipoAsync(int usuarioId, Equipo equipo)
    {
        await EnviarNotificacionAsync(new NotificacionDto
        {
            UsuarioId = usuarioId,
            Tipo = TipoNotificacion.EquipoAsignado,
            Prioridad = PrioridadNotificacion.Normal,
            Titulo = "Equipo asignado",
            Mensaje = $"Se te asignó el equipo: {equipo.Nombre} ({equipo.CodigoInterno})",
            EntidadTipo = "Equipo",
            EntidadId = equipo.Id,
            Accion = "asignado",
            UrlAccion = $"/inventario/{equipo.Id}"
        });
    }
}
```

### PushNotificationService.cs (Firebase)
```csharp
public class PushNotificationService : IPushNotificationService
{
    private readonly FirebaseMessaging _messaging;

    public async Task EnviarAsync(
        string token,
        PlataformaDispositivo plataforma,
        string titulo,
        string mensaje,
        object data = null)
    {
        var message = new Message
        {
            Token = token,
            Notification = new Notification
            {
                Title = titulo,
                Body = mensaje
            },
            Data = data != null
                ? JsonSerializer.Serialize(data)
                    .ToDictionary(x => x.Key, x => x.Value.ToString())
                : null
        };

        // Configuración específica por plataforma
        if (plataforma == PlataformaDispositivo.Android)
        {
            message.Android = new AndroidConfig
            {
                Priority = Priority.High,
                Notification = new AndroidNotification
                {
                    Sound = "default",
                    ChannelId = "tickets_channel"
                }
            };
        }
        else if (plataforma == PlataformaDispositivo.iOS)
        {
            message.Apns = new ApnsConfig
            {
                Aps = new Aps
                {
                    Sound = "default",
                    Badge = 1
                }
            };
        }

        await _messaging.SendAsync(message);
    }
}
```

## Implementación Frontend

### NotificationService (Flutter)
```dart
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SignalRService _signalr;
  final StorageService _storage;

  Future<void> initialize() async {
    // Solicitar permisos
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Obtener token
      final token = await _messaging.getToken();
      if (token != null) {
        await _registrarDispositivo(token);
      }

      // Escuchar cambios de token
      _messaging.onTokenRefresh.listen(_registrarDispositivo);

      // Configurar handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    }

    // SignalR para notificaciones en tiempo real
    _signalr.on('NuevaNotificacion', _handleSignalRNotification);
  }

  Future<void> _registrarDispositivo(String token) async {
    final deviceInfo = await _getDeviceInfo();

    await _apiClient.post('/api/notificaciones/registrar-dispositivo', data: {
      'tokenPush': token,
      'plataforma': deviceInfo.platform,
      'nombreDispositivo': deviceInfo.name,
      'versionApp': deviceInfo.appVersion,
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Mostrar notificación local
    _showLocalNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      payload: json.encode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navegar a la pantalla correspondiente
    final data = message.data;
    if (data['notificacionId'] != null) {
      _navigateToNotification(data);
    }
  }

  void _handleSignalRNotification(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final notificacion = Notificacion.fromJson(args[0] as Map<String, dynamic>);
      _mostrarNotificacionInApp(notificacion);
    }
  }
}
```

---

# 📍 MÓDULO 2: Gestión de Ubicaciones

## Objetivos
- Gestionar ubicaciones físicas (edificios, pisos, áreas)
- Jerarquía de ubicaciones
- Mapa de equipos por ubicación
- Asignación de equipos a ubicaciones

## Modelo de Datos

### Ubicacion.cs (Domain/Entities/)
```csharp
public class Ubicacion : BaseEntity
{
    public string Nombre { get; set; }
    public string Codigo { get; set; }               // Ej: "ED1-P2-A3"
    public string Descripcion { get; set; }
    public TipoUbicacion Tipo { get; set; }

    // Jerarquía
    public int? UbicacionPadreId { get; set; }
    public Ubicacion UbicacionPadre { get; set; }
    public ICollection<Ubicacion> UbicacionesHijas { get; set; }

    // Información adicional
    public string Direccion { get; set; }
    public string Ciudad { get; set; }
    public string Pais { get; set; }
    public string CodigoPostal { get; set; }

    // Coordenadas (opcional)
    public decimal? Latitud { get; set; }
    public decimal? Longitud { get; set; }

    // Contacto
    public string TelefonoContacto { get; set; }
    public string EmailContacto { get; set; }
    public int? ResponsableId { get; set; }
    public Usuario Responsable { get; set; }

    // Capacidad
    public int? CapacidadPersonas { get; set; }
    public int? CapacidadEquipos { get; set; }

    // Estado
    public bool Activa { get; set; }

    // Relaciones
    public ICollection<Equipo> Equipos { get; set; }
    public ICollection<Usuario> Usuarios { get; set; }
    public ICollection<Ticket> Tickets { get; set; }
}

public enum TipoUbicacion
{
    Pais,
    Ciudad,
    Edificio,
    Piso,
    Area,
    Sala,
    Escritorio
}
```

## API Endpoints

```
GET    /api/ubicaciones
       - Parámetros: tipo, activas, page, pageSize
       - Response: Lista paginada

GET    /api/ubicaciones/jerarquia
       - Response: Árbol jerárquico de ubicaciones

GET    /api/ubicaciones/{id}
POST   /api/ubicaciones
PUT    /api/ubicaciones/{id}
DELETE /api/ubicaciones/{id}

GET    /api/ubicaciones/{id}/equipos
       - Response: Equipos en esta ubicación

GET    /api/ubicaciones/{id}/usuarios
       - Response: Usuarios en esta ubicación

GET    /api/ubicaciones/{id}/estadisticas
       - Response: Stats de la ubicación
```

## Implementación

### UbicacionService.cs
```csharp
public class UbicacionService : IUbicacionService
{
    public async Task<List<UbicacionJerarquiaDto>> ObtenerJerarquiaAsync()
    {
        var ubicaciones = await _unitOfWork.Repository<Ubicacion>()
            .Include(u => u.UbicacionesHijas)
            .ThenInclude(u => u.UbicacionesHijas)
            .Where(u => u.UbicacionPadreId == null && u.Activa)
            .ToListAsync();

        return _mapper.Map<List<UbicacionJerarquiaDto>>(ubicaciones);
    }

    public async Task<UbicacionDto> CrearUbicacionAsync(UbicacionCreateDto dto)
    {
        // Validar código único
        var existeCodigo = await _unitOfWork.Repository<Ubicacion>()
            .AnyAsync(u => u.Codigo == dto.Codigo);

        if (existeCodigo)
            throw new ValidationException("El código ya existe");

        // Validar ubicación padre
        if (dto.UbicacionPadreId.HasValue)
        {
            var padre = await _unitOfWork.Repository<Ubicacion>()
                .GetByIdAsync(dto.UbicacionPadreId.Value);

            if (padre == null)
                throw new NotFoundException("Ubicación padre no encontrada");

            // Validar jerarquía lógica
            ValidarJerarquia(dto.Tipo, padre.Tipo);
        }

        var ubicacion = _mapper.Map<Ubicacion>(dto);
        _unitOfWork.Repository<Ubicacion>().Add(ubicacion);
        await _unitOfWork.SaveChangesAsync();

        return _mapper.Map<UbicacionDto>(ubicacion);
    }

    private void ValidarJerarquia(TipoUbicacion hijo, TipoUbicacion padre)
    {
        var jerarquiaValida = (padre, hijo) switch
        {
            (TipoUbicacion.Pais, TipoUbicacion.Ciudad) => true,
            (TipoUbicacion.Ciudad, TipoUbicacion.Edificio) => true,
            (TipoUbicacion.Edificio, TipoUbicacion.Piso) => true,
            (TipoUbicacion.Piso, TipoUbicacion.Area) => true,
            (TipoUbicacion.Area, TipoUbicacion.Sala) => true,
            (TipoUbicacion.Sala, TipoUbicacion.Escritorio) => true,
            _ => false
        };

        if (!jerarquiaValida)
            throw new ValidationException("Jerarquía de ubicaciones inválida");
    }
}
```

---

# 🏢 MÓDULO 3: Gestión de Proveedores

## Objetivos
- Catálogo de proveedores
- Gestión de contratos y garantías
- Seguimiento de renovaciones
- Evaluación de proveedores

## Modelo de Datos

### Proveedor.cs (Domain/Entities/)
```csharp
public class Proveedor : BaseEntity
{
    // Información básica
    public string Nombre { get; set; }
    public string RazonSocial { get; set; }
    public string RFC { get; set; }
    public TipoProveedor Tipo { get; set; }

    // Contacto
    public string Direccion { get; set; }
    public string Ciudad { get; set; }
    public string Pais { get; set; }
    public string CodigoPostal { get; set; }
    public string Telefono { get; set; }
    public string Email { get; set; }
    public string SitioWeb { get; set; }

    // Contactos clave
    public string NombreContactoPrincipal { get; set; }
    public string TelefonoContacto { get; set; }
    public string EmailContacto { get; set; }

    // Información comercial
    public string NumeroProveedor { get; set; }      // Código interno
    public string CondicionesPago { get; set; }
    public int DiasPago { get; set; }
    public bool RequiereOrdenCompra { get; set; }

    // Evaluación
    public decimal? CalificacionPromedio { get; set; }
    public int CantidadEvaluaciones { get; set; }

    // Estado
    public bool Activo { get; set; }
    public bool Preferente { get; set; }

    public string Observaciones { get; set; }

    // Relaciones
    public ICollection<Equipo> Equipos { get; set; }
    public ICollection<Software> Software { get; set; }
    public ICollection<ContratoProveedor> Contratos { get; set; }
    public ICollection<EvaluacionProveedor> Evaluaciones { get; set; }
    public ICollection<DocumentoProveedor> Documentos { get; set; }
}

public enum TipoProveedor
{
    Hardware,
    Software,
    Servicios,
    Mantenimiento,
    Consultoria,
    Mixto
}
```

### ContratoProveedor.cs (Domain/Entities/)
```csharp
public class ContratoProveedor : BaseEntity
{
    public int ProveedorId { get; set; }
    public Proveedor Proveedor { get; set; }

    public string NumeroContrato { get; set; }
    public string Descripcion { get; set; }
    public TipoContrato Tipo { get; set; }

    // Vigencia
    public DateTime FechaInicio { get; set; }
    public DateTime FechaFin { get; set; }
    public bool AutoRenovable { get; set; }
    public int DiasNotificacionRenovacion { get; set; }

    // Financiero
    public decimal MontoTotal { get; set; }
    public string Moneda { get; set; }
    public PeriodoFacturacion PeriodoFacturacion { get; set; }

    // SLA del contrato
    public string SLADescripcion { get; set; }
    public int? TiempoRespuestaHoras { get; set; }

    public bool Activo { get; set; }
    public string RutaDocumento { get; set; }
}

public enum TipoContrato
{
    CompraUnica,
    MantenimientoPreventivoAnual,
    SoporteTecnico,
    LicenciamientoAnual,
    Arrendamiento,
    Consultoria
}

public enum PeriodoFacturacion
{
    Mensual,
    Trimestral,
    Semestral,
    Anual,
    Unico
}
```

### EvaluacionProveedor.cs (Domain/Entities/)
```csharp
public class EvaluacionProveedor : BaseEntity
{
    public int ProveedorId { get; set; }
    public Proveedor Proveedor { get; set; }

    public int EvaluadorId { get; set; }
    public Usuario Evaluador { get; set; }

    public DateTime FechaEvaluacion { get; set; }
    public string Periodo { get; set; }             // Ej: "Q1 2024"

    // Criterios (1-5)
    public int CalidadProductos { get; set; }
    public int TiempoEntrega { get; set; }
    public int Precios { get; set; }
    public int AtencionCliente { get; set; }
    public int SoporteTecnico { get; set; }

    public decimal CalificacionGeneral { get; set; }
    public string Comentarios { get; set; }
    public bool Recomendado { get; set; }
}
```

## API Endpoints

```
GET    /api/proveedores
POST   /api/proveedores
PUT    /api/proveedores/{id}
DELETE /api/proveedores/{id}

GET    /api/proveedores/{id}/contratos
POST   /api/proveedores/{id}/contratos
PUT    /api/proveedores/contratos/{id}

GET    /api/proveedores/{id}/evaluaciones
POST   /api/proveedores/{id}/evaluar

GET    /api/proveedores/contratos/proximos-vencer
       - Parámetros: diasProximos
       - Response: Contratos por vencer

GET    /api/proveedores/{id}/estadisticas
```

---

# 🔐 MÓDULO 4: Control de Accesos Avanzado

## Objetivos
- Permisos granulares por módulo
- Roles personalizados
- Auditoría completa de acciones
- Políticas de seguridad

## Modelo de Datos (Ampliación)

### PermisoPersonalizado.cs
```csharp
public class PermisoPersonalizado : BaseEntity
{
    public int UsuarioId { get; set; }
    public Usuario Usuario { get; set; }

    public int PermisoId { get; set; }
    public Permiso Permiso { get; set; }

    public bool Concedido { get; set; }              // true: grant, false: deny
    public DateTime? FechaExpiracion { get; set; }
    public string Motivo { get; set; }

    public int ConcedidoPorId { get; set; }
    public Usuario ConcedidoPor { get; set; }
}
```

### LogAuditoria.cs
```csharp
public class LogAuditoria : BaseEntity
{
    public int? UsuarioId { get; set; }
    public Usuario Usuario { get; set; }

    public string Accion { get; set; }               // CREATE, UPDATE, DELETE, READ
    public string Modulo { get; set; }               // Inventario, Tickets, etc.
    public string EntidadTipo { get; set; }
    public int? EntidadId { get; set; }

    public string ValoresAnteriores { get; set; }    // JSON
    public string ValoresNuevos { get; set; }        // JSON

    public DateTime FechaHora { get; set; }
    public string DireccionIP { get; set; }
    public string UserAgent { get; set; }
    public bool Exitoso { get; set; }
    public string MensajeError { get; set; }
}
```

## API Endpoints

```
GET    /api/accesos/permisos
       - Response: Lista de todos los permisos

GET    /api/accesos/roles
POST   /api/accesos/roles
PUT    /api/accesos/roles/{id}
DELETE /api/accesos/roles/{id}

POST   /api/accesos/usuarios/{id}/permisos
       - Body: { permisoId, concedido, fechaExpiracion }
       - Response: Permiso personalizado creado

GET    /api/accesos/usuarios/{id}/permisos-efectivos
       - Response: Todos los permisos del usuario (roles + personalizados)

GET    /api/auditoria
       - Parámetros: usuarioId, modulo, accion, fechaDesde, fechaHasta
       - Response: Logs de auditoría

GET    /api/auditoria/reporte
       - Parámetros: formato (excel, pdf)
       - Response: Reporte descargable
```

## Implementación

### AuditoriaService.cs
```csharp
public class AuditoriaService : IAuditoriaService
{
    public async Task RegistrarAccionAsync<T>(
        string accion,
        T entidadAnterior,
        T entidadNueva,
        int? usuarioId = null) where T : BaseEntity
    {
        var log = new LogAuditoria
        {
            UsuarioId = usuarioId ?? _currentUserService.UsuarioId,
            Accion = accion,
            Modulo = ObtenerModulo<T>(),
            EntidadTipo = typeof(T).Name,
            EntidadId = entidadNueva?.Id ?? entidadAnterior?.Id,
            ValoresAnteriores = entidadAnterior != null
                ? JsonSerializer.Serialize(entidadAnterior)
                : null,
            ValoresNuevos = entidadNueva != null
                ? JsonSerializer.Serialize(entidadNueva)
                : null,
            FechaHora = DateTime.UtcNow,
            DireccionIP = _httpContextAccessor.HttpContext?.Connection?.RemoteIpAddress?.ToString(),
            UserAgent = _httpContextAccessor.HttpContext?.Request?.Headers["User-Agent"],
            Exitoso = true
        };

        _unitOfWork.Repository<LogAuditoria>().Add(log);
        await _unitOfWork.SaveChangesAsync();
    }

    private string ObtenerModulo<T>()
    {
        return typeof(T).Name switch
        {
            nameof(Equipo) => "Inventario",
            nameof(Software) => "Inventario",
            nameof(Ticket) => "Tickets",
            nameof(Usuario) => "Usuarios",
            nameof(Ubicacion) => "Ubicaciones",
            nameof(Proveedor) => "Proveedores",
            _ => "Sistema"
        };
    }
}
```

### Middleware de Auditoría
```csharp
public class AuditoriaMiddleware
{
    private readonly RequestDelegate _next;

    public async Task InvokeAsync(HttpContext context, IAuditoriaService auditoria)
    {
        // Capturar request
        var originalBody = context.Response.Body;

        try
        {
            using var memStream = new MemoryStream();
            context.Response.Body = memStream;

            await _next(context);

            memStream.Position = 0;
            var responseBody = await new StreamReader(memStream).ReadToEndAsync();

            // Solo auditar ciertas rutas y métodos
            if (DebeAuditar(context))
            {
                await auditoria.RegistrarAccesoAsync(
                    context.Request.Path,
                    context.Request.Method,
                    context.Response.StatusCode
                );
            }

            memStream.Position = 0;
            await memStream.CopyToAsync(originalBody);
        }
        finally
        {
            context.Response.Body = originalBody;
        }
    }

    private bool DebeAuditar(HttpContext context)
    {
        var rutasAuditar = new[] { "/api/inventario", "/api/tickets", "/api/usuarios" };
        var metodosAuditar = new[] { "POST", "PUT", "DELETE" };

        return rutasAuditar.Any(r => context.Request.Path.StartsWithSegments(r)) &&
               metodosAuditar.Contains(context.Request.Method);
    }
}
```

---

## ✅ Entregables de la Fase 4

### Notificaciones
- [ ] Sistema de notificaciones push (Firebase)
- [ ] Notificaciones por email
- [ ] Notificaciones in-app (SignalR)
- [ ] Centro de notificaciones en frontend
- [ ] Preferencias de notificación
- [ ] Badges de notificaciones no leídas

### Ubicaciones
- [ ] CRUD de ubicaciones
- [ ] Jerarquía de ubicaciones
- [ ] Árbol visual de ubicaciones
- [ ] Asignación de equipos a ubicaciones
- [ ] Estadísticas por ubicación

### Proveedores
- [ ] CRUD de proveedores
- [ ] Gestión de contratos
- [ ] Sistema de evaluación
- [ ] Alertas de contratos por vencer
- [ ] Reportes de proveedores

### Control de Accesos
- [ ] Permisos personalizados
- [ ] Logs de auditoría
- [ ] Dashboard de auditoría
- [ ] Reportes de accesos
- [ ] Middleware de auditoría

---

## 🧪 Casos de Prueba

1. Envío de notificaciones por múltiples canales
2. Registro de dispositivos para push
3. Preferencias de notificación
4. Jerarquía de ubicaciones
5. Creación de proveedores y contratos
6. Evaluación de proveedores
7. Permisos personalizados
8. Auditoría de cambios
9. Reportes de auditoría

---

**Siguiente Fase:** [FASE 5: Optimización y Extras](FASE-5.md)
