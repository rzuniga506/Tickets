using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
    {
        public void Configure(EntityTypeBuilder<RefreshToken> builder)
        {
            builder.ToTable("RefreshTokens");

            builder.HasKey(rt => rt.Id);

            builder.Property(rt => rt.Token)
                .IsRequired()
                .HasMaxLength(500);

            builder.HasIndex(rt => rt.Token)
                .IsUnique()
                .HasDatabaseName("IX_RefreshTokens_Token");

            builder.Property(rt => rt.Expiracion)
                .IsRequired();

            builder.Property(rt => rt.Revocado)
                .IsRequired()
                .HasDefaultValue(false);

            builder.Property(rt => rt.DispositivoInfo)
                .HasMaxLength(500);

            builder.Property(rt => rt.DireccionIP)
                .HasMaxLength(50);

            builder.HasOne(rt => rt.Usuario)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(rt => rt.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(rt => new { rt.UsuarioId, rt.Expiracion })
                .HasDatabaseName("IX_RefreshTokens_Usuario_Expiracion");
        }
    }
}
