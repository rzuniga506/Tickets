using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    public class RolConfiguration : IEntityTypeConfiguration<Rol>
    {
        public void Configure(EntityTypeBuilder<Rol> builder)
        {
            builder.ToTable("Roles");

            builder.HasKey(r => r.Id);

            builder.Property(r => r.Nombre)
                .IsRequired()
                .HasMaxLength(100);

            builder.HasIndex(r => r.Nombre)
                .IsUnique()
                .HasDatabaseName("IX_Roles_Nombre");

            builder.Property(r => r.Descripcion)
                .HasMaxLength(500);

            builder.Property(r => r.EsSistema)
                .IsRequired()
                .HasDefaultValue(false);

            builder.HasMany(r => r.UsuarioRoles)
                .WithOne(ur => ur.Rol)
                .HasForeignKey(ur => ur.RolId);

            builder.HasMany(r => r.RolPermisos)
                .WithOne(rp => rp.Rol)
                .HasForeignKey(rp => rp.RolId);
        }
    }
}
