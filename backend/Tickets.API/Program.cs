using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Serilog;
using Serilog.Events;
using System;
using System.IO;
using System.Text;
using Tickets.API.Middleware;
using Tickets.Application.DTOs.Common;
using Tickets.Application.Mappings;
using Tickets.Application.Services.Implementation;
using Tickets.Application.Services.Interfaces;
using Tickets.Infrastructure.Data;
using Tickets.Infrastructure.Repositories.Implementation;
using Tickets.Infrastructure.Repositories.Interfaces;
using Tickets.Infrastructure.Services;

// Configurar Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.Hosting.Lifetime", LogEventLevel.Information)
    .MinimumLevel.Override("System", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "Tickets TI")
    .WriteTo.Console(
        outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj}{NewLine}{Exception}")
    .WriteTo.File(
        path: Path.Combine("logs", "tickets-.log"),
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30,
        outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}")
    .CreateLogger();

try
{
    Log.Information("Iniciando aplicación Tickets TI");

var builder = WebApplication.CreateBuilder(args);

// Configurar Serilog como el provider de logging
builder.Host.UseSerilog();

// ============================================================
// CONFIGURACIÓN DE SERVICIOS
// ============================================================

// Configuración de Base de Datos
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        b => b.MigrationsAssembly("Tickets.Infrastructure")));

// Configuración de JWT
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey no está configurada");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false; // En producción, cambiar a true
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        ClockSkew = TimeSpan.Zero // Eliminar delay de expiración
    };
});

builder.Services.AddAuthorization();

// Configuración de CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });

    options.AddPolicy("Production", policy =>
    {
        policy.WithOrigins(
                builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? Array.Empty<string>())
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

// AutoMapper
builder.Services.AddAutoMapper(typeof(AutoMapperProfile));

// Configuración de JwtSettings para DI
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));

// Repositorios
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));

// Servicios de Infraestructura
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddSingleton<IFileStorageService, FileStorageService>();

// Servicios de Aplicación
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<IDepartamentoService, DepartamentoService>();
builder.Services.AddScoped<IRolService, RolService>();
builder.Services.AddScoped<IPermisoService, PermisoService>();
builder.Services.AddScoped<IEquipoService, EquipoService>();
builder.Services.AddScoped<ITicketService, TicketService>();
builder.Services.AddScoped<IComentarioTicketService, ComentarioTicketService>();
builder.Services.AddScoped<IAdjuntoTicketService, AdjuntoTicketService>();
builder.Services.AddScoped<ICategoriaTicketService, CategoriaTicketService>();
builder.Services.AddScoped<IHistorialEstadoTicketService, HistorialEstadoTicketService>();
builder.Services.AddScoped<IAsignacionTicketService, AsignacionTicketService>();
builder.Services.AddScoped<INotificacionService, NotificacionService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();

// Controllers
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
    });

// Configuración de Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Tickets API",
        Version = "v1",
        Description = "API para gestión de tickets de soporte e inventario de TI",
        Contact = new OpenApiContact
        {
            Name = "Departamento de TI",
            Email = "soporte@empresa.com"
        }
    });

    // Configuración de seguridad JWT en Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header usando el esquema Bearer. Ejemplo: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
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
            Array.Empty<string>()
        }
    });
});

// Health Checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ApplicationDbContext>();

// ============================================================
// CONSTRUCCIÓN DE LA APLICACIÓN
// ============================================================

var app = builder.Build();

// ============================================================
// CONFIGURACIÓN DEL PIPELINE HTTP
// ============================================================

// Middleware de manejo de excepciones
app.UseExceptionMiddleware();

// Swagger en desarrollo
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Tickets API v1");
        c.RoutePrefix = string.Empty; // Swagger en la raíz
    });
}

// HTTPS Redirection
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

// CORS
var corsPolicy = app.Environment.IsDevelopment() ? "AllowAll" : "Production";
app.UseCors(corsPolicy);

// Configuración de Archivos Estáticos (uploads)
var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "uploads");
if (!Directory.Exists(uploadsPath))
{
    Directory.CreateDirectory(uploadsPath);
}

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadsPath),
    RequestPath = "/uploads",
    OnPrepareResponse = ctx =>
    {
        // Agregar headers de cache para archivos estáticos
        ctx.Context.Response.Headers.Append("Cache-Control", "public,max-age=3600");
    }
});

// Autenticación y Autorización
app.UseAuthentication();
app.UseAuthorization();

// Mapear controladores
app.MapControllers();

// Health Checks
app.MapHealthChecks("/health");

// ============================================================
// INICIALIZACIÓN DE LA BASE DE DATOS
// ============================================================

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<ApplicationDbContext>();

        // Aplicar migraciones pendientes
        if (context.Database.GetPendingMigrations().Any())
        {
            context.Database.Migrate();
        }

        // Mensaje de inicio
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogInformation("Aplicación iniciada correctamente");
        logger.LogInformation("Base de datos: {ConnectionString}",
            builder.Configuration.GetConnectionString("DefaultConnection")?.Split(";")[0]);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Error al inicializar la base de datos");
    }
}

// ============================================================
// EJECUTAR LA APLICACIÓN
// ============================================================

Log.Information("Aplicación Tickets TI iniciada exitosamente");
app.Run();
Log.Information("Aplicación Tickets TI detenida");
}
catch (Exception ex)
{
    Log.Fatal(ex, "La aplicación falló al iniciar");
}
finally
{
    Log.CloseAndFlush();
}
