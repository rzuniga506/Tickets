using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Auth
{
    /// <summary>
    /// DTO para cambio de contraseña
    /// </summary>
    public class ChangePasswordRequest
    {
        /// <summary>
        /// Contraseña actual
        /// </summary>
        [Required(ErrorMessage = "La contraseña actual es requerida")]
        public string CurrentPassword { get; set; } = string.Empty;

        /// <summary>
        /// Nueva contraseña
        /// </summary>
        [Required(ErrorMessage = "La nueva contraseña es requerida")]
        [MinLength(8, ErrorMessage = "La contraseña debe tener al menos 8 caracteres")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]",
            ErrorMessage = "La contraseña debe contener al menos una mayúscula, una minúscula, un número y un carácter especial")]
        public string NewPassword { get; set; } = string.Empty;

        /// <summary>
        /// Confirmación de nueva contraseña
        /// </summary>
        [Required(ErrorMessage = "La confirmación de contraseña es requerida")]
        [Compare(nameof(NewPassword), ErrorMessage = "Las contraseñas no coinciden")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }
}
