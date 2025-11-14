# 📘 FASE 1: Base y Autenticación

**Duración estimada:** 2-3 semanas
**Prioridad:** CRÍTICA
**Estado:** Pendiente

---

## 🎯 Objetivos

1. Configurar la infraestructura base del proyecto (Backend + Frontend)
2. Implementar sistema de autenticación JWT
3. Crear sistema de roles y permisos
4. Diseñar UI/UX base responsivo
5. Establecer conexión segura API-Cliente

---

## 📋 Tareas Detalladas

### 1. Setup del Proyecto Backend (.NET Core)

#### 1.1 Creación de la Solución
```bash
# Crear solución
dotnet new sln -n Tickets

# Crear proyectos
dotnet new webapi -n Tickets.API
dotnet new classlib -n Tickets.Application
dotnet new classlib -n Tickets.Domain
dotnet new classlib -n Tickets.Infrastructure

# Agregar proyectos a la solución
dotnet sln add Tickets.API/Tickets.API.csproj
dotnet sln add Tickets.Application/Tickets.Application.csproj
dotnet sln add Tickets.Domain/Tickets.Domain.csproj
dotnet sln add Tickets.Infrastructure/Tickets.Infrastructure.csproj

# Referencias entre proyectos
cd Tickets.API
dotnet add reference ../Tickets.Application/Tickets.Application.csproj
dotnet add reference ../Tickets.Infrastructure/Tickets.Infrastructure.csproj

cd ../Tickets.Application
dotnet add reference ../Tickets.Domain/Tickets.Domain.csproj

cd ../Tickets.Infrastructure
dotnet add reference ../Tickets.Domain/Tickets.Domain.csproj
```

#### 1.2 Instalación de Paquetes NuGet

**Tickets.API:**
```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Swashbuckle.AspNetCore
dotnet add package Serilog.AspNetCore
dotnet add package Microsoft.AspNetCore.SignalR
```

**Tickets.Application:**
```bash
dotnet add package AutoMapper
dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
dotnet add package FluentValidation
dotnet add package FluentValidation.DependencyInjectionExtensions
```

**Tickets.Infrastructure:**
```bash
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package BCrypt.Net-Next
```

#### 1.3 Configuración de appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=TicketsDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"
  },
  "JwtSettings": {
    "SecretKey": "TU_CLAVE_SECRETA_MUY_SEGURA_DE_AL_MENOS_32_CARACTERES",
    "Issuer": "TicketsAPI",
    "Audience": "TicketsClient",
    "ExpirationMinutes": 60,
    "RefreshTokenExpirationDays": 7
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Cors": {
    "AllowedOrigins": [
      "http://localhost:3000",
      "http://localhost:5000"
    ]
  }
}
```

---

### 2. Base de Datos SQL Server

#### 2.1 Creación de Entidades Base

**Usuario.cs** (Domain/Entities/)
```csharp
public class Usuario : BaseEntity
{
    public string Nombre { get; set; }
    public string Apellido { get; set; }
    public string Email { get; set; }
    public string PasswordHash { get; set; }
    public string Telefono { get; set; }
    public bool Activo { get; set; }
    public DateTime? UltimoAcceso { get; set; }

    // Relaciones
    public int? DepartamentoId { get; set; }
    public Departamento Departamento { get; set; }

    public ICollection<UsuarioRol> UsuarioRoles { get; set; }
    public ICollection<RefreshToken> RefreshTokens { get; set; }
}
```

**Rol.cs** (Domain/Entities/)
```csharp
public class Rol : BaseEntity
{
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public bool EsSistema { get; set; } // No se puede eliminar

    // Relaciones
    public ICollection<UsuarioRol> UsuarioRoles { get; set; }
    public ICollection<RolPermiso> RolPermisos { get; set; }
}
```

**Permiso.cs** (Domain/Entities/)
```csharp
public class Permiso : BaseEntity
{
    public string Codigo { get; set; } // ej: "inventario.read"
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public string Modulo { get; set; } // ej: "Inventario", "Tickets"

    // Relaciones
    public ICollection<RolPermiso> RolPermisos { get; set; }
}
```

**RefreshToken.cs** (Domain/Entities/)
```csharp
public class RefreshToken : BaseEntity
{
    public string Token { get; set; }
    public DateTime Expiracion { get; set; }
    public bool Revocado { get; set; }
    public DateTime? FechaRevocacion { get; set; }
    public string DispositivoInfo { get; set; }

    // Relaciones
    public int UsuarioId { get; set; }
    public Usuario Usuario { get; set; }
}
```

**BaseEntity.cs** (Domain/Common/)
```csharp
public abstract class BaseEntity
{
    public int Id { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public string CreadoPor { get; set; }
    public string ModificadoPor { get; set; }
    public bool Eliminado { get; set; } // Soft delete
}
```

**Departamento.cs** (Domain/Entities/)
```csharp
public class Departamento : BaseEntity
{
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public string Codigo { get; set; }

