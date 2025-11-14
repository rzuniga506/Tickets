# Backend - Sistema de Tickets y Soporte TI

Sistema de gestión de tickets de soporte e inventario de TI desarrollado con .NET Core 8, SQL Server y arquitectura limpia.

## Arquitectura

El backend está construido siguiendo los principios de **Clean Architecture** y **Domain-Driven Design (DDD)**:

```
backend/
├── Tickets.Domain/          # Capa de Dominio - Entidades, Enums, Excepciones
├── Tickets.Application/     # Capa de Aplicación - DTOs, Servicios, Mappers
├── Tickets.Infrastructure/  # Capa de Infraestructura - DbContext, Repositorios, EF Configurations
└── Tickets.API/            # Capa de Presentación - Controllers, Middleware, Program.cs
```

## Tecnologías Utilizadas

- **.NET Core 8.0** - Framework principal
- **Entity Framework Core 8.0** - ORM para acceso a datos
- **SQL Server** - Base de datos relacional
- **JWT (JSON Web Tokens)** - Autenticación y autorización
- **AutoMapper 12.0** - Mapeo de objetos
- **BCrypt.Net** - Hash de contraseñas
- **FluentValidation 11.9** - Validación de modelos
- **Swagger/OpenAPI** - Documentación de API
- **Serilog** - Logging avanzado

## Características Principales

### Módulos Implementados

1. **Autenticación y Autorización**
   - Login con JWT
   - Refresh Token rotation
   - Control de acceso basado en roles (RBAC)
   - Gestión de permisos granulares

2. **Gestión de Usuarios**
   - CRUD completo de usuarios
   - Asignación de roles
   - Gestión de departamentos
   - Activación/Desactivación de usuarios

3. **Inventario de Equipos**
   - CRUD completo de equipos
   - Generación de códigos QR
   - Asignación de equipos a usuarios
   - Seguimiento de garantías
   - Estados y condiciones de equipos
   - Historial de asignaciones

4. **Tickets de Soporte**
   - Creación y gestión de tickets
   - Sistema de prioridades (Baja, Media, Alta, Urgente, Crítica)
   - Flujo de estados (Nuevo → Asignado → En Proceso → Resuelto → Cerrado)
   - Cálculo automático de SLA por prioridad
   - Asignación de técnicos
   - Evaluación de servicio
   - Reapertura de tickets
   - Estadísticas y métricas

5. **Notificaciones**
   - Notificaciones en tiempo real
   - Soporte para múltiples canales (In-App, Push, Email)
   - Notificaciones automáticas por eventos de tickets
   - Gestión de notificaciones leídas/no leídas

### Patrones y Principios Implementados

- **Repository Pattern** - Abstracción del acceso a datos
- **Unit of Work** - Gestión de transacciones
- **Dependency Injection** - Inversión de control
- **Soft Delete** - Eliminación lógica de registros
- **Auditoría Automática** - Tracking de cambios (Creado por, Modificado por, Fechas)
- **Global Exception Handling** - Manejo centralizado de errores
- **DTOs** - Separación de modelos de dominio y API
- **AutoMapper** - Mapeo automático entre entidades y DTOs

