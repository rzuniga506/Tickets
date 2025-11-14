# 📦 FASE 2: Módulo de Inventarios

**Duración estimada:** 3-4 semanas
**Prioridad:** ALTA
**Dependencias:** Fase 1 completada
**Estado:** Pendiente

---

## 🎯 Objetivos

1. Implementar gestión completa de inventarios de hardware y software
2. Sistema de asignación de equipos a usuarios/departamentos
3. Generación de códigos QR para identificación
4. Tracking de ubicaciones físicas
5. Control de garantías y proveedores
6. Reportes y exportación de datos
7. Dashboard con estadísticas en tiempo real

---

## 📋 Submódulos

### 1. Gestión de Hardware
- Computadoras (Desktop/Laptop)
- Servidores
- Impresoras y multifuncionales
- Dispositivos de red (switches, routers, APs)
- Periféricos (monitores, teclados, mouse)
- Componentes (RAM, discos, procesadores)
- Equipos móviles (tablets, smartphones)

### 2. Gestión de Software
- Licencias de software
- Seguimiento de vencimientos
- Asignación por usuario/equipo
- Control de versiones

### 3. Accesorios y Consumibles
- Cables y adaptadores
- Tóner y cartuchos
- Material de oficina TI

---

## 🗃️ Modelo de Datos

### Entidades Principales

#### Equipo.cs (Domain/Entities/)
```csharp
public class Equipo : BaseEntity
{
    // Información básica
    public string CodigoInterno { get; set; }      // Código único de la empresa
    public string NumeroSerie { get; set; }
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public string CodigoQR { get; set; }           // Hash único para QR

    // Clasificación
    public int TipoEquipoId { get; set; }
    public TipoEquipo TipoEquipo { get; set; }

    public int? MarcaId { get; set; }
    public Marca Marca { get; set; }

    public string Modelo { get; set; }

    // Especificaciones técnicas (JSON)
    public string EspecificacionesJson { get; set; } // Flexible para cada tipo

    // Estado y condición
    public EstadoEquipo Estado { get; set; }        // Disponible, EnUso, EnMantenimiento, DadoDeBaja
    public CondicionEquipo Condicion { get; set; }  // Nuevo, Bueno, Regular, Malo

    // Financiero
    public decimal? CostoAdquisicion { get; set; }
    public DateTime? FechaAdquisicion { get; set; }
    public int VidaUtilMeses { get; set; }          // Para depreciación
    public decimal? ValorResidual { get; set; }

    // Garantía
    public DateTime? FechaInicioGarantia { get; set; }
    public DateTime? FechaFinGarantia { get; set; }
    public int? ProveedorId { get; set; }
    public Proveedor Proveedor { get; set; }

    // Ubicación
    public int? UbicacionId { get; set; }
    public Ubicacion Ubicacion { get; set; }

    // Asignación
    public int? UsuarioAsignadoId { get; set; }
    public Usuario UsuarioAsignado { get; set; }
    public DateTime? FechaAsignacion { get; set; }

    public int? DepartamentoAsignadoId { get; set; }
    public Departamento DepartamentoAsignado { get; set; }

    // Observaciones
    public string Observaciones { get; set; }

    // Relaciones
    public ICollection<HistorialMovimiento> Movimientos { get; set; }
    public ICollection<EquipoSoftware> SoftwareInstalado { get; set; }
    public ICollection<MantenimientoEquipo> Mantenimientos { get; set; }
    public ICollection<Ticket> Tickets { get; set; }
    public ICollection<DocumentoEquipo> Documentos { get; set; }
}
```

#### TipoEquipo.cs (Domain/Entities/)
```csharp
public class TipoEquipo : BaseEntity
{
    public string Nombre { get; set; }              // Desktop, Laptop, Servidor, etc.
    public string Descripcion { get; set; }
    public string Icono { get; set; }               // Para UI
    public CategoriaEquipo Categoria { get; set; }  // Hardware, Periferico, Red, etc.
    public string PlantillaEspecificaciones { get; set; } // JSON Schema para specs

    // Relaciones
    public ICollection<Equipo> Equipos { get; set; }
}

public enum CategoriaEquipo
{
    Computadoras,
    Servidores,
    Impresoras,
    DispositivosRed,
    Perifericos,
    Componentes,
    MovilesTablets,
    Otros
}

public enum EstadoEquipo
{
    Disponible,
    EnUso,
    EnMantenimiento,
    EnReparacion,
    DadoDeBaja,
    Perdido,
    Robado
}

public enum CondicionEquipo
{
    Nuevo,
    Excelente,
    Bueno,
    Regular,
    Malo,
    NoFuncional
}
```

