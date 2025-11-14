using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Reflection;
using Tickets.Domain.Entities;
using Tickets.Domain.Common;

namespace Tickets.Infrastructure.Data
{
    /// <summary>
    /// Contexto de base de datos principal de la aplicación
    /// </summary>
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // DbSets - Entidades del sistema
        public DbSet<Usuario> Usuarios { get; set; } = null!;
        public DbSet<Rol> Roles { get; set; } = null!;
        public DbSet<Permiso> Permisos { get; set; } = null!;
        public DbSet<UsuarioRol> UsuarioRoles { get; set; } = null!;
        public DbSet<RolPermiso> RolPermisos { get; set; } = null!;
        public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;
        public DbSet<Departamento> Departamentos { get; set; } = null!;
        public DbSet<DispositivoUsuario> DispositivosUsuario { get; set; } = null!;
        public DbSet<Notificacion> Notificaciones { get; set; } = null!;
        public DbSet<Equipo> Equipos { get; set; } = null!;
        public DbSet<Ticket> Tickets { get; set; } = null!;
        public DbSet<ComentarioTicket> ComentariosTicket { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Aplicar todas las configuraciones del assembly
            modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

            // Configurar filtros globales para soft delete
            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                if (typeof(BaseEntity).IsAssignableFrom(entityType.ClrType))
                {
                    var method = typeof(ApplicationDbContext)
                        .GetMethod(nameof(SetSoftDeleteFilter),
                            BindingFlags.NonPublic | BindingFlags.Static)?
                        .MakeGenericMethod(entityType.ClrType);

                    method?.Invoke(null, new object[] { modelBuilder });
                }
            }

