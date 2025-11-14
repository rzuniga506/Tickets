using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Tickets
{
    /// <summary>
    /// DTO para evaluar un ticket resuelto
    /// </summary>
    public class TicketEvaluarDto
    {
        [Required(ErrorMessage = "La calificación es requerida")]
        [Range(1, 5, ErrorMessage = "La calificación debe estar entre 1 y 5")]
        public int CalificacionServicio { get; set; }

        [MaxLength(2000, ErrorMessage = "El comentario no puede exceder 2000 caracteres")]
        public string? ComentarioEvaluacion { get; set; }
    }
}
