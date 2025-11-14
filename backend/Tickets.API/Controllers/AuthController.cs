using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Application.DTOs.Auth;
using Tickets.Application.DTOs.Usuarios;
using Tickets.Application.Services.Interfaces;

namespace Tickets.API.Controllers
{
    /// <summary>
    /// Controlador de autenticación
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        /// <summary>
        /// Inicia sesión con credenciales de usuario
        /// </summary>
        /// <param name="request">Datos de login</param>
        /// <returns>Tokens de acceso y refresh</returns>
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<ActionResult<ApiResponse<AuthResponse>>> Login([FromBody] LoginRequest request)
        {
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
            var result = await _authService.LoginAsync(request, ipAddress);

            return Ok(ApiResponse<AuthResponse>.SuccessResponse(result, "Inicio de sesión exitoso"));
        }

        /// <summary>
        /// Renueva el access token usando un refresh token
        /// </summary>
        /// <param name="request">Refresh token</param>
        /// <returns>Nuevos tokens de acceso y refresh</returns>
        [HttpPost("refresh")]
        [AllowAnonymous]
        public async Task<ActionResult<ApiResponse<AuthResponse>>> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
            var result = await _authService.RefreshTokenAsync(request.RefreshToken, ipAddress);

            return Ok(ApiResponse<AuthResponse>.SuccessResponse(result, "Token renovado exitosamente"));
        }

        /// <summary>
        /// Cierra la sesión del usuario
        /// </summary>
        /// <param name="refreshToken">Token de refresco a revocar (opcional)</param>
        /// <returns>Confirmación de logout</returns>
        [HttpPost("logout")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<object>>> Logout([FromBody] string? refreshToken = null)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            await _authService.LogoutAsync(usuarioId, refreshToken);

            return Ok(ApiResponse<object>.SuccessResponse(null, "Sesión cerrada exitosamente"));
        }

        /// <summary>
        /// Obtiene el perfil del usuario autenticado
        /// </summary>
        /// <returns>Datos del usuario</returns>
        [HttpGet("profile")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<UsuarioDto>>> GetProfile()
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var result = await _authService.GetProfileAsync(usuarioId);

            return Ok(ApiResponse<UsuarioDto>.SuccessResponse(result));
        }

        /// <summary>
        /// Cambia la contraseña del usuario autenticado
        /// </summary>
        /// <param name="request">Datos para cambio de contraseña</param>
        /// <returns>Confirmación de cambio</returns>
        [HttpPost("change-password")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<object>>> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var usuarioId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            await _authService.ChangePasswordAsync(usuarioId, request);

            return Ok(ApiResponse<object>.SuccessResponse(null, "Contraseña cambiada exitosamente"));
        }

        /// <summary>
        /// Verifica si un email ya está registrado
        /// </summary>
        /// <param name="email">Email a verificar</param>
        /// <returns>True si existe, false si no</returns>
        [HttpGet("email-exists")]
        [AllowAnonymous]
        public async Task<ActionResult<ApiResponse<bool>>> EmailExists([FromQuery] string email)
        {
            var exists = await _authService.EmailExistsAsync(email);
            return Ok(ApiResponse<bool>.SuccessResponse(exists));
        }
    }
}