    // Relaciones
    public ICollection<Usuario> Usuarios { get; set; }
}
```

#### 2.2 DbContext

**ApplicationDbContext.cs** (Infrastructure/Data/)
```csharp
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Rol> Roles { get; set; }
    public DbSet<Permiso> Permisos { get; set; }
    public DbSet<UsuarioRol> UsuarioRoles { get; set; }
    public DbSet<RolPermiso> RolPermisos { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }
    public DbSet<Departamento> Departamentos { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Aplicar configuraciones
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

        // Seed data inicial
        modelBuilder.SeedInitialData();
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Actualizar campos de auditoría
        var entries = ChangeTracker.Entries<BaseEntity>();

        foreach (var entry in entries)
        {
            if (entry.State == EntityState.Added)
            {
                entry.Entity.FechaCreacion = DateTime.UtcNow;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.FechaModificacion = DateTime.UtcNow;
            }
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
```

#### 2.3 Configuraciones Fluent API

**UsuarioConfiguration.cs** (Infrastructure/Data/Configurations/)
```csharp
public class UsuarioConfiguration : IEntityTypeConfiguration<Usuario>
{
    public void Configure(EntityTypeBuilder<Usuario> builder)
    {
        builder.ToTable("Usuarios");

        builder.HasKey(u => u.Id);

        builder.Property(u => u.Nombre)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(150);

        builder.HasIndex(u => u.Email)
            .IsUnique();

        builder.Property(u => u.PasswordHash)
            .IsRequired();

        builder.HasQueryFilter(u => !u.Eliminado); // Soft delete global
    }
}
```

#### 2.4 Seed Data Inicial

```csharp
public static class DataSeeder
{
    public static void SeedInitialData(this ModelBuilder modelBuilder)
    {
        // Roles del sistema
        modelBuilder.Entity<Rol>().HasData(
            new Rol { Id = 1, Nombre = "Super Admin", EsSistema = true, FechaCreacion = DateTime.UtcNow },
            new Rol { Id = 2, Nombre = "Administrador TI", EsSistema = true, FechaCreacion = DateTime.UtcNow },
            new Rol { Id = 3, Nombre = "Técnico", EsSistema = true, FechaCreacion = DateTime.UtcNow },
            new Rol { Id = 4, Nombre = "Usuario Final", EsSistema = true, FechaCreacion = DateTime.UtcNow }
        );

        // Permisos base
        var permisos = new List<Permiso>
        {
            new Permiso { Id = 1, Codigo = "inventario.read", Nombre = "Ver Inventario", Modulo = "Inventario" },
            new Permiso { Id = 2, Codigo = "inventario.write", Nombre = "Crear/Editar Inventario", Modulo = "Inventario" },
            new Permiso { Id = 3, Codigo = "inventario.delete", Nombre = "Eliminar Inventario", Modulo = "Inventario" },
            new Permiso { Id = 4, Codigo = "tickets.read", Nombre = "Ver Tickets", Modulo = "Tickets" },
            new Permiso { Id = 5, Codigo = "tickets.write", Nombre = "Crear/Editar Tickets", Modulo = "Tickets" },
            new Permiso { Id = 6, Codigo = "tickets.assign", Nombre = "Asignar Tickets", Modulo = "Tickets" },
            new Permiso { Id = 7, Codigo = "usuarios.read", Nombre = "Ver Usuarios", Modulo = "Usuarios" },
            new Permiso { Id = 8, Codigo = "usuarios.write", Nombre = "Crear/Editar Usuarios", Modulo = "Usuarios" },
            new Permiso { Id = 9, Codigo = "reportes.generate", Nombre = "Generar Reportes", Modulo = "Reportes" },
        };

        modelBuilder.Entity<Permiso>().HasData(permisos);

        // Usuario admin por defecto
        var adminPasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!");
        modelBuilder.Entity<Usuario>().HasData(
            new Usuario
            {
                Id = 1,
                Nombre = "Administrador",
                Apellido = "Sistema",
                Email = "admin@empresa.com",
                PasswordHash = adminPasswordHash,
                Activo = true,
                FechaCreacion = DateTime.UtcNow
            }
        );

        // Asignar admin a rol Super Admin
        modelBuilder.Entity<UsuarioRol>().HasData(
            new UsuarioRol { UsuarioId = 1, RolId = 1 }
        );
    }
}
```

#### 2.5 Migraciones

```bash
# En Tickets.API
dotnet ef migrations add InitialCreate --project ../Tickets.Infrastructure
dotnet ef database update --project ../Tickets.Infrastructure
```

---

### 3. Implementación de Autenticación JWT

#### 3.1 JwtService

**IJwtService.cs** (Application/Services/Interfaces/)
```csharp
public interface IJwtService
{
    string GenerateToken(Usuario usuario, List<string> roles, List<string> permisos);
    RefreshToken GenerateRefreshToken(int usuarioId);
    ClaimsPrincipal ValidateToken(string token);
}
```

**JwtService.cs** (Infrastructure/Services/)
```csharp
public class JwtService : IJwtService
{
    private readonly JwtSettings _jwtSettings;

    public JwtService(IOptions<JwtSettings> jwtSettings)
    {
        _jwtSettings = jwtSettings.Value;
    }

    public string GenerateToken(Usuario usuario, List<string> roles, List<string> permisos)
    {
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
            new Claim(ClaimTypes.Email, usuario.Email),
            new Claim(ClaimTypes.Name, $"{usuario.Nombre} {usuario.Apellido}"),
        };

        // Agregar roles
        foreach (var role in roles)
        {
            claims.Add(new Claim(ClaimTypes.Role, role));
        }

        // Agregar permisos
        foreach (var permiso in permisos)
        {
            claims.Add(new Claim("Permission", permiso));
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.SecretKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _jwtSettings.Issuer,
            audience: _jwtSettings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_jwtSettings.ExpirationMinutes),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public RefreshToken GenerateRefreshToken(int usuarioId)
    {
        return new RefreshToken
        {
            Token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)),
            Expiracion = DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays),
            UsuarioId = usuarioId,
            FechaCreacion = DateTime.UtcNow
        };
    }
}
```

#### 3.2 AuthService

**IAuthService.cs** (Application/Services/Interfaces/)
```csharp
public interface IAuthService
{
    Task<AuthResponse> LoginAsync(LoginRequest request);
    Task<AuthResponse> RefreshTokenAsync(string refreshToken);
    Task LogoutAsync(int usuarioId);
    Task<UsuarioDto> GetProfileAsync(int usuarioId);
}
```

**AuthService.cs** (Application/Services/Implementation/)
```csharp
public class AuthService : IAuthService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IJwtService _jwtService;
    private readonly IMapper _mapper;

    public AuthService(
        IUnitOfWork unitOfWork,
        IJwtService jwtService,
        IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _jwtService = jwtService;
        _mapper = mapper;
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        // Buscar usuario
        var usuario = await _unitOfWork.Repository<Usuario>()
            .FirstOrDefaultAsync(u => u.Email == request.Email);

        if (usuario == null || !BCrypt.Net.BCrypt.Verify(request.Password, usuario.PasswordHash))
        {
            throw new UnauthorizedException("Credenciales inválidas");
        }

        if (!usuario.Activo)
        {
            throw new UnauthorizedException("Usuario inactivo");
        }

        // Obtener roles y permisos
        var roles = await _unitOfWork.Repository<UsuarioRol>()
            .Include(ur => ur.Rol)
            .Where(ur => ur.UsuarioId == usuario.Id)
            .Select(ur => ur.Rol.Nombre)
            .ToListAsync();

        var permisos = await _unitOfWork.Repository<RolPermiso>()
            .Include(rp => rp.Permiso)
            .Where(rp => roles.Contains(rp.Rol.Nombre))
            .Select(rp => rp.Permiso.Codigo)
            .Distinct()
            .ToListAsync();

        // Generar tokens
        var accessToken = _jwtService.GenerateToken(usuario, roles, permisos);
        var refreshToken = _jwtService.GenerateRefreshToken(usuario.Id);

        // Guardar refresh token
        _unitOfWork.Repository<RefreshToken>().Add(refreshToken);

        // Actualizar último acceso
        usuario.UltimoAcceso = DateTime.UtcNow;

        await _unitOfWork.SaveChangesAsync();

        return new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken.Token,
            Usuario = _mapper.Map<UsuarioDto>(usuario),
            Roles = roles,
            Permisos = permisos
        };
    }
}
```

#### 3.3 AuthController

**AuthController.cs** (API/Controllers/)
```csharp
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    public async Task<ActionResult<ApiResponse<AuthResponse>>> Login([FromBody] LoginRequest request)
    {
        var result = await _authService.LoginAsync(request);
        return Ok(ApiResponse<AuthResponse>.Success(result, "Login exitoso"));
    }

    [HttpPost("refresh")]
    public async Task<ActionResult<ApiResponse<AuthResponse>>> RefreshToken([FromBody] RefreshTokenRequest request)
    {
        var result = await _authService.RefreshTokenAsync(request.RefreshToken);
        return Ok(ApiResponse<AuthResponse>.Success(result));
    }

    [HttpPost("logout")]
    [Authorize]
    public async Task<ActionResult<ApiResponse<bool>>> Logout()
    {
        var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier).Value);
        await _authService.LogoutAsync(usuarioId);
        return Ok(ApiResponse<bool>.Success(true, "Logout exitoso"));
    }

    [HttpGet("profile")]
    [Authorize]
    public async Task<ActionResult<ApiResponse<UsuarioDto>>> GetProfile()
    {
        var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier).Value);
        var result = await _authService.GetProfileAsync(usuarioId);
        return Ok(ApiResponse<UsuarioDto>.Success(result));
    }
}
```

---

### 4. Setup del Proyecto Frontend (Flutter)

#### 4.1 Crear Proyecto Flutter

```bash
flutter create frontend
cd frontend
```

#### 4.2 Configurar pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  # get: ^4.6.6  # Alternativa a BLoC

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

dev_dependencies:
  flutter_test:
    sdk: flutter

  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  flutter_lints: ^3.0.1
```

