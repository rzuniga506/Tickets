using System;
using Tickets.Domain.Common;
using Tickets.Domain.Enums;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un dispositivo registrado para notificaciones push
    /// </summary>
    public class DispositivoUsuario : BaseEntity
    {
        /// <summary>
        /// Token de FCM/APNS para notificaciones push
        /// </summary>
        public string TokenPush { get; set; } = string.Empty;

        /// <summary>
        /// Plataforma del dispositivo
        /// </summary>
        public PlataformaDispositivo Plataforma { get; set; }

        /// <summary>
        /// Nombre descriptivo del dispositivo
        /// </summary>
        public string? NombreDispositivo { get; set; }

        /// <summary>
        /// Versión de la aplicación instalada
        /// </summary>
        public string? VersionApp { get; set; }

        /// <summary>
        /// Indica si el dispositivo está activo para recibir notificaciones
        /// </summary>
        public bool Activo { get; set; }

        /// <summary>
        /// Fecha y hora del último acceso desde este dispositivo
        /// </summary>
        public DateTime UltimoAcceso { get; set; }

        /// <summary>
        /// Usuario dueño del dispositivo
        /// </summary>
        public int UsuarioId { get; set; }
        public virtual Usuario Usuario { get; set; } = null!;

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public DispositivoUsuario()
        {
            Activo = true;
            UltimoAcceso = DateTime.UtcNow;
        }
    }
}