            // Aplicar seed data
            SeedData(modelBuilder);
        }

        /// <summary>
        /// Configura filtro global de soft delete para una entidad
        /// </summary>
        private static void SetSoftDeleteFilter<TEntity>(ModelBuilder modelBuilder)
            where TEntity : BaseEntity
        {
            modelBuilder.Entity<TEntity>().HasQueryFilter(e => !e.Eliminado);
        }

        /// <summary>
        /// Override de SaveChanges para manejar auditoría automática
        /// </summary>
        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            // Actualizar campos de auditoría
            var entries = ChangeTracker.Entries<BaseEntity>();

            foreach (var entry in entries)
            {
                switch (entry.State)
                {
                    case EntityState.Added:
                        entry.Entity.FechaCreacion = DateTime.UtcNow;
                        // El CreadoPor se debe establecer en el servicio/controlador
                        break;

                    case EntityState.Modified:
                        entry.Entity.FechaModificacion = DateTime.UtcNow;
                        // El ModificadoPor se debe establecer en el servicio/controlador
                        break;

                    case EntityState.Deleted:
                        // Implementar soft delete
                        entry.State = EntityState.Modified;
                        entry.Entity.Eliminado = true;
                        entry.Entity.FechaModificacion = DateTime.UtcNow;
                        break;
                }
            }

            return await base.SaveChangesAsync(cancellationToken);
        }

        /// <summary>
        /// Datos iniciales del sistema
        /// </summary>
        private void SeedData(ModelBuilder modelBuilder)
        {
            // Seed Roles
            modelBuilder.Entity<Rol>().HasData(
                new Rol
                {
                    Id = 1,
                    Nombre = "Super Admin",
                    Descripcion = "Administrador del sistema con acceso total",
                    EsSistema = true,
                    FechaCreacion = DateTime.UtcNow
                },
                new Rol
                {
                    Id = 2,
                    Nombre = "Administrador TI",
                    Descripcion = "Administrador del departamento de TI",
                    EsSistema = true,
                    FechaCreacion = DateTime.UtcNow
                },
                new Rol
                {
                    Id = 3,
                    Nombre = "Técnico",
                    Descripcion = "Técnico de soporte",
                    EsSistema = true,
                    FechaCreacion = DateTime.UtcNow
                },
                new Rol
                {
                    Id = 4,
                    Nombre = "Usuario Final",
                    Descripcion = "Usuario estándar del sistema",
                    EsSistema = true,
                    FechaCreacion = DateTime.UtcNow
                }
            );

            // Seed Permisos
            var permisos = new[]
            {
                // Inventario
                new Permiso { Id = 1, Codigo = "inventario.read", Nombre = "Ver Inventario", Modulo = "Inventario", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 2, Codigo = "inventario.write", Nombre = "Crear/Editar Inventario", Modulo = "Inventario", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 3, Codigo = "inventario.delete", Nombre = "Eliminar Inventario", Modulo = "Inventario", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 4, Codigo = "inventario.assign", Nombre = "Asignar Equipos", Modulo = "Inventario", FechaCreacion = DateTime.UtcNow },

                // Tickets
                new Permiso { Id = 5, Codigo = "tickets.read", Nombre = "Ver Tickets", Modulo = "Tickets", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 6, Codigo = "tickets.write", Nombre = "Crear/Editar Tickets", Modulo = "Tickets", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 7, Codigo = "tickets.delete", Nombre = "Eliminar Tickets", Modulo = "Tickets", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 8, Codigo = "tickets.assign", Nombre = "Asignar Tickets", Modulo = "Tickets", FechaCreacion = DateTime.UtcNow },

                // Usuarios
                new Permiso { Id = 9, Codigo = "usuarios.read", Nombre = "Ver Usuarios", Modulo = "Usuarios", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 10, Codigo = "usuarios.write", Nombre = "Crear/Editar Usuarios", Modulo = "Usuarios", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 11, Codigo = "usuarios.delete", Nombre = "Eliminar Usuarios", Modulo = "Usuarios", FechaCreacion = DateTime.UtcNow },

                // Reportes
                new Permiso { Id = 12, Codigo = "reportes.generate", Nombre = "Generar Reportes", Modulo = "Reportes", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 13, Codigo = "reportes.export", Nombre = "Exportar Reportes", Modulo = "Reportes", FechaCreacion = DateTime.UtcNow },

                // Configuración
                new Permiso { Id = 14, Codigo = "config.read", Nombre = "Ver Configuración", Modulo = "Configuracion", FechaCreacion = DateTime.UtcNow },
                new Permiso { Id = 15, Codigo = "config.write", Nombre = "Modificar Configuración", Modulo = "Configuracion", FechaCreacion = DateTime.UtcNow },
            };

            modelBuilder.Entity<Permiso>().HasData(permisos);

            // Seed RolPermisos - Super Admin tiene todos los permisos
            var rolPermisos = new List<RolPermiso>();
            for (int i = 1; i <= 15; i++)
            {
                rolPermisos.Add(new RolPermiso { RolId = 1, PermisoId = i });
            }

            // Admin TI - Permisos de inventario, tickets y usuarios (lectura)
            rolPermisos.AddRange(new[]
            {
                new RolPermiso { RolId = 2, PermisoId = 1 }, // inventario.read
                new RolPermiso { RolId = 2, PermisoId = 2 }, // inventario.write
                new RolPermiso { RolId = 2, PermisoId = 4 }, // inventario.assign
                new RolPermiso { RolId = 2, PermisoId = 5 }, // tickets.read
                new RolPermiso { RolId = 2, PermisoId = 6 }, // tickets.write
                new RolPermiso { RolId = 2, PermisoId = 8 }, // tickets.assign
                new RolPermiso { RolId = 2, PermisoId = 9 }, // usuarios.read
                new RolPermiso { RolId = 2, PermisoId = 12 }, // reportes.generate
            });

            // Técnico - Permisos básicos de tickets e inventario
            rolPermisos.AddRange(new[]
            {
                new RolPermiso { RolId = 3, PermisoId = 1 }, // inventario.read
                new RolPermiso { RolId = 3, PermisoId = 5 }, // tickets.read
                new RolPermiso { RolId = 3, PermisoId = 6 }, // tickets.write
            });

            // Usuario Final - Solo lectura básica y crear tickets
            rolPermisos.AddRange(new[]
            {
                new RolPermiso { RolId = 4, PermisoId = 1 }, // inventario.read
                new RolPermiso { RolId = 4, PermisoId = 5 }, // tickets.read
                new RolPermiso { RolId = 4, PermisoId = 6 }, // tickets.write (solo sus propios tickets)
            });

            modelBuilder.Entity<RolPermiso>().HasData(rolPermisos);

            // Seed Usuario Administrador
            // Password: Admin123!
            var adminPasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!");

            modelBuilder.Entity<Usuario>().HasData(
                new Usuario
                {
                    Id = 1,
                    Nombre = "Administrador",
                    Apellido = "Sistema",
                    Email = "admin@tickets.com",
                    PasswordHash = adminPasswordHash,
                    Activo = true,
                    FechaCreacion = DateTime.UtcNow
                }
            );

            // Asignar rol Super Admin al usuario administrador
            modelBuilder.Entity<UsuarioRol>().HasData(
                new UsuarioRol { UsuarioId = 1, RolId = 1 }
            );
        }
    }
}
