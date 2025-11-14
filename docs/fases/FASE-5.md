# 🚀 FASE 5: Optimización y Módulos Extras

**Duración estimada:** 2-3 semanas
**Prioridad:** MEDIA
**Dependencias:** Todas las fases anteriores completadas
**Estado:** Pendiente

---

## 🎯 Objetivos

1. Base de Conocimiento (Knowledge Base)
2. Mantenimientos Preventivos
3. Analytics y Reportes Avanzados
4. Optimizaciones de Rendimiento
5. Documentación completa
6. Testing exhaustivo
7. Deployment y CI/CD

---

# 📚 MÓDULO 1: Base de Conocimiento

## Objetivos
- Artículos de soluciones comunes
- FAQs
- Tutoriales y guías
- Búsqueda inteligente
- Vinculación con tickets

## Modelo de Datos

### ArticuloConocimiento.cs
```csharp
public class ArticuloConocimiento : BaseEntity
{
    public string Titulo { get; set; }
    public string Contenido { get; set; }           // HTML/Markdown
    public string Resumen { get; set; }

    // Clasificación
    public int CategoriaId { get; set; }
    public CategoriaArticulo Categoria { get; set; }
    public ICollection<EtiquetaArticulo> Etiquetas { get; set; }

    // Metadata
    public int AutorId { get; set; }
    public Usuario Autor { get; set; }
    public EstadoArticulo Estado { get; set; }
    public int Visualizaciones { get; set; }
    public bool Destacado { get; set; }

    // Utilidad
    public int VotosUtiles { get; set; }
    public int VotosNoUtiles { get; set; }
    public decimal PorcentajeUtilidad { get; set; }

    // SEO
    public string Slug { get; set; }
    public string MetaDescripcion { get; set; }
    public string PalabrasClaveJson { get; set; }

    // Relaciones
    public ICollection<ArticuloRelacionado> ArticulosRelacionados { get; set; }
    public ICollection<AdjuntoArticulo> Adjuntos { get; set; }
}

public enum EstadoArticulo
{
    Borrador,
    Revision,
    Publicado,
    Archivado
}
```

## API Endpoints

```
GET    /api/conocimiento/articulos
GET    /api/conocimiento/articulos/{id}
POST   /api/conocimiento/articulos
PUT    /api/conocimiento/articulos/{id}
DELETE /api/conocimiento/articulos/{id}

GET    /api/conocimiento/buscar
       - Parámetros: q, categoriaId, etiquetas
       - Response: Resultados de búsqueda

POST   /api/conocimiento/articulos/{id}/valorar
       - Body: { esUtil: bool }

GET    /api/conocimiento/destacados
GET    /api/conocimiento/mas-vistos
```

---

# 🔧 MÓDULO 2: Mantenimientos Preventivos

## Objetivos
- Calendario de mantenimientos
- Recordatorios automáticos
- Historial de mantenimientos
- Checklist de mantenimiento

## Modelo de Datos

### MantenimientoPreventivo.cs
```csharp
public class MantenimientoPreventivo : BaseEntity
{
    public int EquipoId { get; set; }
    public Equipo Equipo { get; set; }

    public string Descripcion { get; set; }
    public TipoMantenimiento Tipo { get; set; }
    public Periodicidad Periodicidad { get; set; }

    // Programación
    public DateTime FechaProximoMantenimiento { get; set; }
    public DateTime? FechaUltimoMantenimiento { get; set; }

    // Notificaciones
    public int DiasAntesNotificar { get; set; }
    public bool NotificacionEnviada { get; set; }

    // Asignación
    public int? TecnicoAsignadoId { get; set; }
    public Usuario TecnicoAsignado { get; set; }

    public bool Activo { get; set; }

    // Checklist
    public string ChecklistJson { get; set; }

    // Relaciones
    public ICollection<RegistroMantenimiento> Registros { get; set; }
}

public enum Periodicidad
{
    Mensual,
    Trimestral,
    Semestral,
    Anual
}

public enum TipoMantenimiento
{
    Preventivo,
    Correctivo,
    Predictivo
}
```