## Requisitos Previos

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [SQL Server 2019+](https://www.microsoft.com/sql-server/sql-server-downloads) o SQL Server Express
- [SQL Server Management Studio (SSMS)](https://docs.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms) - Opcional

## Configuración Inicial

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd Tickets/backend
```

### 2. Configurar la Base de Datos

Editar `appsettings.Development.json` con tu cadena de conexión:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=TicketsDB_Dev;User Id=sa;Password=TU_PASSWORD;TrustServerCertificate=True;MultipleActiveResultSets=true"
  }
}
```

### 3. Aplicar Migraciones

```bash
cd Tickets.Infrastructure
dotnet ef migrations add InitialCreate --startup-project ../Tickets.API
dotnet ef database update --startup-project ../Tickets.API
```

### 4. Datos Iniciales

El sistema crea automáticamente:

**Roles predefinidos:**
- Super Admin
- Admin TI
- Técnico
- Usuario Final

**Usuario administrador por defecto:**
- Email: `admin@tickets.com`
- Password: `Admin123!`

**Permisos completos** asignados al rol Super Admin

## Ejecución

### Desarrollo

```bash
cd Tickets.API
dotnet run
```

La API estará disponible en:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger: `http://localhost:5000` (raíz)

### Producción

```bash
dotnet publish -c Release -o ./publish
cd publish
dotnet Tickets.API.dll
```

## Endpoints Principales

### Autenticación
```
POST   /api/auth/login              - Iniciar sesión
POST   /api/auth/refresh            - Renovar token
POST   /api/auth/logout             - Cerrar sesión
GET    /api/auth/profile            - Obtener perfil
POST   /api/auth/change-password    - Cambiar contraseña
```

### Usuarios
```
GET    /api/usuarios                - Listar usuarios (paginado)
GET    /api/usuarios/{id}           - Obtener usuario
POST   /api/usuarios                - Crear usuario
PUT    /api/usuarios/{id}           - Actualizar usuario
DELETE /api/usuarios/{id}           - Eliminar usuario
POST   /api/usuarios/{id}/asignar-roles - Asignar roles
```

### Equipos
```
GET    /api/equipos                 - Listar equipos (paginado con filtros)
GET    /api/equipos/{id}            - Obtener equipo
GET    /api/equipos/codigo/{codigo} - Buscar por código interno
GET    /api/equipos/qr/{qr}         - Buscar por QR
POST   /api/equipos                 - Crear equipo
PUT    /api/equipos/{id}            - Actualizar equipo
DELETE /api/equipos/{id}            - Eliminar equipo
POST   /api/equipos/{id}/asignar/{userId} - Asignar equipo
POST   /api/equipos/{id}/generar-qr - Generar código QR
```

### Tickets
```
GET    /api/tickets                 - Listar tickets (paginado con filtros)
GET    /api/tickets/{id}            - Obtener ticket
GET    /api/tickets/mis-tickets     - Mis tickets
GET    /api/tickets/asignados       - Tickets asignados a mí
POST   /api/tickets                 - Crear ticket
PUT    /api/tickets/{id}            - Actualizar ticket
POST   /api/tickets/{id}/asignar    - Asignar técnico
POST   /api/tickets/{id}/iniciar-proceso - Iniciar atención
POST   /api/tickets/{id}/resolver   - Resolver ticket
POST   /api/tickets/{id}/cerrar     - Cerrar ticket
POST   /api/tickets/{id}/evaluar    - Evaluar servicio
GET    /api/tickets/estadisticas    - Estadísticas globales
```

### Notificaciones
```
GET    /api/notificaciones          - Mis notificaciones (paginado)
GET    /api/notificaciones/no-leidas/count - Conteo no leídas
PATCH  /api/notificaciones/{id}/marcar-leida - Marcar como leída
PATCH  /api/notificaciones/marcar-todas-leidas - Marcar todas
DELETE /api/notificaciones/{id}     - Eliminar notificación
```

## Estructura de Base de Datos

### Tablas Principales

- **Usuarios** - Información de usuarios del sistema
- **Roles** - Roles de acceso
- **Permisos** - Permisos granulares
- **UsuarioRoles** - Relación muchos a muchos
- **RolPermisos** - Relación muchos a muchos
- **RefreshTokens** - Tokens de refresco JWT
- **Departamentos** - Departamentos de la organización
- **Equipos** - Inventario de equipos de TI
- **Tickets** - Tickets de soporte
- **Notificaciones** - Notificaciones a usuarios

### Características de Auditoría

Todas las entidades heredan de `BaseEntity` con:
- `Id` - Identificador único
- `FechaCreacion` - Timestamp de creación
- `FechaModificacion` - Timestamp de última modificación
- `CreadoPor` - Usuario que creó el registro
- `ModificadoPor` - Usuario que modificó el registro
- `Eliminado` - Flag de eliminación lógica (Soft Delete)

## Seguridad

### JWT Authentication

- **Access Token**: Expira en 60 minutos (configurable)
- **Refresh Token**: Expira en 7 días (configurable)
- **Algoritmo**: HS256 (HMAC-SHA256)
- **Rotation**: Los refresh tokens se rotan automáticamente

### Contraseñas

- Hash con **BCrypt** (10 rounds por defecto)
- Validación de complejidad:
  - Mínimo 8 caracteres
  - Al menos 1 mayúscula
  - Al menos 1 minúscula
  - Al menos 1 número
  - Al menos 1 carácter especial

### CORS

Configurado para:
- **Desarrollo**: Permitir todos los orígenes
- **Producción**: Lista blanca definida en `appsettings.json`

## Variables de Entorno

```bash
ASPNETCORE_ENVIRONMENT=Development
ConnectionStrings__DefaultConnection="Server=...;Database=...;"
JwtSettings__SecretKey="YourSecretKey"
```

## Logs

Los logs se generan utilizando Serilog y se guardan en:
- Consola (desarrollo)
- Archivos en `/logs` (producción)
- Base de datos (opcional)

Niveles de log:
- **Debug** - Desarrollo
- **Information** - Operaciones normales
- **Warning** - Advertencias
- **Error** - Errores manejados
- **Critical** - Errores críticos

## Testing

### Unit Tests (Próximamente)

```bash
cd Tickets.Tests
dotnet test
```

### Integration Tests (Próximamente)

```bash
cd Tickets.IntegrationTests
dotnet test
```

## Migraciones

### Crear nueva migración

```bash
cd Tickets.Infrastructure
dotnet ef migrations add NombreDeMigracion --startup-project ../Tickets.API
```

### Aplicar migraciones

```bash
dotnet ef database update --startup-project ../Tickets.API
```

### Revertir migración

```bash
dotnet ef database update NombreMigracionAnterior --startup-project ../Tickets.API
```

### Eliminar última migración

```bash
dotnet ef migrations remove --startup-project ../Tickets.API
```

## Troubleshooting

### Error: "Cannot connect to SQL Server"

Verificar:
1. SQL Server está corriendo
2. Cadena de conexión correcta en `appsettings.json`
3. Credenciales válidas
4. Puerto 1433 abierto

### Error: "JWT Bearer error"

Verificar:
1. `SecretKey` configurada en `appsettings.json`
2. Longitud mínima de 32 caracteres
3. Issuer y Audience coinciden

### Error: "Migrations pending"

Ejecutar:
```bash
dotnet ef database update --startup-project ../Tickets.API
```

## Contribución

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/NuevaCaracteristica`)
3. Commit cambios (`git commit -m 'Add: Nueva característica'`)
4. Push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Crear Pull Request

## Licencia

Este proyecto es privado y confidencial.

## Contacto

- Desarrollador: Departamento de TI
- Email: soporte@empresa.com

## Roadmap

### Fase 2 - Próximas Características
- [ ] Reportes y dashboards
- [ ] Exportación de datos (Excel, PDF)
- [ ] Integración con Active Directory/LDAP
- [ ] Sistema de archivos adjuntos
- [ ] Historial de cambios de tickets
- [ ] Comentarios en tickets
- [ ] Categorías de tickets

### Fase 3 - Optimizaciones
- [ ] Cache con Redis
- [ ] Background jobs con Hangfire
- [ ] SignalR para notificaciones en tiempo real
- [ ] Búsqueda avanzada con Elasticsearch

### Fase 4 - Módulos Adicionales
- [ ] Gestión de proveedores
- [ ] Gestión de ubicaciones físicas
- [ ] Módulo de mantenimientos preventivos
- [ ] Base de conocimientos (KB)
- [ ] Chatbot de soporte
