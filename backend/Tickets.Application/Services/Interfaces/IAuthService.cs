using System.Threading.Tasks;
using Tickets.Application.DTOs.Auth;
using Tickets.Application.DTOs.Usuarios;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de autenticación
    /// </summary>
    public interface IAuthService
    {
        /// <summary>
        /// Inicia sesión con credenciales de usuario
        /// </summary>
        Task<AuthResponse> LoginAsync(LoginRequest request, string? ipAddress = null);

        /// <summary>
        /// Renueva el access token usando un refresh token
        /// </summary>
        Task<AuthResponse> RefreshTokenAsync(string refreshToken, string? ipAddress = null);

        /// <summary>
        /// Cierra la sesión del usuario
        /// </summary>
        Task LogoutAsync(int usuarioId, string? refreshToken = null);

        /// <summary>
        /// Obtiene el perfil del usuario autenticado
        /// </summary>
        Task<UsuarioDto> GetProfileAsync(int usuarioId);

        /// <summary>
        /// Cambia la contraseña del usuario
        /// </summary>
        Task ChangePasswordAsync(int usuarioId, ChangePasswordRequest request);

        /// <summary>
        /// Verifica si un email ya está registrado
        /// </summary>
        Task<bool> EmailExistsAsync(string email);
    }
}