#### Software.cs (Domain/Entities/)
```csharp
public class Software : BaseEntity
{
    public string Nombre { get; set; }
    public string Version { get; set; }
    public string Fabricante { get; set; }
    public TipoSoftware Tipo { get; set; }          // Sistema, Aplicacion, Herramienta
    public TipoLicencia TipoLicencia { get; set; }  // Perpetua, Suscripcion, Gratuita

    public string Descripcion { get; set; }

    // Licenciamiento
    public int? CantidadLicencias { get; set; }
    public int? LicenciasEnUso { get; set; }
    public decimal? CostoLicencia { get; set; }
    public DateTime? FechaCompra { get; set; }
    public DateTime? FechaVencimiento { get; set; }
    public bool AlertarVencimiento { get; set; }
    public int DiasAntesAlertar { get; set; }

    public string ClaveProducto { get; set; }       // Encriptada
    public string Observaciones { get; set; }

    // Proveedor
    public int? ProveedorId { get; set; }
    public Proveedor Proveedor { get; set; }

    // Relaciones
    public ICollection<EquipoSoftware> EquiposConSoftware { get; set; }
    public ICollection<UsuarioSoftware> UsuariosConLicencia { get; set; }
}

public enum TipoSoftware
{
    SistemaOperativo,
    Aplicacion,
    Herramienta,
    Antivirus,
    Suite,
    Desarrollo,
    Diseno,
    Otro
}

public enum TipoLicencia
{
    Perpetua,
    SuscripcionAnual,
    SuscripcionMensual,
    Gratuita,
    OpenSource,
    Trial
}
```

#### HistorialMovimiento.cs (Domain/Entities/)
```csharp
public class HistorialMovimiento : BaseEntity
{
    public int EquipoId { get; set; }
    public Equipo Equipo { get; set; }

    public TipoMovimiento Tipo { get; set; }

    // Estado anterior
    public EstadoEquipo? EstadoAnterior { get; set; }
    public int? UbicacionAnteriorId { get; set; }
    public Ubicacion UbicacionAnterior { get; set; }
    public int? UsuarioAnteriorId { get; set; }
    public Usuario UsuarioAnterior { get; set; }

    // Estado nuevo
    public EstadoEquipo? EstadoNuevo { get; set; }
    public int? UbicacionNuevaId { get; set; }
    public Ubicacion UbicacionNueva { get; set; }
    public int? UsuarioNuevoId { get; set; }
    public Usuario UsuarioNuevo { get; set; }

    public string Motivo { get; set; }
    public string Observaciones { get; set; }
    public DateTime FechaMovimiento { get; set; }

    public int RegistradoPorId { get; set; }
    public Usuario RegistradoPor { get; set; }
}

public enum TipoMovimiento
{
    Asignacion,
    Reasignacion,
    Devolucion,
    CambioUbicacion,
    CambioEstado,
    Mantenimiento,
    BajaDefinitiva
}
```

#### Marca.cs (Domain/Entities/)
```csharp
public class Marca : BaseEntity
{
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public string PaisOrigen { get; set; }
    public string SitioWeb { get; set; }
    public string LogoUrl { get; set; }

    // Relaciones
    public ICollection<Equipo> Equipos { get; set; }
}
```

#### DocumentoEquipo.cs (Domain/Entities/)
```csharp
public class DocumentoEquipo : BaseEntity
{
    public int EquipoId { get; set; }
    public Equipo Equipo { get; set; }

    public string Nombre { get; set; }
    public TipoDocumento Tipo { get; set; }
    public string RutaArchivo { get; set; }
    public string Extension { get; set; }
    public long TamanoBytes { get; set; }
    public string Descripcion { get; set; }
}

public enum TipoDocumento
{
    Factura,
    Garantia,
    Manual,
    Certificado,
    Foto,
    Otro
}
```

