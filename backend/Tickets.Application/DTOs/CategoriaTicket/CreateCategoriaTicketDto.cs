using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.CategoriaTicket;

/// <summary>
/// DTO para crear una nueva Categoría de Ticket
/// </summary>
public class CreateCategoriaTicketDto
{
    [Required(ErrorMessage = "El nombre es requerido")]
    [StringLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
    public string Nombre { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
    public string? Descripcion { get; set; }

    [Required(ErrorMessage = "El color es requerido")]
    [RegularExpression("^#([A-Fa-f0-9]{6})$", ErrorMessage = "El color debe ser un código hexadecimal válido (ej: #FF5733)")]
    public string Color { get; set; } = "#6B7280";

    [StringLength(50, ErrorMessage = "El ícono no puede exceder 50 caracteres")]
    public string? Icono { get; set; }

    [Range(0, int.MaxValue, ErrorMessage = "El orden debe ser mayor o igual a 0")]
    public int Orden { get; set; } = 0;

    public bool Activo { get; set; } = true;
}
