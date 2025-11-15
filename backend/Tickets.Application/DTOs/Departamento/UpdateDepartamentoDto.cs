using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Departamento;

/// <summary>
/// DTO para actualizar un Departamento
/// </summary>
public class UpdateDepartamentoDto
{
    [Required(ErrorMessage = "El nombre es requerido")]
    [StringLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
    public string Nombre { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
    public string? Descripcion { get; set; }

    [StringLength(20, ErrorMessage = "El código no puede exceder 20 caracteres")]
    public string? Codigo { get; set; }

    public bool Activo { get; set; }
}
