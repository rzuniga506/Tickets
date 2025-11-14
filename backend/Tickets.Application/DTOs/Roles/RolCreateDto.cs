using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Roles
{
    /// <summary>
    /// DTO para crear un nuevo rol
    /// </summary>
    public class RolCreateDto
    {
        [Required(ErrorMessage = "El nombre es requerido")]
        [MaxLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
        public string Nombre { get; set; } = string.Empty;

        [MaxLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
        public string? Descripcion { get; set; }

        public List<int> PermisosIds { get; set; } = new();
    }
}
