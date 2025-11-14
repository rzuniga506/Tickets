using System.Collections.Generic;
using Tickets.Application.DTOs.Usuarios;

namespace Tickets.Application.DTOs.Auth
{
    /// <summary>
    /// DTO de respuesta de autenticación
    /// </summary>
    public class AuthResponse
    {
        /// <summary>
        /// Token de acceso JWT
        /// </summary>
        public string AccessToken { get; set; } = string.Empty;

        /// <summary>
        /// Token de refresco
        /// </summary>
        public string RefreshToken { get; set; } = string.Empty;

        /// <summary>
        /// Fecha de expiración del access token
        /// </summary>
        public DateTime ExpiresAt { get; set; }

        /// <summary>
        /// Información del usuario
        /// </summary>
        public UsuarioDto Usuario { get; set; } = null!;

        /// <summary>
        /// Roles del usuario
        /// </summary>
        public List<string> Roles { get; set; } = new();

        /// <summary>
        /// Permisos del usuario
        /// </summary>
        public List<string> Permisos { get; set; } = new();
    }
}