### RegistroMantenimiento.cs
```csharp
public class RegistroMantenimiento : BaseEntity
{
    public int MantenimientoId { get; set; }
    public MantenimientoPreventivo Mantenimiento { get; set; }

    public DateTime FechaMantenimiento { get; set; }
    public int TecnicoId { get; set; }
    public Usuario Tecnico { get; set; }

    public string ActividadesRealizadas { get; set; }
    public string Observaciones { get; set; }
    public string ChecklistCompletadoJson { get; set; }

    public int TiempoInvertidoMinutos { get; set; }
    public decimal? CostoManoObra { get; set; }
    public decimal? CostoRepuestos { get; set; }

    public EstadoEquipo EstadoAntes { get; set; }
    public EstadoEquipo EstadoDespues { get; set; }

    public ICollection<AdjuntoMantenimiento> Adjuntos { get; set; }
}
```

---

# 📊 MÓDULO 3: Analytics y Reportes Avanzados

## Dashboards

### Dashboard Principal
- Total de tickets abiertos/cerrados
- Tiempo promedio de resolución
- SLA compliance
- Equipos disponibles vs en uso
- Gráficas de tendencias
- Top 10 categorías de tickets
- Técnicos más productivos

### Dashboard de Inventarios
- Valor total del inventario
- Depreciación mensual
- Equipos por estado
- Equipos por ubicación
- Software próximo a vencer
- Garantías por vencer

### Dashboard de Tickets
- Tickets por estado
- Tickets por prioridad
- Tickets por categoría
- Tiempo promedio por categoría
- Satisfacción del cliente
- Tickets por técnico
- Tendencias mensuales

## Reportes Personalizables

```csharp
public class ReportePersonalizado : BaseEntity
{
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public TipoReporte Tipo { get; set; }

    // Configuración
    public string FiltrosJson { get; set; }
    public string ColumnasJson { get; set; }
    public string AgrupacionesJson { get; set; }

    // Programación
    public bool Programado { get; set; }
    public Frecuencia? Frecuencia { get; set; }
    public string DestinatariosJson { get; set; }

    public int CreadoPorId { get; set; }
    public Usuario CreadoPor { get; set; }
}

public enum TipoReporte
{
    Inventario,
    Tickets,
    Usuarios,
    Auditoria,
    Financiero,
    Personalizado
}
```

---

# ⚡ MÓDULO 4: Optimizaciones de Rendimiento

## Backend

### 1. Caching
```csharp
public class CacheService : ICacheService
{
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;

    public async Task<T> GetOrCreateAsync<T>(
        string key,
        Func<Task<T>> factory,
        TimeSpan? expiration = null)
    {
        // Intentar obtener del cache
        if (_memoryCache.TryGetValue(key, out T value))
        {
            return value;
        }

        // Si no está, ejecutar factory
        value = await factory();

        // Guardar en cache
        var options = new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = expiration ?? TimeSpan.FromMinutes(10)
        };

        _memoryCache.Set(key, value, options);

        return value;
    }
}

// Uso en servicio
public async Task<List<CategoriaDto>> ObtenerCategoriasAsync()
{
    return await _cacheService.GetOrCreateAsync(
        "categorias_tickets",
        async () =>
        {
            var categorias = await _unitOfWork.Repository<CategoriaTicket>()
                .Where(c => c.Activa)
                .ToListAsync();

            return _mapper.Map<List<CategoriaDto>>(categorias);
        },
        TimeSpan.FromHours(1)
    );
}
```

### 2. Paginación Eficiente
```csharp
public class PagedResult<T>
{
    public List<T> Items { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalItems { get; set; }
    public int TotalPages => (int)Math.Ceiling(TotalItems / (double)PageSize);
    public bool HasPreviousPage => Page > 1;
    public bool HasNextPage => Page < TotalPages;
}

// Extension method para IQueryable
public static async Task<PagedResult<T>> ToPagedResultAsync<T>(
    this IQueryable<T> query,
    int page,
    int pageSize)
{
    var totalItems = await query.CountAsync();

    var items = await query
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync();

    return new PagedResult<T>
    {
        Items = items,
        Page = page,
        PageSize = pageSize,
        TotalItems = totalItems
    };
}
```

