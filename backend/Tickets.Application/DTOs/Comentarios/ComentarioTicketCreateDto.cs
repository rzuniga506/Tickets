using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Comentarios
{
    /// <summary>
    /// DTO para crear un nuevo comentario en un ticket
    /// </summary>
    public class ComentarioTicketCreateDto
    {
        [Required(ErrorMessage = "El contenido del comentario es requerido")]
        [MaxLength(5000, ErrorMessage = "El comentario no puede exceder 5000 caracteres")]
        public string Contenido { get; set; } = string.Empty;

        public bool EsInterno { get; set; } = false;

        [Required(ErrorMessage = "El ID del ticket es requerido")]
        public int TicketId { get; set; }

        /// <summary>
        /// IDs de usuarios mencionados con @
        /// </summary>
        public List<int> UsuariosIdMencionados { get; set; } = new List<int>();
    }
}
