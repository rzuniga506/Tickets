using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    public class EquipoConfiguration : IEntityTypeConfiguration<Equipo>
    {
        public void Configure(EntityTypeBuilder<Equipo> builder)
        {
            builder.ToTable("Equipos");

            builder.HasKey(e => e.Id);

            builder.Property(e => e.CodigoInterno)
                .IsRequired()
                .HasMaxLength(50);

            builder.HasIndex(e => e.CodigoInterno)
                .IsUnique()
                .HasDatabaseName("IX_Equipos_CodigoInterno");

            builder.Property(e => e.NumeroSerie)
                .HasMaxLength(100);

            builder.Property(e => e.Nombre)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(e => e.Descripcion)
                .HasMaxLength(1000);

            builder.Property(e => e.CodigoQR)
                .HasMaxLength(100);

            builder.HasIndex(e => e.CodigoQR)
                .IsUnique()
                .HasDatabaseName("IX_Equipos_CodigoQR")
                .HasFilter("[CodigoQR] IS NOT NULL");

            builder.Property(e => e.Modelo)
                .HasMaxLength(150);

            builder.Property(e => e.Estado)
                .IsRequired();

            builder.Property(e => e.Condicion)
                .IsRequired();

            builder.Property(e => e.CostoAdquisicion)
                .HasColumnType("decimal(18,2)");

            builder.Property(e => e.ValorResidual)
                .HasColumnType("decimal(18,2)");

            builder.Property(e => e.VidaUtilMeses)
                .IsRequired()
                .HasDefaultValue(36);

            builder.Property(e => e.Observaciones)
                .HasMaxLength(2000);

            // Relaciones
            builder.HasOne(e => e.UsuarioAsignado)
                .WithMany(u => u.EquiposAsignados)
                .HasForeignKey(e => e.UsuarioAsignadoId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasOne(e => e.DepartamentoAsignado)
                .WithMany(d => d.Equipos)
                .HasForeignKey(e => e.DepartamentoAsignadoId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasMany(e => e.Tickets)
                .WithOne(t => t.Equipo)
                .HasForeignKey(t => t.EquipoId)
                .OnDelete(DeleteBehavior.SetNull);

            // Índices para búsquedas comunes
            builder.HasIndex(e => new { e.Estado })
                .HasDatabaseName("IX_Equipos_Estado");

            builder.HasIndex(e => e.UsuarioAsignadoId)
                .HasDatabaseName("IX_Equipos_UsuarioAsignado")
                .HasFilter("[UsuarioAsignadoId] IS NOT NULL");

            builder.HasIndex(e => e.FechaFinGarantia)
                .HasDatabaseName("IX_Equipos_FechaFinGarantia")
                .HasFilter("[FechaFinGarantia] IS NOT NULL");
        }
    }
}
