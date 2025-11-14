using System;
using System.Collections.Generic;

namespace Tickets.Application.DTOs.Usuarios
{
    /// <summary>
    /// DTO de usuario para respuestas
    /// </summary>
    public class UsuarioDto
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string NombreCompleto { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? Telefono { get; set; }
        public bool Activo { get; set; }
        public DateTime? UltimoAcceso { get; set; }
        public string? FotoPerfilUrl { get; set; }
        public int? DepartamentoId { get; set; }
        public string? DepartamentoNombre { get; set; }
        public List<string> Roles { get; set; } = new();
        public DateTime FechaCreacion { get; set; }
    }

    /// <summary>
    /// DTO para crear usuario
    /// </summary>
    public class UsuarioCreateDto
    {
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? Telefono { get; set; }
        public int? DepartamentoId { get; set; }
        public List<int> RolesIds { get; set; } = new();
    }

    /// <summary>
    /// DTO para actualizar usuario
    /// </summary>
    public class UsuarioUpdateDto
    {
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string? Telefono { get; set; }
        public int? DepartamentoId { get; set; }
        public bool Activo { get; set; }
        public List<int> RolesIds { get; set; } = new();
    }
}