### 3. Índices de Base de Datos
```sql
-- Tickets
CREATE NONCLUSTERED INDEX IX_Tickets_Estado_FechaApertura
ON Tickets(Estado, FechaApertura DESC)
INCLUDE (NumeroTicket, Asunto, Prioridad);

CREATE NONCLUSTERED INDEX IX_Tickets_TecnicoAsignado_Estado
ON Tickets(TecnicoAsignadoId, Estado);

CREATE NONCLUSTERED INDEX IX_Tickets_Solicitante
ON Tickets(SolicitanteId);

-- Equipos
CREATE NONCLUSTERED INDEX IX_Equipos_CodigoInterno
ON Equipos(CodigoInterno);

CREATE NONCLUSTERED INDEX IX_Equipos_Estado_TipoEquipo
ON Equipos(Estado, TipoEquipoId);

CREATE NONCLUSTERED INDEX IX_Equipos_UbicacionId
ON Equipos(UbicacionId)
WHERE UbicacionId IS NOT NULL;

-- Notificaciones
CREATE NONCLUSTERED INDEX IX_Notificaciones_Usuario_Leida
ON Notificaciones(UsuarioId, Leida)
INCLUDE (Titulo, FechaCreacion);
```

### 4. Proyecciones DTO
```csharp
// En lugar de esto:
var tickets = await _context.Tickets
    .Include(t => t.Categoria)
    .Include(t => t.Solicitante)
    .Include(t => t.TecnicoAsignado)
    .ToListAsync();

var ticketsDto = _mapper.Map<List<TicketDto>>(tickets);

// Hacer esto (más eficiente):
var ticketsDto = await _context.Tickets
    .Select(t => new TicketDto
    {
        Id = t.Id,
        NumeroTicket = t.NumeroTicket,
        Asunto = t.Asunto,
        Estado = t.Estado,
        Prioridad = t.Prioridad,
        CategoriaNombre = t.Categoria.Nombre,
        SolicitanteNombre = t.Solicitante.Nombre,
        TecnicoNombre = t.TecnicoAsignado != null ? t.TecnicoAsignado.Nombre : null,
        FechaApertura = t.FechaApertura
    })
    .ToListAsync();
```

## Frontend

### 1. Lazy Loading
```dart
// Cargar módulos bajo demanda
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/inventario',
      builder: (context, state) => const InventarioListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.parse(state.params['id']!);
            return InventarioDetailScreen(equipoId: id);
          },
        ),
      ],
    ),
  ],
);
```

### 2. Optimistic Updates
```dart
class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  Future<void> _onActualizarEquipo(
    ActualizarEquipo event,
    Emitter<InventarioState> emit,
  ) async {
    final currentState = state as InventarioLoaded;

    // Actualización optimista
    final equiposActualizados = currentState.equipos.map((e) {
      return e.id == event.equipo.id ? event.equipo : e;
    }).toList();

    emit(currentState.copyWith(equipos: equiposActualizados));

    try {
      // Llamada al API
      await _repository.actualizarEquipo(event.equipo);
    } catch (e) {
      // Revertir en caso de error
      emit(currentState);
      emit(InventarioError(message: e.toString()));
    }
  }
}
```

### 3. Image Optimization
```dart
// Cached network image
CachedNetworkImage(
  imageUrl: equipo.imagenUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 500, // Resize en memoria
  maxWidthDiskCache: 500,
  maxHeightDiskCache: 500,
)
```

### 4. Infinite Scroll
```dart
class TicketsListScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          context.read<TicketsBloc>().add(CargarMasTickets());
        }
        return false;
      },
      child: ListView.builder(
        itemCount: state.tickets.length + 1,
        itemBuilder: (context, index) {
          if (index == state.tickets.length) {
            return state.hasMore
                ? const CircularProgressIndicator()
                : const SizedBox();
          }
          return TicketCard(ticket: state.tickets[index]);
        },
      ),
    );
  }
}
```

---

# 📝 MÓDULO 5: Documentación

## Documentación Técnica

1. **Arquitectura del Sistema** ✅
2. **Guía de Instalación**
3. **Guía de Desarrollo**
4. **API Documentation** (Swagger)
5. **Database Schema**
6. **Diagramas UML**

## Documentación de Usuario

1. **Manual de Usuario Final**
2. **Manual de Técnico**
3. **Manual de Administrador**
4. **FAQs**
5. **Videos Tutoriales**

---

# 🧪 MÓDULO 6: Testing Exhaustivo

## Backend Testing

### Unit Tests
```csharp
public class TicketServiceTests
{
    private readonly Mock<IUnitOfWork> _mockUnitOfWork;
    private readonly Mock<IMapper> _mockMapper;
    private readonly TicketService _service;

    [Fact]
    public async Task CrearTicket_ConDatosValidos_DebeRetornarTicketDto()
    {
        // Arrange
        var dto = new TicketCreateDto
        {
            Asunto = "Test Ticket",
            Descripcion = "Test Description",
            CategoriaId = 1,
            Prioridad = PrioridadTicket.Media
        };

        // Act
        var result = await _service.CrearTicketAsync(dto);

        // Assert
        Assert.NotNull(result);
        Assert.NotEmpty(result.NumeroTicket);
    }
}
```

