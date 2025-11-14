using System;
using Tickets.Domain.Common;
using Tickets.Domain.Enums;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa una notificación para un usuario
    /// </summary>
    public class Notificacion : BaseEntity
    {
        /// <summary>
        /// Título de la notificación
        /// </summary>
        public string Titulo { get; set; } = string.Empty;

        /// <summary>
        /// Mensaje de la notificación
        /// </summary>
        public string Mensaje { get; set; } = string.Empty;

        /// <summary>
        /// Tipo de notificación
        /// </summary>
        public TipoNotificacion Tipo { get; set; }

        /// <summary>
        /// Prioridad de la notificación
        /// </summary>
        public PrioridadNotificacion Prioridad { get; set; }

        /// <summary>
        /// Indica si la notificación ha sido leída
        /// </summary>
        public bool Leida { get; set; }

        /// <summary>
        /// Fecha y hora en que se leyó la notificación
        /// </summary>
        public DateTime? FechaLeida { get; set; }

        /// <summary>
        /// Indica si la notificación fue enviada
        /// </summary>
        public bool Enviada { get; set; }

        /// <summary>
        /// Fecha y hora de envío
        /// </summary>
        public DateTime? FechaEnvio { get; set; }

        /// <summary>
        /// Tipo de entidad relacionada (ej: "Ticket", "Equipo")
        /// </summary>
        public string? EntidadTipo { get; set; }

        /// <summary>
        /// ID de la entidad relacionada
        /// </summary>
        public int? EntidadId { get; set; }

        /// <summary>
        /// Acción que generó la notificación
        /// </summary>
        public string? Accion { get; set; }

        /// <summary>
        /// Datos adicionales en formato JSON
        /// </summary>
        public string? DatosJson { get; set; }

        /// <summary>
        /// URL de acción al hacer clic en la notificación
        /// </summary>
        public string? UrlAccion { get; set; }

        /// <summary>
        /// URL del ícono de la notificación
        /// </summary>
        public string? IconoUrl { get; set; }

        /// <summary>
        /// Indica si se debe enviar notificación push
        /// </summary>
        public bool EnviarPush { get; set; }

        /// <summary>
        /// Indica si se debe enviar por email
        /// </summary>
        public bool EnviarEmail { get; set; }

        /// <summary>
        /// Indica si se muestra en la app
        /// </summary>
        public bool MostrarInApp { get; set; }

        /// <summary>
        /// Usuario destinatario de la notificación
        /// </summary>
        public int UsuarioId { get; set; }
        public virtual Usuario Usuario { get; set; } = null!;

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public Notificacion()
        {
            Leida = false;
            Enviada = false;
            EnviarPush = true;
            EnviarEmail = false;
            MostrarInApp = true;
            Prioridad = PrioridadNotificacion.Normal;
        }
    }
}
