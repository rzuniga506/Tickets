using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    public class NotificacionConfiguration : IEntityTypeConfiguration<Notificacion>
    {
        public void Configure(EntityTypeBuilder<Notificacion> builder)
        {
            builder.ToTable("Notificaciones");

            builder.HasKey(n => n.Id);

            builder.Property(n => n.Titulo)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(n => n.Mensaje)
                .IsRequired()
                .HasMaxLength(1000);

            builder.Property(n => n.Tipo)
                .IsRequired();

            builder.Property(n => n.Prioridad)
                .IsRequired()
                .HasDefaultValue(Domain.Enums.PrioridadNotificacion.Normal);

            builder.Property(n => n.Leida)
                .IsRequired()
                .HasDefaultValue(false);

            builder.Property(n => n.Enviada)
                .IsRequired()
                .HasDefaultValue(false);

            builder.Property(n => n.EntidadTipo)
                .HasMaxLength(50);

            builder.Property(n => n.Accion)
                .HasMaxLength(50);

            builder.Property(n => n.UrlAccion)
                .HasMaxLength(500);

            builder.Property(n => n.IconoUrl)
                .HasMaxLength(500);

            builder.Property(n => n.EnviarPush)
                .IsRequired()
                .HasDefaultValue(true);

            builder.Property(n => n.EnviarEmail)
                .IsRequired()
                .HasDefaultValue(false);

            builder.Property(n => n.MostrarInApp)
                .IsRequired()
                .HasDefaultValue(true);

            builder.HasOne(n => n.Usuario)
                .WithMany(u => u.Notificaciones)
                .HasForeignKey(n => n.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);

            // Índices para búsquedas eficientes
            builder.HasIndex(n => new { n.UsuarioId, n.Leida })
                .HasDatabaseName("IX_Notificaciones_Usuario_Leida")
                .IncludeProperties(n => new { n.Titulo, n.FechaCreacion });

            builder.HasIndex(n => n.FechaCreacion)
                .IsDescending()
                .HasDatabaseName("IX_Notificaciones_FechaCreacion");
        }
    }
}
