using System;
using Tickets.Domain.Common;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un comentario en un ticket
    /// </summary>
    public class ComentarioTicket : BaseEntity
    {
        /// <summary>
        /// Contenido del comentario
        /// </summary>
        public string Contenido { get; set; } = string.Empty;

        /// <summary>
        /// Indica si es un comentario interno (solo visible para técnicos)
        /// </summary>
        public bool EsInterno { get; set; }

        /// <summary>
        /// Indica si es un comentario del sistema (generado automáticamente)
        /// </summary>
        public bool EsSistema { get; set; }

        // Relaciones
        /// <summary>
        /// Ticket al que pertenece el comentario
        /// </summary>
        public int TicketId { get; set; }
        public virtual Ticket Ticket { get; set; } = null!;

        /// <summary>
        /// Usuario que escribió el comentario
        /// </summary>
        public int UsuarioId { get; set; }
        public virtual Usuario Usuario { get; set; } = null!;

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public ComentarioTicket()
        {
            EsInterno = false;
            EsSistema = false;
        }
    }
}