```bash
flutter pub get
```

#### 4.3 Estructura de Carpetas

```bash
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   ├── theme/
│   ├── constants/
│   ├── utils/
│   └── errors/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── bloc/
└── services/
```

#### 4.4 Configuración del Tema

**app_theme.dart** (lib/core/theme/)
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
  );
}
```

#### 4.5 API Client con Dio

**api_client.dart** (lib/data/datasources/remote/)
```dart
class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Agregar token
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Manejar refresh token
        if (error.response?.statusCode == 401) {
          // Intentar refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            return handler.resolve(await _retry(error.requestOptions));
          }
        }
        return handler.next(error);
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  // ... otros métodos
}
```

#### 4.6 Auth BLoC

**auth_bloc.dart** (lib/presentation/bloc/auth/)
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final StorageService _storageService;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required StorageService storageService,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _storageService = storageService,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final authResponse = await _loginUseCase(
        email: event.email,
        password: event.password,
      );

      await _storageService.saveToken(authResponse.accessToken);
      await _storageService.saveRefreshToken(authResponse.refreshToken);
      await _storageService.saveUser(authResponse.usuario);

      emit(Authenticated(usuario: authResponse.usuario));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
    await _storageService.clearAll();
    emit(Unauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _storageService.getToken();
    final user = await _storageService.getUser();

    if (token != null && user != null) {
      emit(Authenticated(usuario: user));
    } else {
      emit(Unauthenticated());
    }
  }
}
```

