using System.ComponentModel.DataAnnotations;

namespace Tickets.Application.DTOs.Tickets
{
    /// <summary>
    /// DTO para asignar un técnico a un ticket
    /// </summary>
    public class TicketAsignarDto
    {
        [Required(ErrorMessage = "El ID del técnico es requerido")]
        public int TecnicoId { get; set; }

        [MaxLength(1000, ErrorMessage = "Las observaciones no pueden exceder 1000 caracteres")]
        public string? Observaciones { get; set; }
    }
}
