using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Auth
{
    /// <summary>
    /// DTO para solicitud de inicio de sesión
    /// </summary>
    public class LoginRequest
    {
        /// <summary>
        /// Correo electrónico del usuario
        /// </summary>
        [Required(ErrorMessage = "El email es requerido")]
        [EmailAddress(ErrorMessage = "El formato del email no es válido")]
        public string Email { get; set; } = string.Empty;

        /// <summary>
        /// Contraseña del usuario
        /// </summary>
        [Required(ErrorMessage = "La contraseña es requerida")]
        [MinLength(6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres")]
        public string Password { get; set; } = string.Empty;

        /// <summary>
        /// Información del dispositivo (opcional)
        /// </summary>
        public string? DispositivoInfo { get; set; }
    }
}
