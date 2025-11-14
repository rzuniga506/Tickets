using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    public class DepartamentoConfiguration : IEntityTypeConfiguration<Departamento>
    {
        public void Configure(EntityTypeBuilder<Departamento> builder)
        {
            builder.ToTable("Departamentos");

            builder.HasKey(d => d.Id);

            builder.Property(d => d.Nombre)
                .IsRequired()
                .HasMaxLength(150);

            builder.Property(d => d.Descripcion)
                .HasMaxLength(500);

            builder.Property(d => d.Codigo)
                .HasMaxLength(20);

            builder.HasIndex(d => d.Codigo)
                .IsUnique()
                .HasDatabaseName("IX_Departamentos_Codigo")
                .HasFilter("[Codigo] IS NOT NULL");

            builder.Property(d => d.Activo)
                .IsRequired()
                .HasDefaultValue(true);

            builder.HasMany(d => d.Usuarios)
                .WithOne(u => u.Departamento)
                .HasForeignKey(u => u.DepartamentoId);

            builder.HasMany(d => d.Equipos)
                .WithOne(e => e.DepartamentoAsignado)
                .HasForeignKey(e => e.DepartamentoAsignadoId);
        }
    }
}
