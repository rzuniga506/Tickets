using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Auth
{
    /// <summary>
    /// DTO para solicitud de renovación de token
    /// </summary>
    public class RefreshTokenRequest
    {
        /// <summary>
        /// Token de refresco
        /// </summary>
        [Required(ErrorMessage = "El refresh token es requerido")]
        public string RefreshToken { get; set; } = string.Empty;
    }
}
