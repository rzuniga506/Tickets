using System;
using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.Notificaciones
{
    /// <summary>
    /// DTO para respuesta de notificación
    /// </summary>
    public class NotificacionDto
    {
        public int Id { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
        public TipoNotificacion Tipo { get; set; }
        public string TipoNombre { get; set; } = string.Empty;
        public PrioridadNotificacion Prioridad { get; set; }
        public string PrioridadNombre { get; set; } = string.Empty;
        public bool Leida { get; set; }
        public DateTime? FechaLeida { get; set; }
        public bool Enviada { get; set; }
        public DateTime? FechaEnvio { get; set; }
        public string? EntidadTipo { get; set; }
        public int? EntidadId { get; set; }
        public string? Accion { get; set; }
        public string? DatosJson { get; set; }
        public string? UrlAccion { get; set; }
        public string? IconoUrl { get; set; }
        public bool EnviarPush { get; set; }
        public bool EnviarEmail { get; set; }
        public bool MostrarInApp { get; set; }
        public int UsuarioId { get; set; }
        public DateTime FechaCreacion { get; set; }
    }
}