### Integration Tests
```csharp
public class TicketsControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    [Fact]
    public async Task Get_Tickets_DebeRetornar200()
    {
        // Act
        var response = await _client.GetAsync("/api/tickets");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        Assert.NotEmpty(content);
    }
}
```

## Frontend Testing

### Widget Tests
```dart
void main() {
  testWidgets('LoginScreen debe mostrar campos de email y password',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen()),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
  });
}
```

### BLoC Tests
```dart
void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc(
        loginUseCase: mockLoginUseCase,
        storageService: mockStorageService,
      );
    });

    test('estado inicial debe ser AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'debe emitir [AuthLoading, Authenticated] cuando login es exitoso',
      build: () => authBloc,
      act: (bloc) => bloc.add(LoginRequested(
        email: 'test@test.com',
        password: 'password',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );
  });
}
```

---

# 🚀 MÓDULO 7: Deployment y CI/CD

## Docker

### Backend Dockerfile
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["Tickets.API/Tickets.API.csproj", "Tickets.API/"]
COPY ["Tickets.Application/Tickets.Application.csproj", "Tickets.Application/"]
COPY ["Tickets.Domain/Tickets.Domain.csproj", "Tickets.Domain/"]
COPY ["Tickets.Infrastructure/Tickets.Infrastructure.csproj", "Tickets.Infrastructure/"]

RUN dotnet restore "Tickets.API/Tickets.API.csproj"
COPY . .
WORKDIR "/src/Tickets.API"
RUN dotnet build "Tickets.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Tickets.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Tickets.API.dll"]
```

### docker-compose.yml
```yaml
version: '3.8'

services:
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=TicketsDB;User=sa;Password=YourStrong@Passw0rd
    depends_on:
      - sqlserver
    networks:
      - tickets-network

  sqlserver:
    image: mcr.microsoft.com/mssql/server:2019-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong@Passw0rd
    ports:
      - "1433:1433"
    volumes:
      - sqldata:/var/opt/mssql
    networks:
      - tickets-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:80"
    networks:
      - tickets-network

networks:
  tickets-network:
    driver: bridge

volumes:
  sqldata:
```

## CI/CD Pipeline (GitHub Actions)

### Backend
```yaml
name: Backend CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Setup .NET
      uses: actions/setup-dotnet@v1
      with:
        dotnet-version: 8.0.x

    - name: Restore dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build --no-restore --configuration Release

    - name: Test
      run: dotnet test --no-build --verbosity normal

    - name: Publish
      run: dotnet publish -c Release -o ./publish

    - name: Build Docker image
      run: docker build -t tickets-api:${{ github.sha }} .

    - name: Push to registry
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker push tickets-api:${{ github.sha }}
```

### Frontend
```yaml
name: Frontend CI/CD

on:
  push:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.x'

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test

    - name: Build web
      run: flutter build web --release

    - name: Deploy to hosting
      # Configurar según hosting (Firebase, Vercel, etc.)
```

---

## ✅ Entregables de la Fase 5

- [ ] Base de conocimiento implementada
- [ ] Sistema de mantenimientos preventivos
- [ ] Dashboards avanzados
- [ ] Reportes personalizables
- [ ] Optimizaciones de rendimiento aplicadas
- [ ] Índices de base de datos
- [ ] Documentación técnica completa
- [ ] Documentación de usuario
- [ ] Unit tests (>80% coverage)
- [ ] Integration tests
- [ ] Widget tests
- [ ] Docker configurado
- [ ] CI/CD pipeline
- [ ] Deployment automatizado

---

## 🎉 Finalización del Proyecto

Al completar esta fase, el proyecto estará **100% funcional** y listo para producción con:

- ✅ Sistema completo de autenticación
- ✅ Gestión integral de inventarios
- ✅ Sistema de tickets de soporte
- ✅ Notificaciones multiplataforma
- ✅ Gestión de ubicaciones y proveedores
- ✅ Control de accesos y auditoría
- ✅ Base de conocimiento
- ✅ Mantenimientos preventivos
- ✅ Analytics y reportes
- ✅ Rendimiento optimizado
- ✅ Testing completo
- ✅ Documentación exhaustiva
- ✅ CI/CD configurado

---

**¡Proyecto completado!** 🚀
