namespace Tickets.Application.DTOs.Rol;

/// <summary>
/// DTO para Rol
/// </summary>
public class RolDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public bool EsSistema { get; set; }
    public List<int> PermisosIds { get; set; } = new();
    public int CantidadUsuarios { get; set; }
    public DateTime FechaCreacion { get; set; }
}

/// <summary>
/// DTO para crear Rol
/// </summary>
public class CreateRolDto
{
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public List<int> PermisosIds { get; set; } = new();
}

/// <summary>
/// DTO para actualizar Rol
/// </summary>
public class UpdateRolDto
{
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public List<int> PermisosIds { get; set; } = new();
}
