# 🚀 Guía de Instalación y Configuración

Esta guía te ayudará a configurar el entorno de desarrollo completo para el proyecto.

## 📋 Tabla de Contenido

1. [Prerrequisitos](#prerrequisitos)
2. [Instalación Backend (.NET)](#instalación-backend-net)
3. [Instalación Frontend (Flutter)](#instalación-frontend-flutter)
4. [Configuración de Base de Datos](#configuración-de-base-de-datos)
5. [Variables de Entorno](#variables-de-entorno)
6. [Ejecución en Desarrollo](#ejecución-en-desarrollo)
7. [Deployment con Docker](#deployment-con-docker)
8. [Troubleshooting](#troubleshooting)

---

## Prerrequisitos

### Backend
- **.NET SDK 8.0** o superior
  - Descargar: https://dotnet.microsoft.com/download
  - Verificar: `dotnet --version`

- **SQL Server 2019+** o **SQL Server Express**
  - Descargar: https://www.microsoft.com/sql-server/sql-server-downloads
  - Alternativa: SQL Server en Docker

- **Visual Studio 2022** o **VS Code**
  - VS 2022: https://visualstudio.microsoft.com/
  - VS Code: https://code.visualstudio.com/

### Frontend
- **Flutter SDK 3.x**
  - Descargar: https://flutter.dev/docs/get-started/install
  - Verificar: `flutter --version`

- **Dart SDK** (incluido con Flutter)

- **Android Studio** (para desarrollo Android)
  - Descargar: https://developer.android.com/studio

- **Xcode** (para desarrollo iOS - solo macOS)

### Herramientas Opcionales
- **Docker Desktop** (para deployment)
- **Git** (control de versiones)
- **Postman** (pruebas de API)

---

## Instalación Backend (.NET)

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-empresa/tickets.git
cd tickets
```

### 2. Crear la Estructura del Proyecto

```bash
# Crear solución
dotnet new sln -n Tickets

# Crear proyectos
cd backend
dotnet new webapi -n Tickets.API
dotnet new classlib -n Tickets.Application
dotnet new classlib -n Tickets.Domain
dotnet new classlib -n Tickets.Infrastructure

# Agregar proyectos a la solución
dotnet sln add Tickets.API/Tickets.API.csproj
dotnet sln add Tickets.Application/Tickets.Application.csproj
dotnet sln add Tickets.Domain/Tickets.Domain.csproj
dotnet sln add Tickets.Infrastructure/Tickets.Infrastructure.csproj

# Establecer referencias
cd Tickets.API
dotnet add reference ../Tickets.Application/Tickets.Application.csproj
dotnet add reference ../Tickets.Infrastructure/Tickets.Infrastructure.csproj

cd ../Tickets.Application
dotnet add reference ../Tickets.Domain/Tickets.Domain.csproj

cd ../Tickets.Infrastructure
dotnet add reference ../Tickets.Domain/Tickets.Domain.csproj
```

### 3. Instalar Paquetes NuGet

**En Tickets.API:**
```bash
cd Tickets.API
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Swashbuckle.AspNetCore
dotnet add package Serilog.AspNetCore
dotnet add package Microsoft.AspNetCore.SignalR
```

**En Tickets.Application:**
```bash
cd ../Tickets.Application
dotnet add package AutoMapper
dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
dotnet add package FluentValidation
dotnet add package FluentValidation.DependencyInjectionExtensions
```

**En Tickets.Infrastructure:**
```bash
cd ../Tickets.Infrastructure
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package BCrypt.Net-Next
```

### 4. Restaurar Dependencias

```bash
cd ..
dotnet restore
```

---

## Configuración de Base de Datos

### Opción 1: SQL Server Local

#### 1. Crear Base de Datos

Abrir SQL Server Management Studio (SSMS) y ejecutar:

```sql
CREATE DATABASE TicketsDB;
GO

USE TicketsDB;
GO
```

#### 2. Configurar Connection String

Editar `backend/Tickets.API/appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=TicketsDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"
  },
  "JwtSettings": {
    "SecretKey": "CAMBIAR_ESTA_CLAVE_SECRETA_DEBE_SER_MINIMO_32_CARACTERES_PARA_SEGURIDAD",
    "Issuer": "TicketsAPI",
    "Audience": "TicketsClient",
    "ExpirationMinutes": 60,
    "RefreshTokenExpirationDays": 7
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  },
  "AllowedHosts": "*",
  "Cors": {
    "AllowedOrigins": [
      "http://localhost:3000",
      "http://localhost:5000",
      "http://localhost:8080"
    ]
  }
}
```

#### 3. Ejecutar Migraciones

```bash
cd backend/Tickets.API

# Crear migración inicial
dotnet ef migrations add InitialCreate --project ../Tickets.Infrastructure

# Aplicar migración
dotnet ef database update --project ../Tickets.Infrastructure
```

### Opción 2: SQL Server en Docker

```bash
# Iniciar SQL Server en Docker
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Passw0rd" \
   -p 1433:1433 --name sqlserver \
   -d mcr.microsoft.com/mssql/server:2019-latest

# Connection String para Docker:
# Server=localhost,1433;Database=TicketsDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True
```

---

## Instalación Frontend (Flutter)

### 1. Navegar al Directorio Frontend

```bash
cd ../frontend
```

### 2. Crear Proyecto Flutter (si no existe)

```bash
flutter create .
```

### 3. Configurar pubspec.yaml

Editar `pubspec.yaml` y agregar dependencias:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3

  # Networking
  dio: ^5.4.0

  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2

  # Navigation
  go_router: ^12.1.3

  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # Utils
  intl: ^0.18.1
  logger: ^2.0.2+1
  equatable: ^2.0.5

  # Push Notifications
  firebase_messaging: ^14.7.6
  firebase_core: ^2.24.2

  # QR
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.5.5

  # Charts
  fl_chart: ^0.65.0

  # PDF
  pdf: ^3.10.7

  # Image
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  flutter_lints: ^3.0.1
  bloc_test: ^9.1.5
```

### 4. Instalar Dependencias

```bash
flutter pub get
```

### 5. Configurar API Base URL

Crear `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  static const String signalRHubUrl = String.fromEnvironment(
    'SIGNALR_HUB_URL',
    defaultValue: 'http://localhost:5000/hubs/notificaciones',
  );
}
```

### 6. Configurar Firebase (opcional - para push notifications)

#### Android
1. Crear proyecto en Firebase Console
2. Descargar `google-services.json`
3. Colocar en `android/app/`
4. Editar `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

5. Editar `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### iOS
1. Descargar `GoogleService-Info.plist`
2. Colocar en `ios/Runner/`
3. Configurar en Xcode

---

## Variables de Entorno

### Backend (.NET)

Crear `backend/Tickets.API/appsettings.Production.json` (NO incluir en Git):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=production-server;Database=TicketsDB;User Id=tickets_user;Password=STRONG_PASSWORD_HERE"
  },
  "JwtSettings": {
    "SecretKey": "SUPER_SECRET_KEY_FOR_PRODUCTION_AT_LEAST_32_CHARS",
    "Issuer": "TicketsAPI",
    "Audience": "TicketsClient",
    "ExpirationMinutes": 60,
    "RefreshTokenExpirationDays": 7
  },
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

### Frontend (Flutter)

Crear archivo `.env` en la raíz del proyecto frontend:

```env
API_BASE_URL=http://localhost:5000/api
SIGNALR_HUB_URL=http://localhost:5000/hubs/notificaciones
```

---

## Ejecución en Desarrollo

### Backend

```bash
cd backend/Tickets.API

# Ejecutar en modo desarrollo
dotnet run

# O con hot reload
dotnet watch run

# La API estará disponible en:
# https://localhost:5001
# http://localhost:5000
# Swagger: http://localhost:5000/swagger
```

### Frontend

#### Web
```bash
cd frontend
flutter run -d chrome
```

#### Android
```bash
flutter run -d android
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

#### Todas las plataformas disponibles
```bash
flutter devices
flutter run -d <device-id>
```

---

## Deployment con Docker

### 1. Backend Dockerfile

Crear `backend/Dockerfile`:

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

### 2. Frontend Dockerfile

Crear `frontend/Dockerfile`:

```dockerfile
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 3. Docker Compose

Crear `docker-compose.yml` en la raíz:

```yaml
version: '3.8'

services:
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

  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=sqlserver;Database=TicketsDB;User=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True
    depends_on:
      - sqlserver
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

### 4. Ejecutar con Docker

```bash
# Build y ejecutar
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v
```

---

## Troubleshooting

### Backend

#### Error: Trust the HTTPS development certificate

```bash
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

#### Error de conexión a SQL Server

1. Verificar que SQL Server esté corriendo
2. Verificar connection string
3. Verificar firewall
4. Probar conexión con SSMS

#### Error al ejecutar migraciones

```bash
# Eliminar carpeta Migrations
# Eliminar base de datos
# Crear migración inicial nuevamente
dotnet ef migrations add InitialCreate --project Tickets.Infrastructure
dotnet ef database update --project Tickets.Infrastructure
```

### Frontend

#### Error: Unable to locate Android SDK

1. Instalar Android Studio
2. Configurar variables de entorno:
   - `ANDROID_HOME`: Ruta al SDK
   - Agregar al PATH: `%ANDROID_HOME%\platform-tools`

3. Ejecutar:
```bash
flutter doctor --android-licenses
```

#### Error de certificados iOS

```bash
# En macOS
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

#### Error: Gradle build failed

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Hot reload no funciona

```bash
flutter clean
flutter pub get
flutter run
```

### Base de Datos

#### No se puede conectar a SQL Server en Docker

```bash
# Verificar que el contenedor esté corriendo
docker ps

# Ver logs del contenedor
docker logs sqlserver

# Verificar puerto
netstat -an | grep 1433
```

---

## Verificación de Instalación

### Backend

```bash
# Verificar que la API esté corriendo
curl http://localhost:5000/health

# O abrir en navegador
http://localhost:5000/swagger
```

### Frontend

```bash
# Verificar Flutter
flutter doctor -v

# Verificar dependencias
flutter pub outdated
```

### Base de Datos

```bash
# Verificar conexión
sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -Q "SELECT @@VERSION"
```

---

## Próximos Pasos

1. ✅ Verificar que todo funcione correctamente
2. 📝 Revisar la [Arquitectura](ARQUITECTURA.md)
3. 🔧 Iniciar desarrollo según [FASE-1](fases/FASE-1.md)
4. 🧪 Configurar testing
5. 📊 Configurar monitoreo

---

## Recursos Adicionales

- [Documentación .NET](https://docs.microsoft.com/dotnet/)
- [Documentación Flutter](https://flutter.dev/docs)
- [Entity Framework Core](https://docs.microsoft.com/ef/core/)
- [SQL Server](https://docs.microsoft.com/sql/)

---

**¿Necesitas ayuda?** Contacta al equipo de desarrollo.

**Última actualización:** Noviembre 2025
