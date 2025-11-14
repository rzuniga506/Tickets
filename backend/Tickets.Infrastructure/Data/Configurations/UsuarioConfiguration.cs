using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    /// <summary>
    /// Configuración de Entity Framework para la entidad Usuario
    /// </summary>
    public class UsuarioConfiguration : IEntityTypeConfiguration<Usuario>
    {
        public void Configure(EntityTypeBuilder<Usuario> builder)
        {
            builder.ToTable("Usuarios");

            builder.HasKey(u => u.Id);

            builder.Property(u => u.Nombre)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(u => u.Apellido)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(u => u.Email)
                .IsRequired()
                .HasMaxLength(150);

            builder.HasIndex(u => u.Email)
                .IsUnique()
                .HasDatabaseName("IX_Usuarios_Email");

            builder.Property(u => u.PasswordHash)
                .IsRequired()
                .HasMaxLength(500);

            builder.Property(u => u.Telefono)
                .HasMaxLength(20);

            builder.Property(u => u.FotoPerfilUrl)
                .HasMaxLength(500);

            builder.Property(u => u.Activo)
                .IsRequired()
                .HasDefaultValue(true);

            // Relaciones
            builder.HasOne(u => u.Departamento)
                .WithMany(d => d.Usuarios)
                .HasForeignKey(u => u.DepartamentoId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasMany(u => u.UsuarioRoles)
                .WithOne(ur => ur.Usuario)
                .HasForeignKey(ur => ur.UsuarioId);

            builder.HasMany(u => u.RefreshTokens)
                .WithOne(rt => rt.Usuario)
                .HasForeignKey(rt => rt.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(u => u.Dispositivos)
                .WithOne(d => d.Usuario)
                .HasForeignKey(d => d.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(u => u.Notificaciones)
                .WithOne(n => n.Usuario)
                .HasForeignKey(n => n.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(u => u.TicketsCreados)
                .WithOne(t => t.Solicitante)
                .HasForeignKey(t => t.SolicitanteId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasMany(u => u.TicketsAsignados)
                .WithOne(t => t.TecnicoAsignado)
                .HasForeignKey(t => t.TecnicoAsignadoId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasMany(u => u.EquiposAsignados)
                .WithOne(e => e.UsuarioAsignado)
                .HasForeignKey(e => e.UsuarioAsignadoId)
                .OnDelete(DeleteBehavior.SetNull);

            // Índices adicionales
            builder.HasIndex(u => u.Activo)
                .HasDatabaseName("IX_Usuarios_Activo");

            builder.HasIndex(u => u.DepartamentoId)
                .HasDatabaseName("IX_Usuarios_Departamento");

            // Auditoría
            builder.Property(u => u.FechaCreacion)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(u => u.CreadoPor)
                .HasMaxLength(150);

            builder.Property(u => u.ModificadoPor)
                .HasMaxLength(150);

            builder.Property(u => u.Eliminado)
                .IsRequired()
                .HasDefaultValue(false);
        }
    }
}
