namespace Tickets.Application.DTOs.Departamentos
{
    /// <summary>
    /// DTO para respuesta de departamento
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
    }
}
