using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Comentarios
{
    /// <summary>
    /// DTO para actualizar un comentario de ticket
    /// </summary>
    public class ComentarioTicketUpdateDto
    {
        [Required(ErrorMessage = "El contenido del comentario es requerido")]
        [MaxLength(5000, ErrorMessage = "El comentario no puede exceder 5000 caracteres")]
        public string Contenido { get; set; } = string.Empty;

        public bool EsInterno { get; set; }
    }
}