---

## 🔌 API Endpoints

### Equipos

```
GET    /api/inventario/equipos
       - Parámetros: page, pageSize, search, tipoEquipoId, estado, ubicacionId
       - Autorización: inventario.read
       - Response: Lista paginada de equipos

GET    /api/inventario/equipos/{id}
       - Autorización: inventario.read
       - Response: Detalle completo del equipo

POST   /api/inventario/equipos
       - Autorización: inventario.write
       - Body: EquipoCreateDto
       - Response: Equipo creado con QR generado

PUT    /api/inventario/equipos/{id}
       - Autorización: inventario.write
       - Body: EquipoUpdateDto
       - Response: Equipo actualizado

DELETE /api/inventario/equipos/{id}
       - Autorización: inventario.delete
       - Response: 204 No Content (soft delete)

POST   /api/inventario/equipos/{id}/asignar
       - Autorización: inventario.write
       - Body: AsignacionEquipoDto
       - Response: Equipo asignado

POST   /api/inventario/equipos/{id}/liberar
       - Autorización: inventario.write
       - Response: Equipo liberado

GET    /api/inventario/equipos/{id}/historial
       - Autorización: inventario.read
       - Response: Historial de movimientos

GET    /api/inventario/equipos/{id}/qr
       - Autorización: inventario.read
       - Response: Imagen QR (PNG)

POST   /api/inventario/equipos/{id}/documentos
       - Autorización: inventario.write
       - Body: Multipart file upload
       - Response: Documento guardado

GET    /api/inventario/equipos/export
       - Autorización: reportes.generate
       - Parámetros: format (excel, pdf, csv)
       - Response: Archivo descargable

GET    /api/inventario/equipos/estadisticas
       - Autorización: inventario.read
       - Response: Estadísticas dashboard
```

### Software

```
GET    /api/inventario/software
POST   /api/inventario/software
PUT    /api/inventario/software/{id}
DELETE /api/inventario/software/{id}

GET    /api/inventario/software/{id}/licencias-disponibles
POST   /api/inventario/software/{id}/asignar-licencia
POST   /api/inventario/software/{id}/liberar-licencia

GET    /api/inventario/software/vencimientos
       - Parámetros: diasProximos
       - Response: Software próximo a vencer
```

### Tipos de Equipo

```
GET    /api/inventario/tipos-equipo
POST   /api/inventario/tipos-equipo
PUT    /api/inventario/tipos-equipo/{id}
DELETE /api/inventario/tipos-equipo/{id}
```

### Marcas

```
GET    /api/inventario/marcas
POST   /api/inventario/marcas
PUT    /api/inventario/marcas/{id}
DELETE /api/inventario/marcas/{id}
```

---

## 💻 Implementación Backend

### EquipoService.cs (Application/Services/)

