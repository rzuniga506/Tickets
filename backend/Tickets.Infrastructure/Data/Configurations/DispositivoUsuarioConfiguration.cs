using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    public class DispositivoUsuarioConfiguration : IEntityTypeConfiguration<DispositivoUsuario>
    {
        public void Configure(EntityTypeBuilder<DispositivoUsuario> builder)
        {
            builder.ToTable("DispositivosUsuario");

            builder.HasKey(d => d.Id);

            builder.Property(d => d.TokenPush)
                .IsRequired()
                .HasMaxLength(500);

            builder.HasIndex(d => d.TokenPush)
                .IsUnique()
                .HasDatabaseName("IX_DispositivosUsuario_TokenPush");

            builder.Property(d => d.Plataforma)
                .IsRequired();

            builder.Property(d => d.NombreDispositivo)
                .HasMaxLength(200);

            builder.Property(d => d.VersionApp)
                .HasMaxLength(50);

            builder.Property(d => d.Activo)
                .IsRequired()
                .HasDefaultValue(true);

            builder.Property(d => d.UltimoAcceso)
                .IsRequired();

            builder.HasOne(d => d.Usuario)
                .WithMany(u => u.Dispositivos)
                .HasForeignKey(d => d.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(d => new { d.UsuarioId, d.Activo })
                .HasDatabaseName("IX_DispositivosUsuario_Usuario_Activo");
        }
    }
}
