using System.ComponentModel.DataAnnotations;
using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.Notificaciones
{
    /// <summary>
    /// DTO para crear una nueva notificación
    /// </summary>
    public class NotificacionCreateDto
    {
        [Required(ErrorMessage = "El título es requerido")]
        [MaxLength(200, ErrorMessage = "El título no puede exceder 200 caracteres")]
        public string Titulo { get; set; } = string.Empty;

        [Required(ErrorMessage = "El mensaje es requerido")]
        [MaxLength(1000, ErrorMessage = "El mensaje no puede exceder 1000 caracteres")]
        public string Mensaje { get; set; } = string.Empty;

        [Required(ErrorMessage = "El tipo es requerido")]
        public TipoNotificacion Tipo { get; set; }

        public PrioridadNotificacion Prioridad { get; set; } = PrioridadNotificacion.Normal;

        [Required(ErrorMessage = "El ID de usuario es requerido")]
        public int UsuarioId { get; set; }

        public string? EntidadTipo { get; set; }
        public int? EntidadId { get; set; }
        public string? Accion { get; set; }
        public string? DatosJson { get; set; }
        public string? UrlAccion { get; set; }
        public string? IconoUrl { get; set; }
        public bool EnviarPush { get; set; } = true;
        public bool EnviarEmail { get; set; } = false;
        public bool MostrarInApp { get; set; } = true;
    }
}