```csharp
public class EquipoService : IEquipoService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly IQRCodeService _qrCodeService;
    private readonly INotificacionService _notificacionService;

    public async Task<EquipoDto> CrearEquipoAsync(EquipoCreateDto dto)
    {
        // Validar código interno único
        var existeCodigo = await _unitOfWork.Repository<Equipo>()
            .AnyAsync(e => e.CodigoInterno == dto.CodigoInterno);

        if (existeCodigo)
            throw new ValidationException("El código interno ya existe");

        var equipo = _mapper.Map<Equipo>(dto);

        // Generar código QR único
        equipo.CodigoQR = GenerarCodigoQRUnico();

        _unitOfWork.Repository<Equipo>().Add(equipo);
        await _unitOfWork.SaveChangesAsync();

        // Generar imagen QR
        await _qrCodeService.GenerarQREquipoAsync(equipo.Id, equipo.CodigoQR);

        return _mapper.Map<EquipoDto>(equipo);
    }

    public async Task<EquipoDto> AsignarEquipoAsync(int equipoId, AsignacionEquipoDto dto)
    {
        var equipo = await _unitOfWork.Repository<Equipo>()
            .Include(e => e.UsuarioAsignado)
            .Include(e => e.Ubicacion)
            .FirstOrDefaultAsync(e => e.Id == equipoId);

        if (equipo == null)
            throw new NotFoundException("Equipo no encontrado");

        if (equipo.Estado != EstadoEquipo.Disponible)
            throw new ValidationException("El equipo no está disponible");

        // Registrar movimiento
        var movimiento = new HistorialMovimiento
        {
            EquipoId = equipoId,
            Tipo = TipoMovimiento.Asignacion,
            EstadoAnterior = equipo.Estado,
            EstadoNuevo = EstadoEquipo.EnUso,
            UsuarioAnteriorId = equipo.UsuarioAsignadoId,
            UsuarioNuevoId = dto.UsuarioId,
            UbicacionAnteriorId = equipo.UbicacionId,
            UbicacionNuevaId = dto.UbicacionId,
            Motivo = dto.Motivo,
            Observaciones = dto.Observaciones,
            FechaMovimiento = DateTime.UtcNow
        };

        _unitOfWork.Repository<HistorialMovimiento>().Add(movimiento);

        // Actualizar equipo
        equipo.Estado = EstadoEquipo.EnUso;
        equipo.UsuarioAsignadoId = dto.UsuarioId;
        equipo.FechaAsignacion = DateTime.UtcNow;
        equipo.UbicacionId = dto.UbicacionId;

        await _unitOfWork.SaveChangesAsync();

        // Enviar notificación al usuario
        await _notificacionService.NotificarAsignacionEquipoAsync(
            dto.UsuarioId,
            equipo
        );

        return _mapper.Map<EquipoDto>(equipo);
    }

    public async Task<PagedResult<EquipoDto>> ObtenerEquiposAsync(
        EquipoFilterDto filtros)
    {
        var query = _unitOfWork.Repository<Equipo>()
            .Include(e => e.TipoEquipo)
            .Include(e => e.Marca)
            .Include(e => e.Ubicacion)
            .Include(e => e.UsuarioAsignado)
            .AsQueryable();

        // Aplicar filtros
        if (!string.IsNullOrEmpty(filtros.Search))
        {
            query = query.Where(e =>
                e.CodigoInterno.Contains(filtros.Search) ||
                e.NumeroSerie.Contains(filtros.Search) ||
                e.Nombre.Contains(filtros.Search) ||
                e.Descripcion.Contains(filtros.Search)
            );
        }

        if (filtros.TipoEquipoId.HasValue)
            query = query.Where(e => e.TipoEquipoId == filtros.TipoEquipoId);

        if (filtros.Estado.HasValue)
            query = query.Where(e => e.Estado == filtros.Estado);

        if (filtros.UbicacionId.HasValue)
            query = query.Where(e => e.UbicacionId == filtros.UbicacionId);

        if (filtros.UsuarioAsignadoId.HasValue)
            query = query.Where(e => e.UsuarioAsignadoId == filtros.UsuarioAsignadoId);

        // Ordenamiento
        query = filtros.OrdenPor switch
        {
            "codigo" => query.OrderBy(e => e.CodigoInterno),
            "nombre" => query.OrderBy(e => e.Nombre),
            "fecha" => query.OrderByDescending(e => e.FechaCreacion),
            _ => query.OrderByDescending(e => e.Id)
        };

        var totalItems = await query.CountAsync();

        var equipos = await query
            .Skip((filtros.Page - 1) * filtros.PageSize)
            .Take(filtros.PageSize)
            .ToListAsync();

        var equiposDto = _mapper.Map<List<EquipoDto>>(equipos);

        return new PagedResult<EquipoDto>
        {
            Items = equiposDto,
            TotalItems = totalItems,
            Page = filtros.Page,
            PageSize = filtros.PageSize
        };
    }

    public async Task<EstadisticasInventarioDto> ObtenerEstadisticasAsync()
    {
        var stats = new EstadisticasInventarioDto
        {
            TotalEquipos = await _unitOfWork.Repository<Equipo>().CountAsync(),
            EquiposDisponibles = await _unitOfWork.Repository<Equipo>()
                .CountAsync(e => e.Estado == EstadoEquipo.Disponible),
            EquiposEnUso = await _unitOfWork.Repository<Equipo>()
                .CountAsync(e => e.Estado == EstadoEquipo.EnUso),
            EquiposEnMantenimiento = await _unitOfWork.Repository<Equipo>()
                .CountAsync(e => e.Estado == EstadoEquipo.EnMantenimiento),

            ValorTotalInventario = await _unitOfWork.Repository<Equipo>()
                .SumAsync(e => e.CostoAdquisicion ?? 0),

            EquiposPorTipo = await _unitOfWork.Repository<Equipo>()
                .GroupBy(e => e.TipoEquipo.Nombre)
                .Select(g => new { Tipo = g.Key, Cantidad = g.Count() })
                .ToListAsync(),

            EquiposPorUbicacion = await _unitOfWork.Repository<Equipo>()
                .Where(e => e.UbicacionId.HasValue)
                .GroupBy(e => e.Ubicacion.Nombre)
                .Select(g => new { Ubicacion = g.Key, Cantidad = g.Count() })
                .ToListAsync(),

            EquiposProximosAVencerGarantia = await _unitOfWork.Repository<Equipo>()
                .Where(e => e.FechaFinGarantia.HasValue &&
                           e.FechaFinGarantia.Value <= DateTime.UtcNow.AddDays(30))
                .CountAsync()
        };

        return stats;
    }

    private string GenerarCodigoQRUnico()
    {
        return Guid.NewGuid().ToString("N").ToUpper();
    }
}
```

