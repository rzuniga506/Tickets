using System.Collections.Generic;
using Tickets.Application.DTOs.Permisos;

namespace Tickets.Application.DTOs.Roles
{
    /// <summary>
    /// DTO para respuesta de rol
    /// </summary>
    public class RolDto
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public bool EsSistema { get; set; }
        public int CantidadUsuarios { get; set; }
        public List<PermisoDto> Permisos { get; set; } = new();
    }
}