#### 4.7 Login Screen

**login_screen.dart** (lib/presentation/screens/auth/)
```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Icon(
                          Icons.support_agent,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Sistema de Tickets',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Inventarios y Soporte TI',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          LoginRequested(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: state is AuthLoading
                              ? const CircularProgressIndicator()
                              : const Text('Iniciar Sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

## ✅ Entregables de la Fase 1

- [ ] Backend .NET Core configurado con Clean Architecture
- [ ] Base de datos SQL Server creada con tablas de autenticación
- [ ] Sistema de autenticación JWT funcional
- [ ] Sistema de roles y permisos implementado
- [ ] Frontend Flutter configurado con BLoC
- [ ] Pantalla de login funcional y responsiva
- [ ] API client con interceptors configurado
- [ ] Documentación de API (Swagger)
- [ ] Usuario admin inicial creado
- [ ] Pruebas unitarias básicas

---

## 🧪 Pruebas de Fase 1

### Pruebas Backend
1. Login con credenciales correctas
2. Login con credenciales incorrectas
3. Generación y validación de JWT
4. Refresh token funcional
5. Middleware de autorización
6. Soft delete en entidades

### Pruebas Frontend
1. Login UI responsivo (móvil/tablet/web)
2. Validaciones de formulario
3. Manejo de errores de API
4. Almacenamiento seguro de tokens
5. Navegación post-login
6. Logout y limpieza de sesión

---

## 🔧 Configuración Adicional

### CORS (Program.cs)
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

// ...

app.UseCors("AllowAll");
```

### Swagger con JWT
```csharp
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Tickets API", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header usando Bearer scheme",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});
```

---

## 📌 Notas Importantes

1. **Seguridad**: Cambiar la clave secreta JWT en producción
2. **Passwords**: Nunca almacenar en texto plano, siempre hasheados
3. **Tokens**: Implementar blacklist para tokens revocados (opcional)
4. **HTTPS**: Obligatorio en producción
5. **Logging**: Configurar Serilog para producción
6. **Rate Limiting**: Considerar implementar en endpoints de login

---

**Siguiente Fase:** [FASE 2: Inventarios](FASE-2.md)