### QRCodeService.cs (Infrastructure/Services/)

```csharp
public class QRCodeService : IQRCodeService
{
    private readonly string _qrStoragePath;

    public QRCodeService(IConfiguration configuration)
    {
        _qrStoragePath = configuration["QR:StoragePath"] ?? "wwwroot/qr-codes";
        Directory.CreateDirectory(_qrStoragePath);
    }

    public async Task<string> GenerarQREquipoAsync(int equipoId, string codigoQR)
    {
        using var qrGenerator = new QRCodeGenerator();

        // Crear payload JSON con info del equipo
        var payload = new
        {
            equipoId,
            codigo = codigoQR,
            tipo = "equipo",
            timestamp = DateTime.UtcNow
        };

        var payloadJson = JsonSerializer.Serialize(payload);

        var qrCodeData = qrGenerator.CreateQrCode(payloadJson, QRCodeGenerator.ECCLevel.Q);
        var qrCode = new PngByteQRCode(qrCodeData);
        var qrCodeImage = qrCode.GetGraphic(20);

        var fileName = $"{codigoQR}.png";
        var filePath = Path.Combine(_qrStoragePath, fileName);

        await File.WriteAllBytesAsync(filePath, qrCodeImage);

        return filePath;
    }

    public async Task<byte[]> ObtenerQRImagenAsync(string codigoQR)
    {
        var filePath = Path.Combine(_qrStoragePath, $"{codigoQR}.png");

        if (!File.Exists(filePath))
            throw new NotFoundException("QR no encontrado");

        return await File.ReadAllBytesAsync(filePath);
    }
}
```

---

## 📱 Implementación Frontend

### Estructura de Pantallas

```
presentation/screens/inventario/
├── inventario_list_screen.dart          # Lista principal
├── inventario_detail_screen.dart        # Detalle del equipo
├── inventario_form_screen.dart          # Crear/Editar
├── inventario_asignar_screen.dart       # Asignar equipo
├── inventario_historial_screen.dart     # Historial movimientos
├── inventario_dashboard_screen.dart     # Dashboard estadísticas
└── inventario_qr_scanner_screen.dart    # Escanear QR
```

### inventario_list_screen.dart

