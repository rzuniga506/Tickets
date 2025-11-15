using Tickets.Domain.Common;

namespace Tickets.Domain.Entities;

/// <summary>
/// Representa una categoría de tickets del sistema
/// </summary>
public class CategoriaTicket : BaseEntity
{
    /// <summary>
    /// Nombre de la categoría
    /// </summary>
    public string Nombre { get; set; } = string.Empty;

    /// <summary>
    /// Descripción detallada de la categoría
    /// </summary>
    public string? Descripcion { get; set; }

    /// <summary>
    /// Color hexadecimal para representación visual (ej: #FF5733)
    /// </summary>
    public string Color { get; set; } = "#6B7280";

    /// <summary>
    /// Identificador del ícono (para usar en frontend)
    /// </summary>
    public string? Icono { get; set; }

    /// <summary>
    /// Orden de visualización
    /// </summary>
    public int Orden { get; set; } = 0;

    /// <summary>
    /// Indica si la categoría está activa
    /// </summary>
    public bool Activo { get; set; } = true;

    // Navegación
    /// <summary>
    /// Tickets asociados a esta categoría
    /// </summary>
    public virtual ICollection<Ticket> Tickets { get; set; }

    public CategoriaTicket()
    {
        Tickets = new HashSet<Ticket>();
    }
}
