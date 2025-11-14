# 👨‍💻 Guía de Desarrollo

Guía para desarrolladores que trabajarán en el proyecto.

## 📝 Convenciones de Código

### Backend (.NET)

#### Nomenclatura
- **Clases**: PascalCase
  - `TicketService`, `UsuarioController`
- **Métodos**: PascalCase
  - `CrearTicketAsync()`, `ObtenerUsuarios()`
- **Variables y parámetros**: camelCase
  - `usuarioId`, `ticketDto`
- **Constantes**: UPPER_CASE
  - `MAX_FILE_SIZE`, `DEFAULT_PAGE_SIZE`
- **Propiedades**: PascalCase
  - `NumeroTicket`, `FechaCreacion`

#### Estructura de Archivos
```
Tickets.API/
├── Controllers/
│   └── {NombreModulo}Controller.cs
├── Hubs/
│   └── {Nombre}Hub.cs
└── Middlewares/
    └── {Nombre}Middleware.cs

Tickets.Application/
├── DTOs/
│   └── {Modulo}/
│       ├── {Entidad}Dto.cs
│       ├── {Entidad}CreateDto.cs
│       └── {Entidad}UpdateDto.cs
├── Services/
│   ├── Interfaces/
│   │   └── I{Nombre}Service.cs
│   └── Implementation/
│       └── {Nombre}Service.cs
└── Validators/
    └── {Entidad}Validator.cs

Tickets.Domain/
├── Entities/
│   └── {Nombre}.cs
├── Enums/
│   └── {Nombre}.cs
└── Common/
    └── BaseEntity.cs

Tickets.Infrastructure/
├── Data/
│   ├── ApplicationDbContext.cs
│   └── Configurations/
│       └── {Entidad}Configuration.cs
└── Repositories/
    ├── Interfaces/
    └── Implementation/
```

#### Buenas Prácticas

**1. Async/Await**
```csharp
// Correcto
public async Task<TicketDto> CrearTicketAsync(TicketCreateDto dto)
{
    var ticket = await _repository.GetByIdAsync(id);
    return _mapper.Map<TicketDto>(ticket);
}

// Incorrecto
public TicketDto CrearTicket(TicketCreateDto dto)
{
    var ticket = _repository.GetById(id).Result;
    return _mapper.Map<TicketDto>(ticket);
}
```

**2. Inyección de Dependencias**
```csharp
// Correcto - Constructor injection
public class TicketService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public TicketService(IUnitOfWork unitOfWork, IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }
}
```

**3. Manejo de Errores**
```csharp
// Usar excepciones personalizadas
if (ticket == null)
    throw new NotFoundException("Ticket no encontrado");

if (!validacion)
    throw new ValidationException("Datos inválidos");
```

**4. DTOs vs Entities**
```csharp
// NUNCA exponer entidades directamente
// Incorrecto
public async Task<Ticket> GetTicket(int id) { }

// Correcto
public async Task<TicketDto> GetTicket(int id)
{
    var ticket = await _repository.GetByIdAsync(id);
    return _mapper.Map<TicketDto>(ticket);
}
```

---

### Frontend (Flutter)

#### Nomenclatura
- **Clases**: PascalCase
  - `TicketBloc`, `LoginScreen`
- **Variables y métodos**: camelCase
  - `ticketList`, `loadTickets()`
- **Constantes**: camelCase con prefijo 'k'
  - `kPrimaryColor`, `kDefaultPadding`
- **Archivos**: snake_case
  - `ticket_list_screen.dart`, `api_client.dart`

