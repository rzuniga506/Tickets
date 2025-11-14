using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    public class PermisoConfiguration : IEntityTypeConfiguration<Permiso>
    {
        public void Configure(EntityTypeBuilder<Permiso> builder)
        {
            builder.ToTable("Permisos");

            builder.HasKey(p => p.Id);

            builder.Property(p => p.Codigo)
                .IsRequired()
                .HasMaxLength(100);

            builder.HasIndex(p => p.Codigo)
                .IsUnique()
                .HasDatabaseName("IX_Permisos_Codigo");

            builder.Property(p => p.Nombre)
                .IsRequired()
                .HasMaxLength(150);

            builder.Property(p => p.Descripcion)
                .HasMaxLength(500);

            builder.Property(p => p.Modulo)
                .IsRequired()
                .HasMaxLength(50);

            builder.HasIndex(p => p.Modulo)
                .HasDatabaseName("IX_Permisos_Modulo");

            builder.HasMany(p => p.RolPermisos)
                .WithOne(rp => rp.Permiso)
                .HasForeignKey(rp => rp.PermisoId);
        }
    }
}
