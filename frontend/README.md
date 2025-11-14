# Frontend - Sistema de Tickets y Soporte TI

Aplicación móvil multiplataforma desarrollada con Flutter para gestión de tickets de soporte e inventario de TI.

## Arquitectura

El frontend está construido siguiendo **Clean Architecture** y **BLoC Pattern**:

```
lib/
├── config/                 # Configuración (constantes, rutas, tema)
├── core/                   # Núcleo de la app
│   ├── api/               # Cliente HTTP y endpoints
│   ├── errors/            # Excepciones y failures
│   ├── storage/           # Almacenamiento seguro
│   └── utils/             # Utilidades
├── data/                   # Capa de Datos
│   ├── models/            # Modelos de datos
│   ├── repositories/      # Repositorios
│   └── services/          # Servicios de API
├── logic/                  # Lógica de Negocio (BLoC/Cubit)
│   ├── auth/              # Autenticación
│   ├── users/             # Usuarios
│   ├── equipos/           # Equipos
│   ├── tickets/           # Tickets
│   └── notificaciones/    # Notificaciones
├── presentation/           # Capa de Presentación
│   ├── screens/           # Pantallas
│   └── widgets/           # Widgets reutilizables
└── l10n/                  # Internacionalización
```

## Tecnologías Utilizadas

### State Management
- **flutter_bloc 8.1.3** - Gestión de estado con BLoC pattern
- **equatable 2.0.5** - Comparación de objetos

### Networking
- **dio 5.4.0** - Cliente HTTP
- **retrofit 4.0.3** - Type-safe HTTP client
- **pretty_dio_logger 1.3.1** - Logging de peticiones

### Storage
- **flutter_secure_storage 9.0.0** - Almacenamiento seguro de tokens
- **shared_preferences 2.2.2** - Preferencias locales

### UI Components
- **flutter_svg 2.0.9** - Imágenes SVG
- **cached_network_image 3.3.1** - Caché de imágenes
- **shimmer 3.0.0** - Efectos de carga
- **lottie 3.0.0** - Animaciones
- **fl_chart 0.65.0** - Gráficas y estadísticas

### Forms & Validation
- **formz 0.6.1** - Validación de formularios
- **mask_text_input_formatter 2.7.0** - Máscaras de entrada

### QR Code
- **qr_flutter 4.1.0** - Generación de QR
- **mobile_scanner 3.5.5** - Escaneo de QR

### Notifications
- **flutter_local_notifications 16.3.0** - Notificaciones locales
- **firebase_core 2.24.2** - Firebase
- **firebase_messaging 14.7.9** - Push notifications

### Utilities
- **get_it 7.6.4** - Dependency Injection
- **injectable 2.3.2** - Code generation para DI
- **logger 2.0.2** - Logging
- **intl 0.18.1** - Internacionalización y formato
- **timeago 3.6.0** - Fechas relativas

### Responsive
- **flutter_screenutil 5.9.0** - Diseño responsivo

## Características Implementadas

### Core Layer ✅

1. **API Client** (`core/api/`)
   - Cliente HTTP con Dio
   - Interceptores para autenticación
   - Refresh token automático
   - Logger de peticiones
   - Manejo de errores

2. **Storage** (`core/storage/`)
   - Almacenamiento seguro de tokens
   - Persistencia de sesión
   - Verificación de autenticación

3. **Errors** (`core/errors/`)
   - Excepciones personalizadas
   - Failures para manejo de errores
   - Mapeo de errores HTTP

### Data Layer ✅

1. **Modelos** (`data/models/`)
   - **Auth**: LoginRequest, AuthResponse
   - **Usuario**: UserModel completo
   - **Equipo**: EquipoModel con estados y condiciones
   - **Ticket**: TicketModel con SLA y prioridades
   - **Notificación**: NotificacionModel con tipos

2. **API Endpoints** (`core/api/api_endpoints.dart`)
   - Todos los endpoints del backend mapeados
   - Auth, Usuarios, Equipos, Tickets, Notificaciones

### Config Layer ✅

1. **Constants** (`config/constants.dart`)
   - URLs de API
   - Timeouts
   - Claves de storage
   - Configuraciones de paginación
   - Enums completos (Estados, Prioridades, Tipos)
   - Extensiones de enums

2. **Theme** (`config/theme.dart`)
   - Tema claro completo
   - Tema oscuro preparado
   - Colores de estado
   - Colores de prioridad
   - Estilos de widgets
   - Typography personalizada

## Instalación

### Requisitos Previos

