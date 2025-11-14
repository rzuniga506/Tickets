using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Data.Configurations
{
    public class TicketConfiguration : IEntityTypeConfiguration<Ticket>
    {
        public void Configure(EntityTypeBuilder<Ticket> builder)
        {
            builder.ToTable("Tickets");

            builder.HasKey(t => t.Id);

            builder.Property(t => t.NumeroTicket)
                .IsRequired()
                .HasMaxLength(50);

            builder.HasIndex(t => t.NumeroTicket)
                .IsUnique()
                .HasDatabaseName("IX_Tickets_NumeroTicket");

            builder.Property(t => t.Asunto)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(t => t.Descripcion)
                .IsRequired();

            builder.Property(t => t.Prioridad)
                .IsRequired();

            builder.Property(t => t.Estado)
                .IsRequired();

            builder.Property(t => t.FechaApertura)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            builder.Property(t => t.SLACumplido)
                .IsRequired()
                .HasDefaultValue(false);

            builder.Property(t => t.FueReabierto)
                .IsRequired()
                .HasDefaultValue(false);

            builder.Property(t => t.CantidadReaberturas)
                .IsRequired()
                .HasDefaultValue(0);

            builder.Property(t => t.ComentarioEvaluacion)
                .HasMaxLength(1000);

            // Relaciones
            builder.HasOne(t => t.Solicitante)
                .WithMany(u => u.TicketsCreados)
                .HasForeignKey(t => t.SolicitanteId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(t => t.TecnicoAsignado)
                .WithMany(u => u.TicketsAsignados)
                .HasForeignKey(t => t.TecnicoAsignadoId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasOne(t => t.Equipo)
                .WithMany(e => e.Tickets)
                .HasForeignKey(t => t.EquipoId)
                .OnDelete(DeleteBehavior.SetNull);

            // Índices para búsquedas y reportes eficientes
            builder.HasIndex(t => new { t.Estado, t.FechaApertura })
                .IsDescending(false, true)
                .HasDatabaseName("IX_Tickets_Estado_FechaApertura")
                .IncludeProperties(t => new { t.NumeroTicket, t.Asunto, t.Prioridad });

            builder.HasIndex(t => new { t.TecnicoAsignadoId, t.Estado })
                .HasDatabaseName("IX_Tickets_TecnicoAsignado_Estado")
                .HasFilter("[TecnicoAsignadoId] IS NOT NULL");

            builder.HasIndex(t => t.SolicitanteId)
                .HasDatabaseName("IX_Tickets_Solicitante");

            builder.HasIndex(t => t.FechaLimiteSLA)
                .HasDatabaseName("IX_Tickets_FechaLimiteSLA")
                .HasFilter("[FechaLimiteSLA] IS NOT NULL AND [Estado] NOT IN (4, 5)");

            builder.HasIndex(t => t.FechaApertura)
                .IsDescending()
                .HasDatabaseName("IX_Tickets_FechaApertura");
        }
    }
}
