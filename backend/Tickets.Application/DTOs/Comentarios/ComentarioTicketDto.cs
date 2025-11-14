using System;

namespace Tickets.Application.DTOs.Comentarios
{
    /// <summary>
    /// DTO para respuesta de comentario de ticket
    /// </summary>
    public class ComentarioTicketDto
    {
        public int Id { get; set; }
        public string Contenido { get; set; } = string.Empty;
        public bool EsInterno { get; set; }
        public bool EsSistema { get; set; }

        // Relaciones
        public int TicketId { get; set; }
        public string NumeroTicket { get; set; } = string.Empty;
        public int UsuarioId { get; set; }
        public string UsuarioNombre { get; set; } = string.Empty;
        public string UsuarioEmail { get; set; } = string.Empty;

        // Auditoría
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }
}
