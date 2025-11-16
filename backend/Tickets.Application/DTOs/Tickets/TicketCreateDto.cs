using System.ComponentModel.DataAnnotations;
using Tickets.Domain.Enums;

namespace Tickets.Application.DTOs.Tickets
{
    /// <summary>
    /// DTO para crear un nuevo ticket
    /// </summary>
    public class TicketCreateDto
    {
        [Required(ErrorMessage = "El asunto es requerido")]
        [MaxLength(500, ErrorMessage = "El asunto no puede exceder 500 caracteres")]
        public string Asunto { get; set; } = string.Empty;

        [Required(ErrorMessage = "La descripción es requerida")]
        [MaxLength(5000, ErrorMessage = "La descripción no puede exceder 5000 caracteres")]
        public string Descripcion { get; set; } = string.Empty;

        [Required(ErrorMessage = "La prioridad es requerida")]
        public PrioridadTicket Prioridad { get; set; }

        [Required(ErrorMessage = "El tipo de soporte es requerido")]
        public TipoSoporte TipoSoporte { get; set; }

        public int? EquipoId { get; set; }

        public int? CategoriaTicketId { get; set; }
    }
}
