using System;
using Tickets.Domain.Common;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa una mención de usuario en un comentario
    /// </summary>
    public class MencionComentario : BaseEntity
    {
        /// <summary>
        /// Comentario donde se hizo la mención
        /// </summary>
        public int ComentarioTicketId { get; set; }
        public virtual ComentarioTicket ComentarioTicket { get; set; } = null!;

        /// <summary>
        /// Usuario mencionado
        /// </summary>
        public int UsuarioMencionadoId { get; set; }
        public virtual Usuario UsuarioMencionado { get; set; } = null!;

        /// <summary>
        /// Indica si el usuario ha leído la mención
        /// </summary>
        public bool Leida { get; set; }

        /// <summary>
        /// Fecha en que se leyó la mención
        /// </summary>
        public DateTime? FechaLeida { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public MencionComentario()
        {
            Leida = false;
        }
    }
}
