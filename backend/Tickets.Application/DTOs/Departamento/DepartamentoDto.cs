namespace Tickets.Application.DTOs.Departamento;

/// <summary>
/// DTO para Departamento
/// </summary>
public class DepartamentoDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string? Codigo { get; set; }
    public bool Activo { get; set; }
    public int CantidadUsuarios { get; set; }
    public int CantidadEquipos { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
}
