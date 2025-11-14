using System;
using Tickets.Domain.Common;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un archivo adjunto en un ticket
    /// </summary>
    public class AdjuntoTicket : BaseEntity
    {
        /// <summary>
        /// Nombre original del archivo
        /// </summary>
        public string NombreArchivo { get; set; } = string.Empty;

        /// <summary>
        /// Nombre del archivo en el servidor (único)
        /// </summary>
        public string NombreArchivoServidor { get; set; } = string.Empty;

        /// <summary>
        /// Ruta completa del archivo en el servidor
        /// </summary>
        public string RutaArchivo { get; set; } = string.Empty;

        /// <summary>
        /// Tipo MIME del archivo (image/png, application/pdf, etc.)
        /// </summary>
        public string TipoMime { get; set; } = string.Empty;

        /// <summary>
        /// Tamaño del archivo en bytes
        /// </summary>
        public long TamanoBytes { get; set; }

        /// <summary>
        /// Extensión del archivo (.pdf, .png, etc.)
        /// </summary>
        public string Extension { get; set; } = string.Empty;

        // Relaciones
        /// <summary>
        /// Ticket al que pertenece el adjunto
        /// </summary>
        public int TicketId { get; set; }
        public virtual Ticket Ticket { get; set; } = null!;

        /// <summary>
        /// Usuario que subió el archivo
        /// </summary>
        public int UsuarioId { get; set; }
        public virtual Usuario Usuario { get; set; } = null!;

        /// <summary>
        /// Obtener tamaño formateado (KB, MB)
        /// </summary>
        public string TamanoFormateado
        {
            get
            {
                if (TamanoBytes < 1024)
                    return $"{TamanoBytes} B";
                else if (TamanoBytes < 1024 * 1024)
                    return $"{TamanoBytes / 1024.0:F2} KB";
                else
                    return $"{TamanoBytes / (1024.0 * 1024.0):F2} MB";
            }
        }

        /// <summary>
        /// Verificar si es una imagen
        /// </summary>
        public bool EsImagen => TipoMime.StartsWith("image/");

        /// <summary>
        /// Verificar si es un PDF
        /// </summary>
        public bool EsPdf => TipoMime == "application/pdf";
    }
}
