using System.ComponentModel.DataAnnotations;
using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.Tickets
{
    /// <summary>
    /// DTO para resolver un ticket
    /// </summary>
    public class TicketResolverDto
    {
        [Required(ErrorMessage = "La solución es requerida")]
        [MaxLength(5000, ErrorMessage = "La solución no puede exceder 5000 caracteres")]
        public string Solucion { get; set; } = string.Empty;

        [Required(ErrorMessage = "El tipo de solución es requerido")]
        public TipoSolucion TipoSolucion { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Los minutos invertidos deben ser mayores a 0")]
        public int? MinutosInvertidos { get; set; }
    }
}
