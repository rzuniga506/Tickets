# 🏗️ Arquitectura del Sistema

## Índice
1. [Visión General](#visión-general)
2. [Arquitectura de Backend](#arquitectura-de-backend)
3. [Arquitectura de Frontend](#arquitectura-de-frontend)
4. [Integración y Comunicación](#integración-y-comunicación)
5. [Seguridad](#seguridad)
6. [Escalabilidad](#escalabilidad)

---

## Visión General

El sistema sigue una arquitectura **Cliente-Servidor** con las siguientes características:

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENTE (Flutter)                     │
│  ┌──────────┬───────────┬──────────┬─────────────────┐  │
│  │ Mobile   │  Tablet   │   Web    │     Desktop     │  │
│  └──────────┴───────────┴──────────┴─────────────────┘  │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTPS/WSS
                       │ JWT Authentication
                       │
┌──────────────────────▼──────────────────────────────────┐
│              API REST (.NET Core 8.0)                    │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Controllers │ Services │ Repositories │ SignalR   │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────┘
                       │ Entity Framework Core
                       │
┌──────────────────────▼──────────────────────────────────┐
│                   SQL Server 2019+                       │
│            (Base de Datos Relacional)                    │
└─────────────────────────────────────────────────────────┘
```

### Características Clave
- **Separación de Responsabilidades**: Backend y Frontend completamente desacoplados
- **API RESTful**: Comunicación mediante endpoints REST
- **Tiempo Real**: SignalR para notificaciones push
- **Autenticación**: JWT (JSON Web Tokens)
- **Multiplataforma**: Un solo código para todas las plataformas

---

## Arquitectura de Backend

### Clean Architecture / N-Layer Architecture

```
┌────────────────────────────────────────────────────────┐
│                   API Layer                             │
│  - Controllers                                          │
│  - Middlewares (Auth, Exception, Logging)              │
│  - Filters & Attributes                                │
│  - SignalR Hubs                                        │
└──────────────────┬─────────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────────┐
│               Application Layer                         │
│  - DTOs (Data Transfer Objects)                        │
│  - Services Interfaces & Implementation                │
│  - AutoMapper Profiles                                 │
│  - Validators (FluentValidation)                       │
│  - Business Logic                                      │
└──────────────────┬─────────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────────┐
│                 Domain Layer                            │
│  - Entities (Models)                                   │
│  - Enums                                               │
│  - Domain Exceptions                                   │
│  - Domain Events                                       │
└──────────────────┬─────────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────────┐
│            Infrastructure Layer                         │
│  - DbContext (Entity Framework)                        │
│  - Repositories Implementation                         │
│  - External Services (Email, SMS, Push)                │
│  - File Storage                                        │
└─────────────────────────────────────────────────────────┘
```

### Estructura de Carpetas Backend

```
backend/
├── Tickets.API/                      # Capa de presentación
│   ├── Controllers/
│   │   ├── AuthController.cs
│   │   ├── InventarioController.cs
│   │   ├── TicketsController.cs
│   │   ├── NotificacionesController.cs
│   │   ├── UbicacionesController.cs
│   │   ├── ProveedoresController.cs
│   │   └── UsuariosController.cs
│   ├── Hubs/
│   │   └── NotificacionesHub.cs      # SignalR
│   ├── Middlewares/
│   │   ├── JwtMiddleware.cs
│   │   ├── ExceptionMiddleware.cs
│   │   └── LoggingMiddleware.cs
│   ├── Filters/
│   │   └── AuthorizePermissionAttribute.cs
│   ├── appsettings.json
│   └── Program.cs
│
├── Tickets.Application/              # Lógica de negocio
│   ├── DTOs/
│   │   ├── Auth/
│   │   ├── Inventario/
│   │   ├── Tickets/
│   │   ├── Notificaciones/
│   │   ├── Ubicaciones/
│   │   └── Proveedores/
│   ├── Services/
│   │   ├── Interfaces/
│   │   │   ├── IAuthService.cs
│   │   │   ├── IInventarioService.cs
│   │   │   ├── ITicketService.cs
│   │   │   ├── INotificacionService.cs
│   │   │   └── ...
│   │   └── Implementation/
│   │       ├── AuthService.cs
│   │       ├── InventarioService.cs
│   │       └── ...
│   ├── Mappings/
│   │   └── AutoMapperProfile.cs
│   ├── Validators/
│   │   ├── InventarioValidator.cs
│   │   └── TicketValidator.cs
│   └── Common/
│       ├── Responses/
│       └── Exceptions/
│
├── Tickets.Domain/                   # Entidades de dominio
│   ├── Entities/
│   │   ├── Usuario.cs
│   │   ├── Rol.cs
│   │   ├── Permiso.cs
│   │   ├── Equipo.cs
│   │   ├── Software.cs
│   │   ├── Ticket.cs
│   │   ├── Notificacion.cs
│   │   ├── Ubicacion.cs
│   │   ├── Proveedor.cs
│   │   └── ...
│   ├── Enums/
│   │   ├── EstadoTicket.cs
│   │   ├── PrioridadTicket.cs
│   │   ├── EstadoEquipo.cs
│   │   └── TipoNotificacion.cs
│   └── Common/
│       └── BaseEntity.cs
│
└── Tickets.Infrastructure/           # Acceso a datos
    ├── Data/
    │   ├── ApplicationDbContext.cs
    │   ├── Configurations/          # Fluent API
    │   │   ├── UsuarioConfiguration.cs
    │   │   ├── EquipoConfiguration.cs
    │   │   └── ...
    │   └── Seed/
    │       └── DataSeeder.cs
    ├── Repositories/
    │   ├── Interfaces/
    │   │   ├── IUnitOfWork.cs
    │   │   ├── IGenericRepository.cs
    │   │   └── ...
    │   └── Implementation/
    │       ├── UnitOfWork.cs
    │       ├── GenericRepository.cs
    │       └── ...
    ├── Services/
    │   ├── EmailService.cs
    │   ├── FileStorageService.cs
    │   └── QRCodeService.cs
    └── Migrations/
```

### Patrones Implementados

1. **Repository Pattern**: Abstracción del acceso a datos
2. **Unit of Work**: Transacciones consistentes
3. **Dependency Injection**: IoC Container nativo de .NET
4. **Factory Pattern**: Creación de objetos complejos
5. **Strategy Pattern**: Diferentes estrategias de notificación
6. **CQRS** (opcional): Separación de comandos y consultas

### Tecnologías Backend

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| .NET Core | 8.0 | Framework principal |
| Entity Framework Core | 8.0 | ORM |
| SQL Server | 2019+ | Base de datos |
| AutoMapper | 12.x | Mapeo de objetos |
| FluentValidation | 11.x | Validaciones |
| Serilog | 3.x | Logging |
| SignalR | 8.0 | Comunicación en tiempo real |
| JWT Bearer | 8.0 | Autenticación |
| Swagger/OpenAPI | 6.x | Documentación API |
| QRCoder | 1.x | Generación QR |

---

## Arquitectura de Frontend

### Arquitectura Modular con BLoC/GetX

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Pages/Screens  │  Widgets  │  BLoC/Controllers  │   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                  Domain Layer                            │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Entities  │  Use Cases  │  Repository Interfaces│   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│                   Data Layer                             │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Models  │  Repositories  │  Data Sources (API)  │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Estructura de Carpetas Frontend

```
frontend/
├── lib/
│   ├── main.dart
│   ├── app.dart                      # MaterialApp principal
│   │
│   ├── core/                         # Configuración global
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   ├── api_config.dart
│   │   │   └── routes.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── colors.dart
│   │   │   └── text_styles.dart
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── api_constants.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── helpers.dart
│   │   └── errors/
│   │       └── exceptions.dart
│   │
│   ├── data/                         # Capa de datos
│   │   ├── models/
│   │   │   ├── auth/
│   │   │   ├── inventario/
│   │   │   ├── tickets/
│   │   │   ├── notificaciones/
│   │   │   └── ...
│   │   ├── repositories/
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── inventario_repository_impl.dart
│   │   │   └── ...
│   │   └── datasources/
│   │       ├── remote/
│   │       │   ├── api_client.dart
│   │       │   ├── auth_api.dart
│   │       │   └── ...
│   │       └── local/
│   │           └── local_storage.dart
│   │
│   ├── domain/                       # Capa de dominio
│   │   ├── entities/
│   │   │   ├── usuario.dart
│   │   │   ├── equipo.dart
│   │   │   ├── ticket.dart
│   │   │   └── ...
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── inventario_repository.dart
│   │   │   └── ...
│   │   └── usecases/
│   │       ├── auth/
│   │       │   ├── login_usecase.dart
│   │       │   └── logout_usecase.dart
│   │       └── ...
│   │
│   ├── presentation/                 # Capa de presentación
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── profile_screen.dart
│   │   │   ├── inventario/
│   │   │   │   ├── inventario_list_screen.dart
│   │   │   │   ├── inventario_detail_screen.dart
│   │   │   │   └── inventario_form_screen.dart
│   │   │   ├── tickets/
│   │   │   │   ├── tickets_list_screen.dart
│   │   │   │   ├── ticket_detail_screen.dart
│   │   │   │   └── ticket_form_screen.dart
│   │   │   ├── notificaciones/
│   │   │   ├── ubicaciones/
│   │   │   ├── proveedores/
│   │   │   └── dashboard/
│   │   │       └── dashboard_screen.dart
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   │   ├── custom_button.dart
│   │   │   │   ├── custom_text_field.dart
│   │   │   │   ├── loading_widget.dart
│   │   │   │   └── error_widget.dart
│   │   │   ├── inventario/
│   │   │   ├── tickets/
│   │   │   └── ...
│   │   └── bloc/                     # State Management
│   │       ├── auth/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── inventario/
│   │       ├── tickets/
│   │       └── ...
│   │
│   └── services/                     # Servicios compartidos
│       ├── navigation_service.dart
│       ├── notification_service.dart
│       ├── storage_service.dart
│       ├── signalr_service.dart
│       └── di/
│           └── injection.dart        # Dependency Injection
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
└── analysis_options.yaml
```

### Tecnologías Frontend

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| flutter | 3.x | Framework UI |
| flutter_bloc / get | latest | State management |
| dio | 5.x | HTTP client |
| get_it | 7.x | Dependency injection |
| freezed | 2.x | Inmutabilidad |
| go_router | 12.x | Navegación |
| shared_preferences | 2.x | Storage local |
| flutter_secure_storage | 9.x | Storage seguro |
| signalr_netcore | 1.x | SignalR client |
| qr_flutter | 4.x | Generación QR |
| fl_chart | 0.65.x | Gráficas |
| pdf | 3.x | Generación PDF |
| image_picker | 1.x | Selección imágenes |
| permission_handler | 11.x | Permisos |
| firebase_messaging | 14.x | Push notifications |
| intl | 0.18.x | Internacionalización |

---

## Integración y Comunicación

### API REST

```
Base URL: https://api.empresa.com/api/v1

Headers requeridos:
- Authorization: Bearer {JWT_TOKEN}
- Content-Type: application/json
- Accept: application/json
```

### Endpoints Principales

```
Auth:
POST   /auth/login
POST   /auth/refresh
POST   /auth/logout
GET    /auth/profile

Inventario:
GET    /inventario/equipos
POST   /inventario/equipos
PUT    /inventario/equipos/{id}
DELETE /inventario/equipos/{id}
GET    /inventario/equipos/{id}/qr

Tickets:
GET    /tickets
POST   /tickets
PUT    /tickets/{id}
GET    /tickets/{id}
POST   /tickets/{id}/comentarios
PUT    /tickets/{id}/asignar

Notificaciones:
GET    /notificaciones
PUT    /notificaciones/{id}/leida
POST   /notificaciones/test

Ubicaciones:
GET    /ubicaciones
POST   /ubicaciones
PUT    /ubicaciones/{id}

Proveedores:
GET    /proveedores
POST   /proveedores
PUT    /proveedores/{id}
```

### SignalR (Tiempo Real)

```
Hub URL: wss://api.empresa.com/hubs/notificaciones

Eventos:
- NuevaNotificacion
- TicketActualizado
- EquipoAsignado
- UsuarioConectado
```

### Formato de Respuestas

**Éxito (200 OK):**
```json
{
  "success": true,
  "data": { ... },
  "message": "Operación exitosa"
}
```

**Error (400/500):**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Descripción del error",
    "details": []
  }
}
```

---

## Seguridad

### Autenticación JWT

```
1. Usuario envía credenciales
2. Backend valida y genera JWT
3. Cliente almacena JWT (secure storage)
4. Cliente envía JWT en cada request
5. Backend valida JWT y permisos
```

**Estructura del JWT:**
```json
{
  "sub": "usuario_id",
  "email": "user@empresa.com",
  "roles": ["Admin", "Tecnico"],
  "permissions": ["inventario.read", "tickets.write"],
  "exp": 1234567890
}
```

### Roles y Permisos

**Roles predefinidos:**
- **Super Admin**: Acceso total
- **Administrador TI**: Gestión completa de inventarios y tickets
- **Técnico**: Gestión de tickets asignados e inventarios
- **Usuario Final**: Crear tickets y consultar su estado

**Permisos granulares:**
- `inventario.read` / `inventario.write` / `inventario.delete`
- `tickets.read` / `tickets.write` / `tickets.assign`
- `usuarios.read` / `usuarios.write`
- `reportes.generate`

### Protección de Datos

- ✅ HTTPS obligatorio
- ✅ Tokens JWT con expiración
- ✅ Refresh tokens para sesiones largas
- ✅ Rate limiting en API
- ✅ Validación de inputs (FluentValidation)
- ✅ SQL Injection protection (EF Core)
- ✅ XSS protection
- ✅ CORS configurado
- ✅ Passwords hasheados (BCrypt/Argon2)
- ✅ Auditoría de todas las acciones

---

## Escalabilidad

### Horizontal Scaling

```
┌─────────────┐
│ Load Balancer│
└──────┬───────┘
       │
   ┌───┴────┬─────────┬─────────┐
   │        │         │         │
┌──▼───┐ ┌─▼───┐  ┌──▼───┐  ┌──▼───┐
│API #1│ │API #2│  │API #3│  │API #N│
└──┬───┘ └──┬──┘  └──┬───┘  └──┬───┘
   │        │        │         │
   └────────┴────────┴─────────┘
              │
        ┌─────▼──────┐
        │ SQL Server │
        │  (Primary) │
        └─────┬──────┘
              │
        ┌─────▼──────┐
        │ SQL Server │
        │  (Replica) │
        └────────────┘
```

### Caching Strategy

- **Memory Cache**: Datos frecuentes (catálogos, configuración)
- **Redis** (opcional): Cache distribuido
- **Client-side Cache**: Datos estáticos en Flutter

### Performance

- **Paginación**: Todas las listas
- **Lazy Loading**: Carga diferida
- **Índices DB**: Optimización de queries
- **Compresión**: Gzip en responses
- **CDN**: Assets estáticos

---

## Diagramas de Flujo

### Flujo de Autenticación

```
Usuario → [Login Screen] → API /auth/login → Validar credenciales
                                                     │
                                                     ├─ Valid → Generar JWT
                                                     │          │
                                                     │          ├─ Guardar en Secure Storage
                                                     │          └─ Navegar a Dashboard
                                                     │
                                                     └─ Invalid → Mostrar error
```

### Flujo de Creación de Ticket

```
Usuario → [Nueva Ticket] → Llenar formulario → Validar campos
                                                     │
                                                     ├─ Valid → POST /tickets
                                                     │          │
                                                     │          ├─ Guardar en DB
                                                     │          ├─ Asignar técnico (auto/manual)
                                                     │          ├─ Enviar notificación
                                                     │          └─ Confirmar creación
                                                     │
                                                     └─ Invalid → Mostrar errores
```

---

## Monitoreo y Logs

### Logging Levels

- **Trace**: Información detallada
- **Debug**: Información de desarrollo
- **Information**: Eventos generales
- **Warning**: Eventos inusuales
- **Error**: Errores manejados
- **Critical**: Errores críticos

### Herramientas de Monitoreo (Opcionales)

- **Application Insights**: Telemetría
- **Serilog Sinks**: Archivos, DB, servicios externos
- **Health Checks**: Endpoints de salud
- **Performance Counters**: Métricas de rendimiento

---

**Última actualización**: Noviembre 2025
