namespace Tickets.Application.DTOs.Permisos
{
    /// <summary>
    /// DTO para respuesta de permiso
    /// </summary>
    public class PermisoDto
    {
        public int Id { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string Modulo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
    }
}
