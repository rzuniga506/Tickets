using System;
using Tickets.Domain.Common;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un token de refresco (Refresh Token) para JWT
    /// </summary>
    public class RefreshToken : BaseEntity
    {
        /// <summary>
        /// Token único de refresco
        /// </summary>
        public string Token { get; set; } = string.Empty;

        /// <summary>
        /// Fecha y hora de expiración del token
        /// </summary>
        public DateTime Expiracion { get; set; }

        /// <summary>
        /// Indica si el token ha sido revocado
        /// </summary>
        public bool Revocado { get; set; }

        /// <summary>
        /// Fecha y hora de revocación del token
        /// </summary>
        public DateTime? FechaRevocacion { get; set; }

        /// <summary>
        /// Información del dispositivo que generó el token
        /// </summary>
        public string? DispositivoInfo { get; set; }

        /// <summary>
        /// Dirección IP del cliente
        /// </summary>
        public string? DireccionIP { get; set; }

        /// <summary>
        /// Usuario dueño del token
        /// </summary>
        public int UsuarioId { get; set; }
        public virtual Usuario Usuario { get; set; } = null!;

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public RefreshToken()
        {
            Revocado = false;
        }

        /// <summary>
        /// Verifica si el token está activo y válido
        /// </summary>
        public bool EsActivo => !Revocado && Expiracion > DateTime.UtcNow;
    }
}
