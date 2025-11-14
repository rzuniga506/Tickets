using System;

namespace Tickets.Application.DTOs.Adjuntos
{
    /// <summary>
    /// DTO para respuesta de adjunto de ticket
    /// </summary>
    public class AdjuntoTicketDto
    {
        public int Id { get; set; }
        public string NombreArchivo { get; set; } = string.Empty;
        public string NombreArchivoServidor { get; set; } = string.Empty;
        public string RutaArchivo { get; set; } = string.Empty;
        public string TipoMime { get; set; } = string.Empty;
        public long TamanoBytes { get; set; }
        public string TamanoFormateado { get; set; } = string.Empty;
        public string Extension { get; set; } = string.Empty;
        public bool EsImagen { get; set; }
        public bool EsPdf { get; set; }

        // Relaciones
        public int TicketId { get; set; }
        public string NumeroTicket { get; set; } = string.Empty;
        public int UsuarioId { get; set; }
        public string UsuarioNombre { get; set; } = string.Empty;
        public string UsuarioEmail { get; set; } = string.Empty;

        // Auditoría
        public DateTime FechaCreacion { get; set; }
    }
}