- [Flutter 3.0+](https://flutter.dev/docs/get-started/install)
- [Dart 3.0+](https://dart.dev/get-dart)
- Android Studio / Xcode (para emuladores)
- VS Code con extensiones de Flutter (recomendado)

### Pasos de Instalación

1. **Clonar el repositorio**

```bash
git clone <repository-url>
cd Tickets/frontend
```

2. **Instalar dependencias**

```bash
flutter pub get
```

3. **Generar código (cuando esté configurado)**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configurar Firebase** (para notificaciones push)

```bash
# Agregar google-services.json para Android
# Agregar GoogleService-Info.plist para iOS
```

5. **Ejecutar la aplicación**

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (si está habilitado)
flutter run -d chrome
```

## Configuración

### API Base URL

Editar `lib/config/constants.dart`:

```dart
static const String apiBaseUrl = 'http://TU_IP:5000/api'; // Desarrollo
static const String apiBaseUrlProd = 'https://api.tickets.com/api'; // Producción
```

### Tokens de Firebase

Configurar en `lib/config/constants.dart` y archivos de configuración de Firebase.

## Estructura de Navegación (Próximamente)

```
/
├── /login
├── /home
├── /tickets
│   ├── /tickets/list
│   ├── /tickets/create
│   ├── /tickets/:id
│   └── /tickets/:id/edit
├── /equipos
│   ├── /equipos/list
│   ├── /equipos/create
│   ├── /equipos/:id
│   └── /equipos/scan
├── /usuarios
│   ├── /usuarios/list
│   ├── /usuarios/create
│   └── /usuarios/:id
├── /notificaciones
└── /profile
```

## Pantallas Principales (En Desarrollo)

### 1. Autenticación
- [x] Login
- [ ] Recuperar contraseña
- [ ] Cambiar contraseña

### 2. Home/Dashboard
- [ ] Resumen de tickets
- [ ] Estadísticas
- [ ] Accesos rápidos
- [ ] Notificaciones recientes

### 3. Tickets
- [ ] Lista de tickets (con filtros)
- [ ] Crear ticket
- [ ] Detalle de ticket
- [ ] Asignar ticket
- [ ] Resolver ticket
- [ ] Evaluar ticket
- [ ] Escanear QR de equipo

### 4. Equipos
- [ ] Lista de equipos (con filtros)
- [ ] Crear equipo
- [ ] Detalle de equipo
- [ ] Asignar equipo
- [ ] Generar QR
- [ ] Escanear QR
- [ ] Mis equipos asignados

### 5. Usuarios (Admin)
- [ ] Lista de usuarios
- [ ] Crear usuario
- [ ] Editar usuario
- [ ] Asignar roles

### 6. Notificaciones
- [ ] Lista de notificaciones
- [ ] Marcar como leída
- [ ] Badge de no leídas
- [ ] Filtros por tipo

### 7. Perfil
- [ ] Ver perfil
- [ ] Editar datos
- [ ] Cambiar contraseña
- [ ] Configuraciones
- [ ] Cerrar sesión

## Estado de Desarrollo

### ✅ Completado
- Configuración del proyecto
- Dependencias
- Estructura de carpetas
- Core API Client
- Secure Storage
- Modelos de datos
- Theme completo
- Constants y configuración
- Error handling

### 🚧 En Desarrollo
- Servicios de API
- Repositorios
- BLoCs/Cubits
- Pantallas UI
- Widgets reutilizables
- Routing
- Testing

### 📋 Pendiente
- Integración Firebase
- Notificaciones Push
- Offline support
- Testing unitario
- Testing de integración
- CI/CD

## Patrones de Código

### BLoC Pattern

```dart
// Cubit
class TicketCubit extends Cubit<TicketState> {
  final TicketRepository repository;

  TicketCubit(this.repository) : super(TicketInitial());

  Future<void> loadTickets() async {
    emit(TicketLoading());
    try {
      final tickets = await repository.getTickets();
      emit(TicketLoaded(tickets));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }
}
```

### Repository Pattern

```dart
class TicketRepository {
  final TicketService service;

  Future<List<TicketModel>> getTickets() async {
    try {
      return await service.getTickets();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
```

### Dependency Injection

```dart
// Con GetIt
final getIt = GetIt.instance;

void setupDependencies() {
  // Storage
  getIt.registerLazySingleton(() => SecureStorage());

  // API
  getIt.registerLazySingleton(() => ApiClient(getIt()));

  // Services
  getIt.registerLazySingleton(() => AuthService(getIt()));

  // Repositories
  getIt.registerLazySingleton(() => AuthRepository(getIt()));

  // Cubits
  getIt.registerFactory(() => AuthCubit(getIt()));
}
```

## Testing

### Unit Tests

```bash
flutter test
```

### Integration Tests

```bash
flutter test integration_test
```

### Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Build

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Troubleshooting

### Error: "Couldn't connect to backend"

Verificar:
1. Backend está corriendo
2. URL correcta en `constants.dart`
3. Dispositivo/emulador puede acceder a la IP del backend
4. Usar IP local (no localhost) para dispositivos físicos

### Error: "Token expired"

El refresh token se maneja automáticamente. Si persiste:
1. Cerrar sesión
2. Volver a iniciar sesión

### Error: "Firebase not configured"

1. Agregar archivos de configuración de Firebase
2. Configurar Firebase en la consola
3. Habilitar Firebase Messaging

## Convenciones de Código

- **Nombres de archivos**: snake_case
- **Clases**: PascalCase
- **Variables**: camelCase
- **Constantes**: UPPER_SNAKE_CASE (solo const globales)
- **Private**: prefijo `_`
- **Comentarios**: dartdoc (`///`)

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

### Fase 1 - Autenticación ✅
- [x] Login
- [x] Storage de tokens
- [x] Auto-refresh
- [ ] Pantalla de login UI

### Fase 2 - Tickets 🚧
- [ ] Lista de tickets
- [ ] Crear ticket
- [ ] Detalle y acciones
- [ ] Filtros y búsqueda

### Fase 3 - Inventario 📋
- [ ] Lista de equipos
- [ ] Escaneo QR
- [ ] Asignación
- [ ] Mis equipos

### Fase 4 - Notificaciones 📋
- [ ] Lista de notificaciones
- [ ] Badge contador
- [ ] Push notifications
- [ ] In-app alerts

### Fase 5 - Optimización 📋
- [ ] Offline support
- [ ] Cache
- [ ] Performance
- [ ] Analytics
