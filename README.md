# 🎯 Sistema de Inventarios y Tickets de Soporte TI

Sistema integral desarrollado en **Flutter** y **.NET Core** con **SQL Server** para la gestión de inventarios y tickets de soporte en departamentos de TI.

## 📋 Descripción

Aplicación multiplataforma (Web, Android, iOS, Desktop) que permite gestionar de manera eficiente:
- Inventario de equipos, software y accesorios
- Sistema de tickets de soporte técnico
- Control de accesos y permisos
- Notificaciones en tiempo real
- Gestión de ubicaciones y proveedores

## 🚀 Características Principales

- ✅ **Responsivo**: Funciona en móvil, tablet y web
- ✅ **Modular**: Arquitectura modular y escalable
- ✅ **Seguro**: Autenticación JWT con roles y permisos
- ✅ **Tiempo Real**: Notificaciones push y en tiempo real
- ✅ **Reportes**: Generación de reportes en PDF y Excel
- ✅ **QR Codes**: Identificación rápida de equipos
- ✅ **Dashboard**: Estadísticas y métricas en tiempo real
- ✅ **Auditoría**: Registro completo de todas las acciones

## 📁 Estructura del Proyecto

```
Tickets/
├── backend/                    # API REST con .NET Core
│   ├── API/                   # Controladores y endpoints
│   ├── Core/                  # Lógica de negocio
│   ├── Infrastructure/        # SQL Server, repositorios
│   └── Auth/                  # JWT, autenticación
│
├── frontend/                  # Aplicación Flutter
│   ├── lib/
│   │   ├── core/             # Configuración, constantes, temas
│   │   ├── data/             # Modelos, repositorios, API calls
│   │   ├── domain/           # Entidades de negocio
│   │   ├── presentation/     # UI, widgets, páginas
│   │   └── services/         # Servicios compartidos
│   └── assets/               # Imágenes, iconos, etc.
│
└── docs/                      # Documentación del proyecto
    ├── fases/                # Documentación por fases
    ├── database/             # Esquemas de base de datos
    └── api/                  # Documentación de API
```

## 🎯 Módulos del Sistema

### Módulos Core
1. **Autenticación y Autorización** (JWT)
2. **Gestión de Inventarios**
   - Hardware (PCs, servidores, impresoras, dispositivos de red)
   - Software y licencias
   - Accesorios y consumibles
3. **Sistema de Tickets de Soporte**
   - Creación y asignación
   - Seguimiento y resolución
   - SLA y prioridades

### Módulos Adicionales Prioritarios
4. **Notificaciones**
   - Push notifications
   - Correo electrónico
   - Notificaciones in-app
5. **Gestión de Ubicaciones**
   - Oficinas, pisos, áreas
   - Mapa de equipos
6. **Gestión de Proveedores**
   - Catálogo de proveedores
   - Garantías y contratos
7. **Control de Accesos**
   - Gestión de usuarios y permisos
   - Roles personalizados
   - Auditoría de accesos

### Módulos Opcionales (Fase 5)
8. **Base de Conocimiento**
9. **Mantenimientos Preventivos**
10. **Reportes y Analytics Avanzados**

## 🗓️ Fases de Desarrollo

### [Fase 1: Base y Autenticación](docs/fases/FASE-1.md) ⏱️ 2-3 semanas
- Setup del proyecto (Backend + Frontend)
- Base de datos inicial
- Sistema de autenticación JWT
- Gestión de roles y permisos
- UI/UX base responsivo

### [Fase 2: Inventarios](docs/fases/FASE-2.md) ⏱️ 3-4 semanas
- CRUD completo de inventarios
- Categorización de equipos
- Sistema de asignaciones
- Generación de códigos QR
- Reportes básicos de inventario

### [Fase 3: Tickets de Soporte](docs/fases/FASE-3.md) ⏱️ 3-4 semanas
- Sistema completo de tickets
- Asignación automática/manual
- Seguimiento y comentarios
- SLA y prioridades
- Dashboard de tickets

### [Fase 4: Módulos Adicionales Prioritarios](docs/fases/FASE-4.md) ⏱️ 4-5 semanas
- Sistema de notificaciones
- Gestión de ubicaciones
- Gestión de proveedores
- Control de accesos avanzado
- Integración completa

### [Fase 5: Optimización y Extras](docs/fases/FASE-5.md) ⏱️ 2-3 semanas
- Base de conocimiento
- Mantenimientos preventivos
- Analytics avanzados
- Optimizaciones de rendimiento

## 🛠️ Stack Tecnológico

### Backend
- **.NET Core 8.0** - Framework principal
- **Entity Framework Core** - ORM
- **SQL Server 2019+** - Base de datos
- **JWT** - Autenticación
- **AutoMapper** - Mapeo de objetos
- **FluentValidation** - Validaciones
- **Serilog** - Logging
- **SignalR** - Comunicación en tiempo real

### Frontend
- **Flutter 3.x** - Framework UI
- **Dart 3.x** - Lenguaje
- **BLoC / GetX** - State management
- **Dio** - HTTP client
- **Get_it** - Dependency injection
- **Go_Router** - Navegación
- **Freezed** - Inmutabilidad
- **FL_Chart** - Gráficas
- **QR_Flutter** - Códigos QR

## 📚 Documentación

- [Arquitectura del Sistema](docs/ARQUITECTURA.md)
- [Base de Datos](docs/database/SCHEMA.md)
- [API Endpoints](docs/api/ENDPOINTS.md)
- [Guía de Instalación](docs/INSTALACION.md)
- [Guía de Desarrollo](docs/DESARROLLO.md)

## 🚀 Inicio Rápido

### Prerrequisitos
- .NET Core 8.0 SDK
- SQL Server 2019+
- Flutter 3.x
- Visual Studio Code o Visual Studio 2022

### Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd Tickets
```

2. **Configurar Backend**
```bash
cd backend
dotnet restore
dotnet ef database update
dotnet run
```

3. **Configurar Frontend**
```bash
cd frontend
flutter pub get
flutter run
```

Ver [Guía de Instalación Completa](docs/INSTALACION.md)

## 📝 Convenciones de Código

### Backend (.NET)
- Nomenclatura PascalCase para clases y métodos
- Nomenclatura camelCase para variables
- Async/await para operaciones asíncronas
- Clean Architecture

### Frontend (Flutter)
- Nomenclatura camelCase para variables y métodos
- Nomenclatura PascalCase para clases
- Widgets reutilizables
- Separación de responsabilidades (BLoC/GetX)

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto es privado y de uso interno.

## 👥 Equipo de Desarrollo

- **Desarrollador Principal**: [Tu nombre]
- **Departamento**: TI
- **Contacto**: [email@empresa.com]

## 📞 Soporte

Para soporte y preguntas, contactar al equipo de desarrollo en:
- Email: soporte@empresa.com
- Teams/Slack: #proyecto-inventarios-tickets

---

**Última actualización**: Noviembre 2025
**Versión**: 1.0.0-alpha
