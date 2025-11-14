namespace Tickets.Application.DTOs.Common
{
    /// <summary>
    /// Configuración de JWT desde appsettings
    /// </summary>
    public class JwtSettings
    {
        /// <summary>
        /// Clave secreta para firmar los tokens
        /// </summary>
        public string SecretKey { get; set; } = string.Empty;

        /// <summary>
        /// Emisor del token
        /// </summary>
        public string Issuer { get; set; } = string.Empty;

        /// <summary>
        /// Audiencia del token
        /// </summary>
        public string Audience { get; set; } = string.Empty;

        /// <summary>
        /// Tiempo de expiración del access token en minutos
        /// </summary>
        public int ExpirationMinutes { get; set; } = 60;

        /// <summary>
        /// Tiempo de expiración del refresh token en días
        /// </summary>
        public int RefreshTokenExpirationDays { get; set; } = 7;
    }
}