```dart
class InventarioListScreen extends StatefulWidget {
  const InventarioListScreen({Key? key}) : super(key: key);

  @override
  State<InventarioListScreen> createState() => _InventarioListScreenState();
}

class _InventarioListScreenState extends State<InventarioListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/inventario/scan'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
        ],
      ),
      body: BlocBuilder<InventarioBloc, InventarioState>(
        builder: (context, state) {
          if (state is InventarioLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InventarioError) {
            return Center(child: Text(state.message));
          }

          if (state is InventarioLoaded) {
            return Column(
              children: [
                // Búsqueda
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar equipos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      context.read<InventarioBloc>().add(
                        BuscarEquipos(query: value),
                      );
                    },
                  ),
                ),

                // Chips de filtros rápidos
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: state.filtroEstado == null,
                        onSelected: (_) => _filtrarPorEstado(null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Disponibles'),
                        selected: state.filtroEstado == EstadoEquipo.disponible,
                        onSelected: (_) => _filtrarPorEstado(EstadoEquipo.disponible),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('En uso'),
                        selected: state.filtroEstado == EstadoEquipo.enUso,
                        onSelected: (_) => _filtrarPorEstado(EstadoEquipo.enUso),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Mantenimiento'),
                        selected: state.filtroEstado == EstadoEquipo.enMantenimiento,
                        onSelected: (_) => _filtrarPorEstado(EstadoEquipo.enMantenimiento),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de equipos
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<InventarioBloc>().add(CargarEquipos());
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsivo: Grid en tablet/desktop, lista en móvil
                        if (constraints.maxWidth > 600) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.equipos.length,
                            itemBuilder: (context, index) {
                              return EquipoGridCard(
                                equipo: state.equipos[index],
                              );
                            },
                          );
                        } else {
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.equipos.length,
                            itemBuilder: (context, index) {
                              return EquipoListCard(
                                equipo: state.equipos[index],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventario/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Equipo'),
      ),
    );
  }

  void _filtrarPorEstado(EstadoEquipo? estado) {
    context.read<InventarioBloc>().add(
      FiltrarPorEstado(estado: estado),
    );
  }

  void _mostrarFiltros() {
    // Mostrar bottom sheet con filtros avanzados
  }
}
```

### Widgets Reutilizables

**equipo_list_card.dart**
```dart
class EquipoListCard extends StatelessWidget {
  final EquipoDto equipo;

  const EquipoListCard({Key? key, required this.equipo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorEstado(equipo.estado),
          child: Icon(_getIconoTipo(equipo.tipoEquipo)),
        ),
        title: Text(
          equipo.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${equipo.codigoInterno}'),
            if (equipo.usuarioAsignado != null)
              Text('Asignado a: ${equipo.usuarioAsignado!.nombre}'),
            Text('Estado: ${equipo.estado.displayName}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ver',
              child: Text('Ver detalles'),
            ),
            const PopupMenuItem(
              value: 'editar',
              child: Text('Editar'),
            ),
            if (equipo.estado == EstadoEquipo.disponible)
              const PopupMenuItem(
                value: 'asignar',
                child: Text('Asignar'),
              ),
            const PopupMenuItem(
              value: 'qr',
              child: Text('Ver QR'),
            ),
          ],
          onSelected: (value) => _handleAction(context, value),
        ),
        onTap: () => context.push('/inventario/${equipo.id}'),
      ),
    );
  }

  Color _getColorEstado(EstadoEquipo estado) {
    switch (estado) {
      case EstadoEquipo.disponible:
        return Colors.green;
      case EstadoEquipo.enUso:
        return Colors.blue;
      case EstadoEquipo.enMantenimiento:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoTipo(TipoEquipoDto tipo) {
    // Mapear tipos a iconos
    return Icons.computer;
  }

  void _handleAction(BuildContext context, String action) {
    // Manejar acciones del menú
  }
}
```

---

## ✅ Entregables de la Fase 2

- [ ] Modelo de datos completo de inventarios
- [ ] API endpoints de equipos implementados
- [ ] API endpoints de software implementados
- [ ] Sistema de generación de QR codes
- [ ] Pantallas de gestión de equipos (CRUD)
- [ ] Pantalla de asignación de equipos
- [ ] Pantalla de historial de movimientos
- [ ] Dashboard de estadísticas
- [ ] Scanner de QR codes (móvil)
- [ ] Exportación de reportes (Excel/PDF)
- [ ] Filtros y búsqueda avanzada
- [ ] Sistema de depreciación automática
- [ ] Alertas de garantías próximas a vencer
- [ ] Pruebas unitarias e integración

---

## 🧪 Casos de Prueba

1. Crear equipo con información completa
2. Generar y validar código QR
3. Asignar equipo a usuario
4. Liberar equipo asignado
5. Registrar movimiento de ubicación
6. Búsqueda y filtrado de equipos
7. Exportar inventario a Excel/PDF
8. Validar duplicación de códigos internos
9. Cálculo de depreciación
10. Alertas de garantías vencidas

---

**Siguiente Fase:** [FASE 3: Sistema de Tickets](FASE-3.md)