#### Estructura de Archivos
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   └── routes.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       └── validators.dart
├── data/
│   ├── models/
│   │   └── {modulo}/
│   │       └── {entidad}_model.dart
│   ├── repositories/
│   │   └── {nombre}_repository_impl.dart
│   └── datasources/
│       └── remote/
│           └── {nombre}_api.dart
├── domain/
│   ├── entities/
│   │   └── {entidad}.dart
│   ├── repositories/
│   │   └── {nombre}_repository.dart
│   └── usecases/
│       └── {modulo}/
│           └── {accion}_usecase.dart
├── presentation/
│   ├── screens/
│   │   └── {modulo}/
│   │       └── {nombre}_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   └── {modulo}/
│   └── bloc/
│       └── {nombre}/
│           ├── {nombre}_bloc.dart
│           ├── {nombre}_event.dart
│           └── {nombre}_state.dart
└── services/
    └── {nombre}_service.dart
```

#### Buenas Prácticas

**1. Widgets Stateless vs Stateful**
```dart
// Preferir StatelessWidget cuando sea posible
class TicketCard extends StatelessWidget {
  final TicketDto ticket;
  const TicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(child: Text(ticket.asunto));
  }
}

// Solo usar StatefulWidget cuando se necesite estado interno
class TicketForm extends StatefulWidget {
  // ...
}
```

**2. Const Widgets**
```dart
// Usar const siempre que sea posible para mejor performance
const SizedBox(height: 16)
const Text('Título')
const Padding(padding: EdgeInsets.all(8))
```

**3. BLoC Pattern**
```dart
// Event
class LoadTickets extends TicketEvent {}

// State
class TicketsLoaded extends TicketState {
  final List<TicketDto> tickets;
  const TicketsLoaded({required this.tickets});
}

// BLoC
class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketRepository repository;

  TicketBloc({required this.repository}) : super(TicketInitial()) {
    on<LoadTickets>(_onLoadTickets);
  }

  Future<void> _onLoadTickets(
    LoadTickets event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final tickets = await repository.getTickets();
      emit(TicketsLoaded(tickets: tickets));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }
}
```

**4. Responsivo**
```dart
// Usar LayoutBuilder para diseños responsivos
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return DesktopLayout();
    } else {
      return MobileLayout();
    }
  },
)
```

---

## 🧪 Testing

### Backend - Unit Tests

```csharp
[Fact]
public async Task CrearTicket_ConDatosValidos_DebeRetornarTicketDto()
{
    // Arrange
    var mockRepo = new Mock<ITicketRepository>();
    var mockMapper = new Mock<IMapper>();
    var service = new TicketService(mockRepo.Object, mockMapper.Object);
    var dto = new TicketCreateDto { Asunto = "Test" };

    // Act
    var result = await service.CrearTicketAsync(dto);

    // Assert
    Assert.NotNull(result);
    mockRepo.Verify(x => x.AddAsync(It.IsAny<Ticket>()), Times.Once);
}
```

### Frontend - Widget Tests

```dart
testWidgets('LoginScreen debe mostrar botón de login', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: LoginScreen()),
  );

  expect(find.text('Iniciar Sesión'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

---

## 🔄 Git Workflow

### Branches

- `main`: Producción
- `develop`: Desarrollo
- `feature/*`: Nuevas características
- `bugfix/*`: Corrección de bugs
- `hotfix/*`: Correcciones urgentes en producción

### Commits

Usar conventional commits:

```
feat: agregar sistema de notificaciones
fix: corregir error al asignar tickets
docs: actualizar documentación de API
refactor: optimizar consultas de inventario
test: agregar tests para TicketService
chore: actualizar dependencias
```

### Pull Requests

1. Crear branch desde `develop`
2. Hacer commits con mensajes descriptivos
3. Crear PR hacia `develop`
4. Code review por al menos 1 desarrollador
5. Merge después de aprobación

---

## 🚀 Deployment

### Desarrollo
```bash
# Backend
dotnet run

# Frontend
flutter run -d chrome
```

### Staging
```bash
docker-compose -f docker-compose.staging.yml up -d
```

### Producción
```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📚 Recursos

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC](https://bloclibrary.dev/)
- [Entity Framework Core](https://docs.microsoft.com/ef/core/)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)

---

**Última actualización:** Noviembre 2025
